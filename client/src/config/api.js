/**
 * Centralized API Configuration
 * This file handles all API endpoint configuration for different environments
 */

// Get the current environment
const isDevelopment = process.env.NODE_ENV === 'development';
const isLocalhost = window.location.hostname === 'localhost';

/**
 * Dynamically determine the API base URL based on environment
 */
const getApiBaseUrl = () => {
  // Check if we have an environment variable set
  if (process.env.REACT_APP_API_BASE_URL && process.env.REACT_APP_API_BASE_URL !== '') {
    return process.env.REACT_APP_API_BASE_URL;
  }

  // For local development
  if (isLocalhost) {
    return 'http://localhost:8080/api/v1';
  }

  // For Replit environment - construct URL dynamically
  if (window.location.hostname.includes('replit.dev')) {
    // Use the specific backend URL that we know works
    return 'https://0d7b7a2f-2e76-4e54-b4f4-092df401269e-00-2tuha9lphc0vy.riker.replit.dev:8080/api/v1';
  }

  // For Windows Server deployment (static IP)
  if (window.location.hostname === '18.233.35.219' || process.env.NODE_ENV === 'production') {
    return `${window.location.protocol}//${window.location.hostname}/api`;
  }

  // For other cloud environments, try to construct from current domain
  const port = isDevelopment ? ':8080' : '';
  return `${window.location.protocol}//${window.location.hostname}${port}/api/v1`;
};

/**
 * Get the API host (without /api/v1 path)
 */
const getApiHost = () => {
  if (window.location.hostname.includes('replit.dev')) {
    return 'https://0d7b7a2f-2e76-4e54-b4f4-092df401269e-00-2tuha9lphc0vy.riker.replit.dev:8080';
  }
  
  // For Windows Server deployment
  if (window.location.hostname === '18.233.35.219' || process.env.NODE_ENV === 'production') {
    return `${window.location.protocol}//${window.location.hostname}`;
  }
  
  const baseUrl = getApiBaseUrl();
  return baseUrl.replace('/api/v1', '');
};

// Export configuration
export const apiConfig = {
  baseUrl: getApiBaseUrl(),
  host: getApiHost(),
  timeout: 30000, // 30 seconds
  retries: 3,
  
  // API endpoints
  endpoints: {
    auth: {
      login: '/auth/login',
      logout: '/auth/logout',
      refresh: '/auth/refresh-token',
      validate: '/auth/validate'
    },
    users: '/users',
    assets: '/assets',
    vulnerabilities: '/vulnerabilities',
    systems: '/systems',
    health: '/health' // Note: health is at root level, not /api/v1/health
  }
};

// Helper function to build full API URLs
export const buildApiUrl = (endpoint) => {
  if (endpoint === '/health') {
    // Special case for health endpoint which is at root level
    return `${apiConfig.host}/health`;
  }
  return `${apiConfig.baseUrl}${endpoint}`;
};

// Debug logging in development
if (isDevelopment && process.env.REACT_APP_DEBUG_MODE === 'true') {
  console.log('🔧 API Configuration:', {
    baseUrl: apiConfig.baseUrl,
    host: apiConfig.host,
    environment: process.env.NODE_ENV,
    hostname: window.location.hostname
  });
}

export default apiConfig;