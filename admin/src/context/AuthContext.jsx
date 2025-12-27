import { createContext, useState, useEffect, useContext } from "react";
import Authservice from "../services/AuthService";

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    checkAuthStatus();
  }, []);

  const checkAuthStatus = () => {
    const token = sessionStorage.getItem("accessToken");
    const userData = sessionStorage.getItem("userData");

    if (token && userData) {
      try {
        setUser(JSON.parse(userData));
        setIsAuthenticated(true);
      } catch (err) {
        console.error("Error parsing user data:", err);
        logout();
      }
    }
    setLoading(false);
  };

  const login = async (loginData, rememberMe = false) => {
    try {
      setError(null);
      // Call the Authservice.login
      const response = await Authservice.login(
        loginData.email,
        loginData.password
      );

      if (response.data.success) {
        const { user, tokens } = response.data.data;

        // Store tokens
        if (rememberMe) {
          sessionStorage.setItem("accessToken", tokens.accessToken);
          sessionStorage.setItem("userData", JSON.stringify(user));
        } else {
          sessionStorage.setItem("accessToken", tokens.accessToken);
          sessionStorage.setItem("userData", JSON.stringify(user));
        }

        // Update state
        setUser(user);
        setIsAuthenticated(true);

        return { success: true, data: response.data };
      } else {
        setError(response.message || "Login failed");
        return { success: false, message: response.message };
      }
    } catch (err) {
      console.error("Login catch error:", err); // Debug log
      const errorMessage =
        err.response?.data?.message || "Login failed. Please try again.";
      setError(errorMessage);
      return { success: false, message: errorMessage };
    }
  };

  const logout = () => {
    // Clear all storage
    sessionStorage.removeItem("accessToken");
    sessionStorage.removeItem("userData");

    // Reset state
    setUser(null);
    setIsAuthenticated(false);
    setError(null);

    // Call API logout if needed
    Authservice.logout().catch(console.error);
  };

  const value = {
    user,
    isAuthenticated,
    loading,
    error,
    login,
    logout,
    setError,
    checkAuthStatus,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
