const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user details
    const [users] = await db.query(
      'SELECT id, name, email, phone, profile_image_url, is_verified, created_at FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];

    // Get user settings
    const [settings] = await db.query(
      'SELECT * FROM user_settings WHERE user_id = ?',
      [userId]
    );

    // Get user badges
    const [badges] = await db.query(
      'SELECT * FROM badges WHERE user_id = ? ORDER BY date_earned DESC',
      [userId]
    );

    // Get user favorites count
    const [favoritesCount] = await db.query(
      'SELECT type, COUNT(*) as count FROM favorites WHERE user_id = ? GROUP BY type',
      [userId]
    );

    res.json({
      user,
      settings: settings[0] || null,
      badges,
      favoritesCount
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// Update user profile
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, profile_image_url } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (profile_image_url) updateData.profile_image_url = profile_image_url;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE users SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, userId]
    );

    res.json({ message: 'Profile updated successfully' });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Update user settings
router.put('/settings', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { dark_mode, language, notifications_enabled, push_notifications, email_notifications } = req.body;

    // Check if settings exist
    const [existingSettings] = await db.query(
      'SELECT id FROM user_settings WHERE user_id = ?',
      [userId]
    );

    if (existingSettings.length === 0) {
      // Create new settings
      await db.query(
        `INSERT INTO user_settings (user_id, dark_mode, language, notifications_enabled, push_notifications, email_notifications) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [userId, dark_mode, language, notifications_enabled, push_notifications, email_notifications]
      );
    } else {
      // Update existing settings
      const updateData = {};
      if (dark_mode !== undefined) updateData.dark_mode = dark_mode;
      if (language) updateData.language = language;
      if (notifications_enabled !== undefined) updateData.notifications_enabled = notifications_enabled;
      if (push_notifications !== undefined) updateData.push_notifications = push_notifications;
      if (email_notifications !== undefined) updateData.email_notifications = email_notifications;

      if (Object.keys(updateData).length > 0) {
        const fields = Object.keys(updateData);
        const values = Object.values(updateData);
        const setClause = fields.map(field => `${field} = ?`).join(', ');

        await db.query(
          `UPDATE user_settings SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?`,
          [...values, userId]
        );
      }
    }

    res.json({ message: 'Settings updated successfully' });
  } catch (error) {
    console.error('Update settings error:', error);
    res.status(500).json({ error: 'Failed to update settings' });
  }
});

// Get user favorites
router.get('/favorites', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT f.*, 
             CASE 
               WHEN f.type = 'temple' THEN t.name
               WHEN f.type = 'saint' THEN s.name
               WHEN f.type = 'event' THEN e.name
               WHEN f.type = 'hotel' THEN h.name
               WHEN f.type = 'product' THEN p.name
             END as item_name,
             CASE 
               WHEN f.type = 'temple' THEN t.location
               WHEN f.type = 'saint' THEN s.sect
               WHEN f.type = 'event' THEN e.location
               WHEN f.type = 'hotel' THEN h.location
               WHEN f.type = 'product' THEN p.category
             END as item_description,
             CASE 
               WHEN f.type = 'temple' THEN (SELECT ti.image_url FROM temple_images ti WHERE ti.temple_id = t.id AND ti.is_primary = 1 LIMIT 1)
               WHEN f.type = 'saint' THEN (SELECT si.image_url FROM saint_images si WHERE si.saint_id = s.id AND si.is_primary = 1 LIMIT 1)
               WHEN f.type = 'event' THEN (SELECT ei.image_url FROM event_images ei WHERE ei.event_id = e.id AND ei.is_primary = 1 LIMIT 1)
               WHEN f.type = 'hotel' THEN (SELECT hi.image_url FROM hotel_images hi WHERE hi.hotel_id = h.id AND hi.is_primary = 1 LIMIT 1)
               WHEN f.type = 'product' THEN (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1)
             END as item_image
      FROM favorites f
      LEFT JOIN temples t ON f.type = 'temple' AND f.item_id = t.id
      LEFT JOIN saints s ON f.type = 'saint' AND f.item_id = s.id
      LEFT JOIN events e ON f.type = 'event' AND f.item_id = e.id
      LEFT JOIN hotels h ON f.type = 'hotel' AND f.item_id = h.id
      LEFT JOIN store_products p ON f.type = 'product' AND f.item_id = p.id
      WHERE f.user_id = ?
    `;
    let params = [userId];

    if (type) {
      query += ' AND f.type = ?';
      params.push(type);
    }

    query += ' ORDER BY f.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [favorites] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM favorites WHERE user_id = ?';
    let countParams = [userId];
    
    if (type) {
      countQuery += ' AND type = ?';
      countParams.push(type);
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      favorites,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ error: 'Failed to fetch favorites' });
  }
});

