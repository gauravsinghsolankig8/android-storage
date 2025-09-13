const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all parikrama routes
router.get('/routes', async (req, res) => {
  try {
    const [routes] = await db.query(
      'SELECT * FROM parikrama_routes ORDER BY name'
    );

    res.json({ routes });
  } catch (error) {
    console.error('Get parikrama routes error:', error);
    res.status(500).json({ error: 'Failed to fetch parikrama routes' });
  }
});

// Get parikrama route by ID with stops
router.get('/routes/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get route details
    const [routes] = await db.query(
      'SELECT * FROM parikrama_routes WHERE id = ?',
      [id]
    );

    if (routes.length === 0) {
      return res.status(404).json({ error: 'Parikrama route not found' });
    }

    const route = routes[0];

    // Get route stops
    const [stops] = await db.query(
      'SELECT * FROM parikrama_stops WHERE route_id = ? ORDER BY stop_order ASC',
      [id]
    );

    res.json({
      ...route,
      stops
    });
  } catch (error) {
    console.error('Get parikrama route error:', error);
    res.status(500).json({ error: 'Failed to fetch parikrama route' });
  }
});

// Get parikrama stops for a route
router.get('/routes/:id/stops', async (req, res) => {
  try {
    const { id } = req.params;

    const [stops] = await db.query(
      `SELECT ps.*, 
              (SELECT COUNT(*) FROM temples t WHERE JSON_CONTAINS(ps.nearby_temples, CAST(t.id AS JSON))) as nearby_temples_count
       FROM parikrama_stops ps
       WHERE ps.route_id = ?
       ORDER BY ps.stop_order ASC`,
      [id]
    );

    res.json({ stops });
  } catch (error) {
    console.error('Get parikrama stops error:', error);
    res.status(500).json({ error: 'Failed to fetch parikrama stops' });
  }
});

// Get current location and nearest stop
router.get('/nearest-stop/:lat/:lng', async (req, res) => {
  try {
    const { lat, lng } = req.params;
    const { route_id } = req.query;

    let query = `
      SELECT ps.*, pr.name as route_name,
             (6371 * acos(cos(radians(?)) * cos(radians(ps.lat)) * cos(radians(ps.lng) - radians(?)) + sin(radians(?)) * sin(radians(ps.lat)))) AS distance
      FROM parikrama_stops ps
      JOIN parikrama_routes pr ON ps.route_id = pr.id
    `;
    let params = [lat, lng, lat];

    if (route_id) {
      query += ' WHERE ps.route_id = ?';
      params.push(route_id);
    }

    query += ' ORDER BY distance LIMIT 1';

    const [nearestStop] = await db.query(query, params);

    if (nearestStop.length === 0) {
      return res.status(404).json({ error: 'No parikrama stops found' });
    }

    res.json({ nearestStop: nearestStop[0] });
  } catch (error) {
    console.error('Get nearest stop error:', error);
    res.status(500).json({ error: 'Failed to find nearest stop' });
  }
});

// Get parikrama progress for user
router.get('/progress', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user's parikrama badges
    const [badges] = await db.query(
      `SELECT b.*, pr.name as route_name
       FROM badges b
       JOIN parikrama_routes pr ON JSON_EXTRACT(b.data, '$.route_id') = pr.id
       WHERE b.user_id = ? AND b.badge_type = 'parikrama'
       ORDER BY b.date_earned DESC`,
      [userId]
    );

    // Get all available routes
    const [routes] = await db.query(
      'SELECT * FROM parikrama_routes ORDER BY name'
    );

    // Calculate progress
    const progress = routes.map(route => {
      const routeBadge = badges.find(badge => 
        JSON.parse(badge.data || '{}').route_id === route.id
      );
      
      return {
        routeId: route.id,
        routeName: route.name,
        completed: !!routeBadge,
        completedDate: routeBadge ? routeBadge.date_earned : null,
        totalDistance: route.total_distance,
        estimatedTime: route.estimated_time
      };
    });

    res.json({ progress });
  } catch (error) {
    console.error('Get parikrama progress error:', error);
    res.status(500).json({ error: 'Failed to fetch parikrama progress' });
  }
});

