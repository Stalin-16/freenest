import { useEffect, useState } from "react";
import axiosInstance from "../AxiosConfig";

const getAuthHeaders = () => {
  const encodedCredentials = sessionStorage.getItem("accessToken");
  const headers = {};
  if (encodedCredentials) {
    headers.Authorization = `Bearer ${encodedCredentials}`;
  }
  return headers;
};

const CreateData = async (path, data) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.post(path, data, config);
    return response.data;
  } catch (error) {
    console.error(`Error creating ${path}:`, error);
    return error.response?.data;
  }
};

const PostData = async (path, data) => {
  const config = {
    headers: {
      ...getAuthHeaders(),
      "Content-Type": "application/json",
    },
  };

  try {
    const response = await axiosInstance.post(path, data, config);
    return response.data;
  } catch (error) {
    console.error(`Error posting to ${path}:`, error);
    return error.response?.data || { error: true, message: error.message };
  }
};

const CreateDataWithState = (path, data) => {
  const [resultData, setResultData] = useState(null);
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    setLoading(true);
    const config = {
      headers: getAuthHeaders(),
    };
    try {
      axiosInstance
        .post(path, data, config)
        .then((res) => {
          setResultData(res.data);
          setLoading(false);
        })
        .catch((error) => {
          setLoading(false);
          console.error(`Error fetching ${path}s:`, error);
          setResultData(error.response?.data);
        });
    } catch (error) {
      setLoading(false);
      console.error(`Error fetching ${path}s:`, error);
      setResultData(error.response?.data);
    }
  }, [path, data]);

  return [resultData, setResultData, loading, setLoading];
};

const UpdateData = async (path, data) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.put(path, data, config);
    return response.data;
  } catch (error) {
    console.error(`Error updating ${path}:`, error);
    // Throw the error or return a clear error object
    return error.response?.data;
  }
};

const PartialUpdateData = async (path, data) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.patch(path, data, config);
    return response.data;
  } catch (error) {
    console.error(`Error updating ${path}:`, error);
    return error.response != null ? error.response.data : {};
  }
};

const DeleteDataWithoutState = async (path) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.delete(`${path}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error deleting ${path}:`, error);
    return error.response?.data;
  }
};

const DeleteData = async (path, id) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.delete(`${path}/${id}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error deleting ${path}:`, error);
    return error.response?.data;
  }
};

const DeleteDataAll = async (path, ids) => {
  const config = {
    headers: getAuthHeaders(),
  };

  try {
    const deleteRequests = ids.map(async (id) => {
      const response = await axiosInstance.delete(`${path}/${id}`, config);
      return response.data;
    });

    const responseData = await Promise.all(deleteRequests);
    return responseData;
  } catch (error) {
    console.error(`Error deleting ${path}:`, error);
    return error.response?.data;
  }
};

const DeleteDataWithState = (path, id) => {
  const [data, setData] = useState(null);
  useEffect(() => {
    const config = {
      headers: getAuthHeaders(),
    };
    try {
      axiosInstance
        .delete(`${path}/${id}`, config)
        .then((res) => {
          setData(res.data.data);
        })
        .catch((error) => {
          console.error(`Error fetching ${path}s:`, error);
          setData(error.response?.data);
        });
    } catch (error) {
      console.error(`Error fetching ${path}s:`, error);
      setData(error.response?.data);
    }
  }, [path, id]);
  return [data, setData];
};

const DeleteWithBody = async (path, data, additionalConfig = {}) => {
  const config = {
    headers: {
      ...getAuthHeaders(),
      "Content-Type": "application/json",
      ...additionalConfig.headers,
    },
    data: data,
  };

  try {
    const response = await axiosInstance.delete(path, config);
    return {
      success: true,
      data: response.data,
      status: response.status,
      headers: response.headers,
    };
  } catch (error) {
    console.error(`Error deleting ${path}:`, error);
    return {
      success: false,
      status: error.response?.status || 500,
      message: error.response?.data?.message || error.message,
      data: error.response?.data,
      error: error,
    };
  }
};

const GetAllDataWithState = (path) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    setLoading(true);
    const config = {
      headers: getAuthHeaders(),
    };
    try {
      axiosInstance
        .get(path, config)
        .then((res) => {
          setData(res.data);
          setLoading(false);
        })
        .catch((error) => {
          setLoading(false);
          console.error(`Error fetching ${path}s:`, error);
          setData(error.response?.data);
        });
    } catch (error) {
      setLoading(false);
      console.error(`Error fetching ${path}s:`, error);
      setData(error.response?.data);
    }
  }, [path]);
  return [data, setData, loading, setLoading];
};

