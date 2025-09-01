// BlogFeed.js
import React from "react";
import { useNavigate } from "react-router-dom";
import "./LandingPage.css";  // reuse same styles


const BlogFeed = ({ blogs,setBlogs, showEdit = false, userId, isAdmin=false, showDeletedInfo = false}) => {
    const navigate = useNavigate();
    const token = sessionStorage.getItem("token");


    if (blogs === null) {
        // Blogs not loaded yet
        return <p>Loading blogs..please wait</p>;
    }


    if (blogs.length === 0) {
        // Blogs loaded, but empty
        return <p>No blogs to show.</p>;
    }




    const handleDelete = async (e, blogId) => {
        e.stopPropagation(); // prevent card click navigation


        const confirmDelete = window.confirm("Are you sure you want to delete this blog?");
        if (!confirmDelete) return;


        try {
            const res = await fetch(`/api/blog/${blogId}`, {
                method: "DELETE",
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            if (res.ok) {
                // remove blog from state
                setBlogs((prevBlogs) => prevBlogs.filter((b) => b.id !== blogId));
                alert("Blog deleted successfully!");
            } else {
                const err = await res.json();
                alert(err.error || "Failed to delete blog");
            }
        } catch (err) {
            console.error("Error deleting blog:", err);
            alert("Error deleting blog");
        }
    };






    const handleRestore = async (e, blogId) => {
        e.stopPropagation();


        const confirmRestore = window.confirm("Are you sure you want to restore this blog?");
        if (!confirmRestore) return;


        try {
            const res = await fetch(`/api/blog/${blogId}/restore`, {
                method: "PATCH",
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });


            if (res.ok) {
                // remove blog from deleted list
                setBlogs((prevBlogs) => prevBlogs.filter((b) => b.id !== blogId));
                alert("Blog restored successfully!");
            } else {
                const err = await res.json();
                alert(err.error || "Failed to restore blog");
            }
        } catch (err) {
            console.error("Error restoring blog:", err);
            alert("Error restoring blog");
        }
    };




    return (
        <div className="blog-container">
            {blogs.map((blog) => (
                <div
                    className="blog-card"
                    key={blog.id}
                    onClick={() => navigate(`/blogs/${blog.id}`,{ state: { from: location.pathname } })}
                >
                    <div className="action-icons">
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
                            <img
                            src="/images/pen.png"   // put your image in public/images/edit.png
                            alt="Edit"
                            className="icon-img"
                            />
                        </button>
                    )}


                    {(!showDeletedInfo && isAdmin === true || (userId && userId === blog.user_id)) && (
                        <button
                            className="delete-icon"
                            title="Delete blog"
                            aria-label="Delete blog"
                            onClick={(e) => handleDelete(e, blog.id)}
                        >
                            <img
                                src="/images/bin.png"   // put your image in public/images/edit.png
                                alt="Edit"
                                className="icon-img"
                            />
                        </button>
                    )}
                        {showDeletedInfo && (
                            <button
                                className="restore-icon"
                                title="Restore blog"
                                aria-label="Restore blog"
                                onClick={(e) => handleRestore(e, blog.id)}
                            >
                                <img
                                    src="/images/reset.png"   // put your image in public/images/edit.png
                                    alt="Edit"
                                    className="icon-img"
                                />
                            </button>
                        )}
                    </div>






                    <h2>{blog.title}</h2>
                    <p><span className={"fw-bold"}>Author: </span> &nbsp;{blog.author_name}</p>
                    <p><span className={"fw-bold"}>Tags:</span> &nbsp;  {Array.isArray(blog.tags) ? blog.tags.join(", ") : "No tags"}</p>
                    <p><span className="fw-bold">Content:</span>&nbsp;
                        {blog.content.length > 150
                            ? blog.content.slice(0, 150) + "..."
                            : blog.content}</p>
                    <div className="likes_comments-row">
                        <img src="/images/red-heart.png" alt="Heart" className="red-heart-icon" />
                        <span className="likes-count">{blog.likes_count}</span>


                        <img src="/images/comments.png" alt="comments" className="comment-icon" />
                        <span className="comments-count">{blog.comments_count}</span>
                    </div>


                    {showDeletedInfo && blog.deleted_by && (
                        <p className="deleted-info">
                            <span className="deleted-by"><strong>Deleted by: </strong>{blog.deleted_by.name}</span>
                            <span className="deleted-on"><strong>Deleted On: </strong>{new Date(blog.deleted_at).toLocaleString()}</span>
                        </p>
                    )}







                </div>
            ))}
        </div>
    );
};


export default BlogFeed;

