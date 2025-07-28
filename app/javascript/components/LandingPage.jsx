import React, {useEffect, useState} from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";

const LandingPage = () => {
  const [blogs, setBlogs] = useState([]);

  //fetch blogs
  useEffect(()=> {
    fetch("/api/blog/show")
    .then((response)=> response.json())
    .then((data) => {
      setBlogs(data);
    })
    .catch((error) => {
      console.error("Error fetching blogs:", error);
    });

  }, []);

  const navigate = useNavigate();


  return (
    <div>
      <h1>Latest Blogs</h1>
      <div>
        <button onClick= {() => navigate("/signup")}>Sign up</button>
        <button onClick= {() => navigate("/login")}>Login</button>

      </div>


      {blogs.length === 0 ? (
        <p>Loading blogs..please wait</p>
      ): (
          <div className="blog-container">
            {blogs.map((blog) => (
          <div className="blog-card" key={blog.id} onClick={() => navigate(`/blogs/${blog.id}`)}>
          <h2>{blog.title}</h2>
            <p>Author: {blog.author_name}</p>
            <p>Tags: {blog.tags.join(",")}</p> {/*Takes an array and combines it into a single string*/}
          <p>Content: {blog.content}</p>


          </div>
        ))}
          </div>
      )}
    </div>

  );
};



export default LandingPage;
