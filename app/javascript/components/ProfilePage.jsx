import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

import "./ProfilePage.css";

const ProfilePage = () => {
    const [user, setUser] = useState(null);
    const [name, setName] = useState("");
    const [message, setMessage] = useState("");
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
            } else {
                setMessage("Failed to update profile.");
            }
        } catch (err) {
            console.error(err);
            setMessage("Error updating profile.");
        }
    };

    const handleLogout = () => {
        sessionStorage.removeItem("token");
        navigate("/");
    };

    return (
        <div>


            <div>



                <div className="profile-page">
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
                    <div className="profile-extra">
                        {/* Placeholder for right side (2/3 of page) */}
                        <h2>Welcome back, {user?.name}</h2>
                        <p>You can add more content here (blogs, stats, etc.).</p>
                    </div>

                </div>
            </div>



        </div>

    );
};

export default ProfilePage;
