// routes/AppRoutes.jsx
import { Routes, Route } from "react-router-dom";
import ServiceProfileList from "./screens/Service/ServiceProfileList";
import ServiceProfile from "./screens/Service/ServiceProfile";
import HomeScreen from "./screens/HomeScreen";

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/" index element={<HomeScreen />} />
      <Route path="/admin/service-profiles" element={<ServiceProfileList />} />
      <Route path="/admin/service-profiles/create" element={<ServiceProfile />} />
      <Route path="/admin/service-profiles/:id/edit" element={<ServiceProfile />} />
    </Routes>
  );
}
