import React, { useState, useEffect } from "react";
import "./ProfilePage.css"; // reuse same styling
import BlogFeed from "./Blogfeed";

const AdminDashboard = () => {
    const [activeSection, setActiveSection] = useState("welcome"); // "welcome", "active", "deleted"
    const [activeBlogs, setActiveBlogs] = useState([]);
    const [deletedBlogs, setDeletedBlogs] = useState([]);
    const token = sessionStorage.getItem("token");

    // Fetch Active Blogs
    useEffect(() => {
        if (activeSection === "active") {
            fetch("/admin/blogs/active", {
                headers: { Authorization: `Bearer ${token}` },
            })
                .then((res) => res.ok && res.json())
                .then((data) => setActiveBlogs(data))
                .catch((err) => console.error("Error fetching active blogs:", err));
        }
    }, [activeSection, token]);

    // Fetch Deleted Blogs
    useEffect(() => {
        if (activeSection === "deleted") {
            fetch("/admin/blogs/deleted", {
                headers: { Authorization: `Bearer ${token}` },
            })
                .then((res) => res.ok && res.json())
                .then((data) => setDeletedBlogs(data))
                .catch((err) => console.error("Error fetching deleted blogs:", err));
        }
    }, [activeSection, token]);


    return (
        <div className="profile-page">
            {/* Sidebar */}
            <div className="profile-sidebar">
                <button onClick={() => setActiveSection("active")}>Active Blogs</button>
                <button onClick={() => setActiveSection("deleted")}>Deleted Blogs</button>
            </div>

            {/* Right Content */}
            <div className="profile-content">
                {activeSection === "welcome" && (
                    <div>
                        <h2>Welcome Admin</h2>
                        <p>Select an option from the left to manage blogs.</p>
                    </div>
                )}

                {activeSection === "active" && (
                    <div>
                        <h2>Active Blogs</h2>
                        <BlogFeed blogs={activeBlogs} showEdit={false} setBlogs={setActiveBlogs} isAdmin={true} userId={null}/>
                    </div>
                )}

                {activeSection === "deleted" && (
                    <div>
                        <h2>Deleted Blogs</h2>
                        <BlogFeed blogs={deletedBlogs} showEdit={false} setBlogs={setDeletedBlogs} showDeletedInfo={true} isAdmin={true} userId={null}/>
                    </div>
                )}
            </div>
        </div>
    );
};

export default AdminDashboard;
