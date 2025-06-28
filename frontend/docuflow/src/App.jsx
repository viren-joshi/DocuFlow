import React, { useEffect, useState } from 'react';
import './amplifyConfig';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Auth } from 'aws-amplify';
import LoginForm from './LoginForm';
import SignUpForm from './SignUpForm';
import Home from './Home';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(null); // null = loading

  useEffect(() => {
    Auth.currentAuthenticatedUser()
      .then(() => setIsAuthenticated(true))
      .catch(() => setIsAuthenticated(false));
  }, []);

  if (isAuthenticated === null) {
    return <div>Loading...</div>; // Show a loading state while checking authentication
  }

  return (
    <Routes>
      <Route
        path="/"
        element= { 
          isAuthenticated  ? <Home /> : <Navigate to="/login" replace  /> 
        }
      />

      <Route
          path="/login"
          element={
            isAuthenticated ? <Navigate to="/" replace /> : <LoginForm setAuth={setIsAuthenticated} />
          }
        />
      <Route
        path="/signup"
        element={
          isAuthenticated ? <Navigate to="/" replace /> : <SignUpForm />
        }
      />

      <Route path="*" element={<Navigate to="/" replace />} />

    
    </Routes>
  )
}

export default App
