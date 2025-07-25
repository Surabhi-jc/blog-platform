import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LandingPage from "./components/LandingPage";
import BlogDetail from "./components/BlogDetail";

const App = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<LandingPage />} />
                <Route path="/blogs/:id" element={<BlogDetail />} />
            </Routes>
        </Router>
    );
};

export default App;
