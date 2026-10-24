from django.urls import path
from .views import AIChatView, ChatHistoryView

urlpatterns = [
    path('ai-chat/', AIChatView.as_view(), name='ai-chat'),
    path('ai-chat/history/', ChatHistoryView.as_view(), name='ai-chat-history'),
]
