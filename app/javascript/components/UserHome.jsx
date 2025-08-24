import React, { useEffect, useState} from "react";
import "./LandingPage.css";



import { useNavigate } from "react-router-dom";

const PreferredBlogs = ({ user }) => {
    const [blogs, setBlogs] = useState([]);
    const [error, setError] = useState("");
   // const [user, setUser] = useState(null);

    const token = sessionStorage.getItem("token");

    {/*}  useEffect(() => {
        fetch("/user/me", {
            headers: { Authorization: `Bearer ${token}` }
        })
            .then(res => res.json())
            .then(data => setUser(data))
            .catch(err => console.error("Failed to load user:", err));
    }, []);  */}


    useEffect(() => {
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

        if(token) {
            fetchPreferredBlogs();
        }

    }, [token]);

    const navigate = useNavigate();

    const handleCreateBlog = () => {
        navigate('/Blog');
    }



    return (
        <div>

            {user && <h1>Hello, {user.name}!</h1>}
            <h1>Recommended for you</h1>
            <button onClick={handleCreateBlog} className= "create-blog" >Create Blog</button>



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