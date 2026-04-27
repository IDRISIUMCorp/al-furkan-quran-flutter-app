// Firebase Service Account Key Template
// ─────────────────────────────────────
// 1. Copy this file: service_account_key.example.dart → service_account_key.dart
// 2. Replace placeholder values with your Firebase service account credentials
// 3. service_account_key.dart is gitignored — it will NEVER be committed
//
// Get your key from: Firebase Console → Project Settings → Service Accounts → Generate New Private Key

/// Service account credentials as a JSON-decodable Map.
/// Replace with your real Firebase service account key before using admin features.
const Map<String, dynamic> serviceAccountJson = {
  'type': 'service_account',
  'project_id': 'YOUR_PROJECT_ID',
  'private_key_id': 'YOUR_PRIVATE_KEY_ID',
  'private_key':
      '-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n',
  'client_email':
      'YOUR_CLIENT_EMAIL@YOUR_PROJECT_ID.iam.gserviceaccount.com',
  'client_id': 'YOUR_CLIENT_ID',
  'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
  'token_uri': 'https://oauth2.googleapis.com/token',
  'auth_provider_x509_cert_url':
      'https://www.googleapis.com/oauth2/v1/certs',
  'client_x509_cert_url':
      'https://www.googleapis.com/robot/v1/metadata/x509/YOUR_CLIENT_EMAIL',
};
