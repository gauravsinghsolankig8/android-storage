# Saranam - Vrindavan Spiritual Guide App

A comprehensive full-stack mobile application built with React Native (Expo) and Node.js (Express) that serves as a spiritual guide for visitors to Vrindavan, India.

## 🎯 Features

- **Authentication**: Google, Phone OTP, Email login
- **Home Screen**: Interactive map with nearby temples, saints, events
- **Temples**: Detailed temple information, timings, rituals
- **Saints**: Profiles of past and present spiritual leaders
- **Events**: Upcoming festivals and celebrations
- **Parikrama Guide**: Interactive route maps with audio narration
- **Hotels**: Accommodation options with ratings
- **Today's Darshan**: Daily temple images
- **Spiritual Store**: Books, malas, prasad, and sacred items
- **User Features**: Favorites, notifications, badges, dark mode

## 🏗️ Architecture

### Frontend (React Native + Expo)
- React Native with Expo SDK 49
- React Navigation with bottom tabs
- React Context for state management
- React Native Paper UI components
- React Native Maps for location services

### Backend (Node.js + Express)
- Express.js REST API
- MySQL database with mysql2
- JWT authentication
- Twilio SMS service
- Nodemailer email service
- Multer file uploads

## 🚀 Quick Start

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Configure environment variables
npm run dev
```

### Database Setup
```bash
mysql -u root -p
CREATE DATABASE saranam_db;
USE saranam_db;
source db/schema.sql;
```

### Frontend Setup
```bash
cd frontend
npm install
npx expo start
```

## 📱 Key Screens

- **Splash & Onboarding**: App introduction
- **Authentication**: Multiple login options
- **Home**: Map view with nearby locations
- **Temples**: Browse and search temples
- **Saints**: Spiritual leader profiles
- **Events**: Festival information
- **Parikrama**: Guided spiritual walks
- **Hotels**: Accommodation listings
- **Store**: Spiritual items shopping
- **Profile**: User settings and preferences

## 🔧 API Endpoints

### Core APIs
- `/api/auth/*` - Authentication endpoints
- `/api/temples/*` - Temple information
- `/api/saints/*` - Saint profiles
- `/api/events/*` - Event details
- `/api/parikrama/*` - Parikrama routes
- `/api/hotels/*` - Hotel listings
- `/api/store/*` - Product catalog
- `/api/darshan/*` - Daily darshan images
- `/api/users/*` - User management
- `/api/notifications/*` - Push notifications

## 🎨 Design Features

- **Material Design 3**: Modern UI components
- **Dark Mode**: Complete theme switching
- **Responsive**: Adapts to different screen sizes
- **Accessibility**: High contrast and readable fonts
- **Spiritual Theme**: Colors and icons reflecting Vrindavan culture

## 🔒 Security

- JWT token authentication
- bcrypt password hashing
- Rate limiting and CORS protection
- Input validation and SQL injection protection
- Secure environment variable handling

## 📊 Database Schema

- **users**: Authentication and profiles
- **temples**: Temple information and timings
- **saints**: Spiritual leader data
- **events**: Festival and celebration details
- **parikrama_routes**: Spiritual walking routes
- **hotels**: Accommodation listings
- **store_products**: Spiritual items
- **todays_darshan**: Daily temple images
- **favorites**: User saved items
- **orders**: Store purchases
- **notifications**: Push notifications
- **badges**: Achievement system

## 🚀 Deployment

### Backend
- Deploy to Render, Heroku, or Vercel
- Use PlanetScale, AWS RDS, or DigitalOcean for MySQL
- Configure production environment variables

### Frontend
- Use Expo Go for development
- EAS Build for production app store builds
- Submit to iOS App Store and Google Play Store

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Support

- Email: support@saranam.app
- GitHub Issues for bug reports
- GitHub Discussions for questions

---

**Saranam** - Your spiritual companion in Vrindavan 🙏