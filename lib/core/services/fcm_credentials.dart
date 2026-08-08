// ignore_for_file: prefer_single_quotes
// IMPORTANT: This file contains sensitive credentials.
// It is already added to .gitignore — DO NOT remove it from there.
class FcmCredentials {
  static const String serviceAccountJson = r'''
{
  "type": "service_account",
  "project_id": "amd-app-bbd5c",
  "private_key_id": "YOUR_PRIVATE_KEY_ID",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@amd-app-bbd5c.iam.gserviceaccount.com",
  "client_id": "116328014955138485429",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40amd-app-bbd5c.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
}
