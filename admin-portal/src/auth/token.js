export function setToken(token) {
  localStorage.setItem("adminToken", token);
}

export function getToken() {
  return localStorage.getItem("adminToken");
}

export function logout() {
  localStorage.removeItem("adminToken");
  window.location.replace("/login");
}
