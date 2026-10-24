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

        if not query_text and not image_file:
            return Response(
                {'error': 'Either query text or a prescription file is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get or create an active chat session for this user
        session_id = request.data.get('session_id', None)
        session = None
        if session_id:
            session = ChatSession.objects.filter(id=session_id, user_id=user_id).first()
        if not session:
            title = query_text[:35] if query_text else 'Prescription Analysis'
            session = ChatSession.objects.create(user_id=user_id, title=title)

        # 1. Record patient message in DB under user_id
        user_msg = ChatMessage.objects.create(
            session=session,
            user_id=user_id,
            role='user',
            text=query_text or 'Prescription upload',
            attachment=image_file,
        )

        # 2. Call AI generation service (Gemini 3.8 Flash)
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
            'user_id': user_id,
        }
        return Response(response_payload, status=status.HTTP_200_OK)

class ChatHistoryView(APIView):
    """Fetch or clear chat history for a particular user"""

    def get(self, request, *args, **kwargs):
        user_id = request.query_params.get('user_id', 'tayasshuk').strip()
        messages = ChatMessage.objects.filter(user_id=user_id).order_by('created_at')

        data = [
            {
                'id': str(m.id),
                'role': m.role,
                'user_id': m.user_id,
                'text': m.text,
                'medicines': m.medicines,
                'doctor_recommendation': m.doctor_recommendation,
                'attachment': request.build_absolute_uri(m.attachment.url) if m.attachment else None,
                'created_at': m.created_at.isoformat(),
            }
            for m in messages
        ]
        return Response({'user_id': user_id, 'messages': data}, status=status.HTTP_200_OK)

    def delete(self, request, *args, **kwargs):
        user_id = request.query_params.get('user_id', 'tayasshuk').strip()
        deleted_count, _ = ChatMessage.objects.filter(user_id=user_id).delete()
        ChatSession.objects.filter(user_id=user_id).delete()
        return Response(
            {'message': f'Chat history for user {user_id} deleted successfully.', 'deleted_count': deleted_count},
            status=status.HTTP_200_OK
        )


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