// Get user badges
router.get('/badges', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const [badges] = await db.query(
      'SELECT * FROM badges WHERE user_id = ? ORDER BY date_earned DESC',
      [userId]
    );

    // Group badges by type
    const badgesByType = badges.reduce((acc, badge) => {
      if (!acc[badge.badge_type]) {
        acc[badge.badge_type] = [];
      }
      acc[badge.badge_type].push(badge);
      return acc;
    }, {});

    res.json({ badges, badgesByType });
  } catch (error) {
    console.error('Get badges error:', error);
    res.status(500).json({ error: 'Failed to fetch badges' });
  }
});

// Change password
router.put('/change-password', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res.status(400).json({ error: 'Current password and new password are required' });
    }

    // Get current password
    const [users] = await db.query(
      'SELECT password FROM users WHERE id = ? AND auth_provider = ?',
      [userId, 'email']
    );

    if (users.length === 0) {
      return res.status(400).json({ error: 'Password change not available for this account type' });
    }

    // Verify current password
    const isValidPassword = await bcrypt.compare(current_password, users[0].password);
    if (!isValidPassword) {
      return res.status(400).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(new_password, 12);

    // Update password
    await db.query(
      'UPDATE users SET password = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [hashedPassword, userId]
    );

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Failed to change password' });
  }
});

// Delete account
router.delete('/account', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { password } = req.body;

    // Verify password for email accounts
    const [users] = await db.query(
      'SELECT password, auth_provider FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];

    if (user.auth_provider === 'email') {
      if (!password) {
        return res.status(400).json({ error: 'Password is required to delete account' });
      }

      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        return res.status(400).json({ error: 'Incorrect password' });
      }
    }

    // Delete user and all related data (cascade will handle most)
    await db.query('DELETE FROM users WHERE id = ?', [userId]);

    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Failed to delete account' });
  }
});

// Get user statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get various counts
    const [favoritesCount] = await db.query(
      'SELECT COUNT(*) as total FROM favorites WHERE user_id = ?',
      [userId]
    );

    const [ordersCount] = await db.query(
      'SELECT COUNT(*) as total FROM orders WHERE user_id = ?',
      [userId]
    );

    const [badgesCount] = await db.query(
      'SELECT COUNT(*) as total FROM badges WHERE user_id = ?',
      [userId]
    );

    const [notificationsCount] = await db.query(
      'SELECT COUNT(*) as total FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId]
    );

    // Get account age
    const [userInfo] = await db.query(
      'SELECT created_at FROM users WHERE id = ?',
      [userId]
    );

    const accountAge = Math.floor((new Date() - new Date(userInfo[0].created_at)) / (1000 * 60 * 60 * 24));

    res.json({
      favoritesCount: favoritesCount[0].total,
      ordersCount: ordersCount[0].total,
      badgesCount: badgesCount[0].total,
      unreadNotifications: notificationsCount[0].total,
      accountAge
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({ error: 'Failed to fetch user statistics' });
  }
});

module.exports = router;