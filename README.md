# Rest Framework template with JWT authentication

* This is a template for a Django Rest Framework project with JWT authentication, 
  based on `dj_rest_auth` package.

## Installation
```bash
python -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

## User Model
* Use `accounts.models.User` as the user model, instead of the default `django.contrib.auth.models.User`.
* Username field is replaced with `email` field, and settings are configured to use email as the username field.
  (See `config.settings.base` for details.)

## Frontend API example (with flutter)
* See [`api_example.dart`](./api_example.dart) for an example of using the API with flutter.
* `flutter_secure_storage` and `http` packages are required.

## TODO
- [ ] Add Social Authentication
- [ ] Add Email Verification
