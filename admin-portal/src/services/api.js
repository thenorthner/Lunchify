import axios from "axios";

const apiBaseUrl = process.env.REACT_APP_API_URL || `${window.location.protocol}//${window.location.hostname}:3001/api`;

const api = axios.create({
  baseURL: apiBaseUrl,
  withCredentials: true,
  headers: {
    "X-Requested-With": "XMLHttpRequest"
  }
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("adminToken");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
