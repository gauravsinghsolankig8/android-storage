-- Saranam - Vrindavan Spiritual Guide App Database Schema
-- MySQL Database Schema

CREATE DATABASE IF NOT EXISTS saranam_db;
USE saranam_db;

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255),
    auth_provider ENUM('google', 'phone', 'email') NOT NULL,
    profile_image_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    role ENUM('user', 'admin', 'super_admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Temples table
CREATE TABLE temples (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(500) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    history TEXT,
    timings JSON,
    amenities JSON,
    rituals JSON,
    description TEXT,
    contact_info JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Temple images table
CREATE TABLE temple_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    temple_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (temple_id) REFERENCES temples(id) ON DELETE CASCADE
);

-- Saints table
CREATE TABLE saints (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    sect VARCHAR(255),
    bio TEXT,
    schedule JSON,
    teachings TEXT,
    birth_date DATE,
    death_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Saint images table
CREATE TABLE saint_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    saint_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (saint_id) REFERENCES saints(id) ON DELETE CASCADE
);

-- Events table
CREATE TABLE events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    location VARCHAR(500),
    event_type ENUM('festival', 'celebration', 'special_darshan', 'other') NOT NULL,
    dos_donts JSON,
    best_temples JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Event images table
CREATE TABLE event_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- Parikrama routes table
CREATE TABLE parikrama_routes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    total_distance DECIMAL(8, 2),
    estimated_time INT, -- in minutes
    difficulty_level ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Parikrama stops table
CREATE TABLE parikrama_stops (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    stop_name VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    narration TEXT,
    stop_order INT NOT NULL,
    nearby_temples JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES parikrama_routes(id) ON DELETE CASCADE
);

-- Hotels table
CREATE TABLE hotels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(500) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    price_range ENUM('budget', 'mid', 'premium', 'luxury') NOT NULL,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    amenities JSON,
    contact_info JSON,
    booking_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Hotel images table
CREATE TABLE hotel_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotel_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

-- Store products table
CREATE TABLE store_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    category ENUM('books', 'malas', 'prasad', 'clothing', 'accessories', 'other') NOT NULL,
    weight DECIMAL(8, 2), -- in grams
    dimensions JSON, -- length, width, height
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Product images table
CREATE TABLE product_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES store_products(id) ON DELETE CASCADE
);

-- Today's darshan table
CREATE TABLE todays_darshan (
    id INT PRIMARY KEY AUTO_INCREMENT,
    temple_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    caption VARCHAR(255),
    date_uploaded DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (temple_id) REFERENCES temples(id) ON DELETE CASCADE
);

-- Favorites table
CREATE TABLE favorites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('temple', 'saint', 'event', 'hotel', 'product') NOT NULL,
    item_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, type, item_id)
);

-- Orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address JSON,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES store_products(id) ON DELETE CASCADE
);

-- Notifications table
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    type ENUM('reminder', 'event', 'darshan', 'order', 'general') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    data JSON, -- additional data for the notification
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Badges table
CREATE TABLE badges (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    badge_name VARCHAR(255) NOT NULL,
    badge_type ENUM('parikrama', 'darshan', 'events', 'store', 'general') NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    date_earned TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- User settings table
CREATE TABLE user_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    dark_mode BOOLEAN DEFAULT FALSE,
    language VARCHAR(10) DEFAULT 'en',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_settings (user_id)
);

-- Insert sample data
INSERT INTO temples (name, location, lat, lng, history, timings, amenities, rituals) VALUES
('Banke Bihari Temple', 'Vrindavan, Uttar Pradesh', 27.5848, 77.6964, 'One of the most sacred temples in Vrindavan, dedicated to Lord Krishna in his child form.', '{"morning": "7:30 AM - 12:00 PM", "evening": "4:30 PM - 9:00 PM"}', '["parking", "shoe_storage", "prasad_counter"]', '["mangala_aarti", "shringar_darshan", "rajbhog_darshan", "sandhya_aarti"]'),
('ISKCON Temple', 'Vrindavan, Uttar Pradesh', 27.5841, 77.6961, 'International Society for Krishna Consciousness temple with beautiful architecture.', '{"morning": "4:30 AM - 8:30 PM", "evening": "4:30 PM - 8:30 PM"}', '["parking", "restaurant", "bookstore", "accommodation"]', '["mangala_aarti", "guru_puja", "bhagavatam_class", "kirtan"]'),
('Radha Raman Temple', 'Vrindavan, Uttar Pradesh', 27.5850, 77.6960, 'Ancient temple dedicated to Radha Raman, a form of Lord Krishna.', '{"morning": "8:00 AM - 12:00 PM", "evening": "4:00 PM - 8:00 PM"}', '["parking", "shoe_storage"]', '["mangala_aarti", "shringar_darshan", "sandhya_aarti"]');

INSERT INTO saints (name, sect, bio, schedule, is_current) VALUES
('Chaitanya Mahaprabhu', 'Gaudiya Vaishnavism', 'Founder of Gaudiya Vaishnavism and the Hare Krishna movement.', '{"daily": "Morning prayers and kirtan", "weekly": "Bhagavatam classes on Sundays"}', FALSE),
('Vallabhacharya', 'Pushtimarg', 'Founder of Pushtimarg sect, known for his devotion to Lord Krishna.', '{"daily": "Morning and evening prayers", "special": "Festival celebrations"}', FALSE),
('Swami Prabhupada', 'ISKCON', 'Founder of ISKCON, spread Krishna consciousness worldwide.', '{"daily": "Morning and evening programs", "weekly": "Sunday feast programs"}', FALSE);

INSERT INTO events (name, description, start_date, end_date, location, event_type) VALUES
('Janmashtami', 'Birthday celebration of Lord Krishna', '2024-08-26', '2024-08-27', 'All temples in Vrindavan', 'festival'),
('Radhashtami', 'Birthday celebration of Radha Rani', '2024-09-07', '2024-09-08', 'All temples in Vrindavan', 'festival'),
('Holi', 'Festival of colors celebrating divine love', '2024-03-25', '2024-03-26', 'Vrindavan', 'festival');

INSERT INTO parikrama_routes (name, description, total_distance, estimated_time, difficulty_level) VALUES
('Govardhan Parikrama', 'Sacred circumambulation of Govardhan Hill', 21.0, 480, 'medium'),
('Vrindavan Parikrama', 'Circumambulation of Vrindavan town', 10.5, 240, 'easy'),
('Mathura Parikrama', 'Circumambulation of Mathura city', 15.0, 360, 'medium');

INSERT INTO hotels (name, location, lat, lng, price_range, rating, amenities) VALUES
('Hotel Goverdhan Palace', 'Vrindavan, Uttar Pradesh', 27.5845, 77.6965, 'premium', 4.2, '["wifi", "restaurant", "parking", "ac"]'),
('MVT Guest House', 'Vrindavan, Uttar Pradesh', 27.5842, 77.6962, 'budget', 3.8, '["parking", "basic_amenities"]'),
('Radha Krishna Hotel', 'Vrindavan, Uttar Pradesh', 27.5848, 77.6968, 'mid', 4.0, '["wifi", "restaurant", "parking"]');

INSERT INTO store_products (name, description, price, stock, category) VALUES
('Bhagavad Gita', 'Sacred Hindu scripture with commentary', 299.00, 50, 'books'),
('Tulsi Mala', 'Sacred prayer beads made of tulsi wood', 199.00, 100, 'malas'),
('Krishna Prasad', 'Blessed food offering from temple', 99.00, 200, 'prasad'),
('Krishna T-shirt', 'Cotton t-shirt with Krishna design', 599.00, 75, 'clothing');