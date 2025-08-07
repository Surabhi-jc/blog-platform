import React, { useState} from "react";
import { useNavigate } from "react-router-dom";
import "./LoginForm.css";

const LoginForm = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();



        try{
            const response = await fetch("/api/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ email, password }),
            });

            const data = await response.json();
            if (!response.ok) {
                throw new Error(data.error || "Login failed");
            }

            sessionStorage.setItem("token", data.token);

            const redirectPath= sessionStorage.getItem("redirectAfterLogin");
            if(redirectPath){
                sessionStorage.removeItem("redirectAfterLogin");
                navigate(redirectPath);
            }
            else{
                navigate("/blogs/prefered_blogs");
                //setSuccess("Login successful!");
                //setError("");
            }



        }catch(err){
            setError(err.message);
            setSuccess("");
        }
    };

    return (
        <div className="modal-overlay">
            <div className= "modal-box">
                <button className= "close-btn" onClick={() => navigate("/")}>x</button>

                <h2>Login</h2>
                {error && <p style={{ color: "red" }}>{error}</p>}
                {success && <p style={{ color: "green" }}>{success}</p>}

                <form onSubmit={handleLogin} className="auth-form">
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        required
                        onChange={(e) => setEmail(e.target.value)}
                    />

                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        required
                        onChange={(e) => setPassword(e.target.value)}
                    />

                    <button type="submit">Login</button>

                </form>
                <p>
                    New here? <span className="link" onClick={() => navigate("/signup")}>Sign up </span>
                </p>
            </div>
        </div>



    );
};

export default LoginForm;

