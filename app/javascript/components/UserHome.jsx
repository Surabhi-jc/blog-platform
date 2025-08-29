import React, { useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
import BlogFeed from "./Blogfeed";


const PreferredBlogs = ({ user }) => {
    const [blogs, setBlogs] = useState([]);
    const [error, setError] = useState("");
   // const [user, setUser] = useState(null);

    const token = sessionStorage.getItem("token");


        const fetchPreferredBlogs = async () => {
            try{
                const response= await fetch("/api/blog/prefered_blogs", {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });

                if(!response.ok) {
                    throw new Error("Failed to load blogs..");
                }

                const data= await response.json();
                setBlogs(data.blogs);

            }catch(err){
                setError(err.message);
            }
        };


        // useEffect for initial fetch + polling
        useEffect(() => {
            if (!token) return;

            // Initial fetch
            fetchPreferredBlogs();

            // Poll every 3 minutes (180000 ms)
            const intervalId = setInterval(fetchPreferredBlogs, 180000);

            // Cleanup on unmount
            return () => clearInterval(intervalId);
        }, [token]);



    const navigate = useNavigate();

    const handleCreateBlog = () => {
        navigate('/Blog');
    };



    return (
        <div>

            {user && <h1>Hello, {user.name}!</h1>}
            <h1 className={"text-center"}>Recommended for you</h1>
            <button type="button" onClick={handleCreateBlog} className= "create-blog">Create Blog</button>

            <BlogFeed blogs={blogs} setBlogs={setBlogs} showEdit={false} />

        </div>

    );
};

export default PreferredBlogs;