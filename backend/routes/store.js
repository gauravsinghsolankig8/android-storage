const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all products
router.get('/products', async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category, in_stock } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT p.*, 
             (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as primary_image
      FROM store_products p
    `;
    let params = [];
    let conditions = [];

    if (search) {
      conditions.push('(p.name LIKE ? OR p.description LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }

    if (category) {
      conditions.push('p.category = ?');
      params.push(category);
    }

    if (in_stock === 'true') {
      conditions.push('p.stock > 0');
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY p.name LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [products] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM store_products p';
    let countParams = [];
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
      countParams = params.slice(0, -2); // Remove limit and offset
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Get product by ID
router.get('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get product details
    const [products] = await db.query(
      'SELECT * FROM store_products WHERE id = ?',
      [id]
    );

    if (products.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const product = products[0];

    // Get product images
    const [images] = await db.query(
      'SELECT * FROM product_images WHERE product_id = ? ORDER BY is_primary DESC, created_at ASC',
      [id]
    );

    // Get related products in same category
    const [relatedProducts] = await db.query(
      `SELECT p.*, 
              (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as primary_image
       FROM store_products p
       WHERE p.category = ? AND p.id != ? AND p.stock > 0
       ORDER BY p.name
       LIMIT 5`,
      [product.category, id]
    );

    res.json({
      ...product,
      images,
      relatedProducts
    });
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ error: 'Failed to fetch product details' });
  }
});

// Get products by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const [products] = await db.query(
      `SELECT p.*, 
              (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as primary_image
       FROM store_products p
       WHERE p.category = ? AND p.stock > 0
       ORDER BY p.name
       LIMIT ? OFFSET ?`,
      [category, parseInt(limit), parseInt(offset)]
    );

    // Get total count
    const [countResult] = await db.query(
      'SELECT COUNT(*) as total FROM store_products WHERE category = ? AND stock > 0',
      [category]
    );
    const total = countResult[0].total;

    res.json({
      products,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get products by category error:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// Add product to favorites
router.post('/products/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Check if already favorited
    const [existing] = await db.query(
      'SELECT id FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'product', id]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Product already in favorites' });
    }

    // Add to favorites
    await db.query(
      'INSERT INTO favorites (user_id, type, item_id) VALUES (?, ?, ?)',
      [userId, 'product', id]
    );

    res.json({ message: 'Product added to favorites' });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({ error: 'Failed to add to favorites' });
  }
});

// Remove product from favorites
router.delete('/products/:id/favorite', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await db.query(
      'DELETE FROM favorites WHERE user_id = ? AND type = ? AND item_id = ?',
      [userId, 'product', id]
    );

    res.json({ message: 'Product removed from favorites' });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({ error: 'Failed to remove from favorites' });
  }
});

// Create order
router.post('/orders', authenticateToken, async (req, res) => {
  try {
    const { product_id, quantity, shipping_address } = req.body;
    const userId = req.user.id;

    if (!product_id || !quantity || !shipping_address) {
      return res.status(400).json({ error: 'Product ID, quantity, and shipping address are required' });
    }

    // Get product details
    const [products] = await db.query(
      'SELECT * FROM store_products WHERE id = ?',
      [product_id]
    );

    if (products.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    const product = products[0];

    // Check stock availability
    if (product.stock < quantity) {
      return res.status(400).json({ error: 'Insufficient stock' });
    }

    // Calculate total amount
    const totalAmount = product.price * quantity;

    // Create order
    const [result] = await db.query(
      `INSERT INTO orders (user_id, product_id, quantity, total_amount, shipping_address) 
       VALUES (?, ?, ?, ?, ?)`,
      [userId, product_id, quantity, totalAmount, JSON.stringify(shipping_address)]
    );

    // Update stock
    await db.query(
      'UPDATE store_products SET stock = stock - ? WHERE id = ?',
      [quantity, product_id]
    );

    // Send notification
    await db.query(
      `INSERT INTO notifications (user_id, message, type, data) 
       VALUES (?, ?, ?, ?)`,
      [
        userId,
        `Your order for ${product.name} has been placed successfully. Order ID: ${result.insertId}`,
        'order',
        JSON.stringify({ order_id: result.insertId, product_id })
      ]
    );

    res.status(201).json({
      message: 'Order created successfully',
      orderId: result.insertId,
      totalAmount
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// Get user orders
router.get('/orders', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 20, status } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT o.*, p.name as product_name, p.price, p.category,
             (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as product_image
      FROM orders o
      JOIN store_products p ON o.product_id = p.id
      WHERE o.user_id = ?
    `;
    let params = [userId];

    if (status) {
      query += ' AND o.status = ?';
      params.push(status);
    }

    query += ' ORDER BY o.order_date DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [orders] = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM orders WHERE user_id = ?';
    let countParams = [userId];
    
    if (status) {
      countQuery += ' AND status = ?';
      countParams.push(status);
    }

    const [countResult] = await db.query(countQuery, countParams);
    const total = countResult[0].total;

    res.json({
      orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// Get order by ID
router.get('/orders/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const [orders] = await db.query(
      `SELECT o.*, p.name as product_name, p.price, p.category, p.description,
              (SELECT pi.image_url FROM product_images pi WHERE pi.product_id = p.id AND pi.is_primary = 1 LIMIT 1) as product_image
       FROM orders o
       JOIN store_products p ON o.product_id = p.id
       WHERE o.id = ? AND o.user_id = ?`,
      [id, userId]
    );

    if (orders.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json({ order: orders[0] });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ error: 'Failed to fetch order details' });
  }
});

// Cancel order
router.put('/orders/:id/cancel', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Get order details
    const [orders] = await db.query(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (orders.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const order = orders[0];

    if (order.status === 'cancelled') {
      return res.status(400).json({ error: 'Order is already cancelled' });
    }

    if (order.status === 'delivered') {
      return res.status(400).json({ error: 'Cannot cancel delivered order' });
    }

    // Update order status
    await db.query(
      'UPDATE orders SET status = ? WHERE id = ?',
      ['cancelled', id]
    );

    // Restore stock
    await db.query(
      'UPDATE store_products SET stock = stock + ? WHERE id = ?',
      [order.quantity, order.product_id]
    );

    res.json({ message: 'Order cancelled successfully' });
  } catch (error) {
    console.error('Cancel order error:', error);
    res.status(500).json({ error: 'Failed to cancel order' });
  }
});

// Create new product (admin only)
router.post('/products', authenticateToken, async (req, res) => {
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

    // Validate required fields
    if (!name || !price || !category) {
      return res.status(400).json({ error: 'Name, price, and category are required' });
    }

    const [result] = await db.query(
      `INSERT INTO store_products (name, description, price, stock, category, weight, dimensions) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [name, description, price, stock || 0, category, weight, JSON.stringify(dimensions)]
    );

    res.status(201).json({
      message: 'Product created successfully',
      productId: result.insertId
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ error: 'Failed to create product' });
  }
});

// Update product (admin only)
router.put('/products/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.id;
    delete updateData.created_at;

    // Convert objects to JSON strings
    if (updateData.dimensions) updateData.dimensions = JSON.stringify(updateData.dimensions);

    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    const setClause = fields.map(field => `${field} = ?`).join(', ');

    await db.query(
      `UPDATE store_products SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
      [...values, id]
    );

    res.json({ message: 'Product updated successfully' });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({ error: 'Failed to update product' });
  }
});

module.exports = router;