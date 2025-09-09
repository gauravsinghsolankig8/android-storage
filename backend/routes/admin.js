const express = require('express');
const multer = require('multer');
const path = require('path');
const db = require('../config/database');
const { authenticateAdmin, requireAdminRole } = require('../middleware/adminAuth');
const bcrypt = require('bcryptjs');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Admin Dashboard Statistics
router.get('/dashboard', authenticateAdmin, async (req, res) => {
  try {
    // Get various statistics
    const [
      totalUsers,
      totalTemples,
      totalSaints,
      totalEvents,
      totalHotels,
      totalProducts,
      totalOrders,
      recentUsers,
      recentOrders
    ] = await Promise.all([
      db.query('SELECT COUNT(*) as count FROM users'),
      db.query('SELECT COUNT(*) as count FROM temples'),
      db.query('SELECT COUNT(*) as count FROM saints'),
      db.query('SELECT COUNT(*) as count FROM events'),
      db.query('SELECT COUNT(*) as count FROM hotels'),
      db.query('SELECT COUNT(*) as count FROM store_products'),
      db.query('SELECT COUNT(*) as count FROM orders'),
      db.query('SELECT * FROM users ORDER BY created_at DESC LIMIT 5'),
      db.query(`
        SELECT o.*, u.name as user_name, p.name as product_name 
        FROM orders o 
        JOIN users u ON o.user_id = u.id 
        JOIN store_products p ON o.product_id = p.id 
        ORDER BY o.order_date DESC LIMIT 5
      `)
    ]);

    // Get monthly user registrations
    const [monthlyUsers] = await db.query(`
      SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count
      FROM users 
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
      GROUP BY DATE_FORMAT(created_at, '%Y-%m')
      ORDER BY month
    `);

    // Get popular temples
    const [popularTemples] = await db.query(`
      SELECT t.name, COUNT(f.id) as favorite_count
      FROM temples t
      LEFT JOIN favorites f ON t.id = f.item_id AND f.type = 'temple'
      GROUP BY t.id, t.name
      ORDER BY favorite_count DESC
      LIMIT 10
    `);

    res.json({
      statistics: {
        totalUsers: totalUsers[0][0].count,
        totalTemples: totalTemples[0][0].count,
        totalSaints: totalSaints[0][0].count,
        totalEvents: totalEvents[0][0].count,
        totalHotels: totalHotels[0][0].count,
        totalProducts: totalProducts[0][0].count,
        totalOrders: totalOrders[0][0].count,
      },
      recentUsers: recentUsers[0],
      recentOrders: recentOrders[0],
      monthlyUsers: monthlyUsers[0],
      popularTemples: popularTemples[0]
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard data' });
  }
});

// User Management
router.get('/users', authenticateAdmin, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, role } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT id, name, email, phone, auth_provider, role, is_verified, created_at FROM users';
    let params = [];
    let conditions = [];

    if (search) {
      conditions.push('(name LIKE ? OR email LIKE ? OR phone LIKE ?)');
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    if (role) {
      conditions.push('role = ?');
      params.push(role);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [users] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM users';
    let countParams = [];
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
      countParams = params.slice(0, -2);
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Update user role
router.put('/users/:id/role', authenticateAdmin, requireAdminRole('super_admin'), async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    if (!['user', 'admin', 'super_admin'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    await db.query(
      'UPDATE users SET role = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [role, id]
    );

    res.json({ message: 'User role updated successfully' });
  } catch (error) {
    console.error('Update user role error:', error);
    res.status(500).json({ error: 'Failed to update user role' });
  }
});

// Delete user
router.delete('/users/:id', authenticateAdmin, requireAdminRole('super_admin'), async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is trying to delete themselves
    if (parseInt(id) === req.admin.id) {
      return res.status(400).json({ error: 'Cannot delete your own account' });
    }

    await db.query('DELETE FROM users WHERE id = ?', [id]);

    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

// Content Management - Temples
router.post('/temples', authenticateAdmin, upload.array('images', 10), async (req, res) => {
  try {
    const {
      name,
      location,
      lat,
      lng,
      history,
      timings,
      amenities,
      rituals,
      description,
      contact_info
    } = req.body;

    // Validate required fields
    if (!name || !location || !lat || !lng) {
      return res.status(400).json({ error: 'Name, location, and coordinates are required' });
    }

    // Create temple
    const [result] = await db.query(
      `INSERT INTO temples (name, location, lat, lng, history, timings, amenities, rituals, description, contact_info) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, location, lat, lng, history, JSON.stringify(timings), JSON.stringify(amenities), JSON.stringify(rituals), description, JSON.stringify(contact_info)]
    );

    // Handle uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        await db.query(
          'INSERT INTO temple_images (temple_id, image_url, is_primary) VALUES (?, ?, ?)',
          [result.insertId, `/uploads/${file.filename}`, i === 0]
        );
      }
    }

    res.status(201).json({
      message: 'Temple created successfully',
      templeId: result.insertId
    });
  } catch (error) {
    console.error('Create temple error:', error);
    res.status(500).json({ error: 'Failed to create temple' });
  }
});

// Content Management - Saints
router.post('/saints', authenticateAdmin, upload.array('images', 5), async (req, res) => {
  try {
    const {
      name,
      sect,
      bio,
      schedule,
      teachings,
      birth_date,
      death_date,
      is_current
    } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const [result] = await db.query(
      `INSERT INTO saints (name, sect, bio, schedule, teachings, birth_date, death_date, is_current) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, sect, bio, JSON.stringify(schedule), teachings, birth_date, death_date, is_current === 'true']
    );

    // Handle uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        await db.query(
          'INSERT INTO saint_images (saint_id, image_url, is_primary) VALUES (?, ?, ?)',
          [result.insertId, `/uploads/${file.filename}`, i === 0]
        );
      }
    }

    res.status(201).json({
      message: 'Saint created successfully',
      saintId: result.insertId
    });
  } catch (error) {
    console.error('Create saint error:', error);
    res.status(500).json({ error: 'Failed to create saint' });
  }
});

// Content Management - Events
router.post('/events', authenticateAdmin, upload.array('images', 5), async (req, res) => {
  try {
    const {
      name,
      description,
      start_date,
      end_date,
      location,
      event_type,
      dos_donts,
      best_temples
    } = req.body;

    if (!name || !start_date) {
      return res.status(400).json({ error: 'Name and start date are required' });
    }

    const [result] = await db.query(
      `INSERT INTO events (name, description, start_date, end_date, location, event_type, dos_donts, best_temples) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, start_date, end_date, location, event_type, JSON.stringify(dos_donts), JSON.stringify(best_temples)]
    );

    // Handle uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        await db.query(
          'INSERT INTO event_images (event_id, image_url, is_primary) VALUES (?, ?, ?)',
          [result.insertId, `/uploads/${file.filename}`, i === 0]
        );
      }
    }

    res.status(201).json({
      message: 'Event created successfully',
      eventId: result.insertId
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ error: 'Failed to create event' });
  }
});

// Content Management - Hotels
router.post('/hotels', authenticateAdmin, upload.array('images', 5), async (req, res) => {
  try {
    const {
      name,
      location,
      lat,
      lng,
      price_range,
      rating,
      amenities,
      contact_info,
      booking_url
    } = req.body;

    if (!name || !location || !lat || !lng || !price_range) {
      return res.status(400).json({ error: 'Name, location, coordinates, and price range are required' });
    }

    const [result] = await db.query(
      `INSERT INTO hotels (name, location, lat, lng, price_range, rating, amenities, contact_info, booking_url) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, location, lat, lng, price_range, rating, JSON.stringify(amenities), JSON.stringify(contact_info), booking_url]
    );

    // Handle uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        await db.query(
          'INSERT INTO hotel_images (hotel_id, image_url, is_primary) VALUES (?, ?, ?)',
          [result.insertId, `/uploads/${file.filename}`, i === 0]
        );
      }
    }

    res.status(201).json({
      message: 'Hotel created successfully',
      hotelId: result.insertId
    });
  } catch (error) {
    console.error('Create hotel error:', error);
    res.status(500).json({ error: 'Failed to create hotel' });
  }
});

