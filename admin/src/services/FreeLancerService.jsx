import RestService from "./RestServices";
const basePath = "/freelancers";
const FreeLancerService = {
  getAllFreeLancers: (params) => {
    return RestService.CreateData(`${basePath}/get-all-freelancers`, params);
  },

  getStats: () => {
    return RestService.GetAllData(`${basePath}/stats/summary`);
  },

  createFreelancer: (data) => {
    return RestService.CreateData(`${basePath}/create-freelancers`, data);
  },

  getFreelancerById: (id) => {
    return RestService.GetByIdData(`${basePath}/${id}`);
  },

  updateFreelancer: (id, data) => {
    return RestService.UpdateData(`${basePath}/${id}/status`, data);
  },
};

export default FreeLancerService;
