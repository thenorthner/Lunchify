import axios from "axios";

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || "http://localhost:3001/api", // BACKEND
  withCredentials: true,
  headers: {
    "X-Requested-With": "XMLHttpRequest"
  }
});

export default api;
