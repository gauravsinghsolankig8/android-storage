import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Box } from '@mui/material';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import Dashboard from './pages/Dashboard';
import Layout from './components/Layout';
import UsersPage from './pages/UsersPage';
import TemplesPage from './pages/TemplesPage';
import SaintsPage from './pages/SaintsPage';
import EventsPage from './pages/EventsPage';
import HotelsPage from './pages/HotelsPage';
import ProductsPage from './pages/ProductsPage';
import DarshanPage from './pages/DarshanPage';
import SettingsPage from './pages/SettingsPage';

function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        Loading...
      </Box>
    );
  }

  return isAuthenticated ? children : <Navigate to="/login" />;
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/*"
        element={
          <ProtectedRoute>
            <Layout>
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/users" element={<UsersPage />} />
                <Route path="/temples" element={<TemplesPage />} />
                <Route path="/saints" element={<SaintsPage />} />
                <Route path="/events" element={<EventsPage />} />
                <Route path="/hotels" element={<HotelsPage />} />
                <Route path="/products" element={<ProductsPage />} />
                <Route path="/darshan" element={<DarshanPage />} />
                <Route path="/settings" element={<SettingsPage />} />
              </Routes>
            </Layout>
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}

export default App;