const GetAllData = async (path) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const res = await axiosInstance.get(path, config);
    // console.log('Getall data res:', res);
    return res;
  } catch (error) {
    console.error(`Error fetching ${path}s:`, error);
    return error.response?.data;
  }
};

const GetByIdData = async (path, id) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.get(`${path}/${id}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error fetching ${path}:`, error);
    return error.response?.data;
  }
};

const GetByIdDataWithState = (path, id) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    const config = {
      headers: getAuthHeaders(),
    };
    try {
      axiosInstance
        .get(`${path}/${id}`, config)
        .then((res) => {
          setData(res.data);
          setLoading(false);
        })
        .catch((error) => {
          setLoading(false);
          console.error(`Error fetching ${path}s:`, error);
          setData(error.response?.data);
        });
    } catch (error) {
      setLoading(false);
      console.error(`Error fetching ${path}s:`, error);
      setData(error.response?.data);
    }
  }, [path, id]);
  return [data, setData, loading, setLoading];
};

const ExportData = async (path, data) => {
  const config = {
    responseType: "blob",
    headers: getAuthHeaders(),
  };

  try {
    const response = await axiosInstance.post(path, data, config);
    return response;
  } catch (error) {
    console.error("Error exporting job data:", error);
  }
};

const UseCreateDataWithState = (path, data) => {
  const [resultData, setResultData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    const config = {
      headers: getAuthHeaders(),
    };
    try {
      axiosInstance
        .post(path, data, config)
        .then((res) => {
          setResultData(res.data);
          setLoading(false);
        })
        .catch((error) => {
          setLoading(false);
          console.error(`Error fetching ${path}:`, error);
          setResultData(error.response ? error.response.data : error.message);
        });
    } catch (error) {
      setLoading(false);
      console.error(`Error fetching ${path}:`, error);
      setResultData(error.message);
    }
  }, [path, data]);

  return [resultData, loading];
};

const DeleteclientData = async (path) => {
  const config = {
    headers: getAuthHeaders(),
  };
  try {
    const response = await axiosInstance.delete(`${path}`, config);
    return response.data;
  } catch (error) {
    console.error(`Error deleting ${path}:`, error);
    return error.response?.data;
  }
};

const GetFileToView = async (id) => {
  const config = {
    headers: getAuthHeaders(),
  };

  try {
    const response = await axiosInstance.post(`/get-ac-upload/${id}`, config);

    return {
      success: true,
      data: response.data.data,
      filename: response.data.filename,
      contentType: response.data.contentType,
    };
  } catch (error) {
    console.error("Error fetching authority file:", error);
    return {
      success: false,
      error: error.response?.data?.message || error.message,
    };
  }
};

const GetTrackPaperFileToView = async (id) => {
  const config = {
    headers: getAuthHeaders(),
  };

  try {
    const response = await axiosInstance.post(
      `/get-track-paper-upload/${id}`,
      config
    );

    return {
      success: true,
      data: response.data.data,
      filename: response.data.filename,
      contentType: response.data.contentType,
    };
  } catch (error) {
    console.error("Error fetching trackpaper file:", error);
    return {
      success: false,
      error: error.response?.data?.message || error.message,
    };
  }
};

const DownloadFile = async (path) => {
  const config = {
    responseType: "blob",
    headers: getAuthHeaders(),
  };

  try {
    const response = await axiosInstance.get(path, config);

    const contentDisposition = response.headers["content-disposition"];
    let filename = "download";

    if (contentDisposition) {
      const filenameMatch = contentDisposition.match(
        /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/
      );
      if (filenameMatch) {
        filename = filenameMatch[1].replace(/['"]/g, "");
      }
    }

    const url = window.URL.createObjectURL(response.data);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    link.style.display = "none";

    document.body.appendChild(link);
    link.click();

    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);

    return {
      success: true,
      filename: filename,
      message: "File downloaded successfully",
      data: response.data,
    };
  } catch (error) {
    console.error(`Error downloading file from ${path}:`, error);
    return {
      success: false,
      error: error.response?.data?.message || error.message,
      message: "Failed to download file",
    };
  }
};

const RestService = {
  CreateData,
  PostData,
  UpdateData,
  DeleteData,
  DeleteDataAll,
  DeleteDataWithState,
  GetAllDataWithState,
  GetByIdData,
  GetAllData,
  CreateDataWithState,
  UseCreateDataWithState,
  PartialUpdateData,
  GetByIdDataWithState,
  DeleteDataWithoutState,
  ExportData,
  DeleteclientData,
  DeleteWithBody,
  GetFileToView,
  GetTrackPaperFileToView,
  DownloadFile,
};

export default RestService;
