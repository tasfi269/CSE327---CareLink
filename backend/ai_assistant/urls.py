from django.urls import path
from .views import AIChatView, ChatHistoryView, ChatSessionsView

urlpatterns = [
    path('ai-chat/', AIChatView.as_view(), name='ai-chat'),
    path('ai-chat/history/', ChatHistoryView.as_view(), name='ai-chat-history'),
    path('ai-chat/sessions/', ChatSessionsView.as_view(), name='ai-chat-sessions'),
]
