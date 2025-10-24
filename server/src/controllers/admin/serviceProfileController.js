
const path = require("path");
const fs = require("fs");
const ServiceProfile = require("../../model/admin/serviceProfile");

const parseJSON = (val) => {
  try {
    return typeof val === "string" ? JSON.parse(val) : val;
  } catch {
    return [];
  }
};

// ✅ CREATE
exports.createServiceProfile = async (req, res) => {
  try {
    let imagePath = null;
    if (req.file) {
      imagePath = `/uploads/${req.file.filename}`;
    }

    const newProfile = await ServiceProfile.create({
      serviceTitle: req.body.serviceTitle,
      serviceCategory: req.body.serviceCategory,
      experienceRange: req.body.experienceRange,
      hourlyRate: req.body.hourlyRate,
      tagline: req.body.tagline,
      profileImage: imagePath,
      deliverables: parseJSON(req.body.deliverables),
      processSteps: parseJSON(req.body.processSteps),
      promises: parseJSON(req.body.promises),
      faqs: parseJSON(req.body.faqs),
      rating: req.body.rating,
      reviewComments: req.body.reviewComments,
      jobDescriptionLink: req.body.jobDescriptionLink,
      learningResourceLink: req.body.learningResourceLink,
      metaTitle: req.body.metaTitle,
      metaDescription: req.body.metaDescription,
      keywords: req.body.keywords,
    });

    res.status(201).json({ success: true, data: newProfile });
  } catch (error) {
    console.error("Error creating service profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ GET ALL
exports.getAllProfiles = async (req, res) => {
  try {
    const profiles = await ServiceProfile.findAll();
    res.json({ success: true, data: profiles });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ GET BY ID
exports.getProfileById = async (req, res) => {
  try {
    const profile = await ServiceProfile.findByPk(req.params.id);
    if (!profile) return res.status(404).json({ success: false, message: "Profile not found" });
    res.json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ✅ UPDATE
exports.updateProfile = async (req, res) => {
  try {
    const profile = await ServiceProfile.findByPk(req.params.id);
    if (!profile) return res.status(404).json({ success: false, message: "Profile not found" });

    let imagePath = profile.profileImage;
    if (req.file) {
      if (imagePath && fs.existsSync(path.join(__dirname, "../../..", imagePath))) {
        fs.unlinkSync(path.join(__dirname, "../../..", imagePath));
      }
      imagePath = `/uploads/${req.file.filename}`;
    }

    const updatedData = {
      serviceTitle: req.body.serviceTitle,
      serviceCategory: req.body.serviceCategory,
      experienceRange: req.body.experienceRange,
      hourlyRate: req.body.hourlyRate,
      tagline: req.body.tagline,
      profileImage: imagePath,
      deliverables: parseJSON(req.body.deliverables),
      processSteps: parseJSON(req.body.processSteps),
      promises: parseJSON(req.body.promises),
      faqs: parseJSON(req.body.faqs),
      rating: req.body.rating,
      reviewComments: req.body.reviewComments,
      jobDescriptionLink: req.body.jobDescriptionLink,
      learningResourceLink: req.body.learningResourceLink,
      metaTitle: req.body.metaTitle,
      metaDescription: req.body.metaDescription,
      keywords: req.body.keywords,
    };

    await profile.update(updatedData);
    res.json({ success: true, data: profile });
  } catch (error) {
    console.error("Error updating profile:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};
