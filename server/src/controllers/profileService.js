const createProfileCard = async (req, res) => {
  try {
    const {
      serviceTitle,
      serviceCategory,
      experienceRange,
      hourlyRate,
      tagline,
      deliverables,
      processSteps,
      promises,
      faqs,
      rating,
      reviewComments,
      jobDescriptionLink,
      learningResourceLink,
      metaTitle,
      metaDescription,
      keywords,
    } = req.body;

    // Parse JSON fields if they come as strings
    const parsedDeliverables =
      typeof deliverables === "string"
        ? JSON.parse(deliverables)
        : deliverables;
    const parsedProcessSteps =
      typeof processSteps === "string"
        ? JSON.parse(processSteps)
        : processSteps;
    const parsedPromises =
      typeof promises === "string" ? JSON.parse(promises) : promises;
    const parsedFaqs = typeof faqs === "string" ? JSON.parse(faqs) : faqs;

    const serviceProfileData = {
      serviceTitle,
      serviceCategory,
      experienceRange,
      hourlyRate: parseFloat(hourlyRate),
      tagline,
      deliverables: parsedDeliverables,
      processSteps: parsedProcessSteps,
      promises: parsedPromises,
      faqs: parsedFaqs,
      rating: parseFloat(rating),
      reviewComments,
      jobDescriptionLink: jobDescriptionLink || null,
      learningResourceLink: learningResourceLink || null,
      metaTitle: metaTitle || null,
      metaDescription: metaDescription || null,
      keywords: keywords || null,
      profileImage: req.file ? req.file.filename : null,
    };

    const newServiceProfile = await db.ServiceProfile.create(
      serviceProfileData
    );

    res.status(201).json({
      success: true,
      message: "Service profile created successfully",
      data: newServiceProfile,
    });
  } catch (error) {
    console.error("Error creating service profile:", error);
    res.status(500).json({
      success: false,
      message: "Error creating service profile",
      error: error.message,
    });
  }
};
