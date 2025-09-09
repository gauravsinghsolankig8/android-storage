const express = require('express');
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const { generateToken } = require('../middleware/auth');
const db = require('../config/database');
const { sendOTP, verifyOTP } = require('../services/smsService');
const { sendEmailVerification } = require('../services/emailService');

const router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Register with email
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    // Check if user already exists
    const [existingUsers] = await db.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({ error: 'User already exists with this email' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const [result] = await db.query(
      'INSERT INTO users (name, email, password, auth_provider) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, 'email']
    );

    // Send verification email
    await sendEmailVerification(email, result.insertId);

    res.status(201).json({
      message: 'User registered successfully. Please check your email for verification.',
      userId: result.insertId
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login with email
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const [users] = await db.query(
      'SELECT id, name, email, password, is_verified FROM users WHERE email = ? AND auth_provider = ?',
      [email, 'email']
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = generateToken(user.id);

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        isVerified: user.is_verified
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Google OAuth
router.post('/google', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Google token is required' });
    }

    // Verify Google token
    const ticket = await googleClient.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID
    });

    const payload = ticket.getPayload();
    const { sub: googleId, name, email, picture } = payload;

    // Check if user exists
    let [users] = await db.query(
      'SELECT id, name, email, profile_image_url FROM users WHERE email = ?',
      [email]
    );

    let user;
    if (users.length === 0) {
      // Create new user
      const [result] = await db.query(
        'INSERT INTO users (name, email, auth_provider, profile_image_url, is_verified) VALUES (?, ?, ?, ?, ?)',
        [name, email, 'google', picture, true]
      );
      user = {
        id: result.insertId,
        name,
        email,
        profile_image_url: picture
      };
    } else {
      user = users[0];
      // Update profile image if needed
      if (!user.profile_image_url && picture) {
        await db.query(
          'UPDATE users SET profile_image_url = ? WHERE id = ?',
          [picture, user.id]
        );
        user.profile_image_url = picture;
      }
    }

    const jwtToken = generateToken(user.id);

    res.json({
      message: 'Google authentication successful',
      token: jwtToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        profileImageUrl: user.profile_image_url
      }
    });
  } catch (error) {
    console.error('Google auth error:', error);
    res.status(500).json({ error: 'Google authentication failed' });
  }
});

// Send OTP for phone verification
router.post('/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    // Generate and send OTP
    const otp = await sendOTP(phone);

    res.json({
      message: 'OTP sent successfully',
      phone: phone.replace(/\d(?=\d{4})/g, '*') // Mask phone number
    });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

// Verify OTP and login/register
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp, name } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ error: 'Phone number and OTP are required' });
    }

    // Verify OTP
    const isValidOTP = await verifyOTP(phone, otp);
    if (!isValidOTP) {
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    // Check if user exists
    let [users] = await db.query(
      'SELECT id, name, phone FROM users WHERE phone = ?',
      [phone]
    );

    let user;
    if (users.length === 0) {
      // Create new user
      if (!name) {
        return res.status(400).json({ error: 'Name is required for new users' });
      }
      const [result] = await db.query(
        'INSERT INTO users (name, phone, auth_provider, is_verified) VALUES (?, ?, ?, ?)',
        [name, phone, 'phone', true]
      );
      user = {
        id: result.insertId,
        name,
        phone
      };
    } else {
      user = users[0];
    }

    const token = generateToken(user.id);

    res.json({
      message: 'OTP verification successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone
      }
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'OTP verification failed' });
  }
});

// Verify email
router.post('/verify-email', async (req, res) => {
  try {
    const { userId, token } = req.body;

    // In a real app, you would verify the token from the email
    // For now, we'll just mark the user as verified
    await db.query(
      'UPDATE users SET is_verified = ? WHERE id = ?',
      [true, userId]
    );

    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({ error: 'Email verification failed' });
  }
});

module.exports = router;