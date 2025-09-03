import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "./ProfilePage.css";
import BlogFeed from "./Blogfeed";

const ProfilePage = () => {
    const [user, setUser] = useState(null);
    const [name, setName] = useState("");
    const [message, setMessage] = useState("");
    const [blogs, setBlogs] = useState([]);
    const [activeSection, setActiveSection] = useState("welcome"); // "welcome", "edit", "blogs", "following"
    const navigate = useNavigate();
    const [following, setFollowing] = useState([]);

    const token = localStorage.getItem("token");

    // Fetch current user
    useEffect(() => {
        const fetchUser = async () => {
            const res = await fetch("/user/me", {
                headers: { Authorization: `Bearer ${token}` },
            });
            if (res.ok) {
                const data = await res.json();
                setUser(data);
                setName(data.name);
            }
        };
        fetchUser();
    }, [token]);

    // User blogs
    useEffect(() => {
        const fetchUserBlogs = async () => {
            const res = await fetch("/user/my_blogs", {
                headers: { Authorization: `Bearer ${token}` },
            });
            if (res.ok) {
                const data = await res.json();
                setBlogs(data);
            }
        };
        if (token) fetchUserBlogs();
    }, [token]);

    useEffect(() => {
        const fetchFollowing = async () => {
            if (!user?.id || !token) return;
            try {
                const res = await fetch(`/user/${user.id}/following`, {
                    headers: { Authorization: `Bearer ${token}` },
                });
                if (!res.ok) {
                    setFollowing([]);
                    return;
                }
                const data = await res.json();
                // Support multiple shapes: array, { following: [...] }, { followers: [...] }
                const list = Array.isArray(data)
                    ? data
                    : data.following || data.followers || data;
                setFollowing(Array.isArray(list) ? list : []);
            } catch (err) {
                console.error("Error fetching following authors:", err);
                setFollowing([]);
            }
        };

        if (activeSection === "following") {
            fetchFollowing();
        }
    }, [activeSection, token, user]);

    const handleSave = async () => {
        try {
            const res = await fetch(`/user/update`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ user: { name } }),
            });

            if (res.ok) {
                const updatedUser = await res.json();
                setUser(updatedUser);
                setMessage("Profile updated successfully!");
                setActiveSection("welcome"); // go back to welcome after saving
            } else {
                setMessage("Failed to update profile.");
            }
        } catch (err) {
            console.error(err);
            setMessage("Error updating profile.");
        }
    };

    const handleUnfollow = async (authorId) => {
        if (!token) {
            setMessage("Please login to manage follows.");
            return;
        }
        try {
            const res = await fetch(`/user/${authorId}/unfollow`, {
                method: "DELETE",
                headers: { Authorization: `Bearer ${token}` },
            });
            const data = await res.json().catch(() => ({}));
            if (res.ok) {
                // remove from UI
                setFollowing((prev) => prev.filter((a) => a.id !== authorId));
                setMessage(data.message || "Unfollowed successfully");
            } else {
                setMessage(data.error || data.errors?.join(", ") || "Failed to unfollow");
            }
        } catch (err) {
            console.error("Error unfollowing author:", err);
            setMessage("Error unfollowing author.");
        }
    };


    return (
        <div className="profile-page">
            {/* Left Sidebar */}
            <div className="profile-sidebar">
                <button onClick={() => setActiveSection("edit")} className={"btn btn-light"}>Edit Profile</button>
                <button onClick={() => setActiveSection("blogs")} className={"btn btn-light"}>My Blogs</button>
                <button onClick={() => setActiveSection("following")} className={"btn btn-light"}>
                    Following Authors
                </button>

            </div>

            {/* Right Content Area */}
            <div className="profile-content">
                {activeSection === "welcome" && (
                    <div>
                        <h2>Welcome, {user?.name}</h2>
                        <p>Select an option from the left.</p>
                    </div>
                )}

                {activeSection === "edit" && (
                    <div className="edit-container">
                        <div className="profile-form">
                        <h2>Edit Profile</h2>
                        {user ? (
                            <>
                                <label>Name: </label>
                                <input
                                    type="text"
                                    value={name}
                                    onChange={(e) => setName(e.target.value)}
                                />
                                <button onClick={handleSave}>Save</button>
                                {message && <p>{message}</p>}
                            </>
                        ) : (
                            <p>Loading...</p>
                        )}
                    </div>
                    </div>
                )}

                {activeSection === "blogs" && (
                    <div>
                        <h2>Your Blogs</h2>
                        <BlogFeed blogs={blogs} showEdit={true} isAdmin={user.is_admin} setBlogs={setBlogs} userId={user?.id} />
                    </div>
                )}

                {activeSection === "following" && (
                    <div>
                        <h2>Authors You Follow</h2>
                        {following.length > 0 ? (
                            <ul className="list-unstyled following-list mt-4">
                                {following.map((author) => (
                                    <li key={author.id} className="author-item row align-items-center g-1 py-2">
                                        <div className="col">
                                            <span className="author-name">{author.name}</span>
                                        </div>
                                        <div className="col-auto">
                                            <button className="btn btn-sm btn-outline-danger" onClick={() => handleUnfollow(author.id)}>
                                                Unfollow
                                            </button>
                                        </div>
                                    </li>
                                ))}
                            </ul>
                        ) : (
                            <p>You are not following any authors yet.</p>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
};

export default ProfilePage;