// Mark parikrama as completed
router.post('/complete', authenticateToken, async (req, res) => {
  try {
    const { route_id, completion_time, notes } = req.body;
    const userId = req.user.id;

    if (!route_id) {
      return res.status(400).json({ error: 'Route ID is required' });
    }

    // Check if already completed
    const [existingBadge] = await db.query(
      `SELECT id FROM badges 
       WHERE user_id = ? AND badge_type = 'parikrama' 
       AND JSON_EXTRACT(data, '$.route_id') = ?`,
      [userId, route_id]
    );

    if (existingBadge.length > 0) {
      return res.status(400).json({ error: 'Parikrama already completed' });
    }

    // Get route details
    const [routes] = await db.query(
      'SELECT name FROM parikrama_routes WHERE id = ?',
      [route_id]
    );

    if (routes.length === 0) {
      return res.status(404).json({ error: 'Route not found' });
    }

    const routeName = routes[0].name;

    // Create completion badge
    const badgeData = {
      route_id: parseInt(route_id),
      completion_time: completion_time,
      notes: notes
    };

    await db.query(
      `INSERT INTO badges (user_id, badge_name, badge_type, description, data) 
       VALUES (?, ?, ?, ?, ?)`,
      [
        userId,
        `${routeName} Completed`,
        'parikrama',
        `Successfully completed ${routeName} parikrama`,
        JSON.stringify(badgeData)
      ]
    );

    // Send notification
    await db.query(
      `INSERT INTO notifications (user_id, message, type, data) 
       VALUES (?, ?, ?, ?)`,
      [
        userId,
        `Congratulations! You have completed ${routeName} parikrama.`,
        'general',
        JSON.stringify({ route_id, badge_type: 'parikrama' })
      ]
    );

    res.json({ 
      message: 'Parikrama marked as completed',
      badge: {
        name: `${routeName} Completed`,
        type: 'parikrama',
        dateEarned: new Date()
      }
    });
  } catch (error) {
    console.error('Complete parikrama error:', error);
    res.status(500).json({ error: 'Failed to mark parikrama as completed' });
  }
});

// Get nearby temples for a stop
router.get('/stops/:id/temples', async (req, res) => {
  try {
    const { id } = req.params;

    // Get stop details
    const [stops] = await db.query(
      'SELECT nearby_temples FROM parikrama_stops WHERE id = ?',
      [id]
    );

    if (stops.length === 0) {
      return res.status(404).json({ error: 'Stop not found' });
    }

    const nearbyTemplesIds = JSON.parse(stops[0].nearby_temples || '[]');
    
    if (nearbyTemplesIds.length === 0) {
      return res.json({ temples: [] });
    }

    const placeholders = nearbyTemplesIds.map(() => '?').join(',');
    const [temples] = await db.query(
      `SELECT t.*, 
              (SELECT ti.image_url FROM temple_images ti WHERE ti.temple_id = t.id AND ti.is_primary = 1 LIMIT 1) as primary_image
       FROM temples t
       WHERE t.id IN (${placeholders})`,
      nearbyTemplesIds
    );

    res.json({ temples });
  } catch (error) {
    console.error('Get stop temples error:', error);
    res.status(500).json({ error: 'Failed to fetch nearby temples' });
  }
});

// Create new parikrama route (admin only)
router.post('/routes', authenticateToken, async (req, res) => {
  try {
    const {
      name,
      description,
      total_distance,
      estimated_time,
      difficulty_level
    } = req.body;

    // Validate required fields
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const [result] = await db.query(
      `INSERT INTO parikrama_routes (name, description, total_distance, estimated_time, difficulty_level) 
       VALUES (?, ?, ?, ?, ?)`,
      [name, description, total_distance, estimated_time, difficulty_level]
    );

    res.status(201).json({
      message: 'Parikrama route created successfully',
      routeId: result.insertId
    });
  } catch (error) {
    console.error('Create parikrama route error:', error);
    res.status(500).json({ error: 'Failed to create parikrama route' });
  }
});

// Create new parikrama stop (admin only)
router.post('/stops', authenticateToken, async (req, res) => {
  try {
    const {
      route_id,
      stop_name,
      lat,
      lng,
      narration,
      stop_order,
      nearby_temples
    } = req.body;

    // Validate required fields
    if (!route_id || !stop_name || !lat || !lng) {
      return res.status(400).json({ error: 'Route ID, stop name, and coordinates are required' });
    }

    const [result] = await db.query(
      `INSERT INTO parikrama_stops (route_id, stop_name, lat, lng, narration, stop_order, nearby_temples) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [route_id, stop_name, lat, lng, narration, stop_order, JSON.stringify(nearby_temples)]
    );

    res.status(201).json({
      message: 'Parikrama stop created successfully',
      stopId: result.insertId
    });
  } catch (error) {
    console.error('Create parikrama stop error:', error);
    res.status(500).json({ error: 'Failed to create parikrama stop' });
  }
});

module.exports = router;