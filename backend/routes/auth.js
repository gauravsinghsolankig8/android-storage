const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { OAuth2Client } = require('google-auth-library');
const { generateToken } = require('../middleware/auth');
const db = require('../config/database');
const { sendOTP, verifyOTP } = require('../services/smsService');
const { sendEmailVerification } = require('../services/emailService');

const router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Register with email
router.post('/register', [
  body('name').notEmpty().trim().isLength({ min: 2, max: 50 }).withMessage('Name must be between 2-50 characters'),
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('phone').optional().isMobilePhone().withMessage('Valid phone number is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        success: false,
        errors: errors.array().map(err => ({
          field: err.path,
          message: err.msg
        }))
      });
    }

    const { name, email, password, phone } = req.body;

    // Check if user already exists
    const [existingUsers] = await db.query(
      'SELECT id, email, phone FROM users WHERE email = ? OR phone = ?',
      [email, phone]
    );

    if (existingUsers.length > 0) {
      const existingUser = existingUsers[0];
      if (existingUser.email === email) {
        return res.status(400).json({ 
          success: false,
          error: 'User already exists with this email address' 
        });
      }
      if (existingUser.phone === phone) {
        return res.status(400).json({ 
          success: false,
          error: 'User already exists with this phone number' 
        });
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const [result] = await db.query(
      'INSERT INTO users (name, email, password, phone, auth_provider, is_verified) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, phone, 'email', false]
    );

    // Generate JWT token
    const token = generateToken(result.insertId);

    // Send verification email
    try {
      await sendEmailVerification(email, result.insertId);
    } catch (emailError) {
      console.error('Email verification failed:', emailError);
      // Don't fail registration if email fails
    }

    // Get user data without password
    const [newUser] = await db.query(
      'SELECT id, name, email, phone, auth_provider, is_verified, created_at FROM users WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Please check your email for verification.',
      token,
      user: newUser[0]
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Registration failed. Please try again.' 
    });
  }
});

// Login with email
router.post('/login', [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        success: false,
        errors: errors.array().map(err => ({
          field: err.path,
          message: err.msg
        }))
      });
    }

    const { email, password } = req.body;

    // Find user
    const [users] = await db.query(
      'SELECT id, name, email, password, phone, is_verified, role, created_at FROM users WHERE email = ? AND auth_provider = ?',
      [email, 'email']
    );

    if (users.length === 0) {
      return res.status(401).json({ 
        success: false,
        error: 'Invalid email or password' 
      });
    }

    const user = users[0];

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ 
        success: false,
        error: 'Invalid email or password' 
      });
    }

    // Generate token
    const token = generateToken(user.id);

    // Update last login
    await db.query(
      'UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [user.id]
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        isVerified: user.is_verified,
        role: user.role,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Login failed. Please try again.' 
    });
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