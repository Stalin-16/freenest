import axios from "axios";

// Create axios instance with custom config
const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000, // 10 seconds
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

// Request interceptor to add auth token
axiosInstance.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // Add other common headers if needed
    config.headers["X-Requested-With"] = "XMLHttpRequest";

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for handling common errors
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    // Handle common error responses
    if (error.response) {
      console.error("Response error:", error.response);
      switch (error.response.status) {
        case 401:
          // Token expired or invalid
          // handleUnauthorized();
          break;
        case 403:
          // Forbidden
          console.error("Forbidden access");
          break;
        case 404:
          console.error("Resource not found");
          break;
        case 500:
          console.error("Server error");
          break;
        default:
          console.error("An error occurred");
      }
    } else if (error.request) {
      // The request was made but no response was received
      console.error("No response received");
    } else {
      // Something happened in setting up the request
      console.error("Request setup error:", error.message);
    }

    return Promise.reject(error);
  }
);

// Helper function to get auth token (customize based on your auth setup)
const getAuthToken = () => {
  // Get token from sessionStorage, cookie, or your auth context
  return (
    sessionStorage.getItem("accessToken") ||
    sessionStorage.getItem("accessToken")
  );
};

// Helper function to handle unauthorized access
const handleUnauthorized = () => {
  // Clear auth data
  sessionStorage.removeItem("accessToken");
  sessionStorage.removeItem("accessToken");
  // Redirect to login or show login modal
  window.location.href = "/";
  // Or use your router: router.navigate('/login');
};

export default axiosInstance;
