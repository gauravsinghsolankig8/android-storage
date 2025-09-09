const mysql = require('mysql2');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'saranam_db',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
};

const pool = mysql.createPool(dbConfig);

const db = {
  pool,
  query: (sql, params) => {
    return new Promise((resolve, reject) => {
      pool.execute(sql, params, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results);
        }
      });
    });
  },
  connect: (callback) => {
    pool.getConnection((err, connection) => {
      if (err) {
        callback(err);
      } else {
        console.log('Database connected successfully');
        connection.release();
        callback(null);
      }
    });
  }
};

module.exports = db;