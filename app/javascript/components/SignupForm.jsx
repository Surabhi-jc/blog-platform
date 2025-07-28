import React, {useState} from "react";

const SignupForm = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [name, setName] = useState("");
    const [passwordConfirmation, setPasswordConfirmation] = useState("");

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

            console.log("signup successful", data);
        } catch(err){
            console.error("Signup error:", err.message);
            setError(err.message);
        }
    };

    return (
        <div className="signup-form">
            <h2>Sign Up</h2>
            {error && <p style={{ color: "red" }}>{error}</p>}
            <form onSubmit={handleSignup}>
                <div>
                    <label>Name:</label>
                    <input
                        type="name"
                        value={name}
                        required
                        onChange={(e) => setName(e.target.value)}
                    />
                </div>
                <div>
                    <label>Email:</label>
                    <input
                        type="email"
                        value={email}
                        required
                        onChange={(e) => setEmail(e.target.value)}
                    />
                </div>

                <div>
                    <label>Password:</label>
                    <input
                        type="password"
                        value={password}
                        required
                        onChange={(e) => setPassword(e.target.value)}
                    />
                </div>
                <div>
                    <label>Confirm Password:</label>
                    <input
                        type="password"
                        value={passwordConfirmation}
                        required
                        onChange={(e) => setPasswordConfirmation(e.target.value)}
                    />
                </div>

                <button type="submit">Sign Up</button>
            </form>
        </div>
    );

};

export default SignupForm;