import React, { useState } from "react";

const ServiceProfile = () => {
  const [formData, setFormData] = useState({
    // 1. Basic Information
    serviceTitle: "",
    serviceCategory: "",
    experienceRange: "",
    hourlyRate: "",
    tagline: "",
    profileImage: null,

    // 2. Service Deliverables
    deliverables: [{ title: "", description: "" }],

    // 3. How It Works
    processSteps: [{ title: "", description: "" }],

    // 4. Our Promise
    promises: [
      { checked: false, text: "Verified & Tested Freelancers" },
      { checked: false, text: "Transparent Time Tracking" },
      { checked: false, text: "Dedicated Customer Support" },
      {
        checked: false,
        text: "Assured Referral Credits for successful referrals",
      },
    ],

    // 5. FAQs
    faqs: [{ question: "", answer: "" }],

    // 6. Review & Rating
    rating: 5,
    reviewComments:
      "Thank you for your rating <customer name> & support, your kind words about our service experience will help us find new customers, please share your good experience about our freelance partner with the world",

    // 7. Freelance Partners Reference
    jobDescriptionLink: "",
    learningResourceLink: "",

    // 8. SEO & Meta Settings
    metaTitle: "",
    metaDescription: "",
    keywords: "",
  });

  const serviceCategories = [
    "Web Development",
    "Software Development",
    "Mobile Development",
    "UI/UX Design",
    "Management",
    "Consulting",
    "Salesforce",
  ];

  const experienceRanges = ["3-5 years", "6-10 years", "10+ years"];

  const handleInputChange = (section, field, value, index = null) => {
    if (index !== null) {
      const updatedArray = [...formData[section]];
      updatedArray[index][field] = value;
      setFormData((prev) => ({ ...prev, [section]: updatedArray }));
    } else {
      setFormData((prev) => ({ ...prev, [field]: value }));
    }
  };

  const handlePromiseToggle = (index) => {
    const updatedPromises = [...formData.promises];
    updatedPromises[index].checked = !updatedPromises[index].checked;
    setFormData((prev) => ({ ...prev, promises: updatedPromises }));
  };

  const addArrayItem = (section) => {
    const newItem =
      section === "deliverables" || section === "processSteps"
        ? { title: "", description: "" }
        : { question: "", answer: "" };

    setFormData((prev) => ({
      ...prev,
      [section]: [...prev[section], newItem],
    }));
  };

  const removeArrayItem = (section, index) => {
    const updatedArray = formData[section].filter((_, i) => i !== index);
    setFormData((prev) => ({ ...prev, [section]: updatedArray }));
  };

  const handleImageUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData((prev) => ({ ...prev, profileImage: file }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formDataToSend = new FormData();

    // Append all form data
    formDataToSend.append("serviceTitle", formData.serviceTitle);
    formDataToSend.append("serviceCategory", formData.serviceCategory);
    // ... append all other fields

    // Append JSON fields as strings
    formDataToSend.append(
      "deliverables",
      JSON.stringify(formData.deliverables)
    );
    formDataToSend.append(
      "processSteps",
      JSON.stringify(formData.processSteps)
    );
    formDataToSend.append("promises", JSON.stringify(formData.promises));
    formDataToSend.append("faqs", JSON.stringify(formData.faqs));

    // Append file if exists
    if (formData.profileImage) {
      formDataToSend.append("profileImage", formData.profileImage);
    }

    try {
      const response = await fetch(
        "http://localhost:5000/api/service-profiles",
        {
          method: "POST",
          body: formDataToSend,
        }
      );

      const result = await response.json();

      if (result.success) {
        alert("Service Profile Created Successfully!");
        // Reset form or redirect
      } else {
        alert("Error: " + result.message);
      }
    } catch (error) {
      console.error("Error submitting form:", error);
      alert("Error creating service profile");
    }
  };

  return (
    <div className="bg-white shadow rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-6">
          Create Service Profile
        </h2>

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* 1. Basic Information */}
          <div className="border-b border-gray-200 pb-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              1. Basic Information
            </h3>
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Service Title
                </label>
                <input
                  type="text"
                  value={formData.serviceTitle}
                  onChange={(e) =>
                    handleInputChange(null, "serviceTitle", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="e.g., PHP Developer, React Developer"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Service Category
                </label>
                <select
                  value={formData.serviceCategory}
                  onChange={(e) =>
                    handleInputChange(null, "serviceCategory", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  required
                >
                  <option value="">Select Category</option>
                  {serviceCategories.map((category) => (
                    <option key={category} value={category}>
                      {category}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Experience Range
                </label>
                <select
                  value={formData.experienceRange}
                  onChange={(e) =>
                    handleInputChange(null, "experienceRange", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  required
                >
                  <option value="">Select Experience</option>
                  {experienceRanges.map((range) => (
                    <option key={range} value={range}>
                      {range}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Hourly Rate (USD)
                </label>
                <input
                  type="number"
                  value={formData.hourlyRate}
                  onChange={(e) =>
                    handleInputChange(null, "hourlyRate", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="e.g., 10, 15, 20"
                  required
                />
              </div>

              <div className="sm:col-span-2">
                <label className="block text-sm font-medium text-gray-700">
                  Short Tagline / One-liner
                </label>
                <input
                  type="text"
                  value={formData.tagline}
                  onChange={(e) =>
                    handleInputChange(null, "tagline", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="e.g., Hire skilled Laravel developers for scalable apps"
                  required
                />
              </div>

              <div className="sm:col-span-2">
                <label className="block text-sm font-medium text-gray-700">
                  Profile Image / Icon
                </label>
                <input
                  type="file"
                  onChange={handleImageUpload}
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  accept="image/*"
                />
                {formData.profileImage && (
                  <p className="mt-2 text-sm text-green-600">
                    Selected: {formData.profileImage.name}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* 2. Service Deliverables */}
          <div className="border-b border-gray-200 pb-8">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium text-gray-900">
                2. Service Deliverables
              </h3>
              <button
                type="button"
                onClick={() => addArrayItem("deliverables")}
                className="bg-blue-500 text-white px-3 py-1 rounded text-sm"
              >
                Add Deliverable
              </button>
            </div>
            {formData.deliverables.map((deliverable, index) => (
              <div
                key={index}
                className="mb-4 p-4 border border-gray-200 rounded-lg"
              >
                <div className="flex justify-between items-center mb-2">
                  <h4 className="font-medium">Deliverable {index + 1}</h4>
                  {formData.deliverables.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeArrayItem("deliverables", index)}
                      className="text-red-500 text-sm"
                    >
                      Remove
                    </button>
                  )}
                </div>
                <div className="grid grid-cols-1 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Deliverable Title
                    </label>
                    <input
                      type="text"
                      value={deliverable.title}
                      onChange={(e) =>
                        handleInputChange(
                          "deliverables",
                          "title",
                          e.target.value,
                          index
                        )
                      }
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., Frontend Development"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Deliverable Description
                    </label>
                    <textarea
                      value={deliverable.description}
                      onChange={(e) =>
                        handleInputChange(
                          "deliverables",
                          "description",
                          e.target.value,
                          index
                        )
                      }
                      rows={3}
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., React.js, Bootstrap, and HTML for responsive UI"
                      required
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* 3. How It Works */}
          <div className="border-b border-gray-200 pb-8">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium text-gray-900">
                3. How It Works (Process Steps)
              </h3>
              <button
                type="button"
                onClick={() => addArrayItem("processSteps")}
                className="bg-blue-500 text-white px-3 py-1 rounded text-sm"
              >
                Add Step
              </button>
            </div>
            {formData.processSteps.map((step, index) => (
              <div
                key={index}
                className="mb-4 p-4 border border-gray-200 rounded-lg"
              >
                <div className="flex justify-between items-center mb-2">
                  <h4 className="font-medium">Step {index + 1}</h4>
                  {formData.processSteps.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeArrayItem("processSteps", index)}
                      className="text-red-500 text-sm"
                    >
                      Remove
                    </button>
                  )}
                </div>
                <div className="grid grid-cols-1 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Step Title
                    </label>
                    <input
                      type="text"
                      value={step.title}
                      onChange={(e) =>
                        handleInputChange(
                          "processSteps",
                          "title",
                          e.target.value,
                          index
                        )
                      }
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., Purchase Hours"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Step Description
                    </label>
                    <textarea
                      value={step.description}
                      onChange={(e) =>
                        handleInputChange(
                          "processSteps",
                          "description",
                          e.target.value,
                          index
                        )
                      }
                      rows={3}
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., Hire a verified freelancer at $10/hour"
                      required
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* 4. Our Promise */}
          <div className="border-b border-gray-200 pb-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              4. Our Promise (Highlights Section)
            </h3>
            <div className="space-y-3">
              {formData.promises.map((promise, index) => (
                <div key={index} className="flex items-center">
                  <input
                    type="checkbox"
                    checked={promise.checked}
                    onChange={() => handlePromiseToggle(index)}
                    className="h-4 w-4 text-blue-600 border-gray-300 rounded"
                  />
                  <label className="ml-2 text-sm text-gray-700">
                    {promise.text}
                  </label>
                </div>
              ))}
            </div>
          </div>

          {/* 5. FAQs */}
          <div className="border-b border-gray-200 pb-8">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium text-gray-900">5. FAQs</h3>
              <button
                type="button"
                onClick={() => addArrayItem("faqs")}
                className="bg-blue-500 text-white px-3 py-1 rounded text-sm"
              >
                Add FAQ
              </button>
            </div>
            {formData.faqs.map((faq, index) => (
              <div
                key={index}
                className="mb-4 p-4 border border-gray-200 rounded-lg"
              >
                <div className="flex justify-between items-center mb-2">
                  <h4 className="font-medium">FAQ {index + 1}</h4>
                  {formData.faqs.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeArrayItem("faqs", index)}
                      className="text-red-500 text-sm"
                    >
                      Remove
                    </button>
                  )}
                </div>
                <div className="grid grid-cols-1 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Question
                    </label>
                    <input
                      type="text"
                      value={faq.question}
                      onChange={(e) =>
                        handleInputChange(
                          "faqs",
                          "question",
                          e.target.value,
                          index
                        )
                      }
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., How many hours should I purchase?"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Answer
                    </label>
                    <textarea
                      value={faq.answer}
                      onChange={(e) =>
                        handleInputChange(
                          "faqs",
                          "answer",
                          e.target.value,
                          index
                        )
                      }
                      rows={3}
                      className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                      placeholder="e.g., Start with 1 hour to discuss requirements..."
                      required
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* 6. Review & Rating */}
          <div className="border-b border-gray-200 pb-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              6. Review & Rating
            </h3>
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Rating
                </label>
                <input
                  type="number"
                  min="1"
                  max="5"
                  value={formData.rating}
                  onChange={(e) =>
                    handleInputChange(null, "rating", parseInt(e.target.value))
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  required
                />
              </div>
              <div className="sm:col-span-2">
                <label className="block text-sm font-medium text-gray-700">
                  Review Comments
                </label>
                <textarea
                  value={formData.reviewComments}
                  onChange={(e) =>
                    handleInputChange(null, "reviewComments", e.target.value)
                  }
                  rows={4}
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  required
                />
              </div>
            </div>
          </div>

          {/* 7. Freelance Partners Reference */}
          <div className="border-b border-gray-200 pb-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              7. Freelance Partners Reference
            </h3>
            <div className="grid grid-cols-1 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Job Description Link
                </label>
                <input
                  type="url"
                  value={formData.jobDescriptionLink}
                  onChange={(e) =>
                    handleInputChange(
                      null,
                      "jobDescriptionLink",
                      e.target.value
                    )
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="https://example.com/job-description"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Learning Resource Link
                </label>
                <input
                  type="url"
                  value={formData.learningResourceLink}
                  onChange={(e) =>
                    handleInputChange(
                      null,
                      "learningResourceLink",
                      e.target.value
                    )
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="https://example.com/learning-resources"
                />
              </div>
            </div>
          </div>

          {/* 8. SEO & Meta Settings */}
          <div className="border-b border-gray-200 pb-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              8. SEO & Meta Settings
            </h3>
            <div className="grid grid-cols-1 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Meta Title
                </label>
                <input
                  type="text"
                  value={formData.metaTitle}
                  onChange={(e) =>
                    handleInputChange(null, "metaTitle", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="Meta title for SEO"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Meta Description
                </label>
                <textarea
                  value={formData.metaDescription}
                  onChange={(e) =>
                    handleInputChange(null, "metaDescription", e.target.value)
                  }
                  rows={3}
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="Meta description for SEO"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Keywords
                </label>
                <input
                  type="text"
                  value={formData.keywords}
                  onChange={(e) =>
                    handleInputChange(null, "keywords", e.target.value)
                  }
                  className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
                  placeholder="comma, separated, keywords"
                />
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-end">
            <button
              type="submit"
              className="bg-blue-600 text-white px-6 py-2 rounded-md shadow hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              Create Service Profile
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ServiceProfile;
