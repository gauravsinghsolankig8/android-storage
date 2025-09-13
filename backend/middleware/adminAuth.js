const jwt = require('jsonwebtoken');
const db = require('../config/database');

const authenticateAdmin = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Admin access token required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Verify admin user exists and has admin role
    const [users] = await db.query(
      'SELECT id, name, email, role FROM users WHERE id = ? AND role = ?',
      [decoded.userId, 'admin']
    );

    if (users.length === 0) {
      return res.status(403).json({ error: 'Admin access denied' });
    }

    req.admin = users[0];
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Admin token expired' });
    }
    return res.status(403).json({ error: 'Invalid admin token' });
  }
};

const requireAdminRole = (requiredRole = 'admin') => {
  return (req, res, next) => {
    if (req.admin.role !== requiredRole && req.admin.role !== 'super_admin') {
      return res.status(403).json({ error: 'Insufficient admin privileges' });
    }
    next();
  };
};

module.exports = {
  authenticateAdmin,
  requireAdminRole
};