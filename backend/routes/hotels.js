const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all hotels
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, price_range, min_rating } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT h.*, 
             (SELECT hi.image_url FROM hotel_images hi WHERE hi.hotel_id = h.id AND hi.is_primary = 1 LIMIT 1) as primary_image
      FROM hotels h
    `;
    let params = [];
    let conditions = [];

    if (search) {
      conditions.push('(h.name LIKE ? OR h.location LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }

    if (price_range) {
      conditions.push('h.price_range = ?');
      params.push(price_range);
    }

    if (min_rating) {
      conditions.push('h.rating >= ?');
      params.push(parseFloat(min_rating));
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY h.rating DESC, h.name LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [hotels] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM hotels h';
    let countParams = [];
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
      countParams = params.slice(0, -2); // Remove limit and offset
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      hotels,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get hotels error:', error);
    res.status(500).json({ error: 'Failed to fetch hotels' });
  }
});

// Get hotel by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get hotel details
    const [hotels] = await db.query(
      'SELECT * FROM hotels WHERE id = ?',
      [id]
    );

    if (hotels.length === 0) {
      return res.status(404).json({ error: 'Hotel not found' });
    }

    const hotel = hotels[0];

    // Get hotel images
    const [images] = await db.query(
      'SELECT * FROM hotel_images WHERE hotel_id = ? ORDER BY is_primary DESC, created_at ASC',
      [id]
    );

    // Get nearby temples (within 2km radius)
    const [nearbyTemples] = await db.query(
      `SELECT id, name, lat, lng, 
              (6371 * acos(cos(radians(?)) * cos(radians(lat)) * cos(radians(lng) - radians(?)) + sin(radians(?)) * sin(radians(lat)))) AS distance
       FROM temples 
       HAVING distance < 2 
       ORDER BY distance 
       LIMIT 10`,
      [hotel.lat, hotel.lng, hotel.lat]
    );

    res.json({
      ...hotel,
      images,
      nearbyTemples
    });
  } catch (error) {
    console.error('Get hotel error:', error);
    res.status(500).json({ error: 'Failed to fetch hotel details' });
  }
});

// Get hotels near location
router.get('/nearby/:lat/:lng', async (req, res) => {
  try {
    const { lat, lng } = req.params;
    const { radius = 5, price_range } = req.query; // Default 5km radius

    let query = `
      SELECT h.*, 
             (SELECT hi.image_url FROM hotel_images hi WHERE hi.hotel_id = h.id AND hi.is_primary = 1 LIMIT 1) as primary_image,
             (6371 * acos(cos(radians(?)) * cos(radians(h.lat)) * cos(radians(h.lng) - radians(?)) + sin(radians(?)) * sin(radians(h.lat)))) AS distance
      FROM hotels h
    `;
    let params = [lat, lng, lat];

    if (price_range) {
      query += ' WHERE h.price_range = ?';
      params.push(price_range);
    }

    query += ' HAVING distance < ? ORDER BY distance LIMIT 20';
    params.push(radius);

    const [hotels] = await db.query(query, params);

    res.json({ hotels });
  } catch (error) {
    console.error('Get nearby hotels error:', error);
    res.status(500).json({ error: 'Failed to fetch nearby hotels' });
  }
});

// Get hotels by price range
router.get('/price-range/:range', async (req, res) => {
  try {
    const { range } = req.params;

    const [hotels] = await db.query(
      `SELECT h.*, 
              (SELECT hi.image_url FROM hotel_images hi WHERE hi.hotel_id = h.id AND hi.is_primary = 1 LIMIT 1) as primary_image
       FROM hotels h
       WHERE h.price_range = ?
       ORDER BY h.rating DESC, h.name`,
      [range]
    );

    res.json({ hotels });
  } catch (error) {
    console.error('Get hotels by price range error:', error);
    res.status(500).json({ error: 'Failed to fetch hotels' });
  }
});

// Add hotel to favorites
router.post('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if already favorited
    const [existing] = await db.query(
      'SELECT id FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'hotel', id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Hotel already in favorites' });
    }

    // Add to favorites
    await db.query(
      'INSERT INTO favorites (user_id, type, item_id) VALUES (?, ?, ?)',
      [userId, 'hotel', id]
    );

    res.json({ message: 'Hotel added to favorites' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add to favorites' });
  }
});

// Remove hotel from favorites
router.delete('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await db.query(
      'DELETE FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'hotel', id]
    );

    res.json({ message: 'Hotel removed from favorites' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Failed to remove from favorites' });
  }
});

// Create new hotel (admin only)
router.post('/', authenticateToken, async (req, res) => {
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

    // Validate required fields
    if (!name || !location || !lat || !lng || !price_range) {
      return res.status(400).json({ error: 'Name, location, coordinates, and price range are required' });
    }

    const [result] = await db.query(
      `INSERT INTO hotels (name, location, lat, lng, price_range, rating, amenities, contact_info, booking_url) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, location, lat, lng, price_range, rating, JSON.stringify(amenities), JSON.stringify(contact_info), booking_url]
    );

    res.status(201).json({
      message: 'Hotel created successfully',
      hotelId: result.insertId
    });
  } catch (error) {
    console.error('Create hotel error:', error);
    res.status(500).json({ error: 'Failed to create hotel' });
  }
});

// Update hotel (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.created_at;

    // Convert objects to JSON strings
    if (updateData.amenities) updateData.amenities = JSON.stringify(updateData.amenities);
    if (updateData.contact_info) updateData.contact_info = JSON.stringify(updateData.contact_info);

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE hotels SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, id]
    );

    res.json({ message: 'Hotel updated successfully' });
  } catch (error) {
    console.error('Update hotel error:', error);
    res.status(500).json({ error: 'Failed to update hotel' });
  }
});

module.exports = router;