import { useState, useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import api from "./services/api";

function App() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("adminToken");
    const loggedIn = localStorage.getItem("adminLoggedIn");

    if (!token || !loggedIn || token === "undefined") {
      setSession(null);
      setLoading(false);
      return;
    }

    api.get("/auth/me")
      .then((res) => {
        setSession(res.data);
      })
      .catch((err) => {
        // Token invalid/expired — clear everything
        localStorage.removeItem("adminToken");
        localStorage.removeItem("adminLoggedIn");
        localStorage.removeItem("adminRole");
        localStorage.removeItem("adminCanteenId");
        setSession(null);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  if (loading) {
    return <div>Loading session...</div>;
  }

  const ADMIN_ROLES = ['canteen_admin', 'hr_admin', 'it_admin'];
  const valid = session?.user && ADMIN_ROLES.includes(session.user.role);

  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/"
          element={valid ? <Navigate to="/dashboard" replace /> : <Login />}
        />
        <Route
          path="/dashboard"
          element={valid ? <Dashboard user={session.user} /> : <Navigate to="/" replace />}
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
