import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Base API configuration
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:3000/api' 
  : 'https://your-production-api.com/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  async (config) => {
    try {
      const token = await AsyncStorage.getItem('authToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (error) {
      console.error('Error getting auth token:', error);
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
  async (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      await AsyncStorage.removeItem('authToken');
      await AsyncStorage.removeItem('userData');
      // You might want to redirect to login screen here
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (email, password) => api.post('/auth/login', { email, password }),
  register: (name, email, password) => api.post('/auth/register', { name, email, password }),
  googleLogin: (token) => api.post('/auth/google', { token }),
  sendOTP: (phone) => api.post('/auth/send-otp', { phone }),
  verifyOTP: (phone, otp, name) => api.post('/auth/verify-otp', { phone, otp, name }),
  verifyEmail: (userId, token) => api.post('/auth/verify-email', { userId, token }),
};

// Temples API
export const templesAPI = {
  getAll: (params) => api.get('/temples', { params }),
  getById: (id) => api.get(`/temples/${id}`),
  getNearby: (lat, lng, radius) => api.get(`/temples/nearby/${lat}/${lng}`, { params: { radius } }),
  addFavorite: (id) => api.post(`/temples/${id}/favorite`),
  removeFavorite: (id) => api.delete(`/temples/${id}/favorite`),
  getDarshan: (id, date) => api.get(`/temples/${id}/darshan`, { params: { date } }),
};

// Saints API
export const saintsAPI = {
  getAll: (params) => api.get('/saints', { params }),
  getById: (id) => api.get(`/saints/${id}`),
  getCurrent: () => api.get('/saints/current/list'),
  getPast: () => api.get('/saints/past/list'),
  addFavorite: (id) => api.post(`/saints/${id}/favorite`),
  removeFavorite: (id) => api.delete(`/saints/${id}/favorite`),
};

// Events API
export const eventsAPI = {
  getAll: (params) => api.get('/events', { params }),
  getById: (id) => api.get(`/events/${id}`),
  getUpcoming: (limit) => api.get('/events/upcoming/list', { params: { limit } }),
  getByDateRange: (start, end) => api.get(`/events/date-range/${start}/${end}`),
  addFavorite: (id) => api.post(`/events/${id}/favorite`),
  removeFavorite: (id) => api.delete(`/events/${id}/favorite`),
};

// Parikrama API
export const parikramaAPI = {
  getRoutes: () => api.get('/parikrama/routes'),
  getRouteById: (id) => api.get(`/parikrama/routes/${id}`),
  getStops: (id) => api.get(`/parikrama/routes/${id}/stops`),
  getNearestStop: (lat, lng, routeId) => api.get(`/parikrama/nearest-stop/${lat}/${lng}`, { params: { route_id: routeId } }),
  getProgress: () => api.get('/parikrama/progress'),
  completeParikrama: (data) => api.post('/parikrama/complete', data),
  getStopTemples: (id) => api.get(`/parikrama/stops/${id}/temples`),
};

// Hotels API
export const hotelsAPI = {
  getAll: (params) => api.get('/hotels', { params }),
  getById: (id) => api.get(`/hotels/${id}`),
  getNearby: (lat, lng, radius, priceRange) => api.get(`/hotels/nearby/${lat}/${lng}`, { params: { radius, price_range: priceRange } }),
  getByPriceRange: (range) => api.get(`/hotels/price-range/${range}`),
  addFavorite: (id) => api.post(`/hotels/${id}/favorite`),
  removeFavorite: (id) => api.delete(`/hotels/${id}/favorite`),
};

// Store API
export const storeAPI = {
  getProducts: (params) => api.get('/store/products', { params }),
  getProductById: (id) => api.get(`/store/products/${id}`),
  getByCategory: (category, params) => api.get(`/store/category/${category}`, { params }),
  addFavorite: (id) => api.post(`/store/products/${id}/favorite`),
  removeFavorite: (id) => api.delete(`/store/products/${id}/favorite`),
  createOrder: (data) => api.post('/store/orders', data),
  getOrders: (params) => api.get('/store/orders', { params }),
  getOrderById: (id) => api.get(`/store/orders/${id}`),
  cancelOrder: (id) => api.put(`/store/orders/${id}/cancel`),
};

// Darshan API
export const darshanAPI = {
  getToday: (templeId) => api.get('/darshan/today', { params: { temple_id: templeId } }),
  getByDate: (date, templeId) => api.get(`/darshan/date/${date}`, { params: { temple_id: templeId } }),
  getByTemple: (templeId, params) => api.get(`/darshan/temple/${templeId}`, { params }),
  markViewed: (darshanId) => api.post('/darshan/viewed', { darshan_id: darshanId }),
  getStats: () => api.get('/darshan/stats'),
  getCalendar: (year, month) => api.get(`/darshan/calendar/${year}/${month}`),
};

// User API
export const userAPI = {
  getProfile: () => api.get('/users/profile'),
  updateProfile: (data) => api.put('/users/profile', data),
  updateSettings: (data) => api.put('/users/settings', data),
  getFavorites: (params) => api.get('/users/favorites', { params }),
  getBadges: () => api.get('/users/badges'),
  changePassword: (data) => api.put('/users/change-password', data),
  deleteAccount: (password) => api.delete('/users/account', { data: { password } }),
  getStats: () => api.get('/users/stats'),
};

// Notifications API
export const notificationsAPI = {
  getAll: (params) => api.get('/notifications', { params }),
  getUnreadCount: () => api.get('/notifications/unread-count'),
  markAsRead: (id) => api.put(`/notifications/${id}/read`),
  markAllAsRead: () => api.put('/notifications/mark-all-read'),
  delete: (id) => api.delete(`/notifications/${id}`),
  clearAll: () => api.delete('/notifications/clear-all'),
};

export default api;