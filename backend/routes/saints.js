const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all saints
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, is_current } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT s.*, 
             (SELECT si.image_url FROM saint_images si WHERE si.saint_id = s.id AND si.is_primary = 1 LIMIT 1) as primary_image
      FROM saints s
    `;
    let params = [];
    let conditions = [];

    if (search) {
      conditions.push('(s.name LIKE ? OR s.sect LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }

    if (is_current !== undefined) {
      conditions.push('s.is_current = ?');
      params.push(is_current === 'true' ? 1 : 0);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY s.name LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [saints] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM saints s';
    let countParams = [];
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
      countParams = params.slice(0, -2); // Remove limit and offset
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      saints,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get saints error:', error);
    res.status(500).json({ error: 'Failed to fetch saints' });
  }
});

// Get saint by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get saint details
    const [saints] = await db.query(
      'SELECT * FROM saints WHERE id = ?',
      [id]
    );

    if (saints.length === 0) {
      return res.status(404).json({ error: 'Saint not found' });
    }

    const saint = saints[0];

    // Get saint images
    const [images] = await db.query(
      'SELECT * FROM saint_images WHERE saint_id = ? ORDER BY is_primary DESC, created_at ASC',
      [id]
    );

    // Get related events (if any)
    const [events] = await db.query(
      `SELECT e.*, 
              (SELECT ei.image_url FROM event_images ei WHERE ei.event_id = e.id AND ei.is_primary = 1 LIMIT 1) as primary_image
       FROM events e
       WHERE e.name LIKE ? OR e.description LIKE ?
       ORDER BY e.start_date DESC
       LIMIT 5`,
      [`%${saint.name}%`, `%${saint.name}%`]
    );

    res.json({
      ...saint,
      images,
      relatedEvents: events
    });
  } catch (error) {
    console.error('Get saint error:', error);
    res.status(500).json({ error: 'Failed to fetch saint details' });
  }
});

// Get current saints
router.get('/current/list', async (req, res) => {
  try {
    const [saints] = await db.query(
      `SELECT s.*, 
              (SELECT si.image_url FROM saint_images si WHERE si.saint_id = s.id AND si.is_primary = 1 LIMIT 1) as primary_image
       FROM saints s
       WHERE s.is_current = 1
       ORDER BY s.name`
    );

    res.json({ saints });
  } catch (error) {
    console.error('Get current saints error:', error);
    res.status(500).json({ error: 'Failed to fetch current saints' });
  }
});

// Get past saints
router.get('/past/list', async (req, res) => {
  try {
    const [saints] = await db.query(
      `SELECT s.*, 
              (SELECT si.image_url FROM saint_images si WHERE si.saint_id = s.id AND si.is_primary = 1 LIMIT 1) as primary_image
       FROM saints s
       WHERE s.is_current = 0
       ORDER BY s.birth_date DESC`
    );

    res.json({ saints });
  } catch (error) {
    console.error('Get past saints error:', error);
    res.status(500).json({ error: 'Failed to fetch past saints' });
  }
});

// Add saint to favorites
router.post('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if already favorited
    const [existing] = await db.query(
      'SELECT id FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'saint', id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Saint already in favorites' });
    }

    // Add to favorites
    await db.query(
      'INSERT INTO favorites (user_id, type, item_id) VALUES (?, ?, ?)',
      [userId, 'saint', id]
    );

    res.json({ message: 'Saint added to favorites' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add to favorites' });
  }
});

// Remove saint from favorites
router.delete('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await db.query(
      'DELETE FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'saint', id]
    );

    res.json({ message: 'Saint removed from favorites' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Failed to remove from favorites' });
  }
});

// Create new saint (admin only)
router.post('/', authenticateToken, async (req, res) => {
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

    // Validate required fields
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const [result] = await db.query(
      `INSERT INTO saints (name, sect, bio, schedule, teachings, birth_date, death_date, is_current) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, sect, bio, JSON.stringify(schedule), teachings, birth_date, death_date, is_current || false]
    );

    res.status(201).json({
      message: 'Saint created successfully',
      saintId: result.insertId
    });
  } catch (error) {
    console.error('Create saint error:', error);
    res.status(500).json({ error: 'Failed to create saint' });
  }
});

// Update saint (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.created_at;

    // Convert objects to JSON strings
    if (updateData.schedule) updateData.schedule = JSON.stringify(updateData.schedule);

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE saints SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, id]
    );

    res.json({ message: 'Saint updated successfully' });
  } catch (error) {
    console.error('Update saint error:', error);
    res.status(500).json({ error: 'Failed to update saint' });
  }
});

module.exports = router;