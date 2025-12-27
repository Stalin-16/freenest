import { useEffect, useState } from "react";
import { FiMoreVertical } from "react-icons/fi";
import { useNavigate } from "react-router-dom";
import ServiceProfiles from "../../services/ProfilService";

const ServiceProfileList = () => {
  const [profiles, setProfiles] = useState([]);
  const [menuOpenIndex, setMenuOpenIndex] = useState(null);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    fetchProfiles();
  }, []);

  const fetchProfiles = async () => {
    try {
      setLoading(true);

      const response = await ServiceProfiles.getAllProfiles();

      if (response.data.success) {
        setProfiles(response.data.data || []);
      }
    } catch (err) {
      console.error("Error fetching profiles:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleCardClick = (id) =>
    navigate(`/admin/service-profiles/${id}/edit`);
  const handleCreateNew = () => navigate("/admin/service-profiles/create");

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-800">Service Profiles</h2>
        <button
          onClick={handleCreateNew}
          className="bg-blue-600 text-white px-4 py-2 rounded-md shadow hover:bg-blue-700"
        >
          + Create Service
        </button>
      </div>

      {profiles.length === 0 ? (
        <p className="text-gray-600">No service profiles created yet.</p>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {profiles.map((profile, index) => (
            <div
              key={profile.id}
              className="relative bg-white rounded-lg shadow hover:shadow-md p-4 cursor-pointer transition"
              onClick={() => handleCardClick(profile.id)}
            >
              {/* 3-dot menu */}
              <div
                className="absolute top-3 right-3"
                onClick={(e) => {
                  e.stopPropagation();
                  setMenuOpenIndex(menuOpenIndex === index ? null : index);
                }}
              >
                <FiMoreVertical className="text-gray-500 hover:text-gray-700" />
                {menuOpenIndex === index && (
                  <div className="absolute right-0 mt-2 bg-white border rounded shadow-lg z-10">
                    <button
                      onClick={() => handleCardClick(profile.id)}
                      className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 w-full text-left"
                    >
                      ✏️ Edit
                    </button>
                    {/* Optional delete later */}
                  </div>
                )}
              </div>

              {/* Card content */}
              <div className="flex flex-col items-center text-center">
                <img
                  src={
                    profile.profileImage
                      ? `http://localhost:5000${profile.profileImage}`
                      : "https://via.placeholder.com/100"
                  }
                  alt="Profile"
                  className="w-20 h-20 rounded-full object-cover mb-3"
                />
                <h3 className="text-lg font-semibold text-gray-800">
                  {profile.serviceTitle || "Untitled"}
                </h3>
                <p className="text-sm text-gray-500 mb-2">
                  {profile.serviceCategory}
                </p>
                <p className="text-blue-600 font-medium">
                  ${profile.hourlyRate}/hr
                </p>
                <p className="text-yellow-500 text-sm mt-1">
                  ⭐ {profile.rating}/5
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default ServiceProfileList;
