import { useState } from 'react';
import { Auth } from 'aws-amplify';
import { useNavigate } from 'react-router-dom';
import Header from './Header';

export default function LoginForm({ setAuth }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async () => {
    try {
      const user = await Auth.signIn(email, password);
      console.log('Login successful:', user);
      setAuth(true);
    } catch (err) {
      console.error('Error logging in:', err);
      setError(err.message || 'An error occurred during login.');
    }
  };

  return (
    <div className="min-h-full bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100 p-4">
      <Header />
      <div className="flex items-center justify-center min-h-[calc(100vh-92px)]">
        <div className="w-full max-w-md p-8 bg-white rounded-xl shadow-md">
          <h2 className="text-2xl font-semibold text-center text-gray-800 mb-6">Log In</h2>

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
            onClick={handleLogin}
            className="w-full bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white py-2 rounded-lg hover:from-blue-600 hover:to-pink-600 transition duration-300 shadow-md"
          >
            Log In
          </button>

          {error && <p className="text-red-600 mt-4 text-sm text-center">{error}</p>}

          <p
            onClick={() => navigate("/signup")}
            className="mt-6 text-sm text-center text-blue-600 hover:underline cursor-pointer"
          >
            Don't have an account? Sign up
          </p>
        </div>
      </div>
      
    </div>
  );
}
