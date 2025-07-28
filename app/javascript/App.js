import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LandingPage from "./components/LandingPage";
import BlogDetail from "./components/BlogDetail";
import SignupForm from "./components/SignupForm";

const App = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<LandingPage />} />
                <Route path="/blogs/:id" element={<BlogDetail />} />
                <Route path="/signup" element={<SignupForm />} />
            </Routes>
        </Router>
    );
};

export default App;
