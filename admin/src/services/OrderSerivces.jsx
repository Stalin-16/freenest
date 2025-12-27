import RestService from "./RestServices";

const basePath = "/order";

const OrderService = {
  getAllOrders: () => {
    return RestService.GetAllData(`${basePath}/get-all-orders-admin`);
  },
};

export default OrderService;
