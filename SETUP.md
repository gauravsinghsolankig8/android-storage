# Saranam App - Complete Setup Guide

This guide will help you set up the complete Saranam - Vrindavan Spiritual Guide App including the backend API, mobile app, and admin panel.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **MySQL** (v8.0 or higher) - [Download](https://dev.mysql.com/downloads/)
- **Git** - [Download](https://git-scm.com/)
- **Expo CLI** - `npm install -g @expo/cli`
- **React Native development environment** - [Setup Guide](https://reactnative.dev/docs/environment-setup)

## 🗄️ Database Setup

### 1. Install MySQL
```bash
# On macOS with Homebrew
brew install mysql
brew services start mysql

# On Ubuntu/Debian
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql

# On Windows
# Download and install MySQL from official website
```

### 2. Create Database
```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE saranam_db;
USE saranam_db;

# Import schema
source db/schema.sql;

# Verify tables
SHOW TABLES;
```

### 3. Create Admin User
```bash
# In MySQL console
INSERT INTO users (name, email, password, auth_provider, role, is_verified) 
VALUES ('Admin User', 'admin@saranam.app', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8KzKz2K', 'email', 'super_admin', 1);
# Password: admin123
```

## 🔧 Backend Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your configuration
nano .env
```

### 4. Configure Environment Variables
```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=saranam_db
DB_PORT=3306

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRES_IN=7d

# Server Configuration
PORT=3000
NODE_ENV=development

# Google OAuth (Optional - for Google login)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Twilio Configuration (for SMS OTP)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number

# Email Configuration (for email verification)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Firebase Configuration (for push notifications)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# File Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
```

### 5. Create Uploads Directory
```bash
mkdir uploads
```

### 6. Start Backend Server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

The backend API will be available at `http://localhost:3000`

## 📱 Mobile App Setup

### 1. Navigate to Frontend Directory
```bash
cd frontend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure App Settings
```bash
# Edit app.json to update app configuration
nano app.json
```

Update the following in `app.json`:
```json
{
  "expo": {
    "name": "Saranam - Vrindavan Spiritual Guide",
    "slug": "saranam-vrindavan",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#2c3e50"
    }
  }
}
```

### 4. Update API Configuration
```bash
# Edit src/services/api.js
nano src/services/api.js
```

Update the API base URL:
```javascript
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:3000/api'  // Development
  : 'https://your-production-api.com/api';  // Production
```

### 5. Create Assets Directory
```bash
mkdir -p assets/fonts
mkdir -p assets/images
```

### 6. Add Required Assets
Place the following files in the `assets` directory:
- `icon.png` (1024x1024) - App icon
- `splash.png` (1242x2436) - Splash screen
- `adaptive-icon.png` (1024x1024) - Android adaptive icon
- `favicon.png` (32x32) - Web favicon

### 7. Add Fonts
Download and place Roboto fonts in `assets/fonts/`:
- `Roboto-Regular.ttf`
- `Roboto-Bold.ttf`
- `Roboto-Light.ttf`

### 8. Start Development Server
```bash
# Start Expo development server
npx expo start

# For specific platforms
npx expo start --android
npx expo start --ios
npx expo start --web
```

### 9. Test on Device
- Install **Expo Go** app on your phone
- Scan the QR code from the terminal
- The app will load on your device

## 🖥️ Admin Panel Setup

### 1. Navigate to Admin Directory
```bash
cd admin
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
```bash
# Create .env file
echo "REACT_APP_API_URL=http://localhost:3000/api" > .env
```

### 4. Start Admin Panel
```bash
# Development mode
npm start

# Build for production
npm run build
```

The admin panel will be available at `http://localhost:3001`

### 5. Create Initial Admin User
If you haven't created an admin user in the database, you can use the API:

```bash
curl -X POST http://localhost:3000/api/admin/create-admin \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@saranam.app",
    "password": "admin123"
  }'
```

## 🔐 Third-Party Service Setup

### Google OAuth Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs
6. Copy Client ID and Secret to `.env`

### Twilio SMS Setup
1. Sign up at [Twilio](https://www.twilio.com/)
2. Get Account SID and Auth Token
3. Purchase a phone number
4. Add credentials to `.env`

### Email Service Setup
1. Use Gmail SMTP or any SMTP service
2. For Gmail, enable 2-factor authentication
3. Generate an App Password
4. Add SMTP credentials to `.env`

### Firebase Setup (Optional)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android/iOS apps
4. Download configuration files
5. Add credentials to `.env`

## 🚀 Production Deployment

### Backend Deployment

#### Option 1: Render
1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Set build command: `npm install`
4. Set start command: `npm start`
5. Add environment variables
6. Deploy

#### Option 2: Heroku
```bash
# Install Heroku CLI
npm install -g heroku

# Login to Heroku
heroku login

# Create Heroku app
heroku create saranam-backend

# Add MySQL addon
heroku addons:create jawsdb:kitefin

# Set environment variables
heroku config:set JWT_SECRET=your_jwt_secret
heroku config:set DB_HOST=your_db_host
# ... add all environment variables

# Deploy
git push heroku main
```

#### Option 3: Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard
```

### Database Deployment

#### Option 1: PlanetScale
1. Sign up at [PlanetScale](https://planetscale.com/)
2. Create a new database
3. Import your schema
4. Get connection string
5. Update backend environment variables

#### Option 2: AWS RDS
1. Go to AWS RDS Console
2. Create MySQL instance
3. Configure security groups
4. Get connection details
5. Update backend environment variables

### Mobile App Deployment

#### iOS App Store
```bash
# Install EAS CLI
npm install -g @expo/eas-cli

# Login to Expo
eas login

# Configure EAS
eas build:configure

# Build for iOS
eas build --platform ios

# Submit to App Store
eas submit --platform ios
```

#### Google Play Store
```bash
# Build for Android
eas build --platform android

# Submit to Play Store
eas submit --platform android
```

### Admin Panel Deployment

#### Option 1: Vercel
```bash
cd admin
npm install -g vercel
vercel
```

#### Option 2: Netlify
1. Connect GitHub repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `build`
4. Deploy

## 🧪 Testing

### Backend Testing
```bash
cd backend
npm test
```

### Mobile App Testing
```bash
cd frontend
# Test on different devices
npx expo start --android
npx expo start --ios
```

### Admin Panel Testing
```bash
cd admin
npm test
```

## 🔧 Troubleshooting

### Common Issues

#### Database Connection Failed
- Check MySQL service is running
- Verify database credentials
- Ensure database exists
- Check firewall settings

#### Backend Won't Start
- Check Node.js version (v16+)
- Verify all dependencies installed
- Check environment variables
- Look for port conflicts

#### Mobile App Issues
- Clear Expo cache: `npx expo start -c`
- Check API URL configuration
- Verify network connectivity
- Check device/emulator setup

#### Admin Panel Issues
- Check React version compatibility
- Clear browser cache
- Verify API endpoint accessibility
- Check CORS settings

### Logs and Debugging

#### Backend Logs
```bash
# Development logs
npm run dev

# Production logs (if using PM2)
pm2 logs saranam-backend
```

#### Mobile App Debugging
- Use React Native Debugger
- Check Expo logs in terminal
- Use Flipper for advanced debugging

#### Admin Panel Debugging
- Use browser developer tools
- Check network requests
- Verify API responses

## 📞 Support

### Getting Help
- Check the documentation in each component's README
- Review error logs for specific issues
- Test with minimal configuration first
- Verify all prerequisites are installed

### Common Commands
```bash
# Backend
cd backend && npm run dev

# Mobile App
cd frontend && npx expo start

# Admin Panel
cd admin && npm start

# Database
mysql -u root -p saranam_db
```

### Environment Checklist
- [ ] MySQL installed and running
- [ ] Database created and schema imported
- [ ] Admin user created
- [ ] Backend environment variables configured
- [ ] Backend server running on port 3000
- [ ] Mobile app API URL configured
- [ ] Admin panel API URL configured
- [ ] Required assets added to mobile app
- [ ] Third-party services configured (optional)

## 🎉 Success!

Once everything is set up correctly, you should have:

1. **Backend API** running at `http://localhost:3000`
2. **Mobile App** running via Expo Go
3. **Admin Panel** running at `http://localhost:3001`
4. **Database** with sample data
5. **Admin user** for content management

You can now:
- Test the mobile app features
- Manage content via admin panel
- Add temples, saints, events, etc.
- Upload images and manage data
- Deploy to production when ready

---

**Saranam** - Your spiritual journey in Vrindavan starts here! 🙏