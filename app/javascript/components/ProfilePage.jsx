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

    const token = sessionStorage.getItem("token");

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



    return (
        <div className="profile-page">
            {/* Left Sidebar */}
            <div className="profile-sidebar">
                <button onClick={() => setActiveSection("edit")}>Edit Profile</button>
                <button onClick={() => setActiveSection("blogs")}>My Blogs</button>
                <button onClick={() => setActiveSection("following")}>
                    Following Authors
                </button>

            </div>

            {/* Right Content Area */}
            <div className="profile-content">
                {activeSection === "welcome" && (
                    <div>
                        <h2>Welcome back, {user?.name}</h2>
                        <p>Select an option from the left.</p>
                    </div>
                )}

                {activeSection === "edit" && (
                    <div>
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
                )}

                {activeSection === "blogs" && (
                    <div>
                        <h2>Your Blogs</h2>
                        <BlogFeed blogs={blogs} showEdit={true} setBlogs={setBlogs} />
                    </div>
                )}

                {activeSection === "following" && (
                    <div>
                        <h2>Authors You Follow</h2>
                        <p>TODO: Fetch & display following authors here.</p>
                    </div>
                )}
            </div>
        </div>
    );
};

export default ProfilePage;
