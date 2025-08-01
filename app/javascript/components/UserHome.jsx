import React, { useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";

const PreferredBlogs = () => {
    const [blogs, setBlogs] = useState([]);
    const [error, setError] = useState("");


    useEffect(() => {
        const fetchPreferredBlogs = async () => {
            try{
                const token = sessionStorage.getItem("token");

                const response= await fetch("/api/blog/prefered_blogs", {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });

                if(!response.ok) {
                    throw new Error("Failed to load blogs..");
                }

                const data= await response.json();
                console.log("API response:", data);
                setBlogs(data.blogs);

            }catch(err){
                setError(err.message);
            }
        };
        fetchPreferredBlogs();
    }, []);

    const navigate = useNavigate();

    return (
        <div>
            <h1>Recommended for you</h1>



            {blogs.length === 0 ? (
                <p>Loading blogs..please wait</p>
            ): (
                <div className="blog-container">
                    {blogs.map((blog) => (
                        <div className="blog-card" key={blog.id} onClick={() => navigate(`/blogs/${blog.id}`)}>
                            <h2>{blog.title}</h2>
                            <p>Author: {blog.author_name}</p>
                            <p>Tags: {Array.isArray(blog.tags) ? blog.tags.join(", ") : "No tags"}</p> {/*Takes an array and combines it into a single string*/}
                            <p>Content: {blog.content}</p>


                        </div>
                    ))}
                </div>
            )}
        </div>

    );
};

export default PreferredBlogs;