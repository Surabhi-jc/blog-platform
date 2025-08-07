import React, {useState} from "react";
import "./LoginForm.css";
import {useNavigate} from "react-router-dom";

const SignupForm = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [name, setName] = useState("");
    const [passwordConfirmation, setPasswordConfirmation] = useState("");

    const navigate = useNavigate();

    const handleSignup = async(e) => {
        e.preventDefault();

        try{
            const response = await fetch("/api/signup", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({user: {
                        name,
                        email,
                        password,
                        password_confirmation: passwordConfirmation
                    }}),
            });

            const data= await response.json();
            console.log("status:", response.status)
            console.log("response status:", data)
            if(!response.ok){

                throw new Error(data.error || "signup failed");

            }



            sessionStorage.setItem("token", data.token);
            const redirectPath= sessionStorage.getItem("redirectAfterLogin");
            if(redirectPath){
                sessionStorage.removeItem("redirectAfterLogin");
                navigate(redirectPath);
            }
            else{
                navigate("/blogs/prefered_blogs");

            }

            console.log("signup successful", data);
        } catch(err){
            console.error("Signup error:", err.message);
            setError(err.message);
        }
    };

    return (
        <div className="modal-overlay">
            <div className="modal-box">
                <button className="close-btn" onClick={() => navigate("/")}>×</button>
                <h2>Sign Up</h2>

                {error && <p className="error-text">{error}</p>}

                <form onSubmit={handleSignup} className="auth-form">
                    <input
                        type="text"
                        placeholder="Name"
                        value={name}
                        required
                        onChange={(e) => setName(e.target.value)}
                    />

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

                    <input
                        type="password"
                        placeholder="Confirm Password"
                        value={passwordConfirmation}
                        required
                        onChange={(e) => setPasswordConfirmation(e.target.value)}
                    />

                    <button type="submit">Sign Up</button>
                </form>

                <p>
                    Already have an account?{" "}
                    <span className="link" onClick={() => navigate("/login")}>Login</span>
                </p>
            </div>
        </div>
    );

};

export default SignupForm;