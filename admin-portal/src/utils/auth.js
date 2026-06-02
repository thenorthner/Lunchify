export const isAdminLoggedIn = () => {
  return !!localStorage.getItem("adminToken");
};
