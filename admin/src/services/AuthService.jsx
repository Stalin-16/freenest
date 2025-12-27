import axiosInstance from "../AxiosConfig";

const basePath = "/auth";

const Authservice = {
  login: (email, password) => {
    return axiosInstance.post(`${basePath}/login`, {
      email: email,
      password: password,
    });
  },
};

export default Authservice;
