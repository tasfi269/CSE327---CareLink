from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from ai_assistant.views import ChatDashboardView

urlpatterns = [
    path('', ChatDashboardView.as_view(), name='home_dashboard'),
    path('dashboard/', ChatDashboardView.as_view(), name='chat_dashboard'),
    path('admin/', admin.site.urls),
    path('api/', include('ai_assistant.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
