import axios from "axios";
import { useEffect, useState } from "react";
import OrderService from "../../services/OrderSerivces";

const AdminOrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const response = await OrderService.getAllOrders();

      if (response.data.status === 200) {
        setOrders(response.data.data || []);
      }
    } catch (error) {
      console.error("Failed to fetch orders:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      setUpdating(orderId);
      const res = await axios.put(
        `${API_BASE_URL}/order/update-status/${orderId}`,
        {
          status: newStatus,
        }
      );

      if (res.data.status === 200) {
        alert("Order status updated successfully!");
        fetchOrders();
      } else {
        alert(res.data.message || "Failed to update status");
      }
    } catch (err) {
      console.error(err);
      alert("Error updating status");
    } finally {
      setUpdating(null);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen text-lg font-medium">
        Loading orders...
      </div>
    );
  }

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-2xl font-semibold mb-4 text-gray-800">
        🛒 Manage Orders
      </h1>

      {orders.length === 0 ? (
        <p className="text-gray-500 text-center mt-10">No orders found.</p>
      ) : (
        <div className="overflow-x-auto bg-white rounded-lg shadow">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-100 text-gray-700 uppercase text-sm">
                <th className="p-3 border-b">Order ID</th>
                <th className="p-3 border-b">User</th>
                <th className="p-3 border-b">Items</th>
                <th className="p-3 border-b">Total Price</th>
                <th className="p-3 border-b">Status</th>
                <th className="p-3 border-b text-center">Action</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr
                  key={order.id}
                  className="hover:bg-gray-50 border-b text-gray-800"
                >
                  <td className="p-3">#{order.id}</td>
                  <td className="p-3">
                    {order.User ? order.User.name : "Unknown"}
                  </td>
                  <td className="p-3">{order.total_items}</td>
                  <td className="p-3 font-medium text-blue-600">
                    ₹{Number(order.total_price).toFixed(2)}
                  </td>
                  <td className="p-3 capitalize">
                    <span
                      className={`px-2 py-1 rounded text-sm ${
                        order.status === "completed"
                          ? "bg-green-100 text-green-700"
                          : order.status === "inprogress"
                          ? "bg-yellow-100 text-yellow-700"
                          : order.status === "assigned"
                          ? "bg-blue-100 text-blue-700"
                          : "bg-gray-100 text-gray-700"
                      }`}
                    >
                      {order.status}
                    </span>
                  </td>
                  <td className="p-3 text-center">
                    <select
                      disabled={updating === order.id}
                      value={order.status}
                      onChange={(e) =>
                        handleStatusChange(order.id, e.target.value)
                      }
                      className="border rounded-md px-2 py-1 text-sm"
                    >
                      <option value="">Select Status </option>
                      <option value="Assigned">Assigned</option>
                      <option value="Inprogress">In Progress</option>
                      <option value="Completed">Completed</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default AdminOrdersPage;
