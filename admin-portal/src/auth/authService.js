import axios from "axios";

const api = axios.create({
  baseURL: "http://172.16.19.193:3001/api",
});

export const login = async (id, password) => {
  const res = await api.post("/auth/admin/login", {
    employeeId: id,
    password,
  });
  return res.data;
};
