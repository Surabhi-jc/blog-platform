import React, { useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
import BlogFeed from "./Blogfeed";


const PreferredBlogs = ({ user }) => {
    const [blogs, setBlogs] = useState([]);
    const [error, setError] = useState("");
    const [activeTab, setActiveTab] = useState("recommended");

    const token = localStorage.getItem("token");


        const fetchBlogs = async (tab) => {
            try{
                let url = tab === "recommended"
                    ? "/api/blog/prefered_blogs"
                    : "/user/following_blogs";

                const response= await fetch(url, {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });

                if(!response.ok) {
                    throw new Error("Failed to load blogs..");
                }

                const data= await response.json();
                setBlogs(data.blogs || []);

            }catch(err){
                setError(err.message);
            }
        };


        // useEffect for initial fetch + polling
        useEffect(() => {
            if (!token) return;

            fetchBlogs(activeTab);

            // Poll every 3 minutes (180000 ms)
            const intervalId = setInterval(() => fetchBlogs(activeTab), 180000);

            // Cleanup on unmount
            return () => clearInterval(intervalId);
        }, [token, activeTab]);



    const navigate = useNavigate();

    const handleCreateBlog = () => {
        navigate('/Blog');
    };



    return (
        <div>
            <div className="d-flex align-items-center justify-content-between mb-3 mt-2 mx-5">

                <div className="flex-grow-1 text-start">
                    {user && <h5 className="title-style">Hello, {user.name}!</h5>}
                </div>

                <div className="flex-grow-1 text-center">
                    <h5 className="title-style">Blogs for you</h5>
                </div>
                <div className="flex-grow-1 text-end ">
                    <button
                        type="button"
                        onClick={handleCreateBlog}
                        className="btn btn-success"
                    >
                        Create New Blog
                    </button>
                </div>
            </div>

            {/* Tabs */}
            <ul className="nav nav-tabs mb-3 justify-content-center">
                <li className="nav-item">
                    <button
                        className={`nav-link ${activeTab === "recommended" ? "active" : ""}`}
                        onClick={() => setActiveTab("recommended")}
                    >
                        Recommended
                    </button>
                </li>
                <li className="nav-item">
                    <button
                        className={`nav-link ${activeTab === "following" ? "active" : ""}`}
                        onClick={() => setActiveTab("following")}
                    >
                        Following
                    </button>
                </li>
            </ul>

            <BlogFeed blogs={blogs} setBlogs={setBlogs} showEdit={false} />

        </div>

    );
};

export default PreferredBlogs;