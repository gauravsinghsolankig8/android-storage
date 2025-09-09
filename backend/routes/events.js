const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all events
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, event_type, upcoming } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT e.*, 
             (SELECT ei.image_url FROM event_images ei WHERE ei.event_id = e.id AND ei.is_primary = 1 LIMIT 1) as primary_image
      FROM events e
    `;
    let params = [];
    let conditions = [];

    if (search) {
      conditions.push('(e.name LIKE ? OR e.description LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }

    if (event_type) {
      conditions.push('e.event_type = ?');
      params.push(event_type);
    }

    if (upcoming === 'true') {
      conditions.push('e.start_date >= CURDATE()');
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY e.start_date ASC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [events] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM events e';
    let countParams = [];
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
      countParams = params.slice(0, -2); // Remove limit and offset
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      events,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Get event by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get event details
    const [events] = await db.query(
      'SELECT * FROM events WHERE id = ?',
      [id]
    );

    if (events.length === 0) {
      return res.status(404).json({ error: 'Event not found' });
    }

    const event = events[0];

    // Get event images
    const [images] = await db.query(
      'SELECT * FROM event_images WHERE event_id = ? ORDER BY is_primary DESC, created_at ASC',
      [id]
    );

    // Get related temples if best_temples is specified
    let relatedTemples = [];
    if (event.best_temples) {
      try {
        const bestTemplesIds = JSON.parse(event.best_temples);
        if (Array.isArray(bestTemplesIds) && bestTemplesIds.length > 0) {
          const placeholders = bestTemplesIds.map(() => '?').join(',');
          const [temples] = await db.query(
            `SELECT t.*, 
                    (SELECT ti.image_url FROM temple_images ti WHERE ti.temple_id = t.id AND ti.is_primary = 1 LIMIT 1) as primary_image
             FROM temples t
             WHERE t.id IN (${placeholders})`,
            bestTemplesIds
          );
          relatedTemples = temples;
        }
      } catch (parseError) {
        console.error('Error parsing best_temples:', parseError);
      }
    }

    res.json({
      ...event,
      images,
      relatedTemples
    });
  } catch (error) {
    console.error('Get event error:', error);
    res.status(500).json({ error: 'Failed to fetch event details' });
  }
});

// Get upcoming events
router.get('/upcoming/list', async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const [events] = await db.query(
      `SELECT e.*, 
              (SELECT ei.image_url FROM event_images ei WHERE ei.event_id = e.id AND ei.is_primary = 1 LIMIT 1) as primary_image
       FROM events e
       WHERE e.start_date >= CURDATE()
       ORDER BY e.start_date ASC
       LIMIT ?`,
      [parseInt(limit)]
    );

    res.json({ events });
  } catch (error) {
    console.error('Get upcoming events error:', error);
    res.status(500).json({ error: 'Failed to fetch upcoming events' });
  }
});

// Get events by date range
router.get('/date-range/:start/:end', async (req, res) => {
  try {
    const { start, end } = req.params;

    const [events] = await db.query(
      `SELECT e.*, 
              (SELECT ei.image_url FROM event_images ei WHERE ei.event_id = e.id AND ei.is_primary = 1 LIMIT 1) as primary_image
       FROM events e
       WHERE e.start_date BETWEEN ? AND ?
       ORDER BY e.start_date ASC`,
      [start, end]
    );

    res.json({ events });
  } catch (error) {
    console.error('Get events by date range error:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Add event to favorites
router.post('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if already favorited
    const [existing] = await db.query(
      'SELECT id FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'event', id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Event already in favorites' });
    }

    // Add to favorites
    await db.query(
      'INSERT INTO favorites (user_id, type, item_id) VALUES (?, ?, ?)',
      [userId, 'event', id]
    );

    res.json({ message: 'Event added to favorites' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add to favorites' });
  }
});

// Remove event from favorites
router.delete('/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await db.query(
      'DELETE FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'event', id]
    );

    res.json({ message: 'Event removed from favorites' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Failed to remove from favorites' });
  }
});

// Create new event (admin only)
router.post('/', authenticateToken, async (req, res) => {
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

    // Validate required fields
    if (!name || !start_date) {
      return res.status(400).json({ error: 'Name and start date are required' });
    }

    const [result] = await db.query(
      `INSERT INTO events (name, description, start_date, end_date, location, event_type, dos_donts, best_temples) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, start_date, end_date, location, event_type, JSON.stringify(dos_donts), JSON.stringify(best_temples)]
    );

    res.status(201).json({
      message: 'Event created successfully',
      eventId: result.insertId
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ error: 'Failed to create event' });
  }
});

// Update event (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.created_at;

    // Convert objects to JSON strings
    if (updateData.dos_donts) updateData.dos_donts = JSON.stringify(updateData.dos_donts);
    if (updateData.best_temples) updateData.best_temples = JSON.stringify(updateData.best_temples);

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE events SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, id]
    );

    res.json({ message: 'Event updated successfully' });
  } catch (error) {
    console.error('Update event error:', error);
    res.status(500).json({ error: 'Failed to update event' });
  }
});

module.exports = router;