import React, {useEffect, useState} from "react";
import "./LandingPage.css";

const LandingPage = () => {
  const [blogs, setBlogs] = useState([]);

  //fetch blogs
  useEffect(()=> {
    fetch("/blog/show")
    .then((response)=> response.json())
    .then((data) => {
      setBlogs(data);
    })
    .catch((error) => {
      console.error("Error fetching blogs:", error);
    });

  }, []);

  return (
    <div>
      <h1>Latest Blogs</h1>
      <div>
        <button onClick= {() => window.location.href = "/signup"}>Sign up</button>
        <button onClick= {() => window.location.href = "/login"}>Login</button>

      </div>


      {blogs.length === 0 ? (
        <p>Loading blogs..please wait</p>
      ): (
          <div className="blog-container">
            {blogs.map((blog) => (
          <div className="blog-card" key={blog.id}>
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
