import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./BlogDetail.css";

const BlogDetail = () => {
    const { id } = useParams(); // get blog id from URL
    const navigate = useNavigate();
    const [blog, setBlog] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetch(`/api/blog/${id}`)
            .then((res) => res.json())
            .then((data) => {
                setBlog(data);
                setLoading(false);
            })
            .catch((error) => {
                console.error("Error fetching blog:", error);
                setLoading(false);
            });
    }, [id]);

    if (loading) return <p>Loading blog...</p>;
    if (!blog) return <p>Blog not found.</p>;

    return (
        <div className="blog-detail-container">
            <button onClick={() => navigate("/")}>← Back</button>
            <h1>{blog.title}</h1>
            <p><strong>Author:</strong> {blog.author_name}</p>
            <p><strong>Tags:</strong> {blog.tags.join(", ")}</p>
            <hr />
            <p className="blog-content">{blog.content}</p>
        </div>
    );
};

export default BlogDetail;
