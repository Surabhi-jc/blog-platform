import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import LandingPage from "./components/LandingPage";
import BlogDetail from "./components/BlogDetail";
import SignupForm from "./components/SignupForm";
import LoginForm from "./components/LoginForm";
import UserHome from "./components/UserHome";
import CreateBlogPage from "./components/CreateBlogPage";
import ProfilePage from "./components/ProfilePage";
import Navbar from "./components/Navbar";

const App = () => {

    const [user, setUser] = useState(null);
    const token = sessionStorage.getItem("token");

    useEffect(() => {

        if (!token) return;


            fetch("/user/me", {
                headers: { Authorization: `Bearer ${token}` },
            })
                .then((res) => res.ok && res.json())
                .then((data) => setUser(data))
                .catch(() => setUser(null));

    }, [token]);

    const handleLogout = () => {
        sessionStorage.removeItem("token");
        setUser(null);

    };

    return (
        <Router>
            <Navbar user={user} onLogout={handleLogout} />

            <Routes>
                <Route path="/" element={<LandingPage />} />
                <Route path="/blogs/:id" element={<BlogDetail />} />
                <Route path="/signup" element={<SignupForm />} />
                <Route path="/login" element={<LoginForm setUser={setUser}/>} />
                <Route path="/blogs/prefered_blogs" element={<UserHome user={user}/>} />
                <Route path="/blog" element={<CreateBlogPage />} />
                <Route path="/profile" element={<ProfilePage />} />
                <Route path="/blogs/:id/edit" element={<CreateBlogPage />} />
            </Routes>
        </Router>
    );
};

export default App;
