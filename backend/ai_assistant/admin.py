from django.contrib import admin
from django.utils.html import format_html
from django.utils.safestring import mark_safe
from .models import ChatSession, ChatMessage

# Customize Admin Portal Branding
admin.site.site_header = mark_safe('CareLink Healthcare Administration &nbsp;|&nbsp; <a href="/dashboard/" style="color: #18A795; font-size: 13px; text-decoration: underline; font-weight: normal;">📊 Open Chat Management Dashboard</a>')
admin.site.site_title = "CareLink Admin Portal"
admin.site.index_title = "CareLink Digital Healthcare Platform Management"


class ChatMessageInline(admin.TabularInline):
    model = ChatMessage
    extra = 0
    fields = ('role', 'short_text', 'doctor_recommendation', 'created_at')
    readonly_fields = ('role', 'short_text', 'doctor_recommendation', 'created_at')
    can_delete = True

    def short_text(self, obj):
        return obj.text[:60] + "..." if len(obj.text) > 60 else obj.text
    short_text.short_description = "Message Content"


@admin.register(ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ('id', 'user_id', 'title', 'message_count', 'created_at', 'updated_at')
    list_filter = ('user_id', 'created_at')
    search_fields = ('user_id', 'title')
    readonly_fields = ('id', 'created_at', 'updated_at')
    inlines = [ChatMessageInline]

    def message_count(self, obj):
        return obj.messages.count()
    message_count.short_description = "Total Messages"


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user_id',
        'role_badge',
        'short_text',
        'doctor_recommendation',
        'has_attachment',
        'has_medicines',
        'created_at'
    )
    list_filter = ('role', 'doctor_recommendation', 'user_id', 'created_at')
    search_fields = ('user_id', 'text', 'doctor_recommendation')
    readonly_fields = ('id', 'created_at')
    fieldsets = (
        ('General Information', {
            'fields': ('id', 'session', 'user_id', 'role', 'created_at')
        }),
        ('Message Content', {
            'fields': ('text', 'attachment')
        }),
        ('AI Diagnostics & Extraction', {
            'fields': ('doctor_recommendation', 'medicines')
        }),
    )

    def short_text(self, obj):
        return obj.text[:70] + "..." if len(obj.text) > 70 else obj.text
    short_text.short_description = "Message Preview"

    def role_badge(self, obj):
        if obj.role == 'model':
            return mark_safe('<span style="color: #18A795; font-weight: bold;">🤖 AI Assistant</span>')
        return format_html('<span style="color: #0D1638; font-weight: bold;">👤 Patient ({})</span>', obj.user_id)
    role_badge.short_description = "Role"

    def has_attachment(self, obj):
        return bool(obj.attachment)
    has_attachment.boolean = True
    has_attachment.short_description = "Attachment"

    def has_medicines(self, obj):
        return bool(obj.medicines)
    has_medicines.boolean = True
    has_medicines.short_description = "Medicines Extracted"
