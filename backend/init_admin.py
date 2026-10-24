import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'carelink_backend.settings')
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@carelink.com', 'admin')
    print("[OK] Superuser 'admin' created (Password: admin)")
else:
    print("[OK] Superuser 'admin' is ready.")
