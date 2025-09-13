import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { authAPI } from '../services/api';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    loadStoredAuth();
  }, []);

  const loadStoredAuth = async () => {
    try {
      const storedToken = await AsyncStorage.getItem('authToken');
      const storedUser = await AsyncStorage.getItem('userData');
      
      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
        setIsAuthenticated(true);
      }
    } catch (error) {
      console.error('Error loading stored auth:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      setIsLoading(true);
      const response = await authAPI.login(email, password);
      
      if (response.data.token) {
        const { token: authToken, user: userData } = response.data;
        
        await AsyncStorage.setItem('authToken', authToken);
        await AsyncStorage.setItem('userData', JSON.stringify(userData));
        
        setToken(authToken);
        setUser(userData);
        setIsAuthenticated(true);
        
        return { success: true, user: userData };
      }
    } catch (error) {
      console.error('Login error:', error);
      return { 
        success: false, 
        error: error.response?.data?.error || 'Login failed' 
      };
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (name, email, password) => {
    try {
      setIsLoading(true);
      const response = await authAPI.register(name, email, password);
      
      return { 
        success: true, 
        message: response.data.message 
      };
    } catch (error) {
      console.error('Registration error:', error);
      return { 
        success: false, 
        error: error.response?.data?.error || 'Registration failed' 
      };
    } finally {
      setIsLoading(false);
    }
  };

  const googleLogin = async (googleToken) => {
    try {
      setIsLoading(true);
      const response = await authAPI.googleLogin(googleToken);
      
      if (response.data.token) {
        const { token: authToken, user: userData } = response.data;
        
        await AsyncStorage.setItem('authToken', authToken);
        await AsyncStorage.setItem('userData', JSON.stringify(userData));
        
        setToken(authToken);
        setUser(userData);
        setIsAuthenticated(true);
        
        return { success: true, user: userData };
      }
    } catch (error) {
      console.error('Google login error:', error);
      return { 
        success: false, 
        error: error.response?.data?.error || 'Google login failed' 
      };
    } finally {
      setIsLoading(false);
    }
  };

  const phoneLogin = async (phone, otp, name) => {
    try {
      setIsLoading(true);
      const response = await authAPI.verifyOTP(phone, otp, name);
      
      if (response.data.token) {
        const { token: authToken, user: userData } = response.data;
        
        await AsyncStorage.setItem('authToken', authToken);
        await AsyncStorage.setItem('userData', JSON.stringify(userData));
        
        setToken(authToken);
        setUser(userData);
        setIsAuthenticated(true);
        
        return { success: true, user: userData };
      }
    } catch (error) {
      console.error('Phone login error:', error);
      return { 
        success: false, 
        error: error.response?.data?.error || 'Phone login failed' 
      };
    } finally {
      setIsLoading(false);
    }
  };

  const sendOTP = async (phone) => {
    try {
      const response = await authAPI.sendOTP(phone);
      return { 
        success: true, 
        message: response.data.message 
      };
    } catch (error) {
      console.error('Send OTP error:', error);
      return { 
        success: false, 
        error: error.response?.data?.error || 'Failed to send OTP' 
      };
    }
  };

  const logout = async () => {
    try {
      await AsyncStorage.removeItem('authToken');
      await AsyncStorage.removeItem('userData');
      
      setToken(null);
      setUser(null);
      setIsAuthenticated(false);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const updateUser = (userData) => {
    setUser(userData);
    AsyncStorage.setItem('userData', JSON.stringify(userData));
  };

  const value = {
    user,
    token,
    isLoading,
    isAuthenticated,
    login,
    register,
    googleLogin,
    phoneLogin,
    sendOTP,
    logout,
    updateUser,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};