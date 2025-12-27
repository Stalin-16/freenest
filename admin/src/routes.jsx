import { Routes, Route, Navigate } from "react-router-dom";
import ServiceProfileList from "./screens/Service/ServiceProfileList";
import ServiceProfile from "./screens/Service/ServiceProfile";
import HomeScreen from "./screens/HomeScreen";
import Login from "./screens/Login/Login";
import { useAuth } from "./context/AuthContext";

export default function AppRoutes() {
  const { isAuthenticated, loading } = useAuth();

  const ProtectedRoute = ({ children }) => {
    if (loading) {
      return <div>Loading...</div>; // Add a loading spinner here
    }

    return isAuthenticated ? children : <Navigate to="/" replace />;
  };

  return (
    <Routes>
      <Route
        path="/"
        index
        element={!isAuthenticated ? <Login /> : <Navigate to="/home" replace />}
      />

      <Route
        path="/home"
        element={
          <ProtectedRoute>
            <HomeScreen />
          </ProtectedRoute>
        }
      />

      <Route
        path="/admin/service-profiles"
        element={
          <ProtectedRoute>
            <ServiceProfileList />
          </ProtectedRoute>
        }
      />

      <Route
        path="/admin/service-profiles/create"
        element={
          <ProtectedRoute>
            <ServiceProfile />
          </ProtectedRoute>
        }
      />

      <Route
        path="/admin/service-profiles/:id/edit"
        element={
          <ProtectedRoute>
            <ServiceProfile />
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}
