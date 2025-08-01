import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LandingPage from "./components/LandingPage";
import BlogDetail from "./components/BlogDetail";
import SignupForm from "./components/SignupForm";
import LoginForm from "./components/LoginForm";
import UserHome from "./components/UserHome";

const App = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<LandingPage />} />
                <Route path="/blogs/:id" element={<BlogDetail />} />
                <Route path="/signup" element={<SignupForm />} />
                <Route path="/login" element={<LoginForm />} />
                <Route path="/blogs/prefered_blogs" element={<UserHome />} />
            </Routes>
        </Router>
    );
};

export default App;
