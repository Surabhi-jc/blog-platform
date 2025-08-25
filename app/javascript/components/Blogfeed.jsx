// BlogFeed.js
import React from "react";
import { useNavigate } from "react-router-dom";
import "./LandingPage.css";  // reuse same styles

const BlogFeed = ({ blogs, showEdit = false }) => {
    const navigate = useNavigate();

    if (!blogs || blogs.length === 0) {
        return <p>Loading blogs..please wait</p>;
    }

    return (
        <div className="blog-container">
            {blogs.map((blog) => (
                <div
                    className="blog-card"
                    key={blog.id}
                    onClick={() => navigate(`/blogs/${blog.id}`)}
                >
                    {showEdit && (
                        <button
                            className="edit-icon"
                            title="Edit blog"
                            aria-label="Edit blog"
                            onClick={(e) => {
                                e.stopPropagation();              // doesnt trigger card click
                                navigate(`/blogs/${blog.id}/edit`);
                            }}
                        >
                            ✏️
                        </button>
                    )}

                    <h2>{blog.title}</h2>
                    <p>Author: {blog.author_name}</p>
                    <p>Tags: {Array.isArray(blog.tags) ? blog.tags.join(", ") : "No tags"}</p>
                    <p>Content: {blog.content}</p>
                    <div className="likes-row" aria-label={`Likes: ${blog.likes_count}`}>
                        <svg
                            className="star-icon"
                            viewBox="0 0 24 24"
                            role="img"
                            aria-hidden="true"
                        >
                            <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z" />
                        </svg>
                        <span className="likes-count">{blog.likes_count}</span>
                    </div>
                </div>
            ))}
        </div>
    );
};

export default BlogFeed;
