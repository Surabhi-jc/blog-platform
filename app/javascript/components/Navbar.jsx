import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./Navbar.css";

const Navbar = ({ user, onLogout }) => {
    const navigate = useNavigate();
    const [dropdownOpen, setDropdownOpen] = useState(false);


    const handleLogout = () => {
        onLogout();
        setDropdownOpen(false);
        navigate("/");
    };
    return (
        <header className="navbar px-4 py-3">
            {/* Logo always visible */}
            <h2 className="logo" onClick={() => user ? navigate("/blogs/prefered_blogs") : navigate("/")}>
                BlogPlatform
            </h2>

            {/* Right-side nav options */}
            <nav className="nav-links">
                {user ? (
                    // If logged in
                    <div className="profile-section">
            <span
                className="profile-name"
                onClick={() => setDropdownOpen(!dropdownOpen)}
            >
              👤 {user.name}
            </span>

                        {dropdownOpen && (
                            <div className="dropdown text-center">
                                <p>{user.name}</p>
                                <button onClick={() => {navigate("/profile"); setDropdownOpen(false);}}>My Profile</button>
                                {/* if user is admin */}
                                {user.is_admin && (
                                    <button onClick={() => {navigate("/admin"); setDropdownOpen(false);}}>
                                        Admin Dashboard
                                    </button>
                                )}
                                <button onClick={ () => {handleLogout()} }>Logout</button>
                            </div>
                        )}
                    </div>
                ) : (
                    // If logged out
                    <>
                        <button className="btn" onClick={() => navigate("/signup")}>
                            Sign up
                        </button>
                        <button className="btn" onClick={() => navigate("/login")}>
                            Login
                        </button>
                    </>
                )}
            </nav>
        </header>
    );
};

export default Navbar;
