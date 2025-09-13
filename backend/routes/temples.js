const express = require('express');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all temples
router.get('/', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      search, 
      category,
      sort = 'name',
      order = 'ASC'
    } = req.query;
    
    const offset = (page - 1) * limit;
    const validSortFields = ['name', 'created_at', 'location'];
    const validOrder = ['ASC', 'DESC'];
    
    const sortField = validSortFields.includes(sort) ? sort : 'name';
    const sortOrder = validOrder.includes(order.toUpperCase()) ? order.toUpperCase() : 'ASC';

    let query = `
      SELECT t.*, 
             (SELECT ti.image_url FROM temple_images ti WHERE ti.temple_id = t.id AND ti.is_primary = 1 LIMIT 1) as primary_image,
             (SELECT COUNT(*) FROM favorites f WHERE f.item_id = t.id AND f.type = 'temple') as favorite_count
      FROM temples t
    `;
    let params = [];
    let whereConditions = [];

    if (search) {
      whereConditions.push('(t.name LIKE ? OR t.location LIKE ? OR t.description LIKE ?)');
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    if (category) {
      whereConditions.push('t.category = ?');
      params.push(category);
    }

    if (whereConditions.length > 0) {
      query += ' WHERE ' + whereConditions.join(' AND ');
    }

    query += ` ORDER BY t.${sortField} ${sortOrder} LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));

    const [temples] = await db.query(query, params);

    // Parse JSON fields
    const processedTemples = temples.map(temple => ({
      ...temple,
      timings: temple.timings ? JSON.parse(temple.timings) : null,
      amenities: temple.amenities ? JSON.parse(temple.amenities) : [],
      rituals: temple.rituals ? JSON.parse(temple.rituals) : [],
      contact_info: temple.contact_info ? JSON.parse(temple.contact_info) : null
    }));

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM temples t';
    let countParams = [];
    
    if (whereConditions.length > 0) {
      countQuery += ' WHERE ' + whereConditions.join(' AND ');
      countParams = params.slice(0, -2); // Remove limit and offset
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      success: true,
      data: processedTemples,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get temples error:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch temples' 
    });
  }
});

// Get temple by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get temple details
    const [temples] = await db.query(
      'SELECT * FROM temples WHERE id = ?',
      [id]
    );

    if (temples.length === 0) {
      return res.status(404).json({ error: 'Temple not found' });
    }

    const temple = temples[0];

    // Get temple images
    const [images] = await db.query(
      'SELECT * FROM temple_images WHERE temple_id = ? ORDER BY is_primary DESC, created_at ASC',
      [id]
    );

    // Get nearby temples (within 1km radius)
    const [nearbyTemples] = await db.query(
      `SELECT id, name, lat, lng, 
              (6371 * acos(cos(radians(?)) * cos(radians(lat)) * cos(radians(lng) - radians(?)) + sin(radians(?)) * sin(radians(lat)))) AS distance
       FROM temples 
       WHERE id != ? 
       HAVING distance < 1 
       ORDER BY distance 
       LIMIT 5`,
      [temple.lat, temple.lng, temple.lat, id]
    );

    res.json({
      ...temple,
      images,
      nearbyTemples
    });
  } catch (error) {
    console.error('Get temple error:', error);
    res.status(500).json({ error: 'Failed to fetch temple details' });
  }
});

// Get temples near location
router.get('/nearby/:lat/:lng', async (req, res) => {
  try {
    const { lat, lng } = req.params;
    const { radius = 5 } = req.query; // Default 5km radius

    const [temples] = await db.query(
      `SELECT t.*, 
              (SELECT ti.image_url FROM temple_images ti WHERE ti.temple_id = t.id AND ti.is_primary = 1 LIMIT 1) as primary_image,
              (6371 * acos(cos(radians(?)) * cos(radians(t.lat)) * cos(radians(t.lng) - radians(?)) + sin(radians(?)) * sin(radians(t.lat)))) AS distance
       FROM temples t
       HAVING distance < ?
       ORDER BY distance
       LIMIT 20`,
      [lat, lng, lat, radius]
    );

    res.json({ temples });
  } catch (error) {
    console.error('Get nearby temples error:', error);
    res.status(500).json({ error: 'Failed to fetch nearby temples' });
  }
});

// Add temple to favorites
router.post('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if already favorited
    const [existing] = await db.query(
      'SELECT id FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'temple', id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Temple already in favorites' });
    }

    // Add to favorites
    await db.query(
      'INSERT INTO favorites (user_id, type, item_id) VALUES (?, ?, ?)',
      [userId, 'temple', id]
    );

    res.json({ message: 'Temple added to favorites' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add to favorites' });
  }
});

// Remove temple from favorites
router.delete('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await db.query(
      'DELETE FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'temple', id]
    );

    res.json({ message: 'Temple removed from favorites' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Failed to remove from favorites' });
  }
});

// Get temple darshan updates
router.get('/:id/darshan', async (req, res) => {
  try {
    const { id } = req.params;
    const { date } = req.query;

    let query = `
      SELECT td.*, t.name as temple_name
      FROM todays_darshan td
      JOIN temples t ON td.temple_id = t.id
      WHERE td.temple_id = ?
    `;
    let params = [id];

    if (date) {
      query += ' AND td.date_uploaded = ?';
      params.push(date);
    } else {
      query += ' AND td.date_uploaded = CURDATE()';
    }

    query += ' ORDER BY td.created_at DESC';

    const [darshan] = await db.query(query, params);

    res.json({ darshan });
  } catch (error) {
    console.error('Get darshan error:', error);
    res.status(500).json({ error: 'Failed to fetch darshan updates' });
  }
});

// Create new temple (admin only)
router.post('/', authenticateToken, async (req, res) => {
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

    const [result] = await db.query(
      `INSERT INTO temples (name, location, lat, lng, history, timings, amenities, rituals, description, contact_info) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, location, lat, lng, history, JSON.stringify(timings), JSON.stringify(amenities), JSON.stringify(rituals), description, JSON.stringify(contact_info)]
    );

    res.status(201).json({
      message: 'Temple created successfully',
      templeId: result.insertId
    });
  } catch (error) {
    console.error('Create temple error:', error);
    res.status(500).json({ error: 'Failed to create temple' });
  }
});

// Update temple (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.created_at;

    // Convert objects to JSON strings
    if (updateData.timings) updateData.timings = JSON.stringify(updateData.timings);
    if (updateData.amenities) updateData.amenities = JSON.stringify(updateData.amenities);
    if (updateData.rituals) updateData.rituals = JSON.stringify(updateData.rituals);
    if (updateData.contact_info) updateData.contact_info = JSON.stringify(updateData.contact_info);

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE temples SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, id]
    );

    res.json({ message: 'Temple updated successfully' });
  } catch (error) {
    console.error('Update temple error:', error);
    res.status(500).json({ error: 'Failed to update temple' });
  }
});

module.exports = router;