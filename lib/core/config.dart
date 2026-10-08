const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',
);

const connectTimeout = Duration(seconds: 10);
const receiveTimeout = Duration(seconds: 15);

const retryAttempts = 3;
const retryPause = Duration(milliseconds: 300);
