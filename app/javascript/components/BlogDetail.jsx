import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./BlogDetail.css";

const BlogDetail = () => {
    const { id } = useParams(); // get blog id from URL
    const navigate = useNavigate();
    const [blog, setBlog] = useState(null);
    const [loading, setLoading] = useState(true);
    const [liked, setLiked] = useState(false);
    const token = sessionStorage.getItem("token");
    const [message, setMessage] = useState("");
    const [showAuthModal, setShowAuthModal] = useState(false);
    const [newComment, setNewComment] = useState("");
    const [commentMessage, setCommentMessage] = useState("");


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


    //if blog liked by user
    useEffect(() => {
        if(!token) return;

        fetch(`/api/blog/${id}/is_liked`, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                setLiked(data.liked);
            })
            .catch(error => {
                console.error("Error checking like status:", error);
            });
    }, [id, token]);

    const handleLike = () => {

        if(!token){
            setMessage("Login to like this blog");


            sessionStorage.setItem("redirectAfterLogin", `/blogs/${id}`);
            /* setTimeout(() => {
                navigate("/login");
            }, 1000);  */ // gives time for message to appear
            setShowAuthModal(true);

            return;
        }

        fetch("/api/likes", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`
            },
            body: JSON.stringify({blog_id: id})
        })
            .then(res => res.json())
            .then(data => {
                if(data.message) {
                    setLiked(true);
                }
            })
            .catch(error => {
                console.error("Error liking blog:", error)
            });
    };

    const handleUnlike = () => {
        fetch(`/api/likes?blog_id=${id}`, {
            method: "DELETE",
            headers: {
                Authorization: `Bearer ${token}`
            }
        })
            .then(res => res.json())
            .then(data => {
                if (data.message) {
                    setLiked(false);
                }
            })
            .catch(error => {
                console.error("Error unliking blog:", error);
            });
    };

    const handleAddComment = (e) => {
        e.preventDefault();
        if (!token) {
            setCommentMessage("Please login to add a comment.");
            setShowAuthModal(true);
            return;
        }

        fetch(`/blog/${id}/comment`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`
            },
            body: JSON.stringify({ content: newComment })
        })
            .then(res => res.json())
            .then(data => {
                if (data.errors) {
                    setCommentMessage(data.errors.join(", "));
                } else {
                    // update comments locally so we don’t need to refetch blog
                    setBlog(prev => ({
                        ...prev,
                        comments: [...prev.comments, data]
                    }));
                    setNewComment("");
                    setCommentMessage("Comment added!");
                }
            })
            .catch(error => {
                console.error("Error adding comment:", error);
                setCommentMessage("Something went wrong.");
            });
    };


    if (loading) return <p>Loading blog...</p>;
    if (!blog) return <p>Blog not found.</p>;

    return (
        <div className="blog-detail-container">
            <button onClick={() => {
                if(token) {
                    navigate("/blogs/prefered_blogs");
                } else {
                    navigate("/");
                }
            }}>← Back</button>
            <h1>{blog.title}</h1>
            <p><strong>Author:</strong> {blog.author_name}</p>
            <p><strong>Tags:</strong> {blog.tags.join(", ")}</p>
            <hr />
            <p className="blog-content">{blog.content}</p>

            <h3>Add a Comment</h3>
            <form onSubmit={handleAddComment}>
                <textarea
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    placeholder="Write your comment..."
                    required
                />
                <button type="submit">Post Comment</button>
            </form>
            {commentMessage && <p className="comment-message">{commentMessage}</p>}

            <hr />
            <h3>Comments</h3>
            {blog.comments && blog.comments.length > 0 ? (
                blog.comments.map(comment => (
                    <div key={comment.id} className="comment">
                        <p><strong>{comment.user_name || "Unknown User"}:</strong> {comment.content}</p>
                        <small>{new Date(comment.created_at).toLocaleString()}</small>
                    </div>
                ))
            ) : (
                <p>No comments yet.</p>
            )}

            <div className="like-button-container">
                <button onClick={liked ? handleUnlike : handleLike}>
                    {liked ? "Unlike" : "Like"}
                </button>
                {message && <p className="login-tooltip">{message}</p>}
            </div>

            {/* Modal */}
            { showAuthModal && (
                <div className="modal-overlay">
                    <div className="modal-box">
                        <button className="close-btn" onClick={() => setShowAuthModal(false)}>×</button>
                        <h2>Welcome!</h2>
                        <p>Please choose an option to continue</p>
                        <button onClick={()=> navigate("/login")}>Login</button>
                        <button onClick={() => navigate("/signup")}>Sign Up</button>

                    </div>
                </div>
            )}
        </div>
    );
};

export default BlogDetail;
