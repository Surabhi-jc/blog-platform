import React, {useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
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








            {blogs.length === 0 ? (
                <p>Loading blogs..please wait</p>
            ): (
                <div className="blog-container">
                    <h2 className="section-title">Latest Blogs</h2>
                    {blogs.map((blog) => (
                        <div className="blog-card" key={blog.id} onClick={() => navigate(`/blogs/${blog.id}`)}>
                            <h2>{blog.title}</h2>
                            <p>Author: {blog.author_name}</p>
                            <p>Tags: {blog.tags.join(",")}</p> {/*Takes an array and combines it into a single string*/}
                            <p>Content: {blog.content}</p>
                            <div className="likes-row" aria-label={`Likes: ${blog.likes_count}`}>
                                <svg
                                    className="star-icon"
                                    viewBox="0 0 24 24"
                                    role="img"
                                    aria-hidden="true"
                                >
                                    <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
                                </svg>
                                <span className="likes-count">{blog.likes_count}</span>
                            </div>






                        </div>
                    ))}
                </div>
            )}
        </div>


    );
};






export default LandingPage;

