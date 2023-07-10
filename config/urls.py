from django.contrib import admin
from django.conf import settings
from django.urls import path, re_path, include
from rest_framework.permissions import AllowAny
from rest_framework.routers import DefaultRouter
from drf_yasg import openapi
from drf_yasg.views import get_schema_view


router = DefaultRouter()
# add your ViewSets here


api_prefix = 'api/v1/'
api_urlpatterns = [
    path('accounts/', include('accounts.urls')),
    # add your urlpatterns here
    path('', include(router.get_urls())),
]

schema_view = get_schema_view(
    info=openapi.Info(
        title="title",
        default_version='v1',
        description="description",
        contact=openapi.Contact(email="email"),
        license=openapi.License(name="name"),
    ),
    validators=['flex'],
    public=True,
    permission_classes=[AllowAny],
    patterns=[path(api_prefix, include(api_urlpatterns))],
)

api_urlpatterns += [
    re_path(r'^swagger(?P<format>\.json|\.yaml)/$', schema_view.without_ui(), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger'), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc'), name='schema-redoc'),
]


urlpatterns = [
    path(api_prefix, include(api_urlpatterns)),
]

if settings.DEBUG:
    from django.conf.urls.static import static
    urlpatterns += [path('admin/', admin.site.urls)]
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


__all__ = ['urlpatterns']
