"""
** Usage **
DJANGO_SETTINGS_MODULE=config.settings

This is alias for `config.settings.local` module.
To use production settings, use `config.settings.prod` instead.
"""

from .local import *
