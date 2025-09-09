import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Admin API
export const adminAPI = {
  login: (email, password) => api.post('/admin/login', { email, password }),
  verifyToken: () => api.get('/admin/verify-token'),
  getDashboard: () => api.get('/admin/dashboard'),
  getUsers: (params) => api.get('/admin/users', { params }),
  updateUserRole: (id, role) => api.put(`/admin/users/${id}/role`, { role }),
  deleteUser: (id) => api.delete(`/admin/users/${id}`),
  createTemple: (data) => api.post('/admin/temples', data),
  createSaint: (data) => api.post('/admin/saints', data),
  createEvent: (data) => api.post('/admin/events', data),
  createHotel: (data) => api.post('/admin/hotels', data),
  createProduct: (data) => api.post('/admin/products', data),
  uploadDarshan: (data) => api.post('/admin/darshan', data),
  getSettings: () => api.get('/admin/settings'),
  createAdmin: (data) => api.post('/admin/create-admin', data),
};

// Public API (for initial admin creation)
export const publicAPI = {
  createAdmin: (data) => axios.post(`${API_BASE_URL}/admin/create-admin`, data),
};

export default api;