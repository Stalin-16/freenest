import RestService from "./RestServices";

const basePath = "/order";

const OrderService = {
  getAllOrders: () => {
    return RestService.GetAllData(`${basePath}/get-all-orders-admin`);
  },

  changeOrderStatus: (id, data) => {
    return RestService.UpdateData(`${basePath}/update-status/${id}`, data);
  },
};

export default OrderService;
