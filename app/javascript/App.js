import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import LandingPage from "./components/LandingPage";
import BlogDetail from "./components/BlogDetail";
import SignupForm from "./components/SignupForm";
import LoginForm from "./components/LoginForm";
import UserHome from "./components/UserHome";
import CreateBlogPage from "./components/CreateBlogPage";
import ProfilePage from "./components/ProfilePage";
import Navbar from "./components/Navbar";
import AdminDashboard from "./components/AdminDashboard";

const App = () => {

    const [user, setUser] = useState(null);
    const token = localStorage.getItem("token");


    useEffect(() => {

        if (!token)
            return;

            fetch("/user/me", {
                headers: { Authorization: `Bearer ${token}` },
            })
                .then((res) => res.ok && res.json())
                .then((data) => setUser(data))
                .catch(() => setUser(null));

    }, [token]);

    const handleLogout = () => {
        localStorage.removeItem("token");
        setUser(null);
    };

    const ProtectedRoute = ({ children }) => {
        return token ? children : <Navigate to="/login" replace />;
    };

    const PublicRoute = ({ children }) => {
        return token ? <Navigate to="/blogs/prefered_blogs" replace /> : children;
    };

    return (
        <Router>
            <Navbar user={user} onLogout={handleLogout} />

            <Routes>
                <Route path="/" element={<PublicRoute><LandingPage /></PublicRoute>} />
                <Route path="/blogs/:id" element={<BlogDetail />} />
                <Route path="/signup" element={<SignupForm setUser={setUser}/>} />
                <Route path="/login" element={<LoginForm setUser={setUser}/>} />

                <Route path="/blogs/prefered_blogs" element={<ProtectedRoute><UserHome user={user}/></ProtectedRoute>} />
                <Route path="/blog" element={<ProtectedRoute><CreateBlogPage /></ProtectedRoute>} />
                <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
                <Route path="/blogs/:id/edit" element={<ProtectedRoute><CreateBlogPage /></ProtectedRoute>} />
                <Route path="/admin" element={<ProtectedRoute><AdminDashboard /></ProtectedRoute>} />

            </Routes>
        </Router>
    );
};

export default App;
