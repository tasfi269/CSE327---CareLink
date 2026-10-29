import json
from django.shortcuts import render, redirect
from django.db.models import Count
from django.contrib import messages as django_messages
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .gemini_service import generate_ai_response
from .models import ChatMessage, ChatSession

class AIChatView(APIView):
    parser_classes = (MultiPartParser, FormParser, JSONParser)

    def post(self, request, *args, **kwargs):
        query_text = request.data.get('query', '').strip()
        image_file = request.FILES.get('file', None)
        user_id = request.data.get('user_id', 'tayasshuk').strip()
        session_id = request.data.get('session_id', None)

        if not query_text and not image_file:
            return Response(
                {'error': 'Either query text or a prescription file is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get or create an active chat session for this user
        session = None
        if session_id:
            try:
                session = ChatSession.objects.filter(id=session_id, user_id=user_id).first()
            except Exception:
                session = None

        if not session:
            title = (query_text[:40] + ('...' if len(query_text) > 40 else '')) if query_text else 'Prescription Analysis'
            session = ChatSession.objects.create(user_id=user_id, title=title)
        else:
            session.save(update_fields=['updated_at'])

        # 1. Record patient message in DB under user_id
        user_msg = ChatMessage.objects.create(
            session=session,
            user_id=user_id,
            role='user',
            text=query_text or 'Prescription upload',
            attachment=image_file,
        )

        # 2. Call AI generation service (Gemini 3.1 Flash)
        ai_result = generate_ai_response(
            query_text=query_text,
            image_file=image_file,
        )

        # 3. Record assistant reply in DB under same user_id & session
        bot_msg = ChatMessage.objects.create(
            session=session,
            user_id=user_id,
            role='model',
            text=ai_result.get('reply', ''),
            medicines=ai_result.get('medicines'),
            doctor_recommendation=ai_result.get('doctor_recommendation'),
        )

        response_payload = {
            **ai_result,
            'message_id': str(bot_msg.id),
            'session_id': str(session.id),
            'session_title': session.title,
            'user_id': user_id,
        }
        return Response(response_payload, status=status.HTTP_200_OK)


class ChatHistoryView(APIView):
    """Fetch or clear chat history for a particular user, optionally filtered by session_id"""

    def get(self, request, *args, **kwargs):
        user_id = request.query_params.get('user_id', 'tayasshuk').strip()
        session_id = request.query_params.get('session_id', None)

        messages_qs = ChatMessage.objects.filter(user_id=user_id)
        session_title = None

        if session_id:
            try:
                messages_qs = messages_qs.filter(session_id=session_id)
                session = ChatSession.objects.filter(id=session_id, user_id=user_id).first()
                if session:
                    session_title = session.title
            except Exception:
                pass

        messages = messages_qs.order_by('created_at')

        data = [
            {
                'id': str(m.id),
                'role': m.role,
                'user_id': m.user_id,
                'session_id': str(m.session_id) if m.session_id else None,
                'text': m.text,
                'medicines': m.medicines,
                'doctor_recommendation': m.doctor_recommendation,
                'attachment': request.build_absolute_uri(m.attachment.url) if m.attachment else None,
                'created_at': m.created_at.isoformat(),
            }
            for m in messages
        ]
        return Response({
            'user_id': user_id,
            'session_id': session_id,
            'session_title': session_title,
            'messages': data
        }, status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        user_id = request.query_params.get('user_id', 'tayasshuk').strip()
        session_id = request.query_params.get('session_id', None)

        if session_id:
            deleted_count, _ = ChatMessage.objects.filter(user_id=user_id, session_id=session_id).delete()
            ChatSession.objects.filter(user_id=user_id, id=session_id).delete()
            return Response(
                {'message': f'Session {session_id} for user {user_id} deleted successfully.', 'deleted_count': deleted_count},
                status=status.HTTP_200_OK
            )

        deleted_count, _ = ChatMessage.objects.filter(user_id=user_id).delete()
        ChatSession.objects.filter(user_id=user_id).delete()
        return Response(
            {'message': f'All chat history for user {user_id} deleted successfully.', 'deleted_count': deleted_count},
            status=status.HTTP_200_OK
        )


class ChatSessionsView(APIView):
    """Fetch or delete chat sessions for a specific user for Chat History UI"""

    def get(self, request, *args, **kwargs):
        user_id = request.query_params.get('user_id', 'tayasshuk').strip()
        sessions = ChatSession.objects.filter(user_id=user_id).order_by('-updated_at')

        data = []
        for s in sessions:
            messages = s.messages.all().order_by('created_at')
            count = messages.count()
            if count == 0:
                continue

            last_msg = messages.last()
            has_presc = messages.filter(medicines__isnull=False).exists() or messages.filter(attachment__isnull=False).exclude(attachment='').exists()
            doc_rec = messages.exclude(doctor_recommendation__isnull=True).exclude(doctor_recommendation='').values_list('doctor_recommendation', flat=True).first()

            data.append({
                'id': str(s.id),
                'user_id': s.user_id,
                'title': s.title or 'Health Consultation',
                'created_at': s.created_at.isoformat(),
                'updated_at': s.updated_at.isoformat(),
                'message_count': count,
                'last_message': last_msg.text[:75] if last_msg else '',
                'has_prescription': has_presc,
                'doctor_recommendation': doc_rec,
            })

        return Response({'user_id': user_id, 'sessions': data}, status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        session_id = request.query_params.get('session_id') or request.data.get('session_id')
        user_id = request.query_params.get('user_id') or request.data.get('user_id', 'tayasshuk')

        if not session_id:
            return Response({'error': 'session_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        deleted_msgs, _ = ChatMessage.objects.filter(session_id=session_id, user_id=user_id).delete()
        deleted_sessions, _ = ChatSession.objects.filter(id=session_id, user_id=user_id).delete()
        return Response({
            'message': f'Session {session_id} deleted successfully.',
            'deleted_messages': deleted_msgs,
            'deleted_sessions': deleted_sessions,
        }, status=status.HTTP_200_OK)


class ChatDashboardView(APIView):
    """Visual Dashboard for AI Health Assistant Chat Management"""

    def get(self, request, *args, **kwargs):
        selected_patient = request.GET.get('patient', '').strip()
        search_query = request.GET.get('q', '').strip()

        messages_qs = ChatMessage.objects.all().order_by('-created_at')
        sessions_qs = ChatSession.objects.all().order_by('-updated_at')

        # Get list of unique patients
        all_patients = list(ChatMessage.objects.values_list('user_id', flat=True).distinct())

        if selected_patient:
            messages_qs = messages_qs.filter(user_id=selected_patient)
            sessions_qs = sessions_qs.filter(user_id=selected_patient)

        if search_query:
            messages_qs = messages_qs.filter(text__icontains=search_query)

        # Overview statistics
        total_sessions = sessions_qs.count()
        total_messages = messages_qs.count()
        total_patients = len(all_patients)
        prescriptions_count = messages_qs.filter(medicines__isnull=False).count()
        doctor_recs_count = messages_qs.filter(doctor_recommendation__isnull=False).count()

        # Doctor Specialty Distribution for Chart
        doctor_distribution = (
            messages_qs.filter(doctor_recommendation__isnull=False)
            .values('doctor_recommendation')
            .annotate(total=Count('doctor_recommendation'))
            .order_by('-total')
        )
        doctor_labels = [d['doctor_recommendation'] for d in doctor_distribution]
        doctor_counts = [d['total'] for d in doctor_distribution]

        recent_messages = list(messages_qs[:30])
        db_name = settings.DATABASES['default'].get('NAME', 'carelink_cb_db')

        context = {
            'total_sessions': total_sessions,
            'total_messages': total_messages,
            'total_patients': total_patients,
            'prescriptions_count': prescriptions_count,
            'doctor_recs_count': doctor_recs_count,
            'all_patients': all_patients,
            'selected_patient': selected_patient,
            'search_query': search_query,
            'doctor_labels': json.dumps(doctor_labels),
            'doctor_counts': json.dumps(doctor_counts),
            'recent_messages': recent_messages,
            'db_name': db_name,
        }
        return render(request, 'dashboard.html', context)

    def post(self, request, *args, **kwargs):
        action = request.POST.get('action')
        if action == 'delete_user_history':
            uid = request.POST.get('user_id')
            if uid:
                ChatMessage.objects.filter(user_id=uid).delete()
                ChatSession.objects.filter(user_id=uid).delete()
                django_messages.success(request, f"Successfully cleared chat history for {uid}.")
        elif action == 'delete_message':
            mid = request.POST.get('message_id')
            if mid:
                ChatMessage.objects.filter(id=mid).delete()
                django_messages.success(request, "Message deleted successfully.")
        return redirect('chat_dashboard')
