// App.js
import React, { useState } from "react";
import ServiceProfile from "./Service/ServiceProfile";

function HomeScreen() {
  const [activeTab, setActiveTab] = useState("service-profile");

  const tabs = [
    { id: "service-profile", name: "Service Profile" },
    { id: "client-orders", name: "Client Orders" },
    { id: "clients", name: "Clients" },
    { id: "freelancers", name: "Freelancers" },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-gray-900">
                Chennai Freelancers Admin
              </h1>
            </div>
            <nav className="flex space-x-8">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-3 py-2 rounded-md text-sm font-medium ${
                    activeTab === tab.id
                      ? "bg-blue-100 text-blue-700"
                      : "text-gray-500 hover:text-gray-700"
                  }`}
                >
                  {tab.name}
                </button>
              ))}
            </nav>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {activeTab === "service-profile" && <ServiceProfile />}
        {activeTab === "client-orders" && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Client Orders</h2>
            <p>Client orders management coming soon...</p>
          </div>
        )}
        {activeTab === "clients" && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Clients</h2>
            <p>Clients management coming soon...</p>
          </div>
        )}
        {activeTab === "freelancers" && (
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-4">Freelancers</h2>
            <p>Freelancers management coming soon...</p>
          </div>
        )}
      </main>
    </div>
  );
}

export default HomeScreen;
