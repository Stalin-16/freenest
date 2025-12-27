import RestService from "./RestServices";

const ServiceProfiles = {
  // Get all service profiles
  getAllProfiles: async () => {
    return RestService.GetAllData(`/service-profiles`);
  },

  createServiceProfile: async (data) => {
    return RestService.CreateData(`/service-profiles`, data);
  },

  updateServiceProfile: async (id, data) => {
    return RestService.UpdateData(`/service-profiles/${id}`, data);
  },
  getProfileById: async (id) => {
    return RestService.GetByIdData(`/service-profiles`, id);
  },
};

export default ServiceProfiles;
