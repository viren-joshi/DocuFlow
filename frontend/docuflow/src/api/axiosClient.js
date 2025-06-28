import axios from 'axios';
import { Auth } from 'aws-amplify';

// Create an Axios instance
const axiosClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'https://zt8mbbgqtg.execute-api.us-east-1.amazonaws.com/prod'  , // fallback
});

// Add auth token to every request
axiosClient.interceptors.request.use(async (config) => {
  try {
    const user = await Auth.currentAuthenticatedUser();
    const token = user.signInUserSession.idToken.jwtToken;

    config.headers.Authorization = `Bearer ${token}`;
  } catch (err) {
    console.error('Auth error:', err);
  }

  return config;
});

export default axiosClient;
