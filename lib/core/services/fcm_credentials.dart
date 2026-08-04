class FcmCredentials {
  /// Paste your Firebase Service Account JSON file contents here.
  /// Bypassing assets is required for background push notifications as assets 
  /// cannot be parsed from background isolates.
  static const String serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "amd-app-bbd5c",
  "private_key_id": "YOUR_PRIVATE_KEY_ID",
  "private_key": "YOUR_PRIVATE_KEY",
  "client_email": "YOUR_CLIENT_EMAIL",
  "client_id": "YOUR_CLIENT_ID",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "YOUR_CLIENT_CERT_URL",
  "universe_domain": "googleapis.com"
}
''';
}
