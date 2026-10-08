const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',
);

const connectTimeout = Duration(seconds: 10);
const receiveTimeout = Duration(seconds: 15);

const retryAttempts = 3;
const retryPause = Duration(milliseconds: 300);

const inactivityTimeout = Duration(
  seconds: int.fromEnvironment('INACTIVITY_SECONDS', defaultValue: 180),
);
const inactivityWarning = Duration(seconds: 30);

const sessionMaxDuration = Duration(
  seconds: int.fromEnvironment('SESSION_SECONDS', defaultValue: 1800),
);
