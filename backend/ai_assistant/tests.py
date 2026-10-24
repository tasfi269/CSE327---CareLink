from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from .models import ChatMessage

class AIChatAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.chat_url = reverse('ai-chat')
        self.history_url = reverse('ai-chat-history')

    def test_user_specific_chat_isolation(self):
        # 1. User A (Tayasshuk) sends a message
        res_a = self.client.post(self.chat_url, {
            'user_id': 'tayasshuk',
            'query': 'I have a headache'
        }, format='multipart')
        self.assertEqual(res_a.status_code, status.HTTP_200_OK)

        # 2. User B (Ayesha) sends a message
        res_b = self.client.post(self.chat_url, {
            'user_id': 'ayesha',
            'query': 'I have back pain'
        }, format='multipart')
        self.assertEqual(res_b.status_code, status.HTTP_200_OK)

        # 3. Retrieve history for User A - must only contain User A messages
        hist_a = self.client.get(f"{self.history_url}?user_id=tayasshuk")
        self.assertEqual(hist_a.status_code, status.HTTP_200_OK)
        messages_a = hist_a.json()['messages']
        self.assertTrue(all(m['user_id'] == 'tayasshuk' for m in messages_a))
        self.assertTrue(any('headache' in m['text'] for m in messages_a))
        self.assertFalse(any('back pain' in m['text'] for m in messages_a))

        # 4. Retrieve history for User B - must only contain User B messages
        hist_b = self.client.get(f"{self.history_url}?user_id=ayesha")
        self.assertEqual(hist_b.status_code, status.HTTP_200_OK)
        messages_b = hist_b.json()['messages']
        self.assertTrue(all(m['user_id'] == 'ayesha' for m in messages_b))
        self.assertTrue(any('back pain' in m['text'] for m in messages_b))
        self.assertFalse(any('headache' in m['text'] for m in messages_b))
