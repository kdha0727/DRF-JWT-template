from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class AccountsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = __name__.rsplit('.', 1)[0]
    verbose_name = _('Authentication')
    verbose_name_plural = verbose_name