// Content Management - Store Products
router.post('/products', authenticateAdmin, upload.array('images', 5), async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      stock,
      category,
      weight,
      dimensions
    } = req.body;

    if (!name || !price || !category) {
      return res.status(400).json({ error: 'Name, price, and category are required' });
    }

    const [result] = await db.query(
      `INSERT INTO store_products (name, description, price, stock, category, weight, dimensions) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [name, description, price, stock || 0, category, weight, JSON.stringify(dimensions)]
    );

    // Handle uploaded images
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        await db.query(
          'INSERT INTO product_images (product_id, image_url, is_primary) VALUES (?, ?, ?)',
          [result.insertId, `/uploads/${file.filename}`, i === 0]
        );
      }
    }

    res.status(201).json({
      message: 'Product created successfully',
      productId: result.insertId
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ error: 'Failed to create product' });
  }
});

// Upload Today's Darshan
router.post('/darshan', authenticateAdmin, upload.single('image'), async (req, res) => {
  try {
    const { temple_id, caption } = req.body;

    if (!temple_id || !req.file) {
      return res.status(400).json({ error: 'Temple ID and image are required' });
    }

    const [result] = await db.query(
      'INSERT INTO todays_darshan (temple_id, image_url, caption, date_uploaded) VALUES (?, ?, ?, CURDATE())',
      [temple_id, `/uploads/${req.file.filename}`, caption]
    );

    // Send notification to all users
    const [users] = await db.query('SELECT id FROM users');
    
    for (const user of users) {
      await db.query(
        `INSERT INTO notifications (user_id, message, type, data) 
         VALUES (?, ?, ?, ?)`,
        [
          user.id,
          `New darshan has been uploaded for today!`,
          'darshan',
          JSON.stringify({ darshan_id: result.insertId, temple_id })
        ]
      );
    }

    res.status(201).json({
      message: 'Darshan uploaded successfully',
      darshanId: result.insertId
    });
  } catch (error) {
    console.error('Upload darshan error:', error);
    res.status(500).json({ error: 'Failed to upload darshan' });
  }
});

// System Settings
router.get('/settings', authenticateAdmin, async (req, res) => {
  try {
    // Get system settings (you can create a settings table)
    const settings = {
      app_name: 'Saranam - Vrindavan Spiritual Guide',
      app_version: '1.0.0',
      maintenance_mode: false,
      max_file_size: '5MB',
      supported_image_types: ['jpeg', 'jpg', 'png', 'gif'],
      notification_settings: {
        email_notifications: true,
        sms_notifications: true,
        push_notifications: true
      }
    };

    res.json({ settings });
  } catch (error) {
    console.error('Get settings error:', error);
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// Create Admin User (for initial setup)
router.post('/create-admin', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    // Check if any admin already exists
    const [existingAdmins] = await db.query(
      'SELECT id FROM users WHERE role IN (?, ?)',
      ['admin', 'super_admin']
    );

    if (existingAdmins.length > 0) {
      return res.status(400).json({ error: 'Admin user already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create admin user
    const [result] = await db.query(
      'INSERT INTO users (name, email, password, auth_provider, role, is_verified) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, hashedPassword, 'email', 'super_admin', true]
    );

    res.status(201).json({
      message: 'Admin user created successfully',
      adminId: result.insertId
    });
  } catch (error) {
    console.error('Create admin error:', error);
    res.status(500).json({ error: 'Failed to create admin user' });
  }
});

module.exports = router;