import uuid
from django.db import models

class ChatSession(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_id = models.CharField(max_length=100, default='tayasshuk', db_index=True)
    title = models.CharField(max_length=255, default='Health Consultation')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"User {self.user_id} - Session {self.id} ({self.title})"

class ChatMessage(models.Model):
    ROLE_CHOICES = (
        ('user', 'User'),
        ('model', 'Model'),
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='messages', null=True, blank=True)
    user_id = models.CharField(max_length=100, default='tayasshuk', db_index=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    text = models.TextField()
    attachment = models.ImageField(upload_to='prescriptions/', null=True, blank=True)
    medicines = models.JSONField(null=True, blank=True)
    doctor_recommendation = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"[{self.user_id}] {self.role}: {self.text[:40]}"
