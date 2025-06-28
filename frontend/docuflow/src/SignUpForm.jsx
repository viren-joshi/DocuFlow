import { useState } from "react";
import { Auth } from 'aws-amplify';
import { useNavigate } from "react-router-dom";
import Header from "./Header";

export default function SignUpForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [code, setCode] = useState("");
  const [step, setStep] = useState("form");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleSignUp = async () => {
    try {
      await Auth.signUp({
        username: email,
        password: password,
        attributes: { email },
      });
      alert("Sign up successful! Please check your email for the verification code.");
      setStep("verify");
    } catch (err) {
      console.error("Error signing up:", err);
      setError(err.message || "An error occurred during sign up.");
    }
  };

  const handleVerify = async () => {
    try {
      await Auth.confirmSignUp(email, code);
      navigate("/login");
    } catch (err) {
      console.error("Error verifying code:", err);
      setError(err.message || "An error occurred during verification.");
    }
  };

  return (
    <div className="min-h-full bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100 p-4">
      <Header />
      <div className="flex items-center justify-center min-h-[calc(100vh-92px)]">
        <div className="w-full max-w-md p-8 bg-white rounded-xl shadow-md">
          {step === "form" && (
            <>
              <h2 className="text-2xl font-semibold text-center text-gray-800 mb-6">Sign Up</h2>
              <input
                type="email"
                placeholder="Email"
                className="w-full px-4 py-2 mb-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                onChange={(e) => setEmail(e.target.value)}
              />
              <input
                type="password"
                placeholder="Password"
                className="w-full px-4 py-2 mb-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                onChange={(e) => setPassword(e.target.value)}
              />
              <button
                onClick={handleSignUp}
                className="w-full bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white py-2 rounded-lg hover:from-blue-600 hover:to-pink-600 transition duration-300 shadow-md"
              >
                Sign Up
              </button>
              {error && <p className="text-red-600 mt-4 text-sm text-center">{error}</p>}
            </>
          )}

          {step === "verify" && (
            <>
              <h2 className="text-2xl font-semibold text-center text-gray-800 mb-6">Verify Email</h2>
              <input
                type="text"
                placeholder="Enter Verification Code"
                className="w-full px-4 py-2 mb-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                onChange={(e) => setCode(e.target.value)}
              />
              <button
                onClick={handleVerify}
                className="w-full bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white py-2 rounded-lg hover:from-blue-600 hover:to-pink-600 transition duration-300 shadow-md"
              >
                Confirm
              </button>
              {error && <p className="text-red-600 mt-4 text-sm text-center">{error}</p>}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
