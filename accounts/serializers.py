from dj_rest_auth.serializers import LoginSerializer as BaseLoginSerializer
from dj_rest_auth.registration.serializers import RegisterSerializer as BaseRegisterSerializer


class LoginSerializer(BaseLoginSerializer):
    username = None


class RegisterSerializer(BaseRegisterSerializer):
    username = None
