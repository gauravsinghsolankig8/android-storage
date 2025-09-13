const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get today's darshan
router.get('/today', async (req, res) => {
  try {
    const { temple_id } = req.query;

    let query = `
      SELECT td.*, t.name as temple_name, t.location as temple_location
      FROM todays_darshan td
      JOIN temples t ON td.temple_id = t.id
      WHERE td.date_uploaded = CURDATE()
    `;
    let params = [];

    if (temple_id) {
      query += ' AND td.temple_id = ?';
      params.push(temple_id);
    }

    query += ' ORDER BY td.created_at DESC';

    const [darshan] = await db.query(query, params);

    res.json({ darshan });
  } catch (error) {
    console.error('Get today\'s darshan error:', error);
    res.status(500).json({ error: 'Failed to fetch today\'s darshan' });
  }
});

// Get darshan by date
router.get('/date/:date', async (req, res) => {
  try {
    const { date } = req.params;
    const { temple_id } = req.query;

    let query = `
      SELECT td.*, t.name as temple_name, t.location as temple_location
      FROM todays_darshan td
      JOIN temples t ON td.temple_id = t.id
      WHERE td.date_uploaded = ?
    `;
    let params = [date];

    if (temple_id) {
      query += ' AND td.temple_id = ?';
      params.push(temple_id);
    }

    query += ' ORDER BY td.created_at DESC';

    const [darshan] = await db.query(query, params);

    res.json({ darshan });
  } catch (error) {
    console.error('Get darshan by date error:', error);
    res.status(500).json({ error: 'Failed to fetch darshan' });
  }
});

// Get darshan for specific temple
router.get('/temple/:temple_id', async (req, res) => {
  try {
    const { temple_id } = req.params;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const [darshan] = await db.query(
      `SELECT td.*, t.name as temple_name, t.location as temple_location
       FROM todays_darshan td
       JOIN temples t ON td.temple_id = t.id
       WHERE td.temple_id = ?
       ORDER BY td.date_uploaded DESC, td.created_at DESC
       LIMIT ? OFFSET ?`,
      [temple_id, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const [countResult] = await db.query(
      'SELECT COUNT(*) as total FROM todays_darshan WHERE temple_id = ?',
      [temple_id]
    );
    const total = countResult[0].total;

    res.json({
      darshan,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get temple darshan error:', error);
    res.status(500).json({ error: 'Failed to fetch temple darshan' });
  }
});

// Mark darshan as viewed (for badges)
router.post('/viewed', authenticateToken, async (req, res) => {
  try {
    const { darshan_id } = req.body;
    const userId = req.user.id;

    if (!darshan_id) {
      return res.status(400).json({ error: 'Darshan ID is required' });
    }

    // Check if darshan exists
    const [darshan] = await db.query(
      'SELECT * FROM todays_darshan WHERE id = ?',
      [darshan_id]
    );

    if (darshan.length === 0) {
      return res.status(404).json({ error: 'Darshan not found' });
    }

    // Check if user has already viewed today's darshan
    const today = new Date().toISOString().split('T')[0];
    const [existingBadge] = await db.query(
      `SELECT id FROM badges 
       WHERE user_id = ? AND badge_type = 'darshan' 
       AND DATE(date_earned) = ?`,
      [userId, today]
    );

    if (existingBadge.length === 0) {
      // Create daily darshan badge
      await db.query(
        `INSERT INTO badges (user_id, badge_name, badge_type, description, data) 
         VALUES (?, ?, ?, ?, ?)`,
        [
          userId,
          'Daily Darshan Viewer',
          'darshan',
          'Viewed today\'s darshan',
          JSON.stringify({ darshan_id, date: today })
        ]
      );

      // Send notification
      await db.query(
        `INSERT INTO notifications (user_id, message, type, data) 
         VALUES (?, ?, ?, ?)`,
        [
          userId,
          'Great! You\'ve viewed today\'s darshan. Keep up the spiritual practice!',
          'darshan',
          JSON.stringify({ darshan_id, badge_type: 'darshan' })
        ]
      );
    }

    res.json({ message: 'Darshan marked as viewed' });
  } catch (error) {
    console.error('Mark darshan viewed error:', error);
    res.status(500).json({ error: 'Failed to mark darshan as viewed' });
  }
});

// Get darshan statistics
router.get('/stats', async (req, res) => {
  try {
    // Get total darshan count
    const [totalCount] = await db.query(
      'SELECT COUNT(*) as total FROM todays_darshan'
    );

    // Get darshan count by temple
    const [templeStats] = await db.query(
      `SELECT t.name as temple_name, COUNT(td.id) as darshan_count
       FROM temples t
       LEFT JOIN todays_darshan td ON t.id = td.temple_id
       GROUP BY t.id, t.name
       ORDER BY darshan_count DESC`
    );

    // Get recent darshan (last 7 days)
    const [recentDarshan] = await db.query(
      `SELECT DATE(date_uploaded) as date, COUNT(*) as count
       FROM todays_darshan
       WHERE date_uploaded >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
       GROUP BY DATE(date_uploaded)
       ORDER BY date DESC`
    );

    res.json({
      totalDarshan: totalCount[0].total,
      templeStats,
      recentDarshan
    });
  } catch (error) {
    console.error('Get darshan stats error:', error);
    res.status(500).json({ error: 'Failed to fetch darshan statistics' });
  }
});

// Upload new darshan (admin only)
router.post('/upload', authenticateToken, async (req, res) => {
  try {
    const { temple_id, image_url, caption } = req.body;

    if (!temple_id || !image_url) {
      return res.status(400).json({ error: 'Temple ID and image URL are required' });
    }

    // Verify temple exists
    const [temples] = await db.query(
      'SELECT id FROM temples WHERE id = ?',
      [temple_id]
    );

    if (temples.length === 0) {
      return res.status(404).json({ error: 'Temple not found' });
    }

    const [result] = await db.query(
      'INSERT INTO todays_darshan (temple_id, image_url, caption, date_uploaded) VALUES (?, ?, ?, CURDATE())',
      [temple_id, image_url, caption]
    );

    // Send notification to all users about new darshan
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

// Get darshan calendar (monthly view)
router.get('/calendar/:year/:month', async (req, res) => {
  try {
    const { year, month } = req.params;

    const [calendar] = await db.query(
      `SELECT DATE(date_uploaded) as date, COUNT(*) as darshan_count,
              GROUP_CONCAT(DISTINCT t.name) as temples
       FROM todays_darshan td
       JOIN temples t ON td.temple_id = t.id
       WHERE YEAR(date_uploaded) = ? AND MONTH(date_uploaded) = ?
       GROUP BY DATE(date_uploaded)
       ORDER BY date`,
      [year, month]
    );

    res.json({ calendar });
  } catch (error) {
    console.error('Get darshan calendar error:', error);
    res.status(500).json({ error: 'Failed to fetch darshan calendar' });
  }
});

module.exports = router;