import React, {useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
import BlogFeed from "./Blogfeed";

import Navbar from "./Navbar";


const LandingPage = () => {
    const [blogs, setBlogs] = useState([]);
    const [user, setUser] = useState(null);

    //fetch blogs
    useEffect(()=> {
        const fetchBlogs = () => {
            fetch("/api/blog/show")
                .then((response) => response.json())
                .then((data) => {
                    setBlogs(data);
                })
                .catch((error) => {
                    console.error("Error fetching blogs:", error);
                });
        };
        // Initial fetch
        fetchBlogs();

        // Poll every 3 minutes
        const intervalId = setInterval(fetchBlogs, 180000);

        // Cleanup
        return () => clearInterval(intervalId);

    }, []);

    const navigate = useNavigate();


    return (


        <div>


            <h2 className="section-title text-center fw-normal mt-4">Latest Blogs</h2>

            <BlogFeed blogs={blogs} setBlogs={setBlogs} showEdit={false} />
        </div>


    );
};






export default LandingPage;

