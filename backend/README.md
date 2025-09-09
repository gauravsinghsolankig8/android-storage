# Saranam Backend API

Express.js REST API server for the Saranam - Vrindavan Spiritual Guide App.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Configure your environment variables
# Start development server
npm run dev
```

## 📋 Prerequisites

- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- Twilio account (for SMS OTP)
- Google OAuth credentials
- SMTP email service

## 🔧 Environment Variables

Create a `.env` file with the following variables:

```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=saranam_db
DB_PORT=3306

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Twilio (SMS)
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_PHONE_NUMBER=your_twilio_number

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
```

## 🗄️ Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE saranam_db;
USE saranam_db;

# Import schema
source ../db/schema.sql;
```

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - Email/password login
- `POST /api/auth/google` - Google OAuth
- `POST /api/auth/send-otp` - Send phone OTP
- `POST /api/auth/verify-otp` - Verify phone OTP

### Temples
- `GET /api/temples` - List temples
- `GET /api/temples/:id` - Temple details
- `GET /api/temples/nearby/:lat/:lng` - Nearby temples
- `POST /api/temples/:id/favorite` - Add to favorites

### Saints
- `GET /api/saints` - List saints
- `GET /api/saints/:id` - Saint details
- `GET /api/saints/current/list` - Current saints
- `GET /api/saints/past/list` - Past saints

### Events
- `GET /api/events` - List events
- `GET /api/events/:id` - Event details
- `GET /api/events/upcoming/list` - Upcoming events

### Parikrama
- `GET /api/parikrama/routes` - List routes
- `GET /api/parikrama/routes/:id` - Route details
- `GET /api/parikrama/nearest-stop/:lat/:lng` - Nearest stop
- `POST /api/parikrama/complete` - Mark completed

### Hotels
- `GET /api/hotels` - List hotels
- `GET /api/hotels/:id` - Hotel details
- `GET /api/hotels/nearby/:lat/:lng` - Nearby hotels

### Store
- `GET /api/store/products` - List products
- `GET /api/store/products/:id` - Product details
- `POST /api/store/orders` - Create order
- `GET /api/store/orders` - User orders

### Darshan
- `GET /api/darshan/today` - Today's darshan
- `GET /api/darshan/date/:date` - Darshan by date
- `POST /api/darshan/viewed` - Mark as viewed

### Users
- `GET /api/users/profile` - User profile
- `PUT /api/users/profile` - Update profile
- `GET /api/users/favorites` - User favorites
- `GET /api/users/badges` - User badges

### Notifications
- `GET /api/notifications` - User notifications
- `PUT /api/notifications/:id/read` - Mark as read
- `PUT /api/notifications/mark-all-read` - Mark all as read

## 🛠️ Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run tests
```

## 🔒 Security Features

- JWT token authentication
- bcrypt password hashing
- Rate limiting (100 requests per 15 minutes)
- CORS protection
- Helmet security headers
- Input validation with Joi
- SQL injection protection

## 📊 Database Schema

The database includes tables for:
- Users and authentication
- Temples with images and details
- Saints with profiles and schedules
- Events with descriptions and dates
- Parikrama routes and stops
- Hotels with ratings and amenities
- Store products and orders
- Today's darshan images
- User favorites and notifications
- Badge system for achievements

## 🚀 Deployment

### Production Setup
1. Set up MySQL database
2. Configure environment variables
3. Deploy to Render, Heroku, or Vercel
4. Set up domain and SSL certificate
5. Configure monitoring and logging

### Docker (Optional)
```bash
# Build image
docker build -t saranam-backend .

# Run container
docker run -p 3000:3000 saranam-backend
```

## 📈 Performance

- Connection pooling for MySQL
- Rate limiting to prevent abuse
- Efficient database queries with indexes
- Gzip compression for responses
- Caching for frequently accessed data

## 🧪 Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm test -- --grep "auth"
```

## 📝 API Documentation

The API follows RESTful conventions:
- GET for retrieving data
- POST for creating resources
- PUT for updating resources
- DELETE for removing resources

All responses are in JSON format with consistent error handling.

## 🔧 Development

### Project Structure
```
backend/
├── config/          # Database configuration
├── middleware/      # Custom middleware
├── routes/          # API route handlers
├── services/        # External service integrations
├── server.js        # Main server file
└── package.json     # Dependencies and scripts
```

### Adding New Routes
1. Create route file in `routes/` directory
2. Add route handler functions
3. Import and use in `server.js`
4. Add authentication middleware if needed
5. Test with appropriate HTTP client

## 🐛 Troubleshooting

### Common Issues
- **Database connection failed**: Check MySQL service and credentials
- **JWT token invalid**: Verify JWT_SECRET is set correctly
- **SMS not sending**: Check Twilio credentials and phone number format
- **Email not sending**: Verify SMTP settings and app password

### Logs
- Development: Console logs with timestamps
- Production: Structured logging with log levels
- Error tracking: Stack traces and request context

## 📞 Support

For backend-specific issues:
- Check the logs for error details
- Verify environment variables
- Test database connectivity
- Review API endpoint documentation

---

**Saranam Backend** - Powering the spiritual journey 🙏