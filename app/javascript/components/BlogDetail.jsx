import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./BlogDetail.css";

const BlogDetail = () => {
    const { id } = useParams(); // get blog id from URL
    const navigate = useNavigate();
    const [blog, setBlog] = useState(null);
    const [loading, setLoading] = useState(true);
    const [liked, setLiked] = useState(false);
    const [message, setMessage] = useState("");
    const [showAuthModal, setShowAuthModal] = useState(false);
    const [newComment, setNewComment] = useState("");
    const [commentMessage, setCommentMessage] = useState("");
    const [replyingTo, setReplyingTo] = useState(null);
    const [replyContent, setReplyContent] = useState("");
    const [user, setUser] = useState(null);
    const [comments, setComments] = useState([]);

    const token = sessionStorage.getItem("token");

    // Fetch current user
    useEffect(() => {
        if (!token) return;

        fetch("/user/me", {
            headers: { Authorization: `Bearer ${token}` },
        })
            .then(res => res.json())
            .then(data => setUser(data))
            .catch(err => console.error("Error fetching user:", err));
    }, [token]);


    useEffect(() => {
        fetch(`/api/blog/${id}`)
            .then((res) => res.json())
            .then((data) => {
                setBlog(data);
                setComments(data.comments || []); // store comments separately
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

    const handleAddComment = (e, parentId = null, content) => {
        e && e.preventDefault();
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
            body: JSON.stringify({ content, parent_comment_id: parentId })
        })
            .then(res => res.json())
            .then(data => {
                if (data.errors) {
                    setCommentMessage(data.errors.join(", "));
                    return;
                }

                // If top-level comment, append to comments
                if (!parentId) {
                    setComments(prev => [...(prev || []), data]);
                } else {
                    // Insert reply recursively
                    const addReplyRecursively = (arr) =>
                        arr.map(c => {
                            if (c.id === parentId) {
                                return { ...c, replies: [...(c.replies || []), data] };
                            } else if (c.replies && c.replies.length) {
                                return { ...c, replies: addReplyRecursively(c.replies) };
                            }
                            return c;
                        });

                    setComments(prev => addReplyRecursively(prev || []));
                }

                setNewComment("");
                setCommentMessage("Comment added!");
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
            <hr />

            <div style={{ display: "flex", alignItems: "center", gap: "15px" }}>
                <span role="img" style={{ fontSize: "22px", cursor: "pointer" }}>💬</span>
                <span
                    style={{
                        fontSize: "22px",
                        cursor: "pointer",
                        color: liked ? "red" : "black"
                    }}
                    onClick={liked ? handleUnlike : handleLike}
                >
                 {liked ? "♥" : "♡"}
                </span>
            </div>


            <form onSubmit= {(e) => handleAddComment(e, null, newComment)}>
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
            {comments && comments.length > 0 ? (
                comments.map(comment => (
                    <Comment
                        key={comment.id}
                        comment={comment}
                        handleAddComment={handleAddComment}
                        token={token}
                        setShowAuthModal={setShowAuthModal}
                        setCommentMessage={setCommentMessage}
                        currentUserId={user?.id}
                        setComments={setComments}    // pass setter down
                    />
                ))
            ) : (
                <p>No comments yet.</p>
            )}



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

const Comment = ({ comment, handleAddComment, token, setShowAuthModal, setCommentMessage, currentUserId, setComments  }) => {
    const [replying, setReplying] = useState(false);
    const [replyContent, setReplyContent] = useState("");

    const handleReply = (e) => {
        handleAddComment(e, comment.id, replyContent);
        setReplyContent("");
        setReplying(false);
    };

    // recursive helper to mark deleted in nested arrays
    const markDeletedRecursively = (arr, commentId) =>
        (arr || []).map(c => {
            if (c.id === commentId) return { ...c, deleted_at: new Date().toISOString(), content: null };
            return { ...c, replies: c.replies ? markDeletedRecursively(c.replies, commentId) : [] };
        });

    const handleDelete = async (e, commentId) => {
        e.stopPropagation();

        const confirmDelete = window.confirm("Are you sure you want to delete this comment?");
        if (!confirmDelete) return;

        try {
            const res = await fetch(`/api/blog/${comment.blog_id}/comments/${commentId}`, {
                method: "DELETE",
                headers: { Authorization: `Bearer ${token}` },
            });

            if (res.ok) {
                setComments(prev => markDeletedRecursively(prev, commentId));
            } else {
                const data = await res.json();
                setCommentMessage(data.errors?.join(", ") || "Failed to delete comment.");
            }
        } catch (err) {
            console.error("Error deleting comment:", err);
            setCommentMessage("Something went wrong.");
        }
    };

    return (
        <div className="comment">
            <p><strong>{comment.user_name || "Unknown User"}:</strong> {" "}
                {comment.deleted_at ? (
                    <em>This comment was deleted by the author</em>
                ) : (
                    comment.content
                )} </p>

            { !comment.deleted_at && (
            <button onClick={() => {
                if (!token) {
                    setCommentMessage("Please login to reply.");
                    setShowAuthModal(true);
                    return;
                }
                setReplying(!replying);
            }}>
                💬 Reply
            </button>
            )}

            {/* Delete button (only for own comment) */}
            {comment.user_id === currentUserId && !comment.deleted_at && (
                <button
                    className="delete-icon"
                    onClick={(e) => handleDelete(e, comment.id)}
                    title="Delete comment"
                >
                    🗑️
                </button>
            )}

            {replying && (
                <form onSubmit={handleReply}>
                    <textarea
                        value={replyContent}
                        onChange={(e) => setReplyContent(e.target.value)}
                        placeholder="Write a reply..."
                        required
                    />
                    <button type="submit">Post Reply</button>
                </form>
            )}

            {comment.replies && comment.replies.map(reply => (
                <div key={reply.id} className="reply">
                    <Comment
                        comment={reply}
                        handleAddComment={handleAddComment}
                        token={token}
                        setShowAuthModal={setShowAuthModal}
                        setCommentMessage={setCommentMessage}
                        currentUserId={currentUserId}
                        setComments={setComments}
                    />
                </div>
            ))}
        </div>
    );
};

export default BlogDetail;
