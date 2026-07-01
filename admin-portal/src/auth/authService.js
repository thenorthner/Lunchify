import axios from "axios";

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || "http://localhost:3001/api",
  withCredentials: true,
});

export const login = async (id, password) => {
  const res = await api.post("/auth/admin/login", {
    employeeId: id,
    password,
  });
  return res.data;
};
