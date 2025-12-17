-- TaniFresh Database Schema

CREATE DATABASE IF NOT EXISTS tanifresh;
USE tanifresh;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('client', 'admin') NOT NULL DEFAULT 'client',
    is_active BOOLEAN DEFAULT FALSE,
    address TEXT,
    phone VARCHAR(20),
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    unit ENUM('Kg', 'Ton', 'Kuintal') DEFAULT 'Kg',
    stock DECIMAL(10, 2) DEFAULT 0,
    category VARCHAR(100),
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    subtotal DECIMAL(15, 2) NOT NULL,
    discount DECIMAL(15, 2) DEFAULT 0,
    tax DECIMAL(15, 2) NOT NULL,
    total DECIMAL(15, 2) NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'delivered') DEFAULT 'pending',
    notes TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    product_id VARCHAR(36) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert default admin user (password: admin123)
INSERT INTO users (id, name, email, password, role, is_active) VALUES
('admin-001', 'Admin TaniFresh', 'admin@tanifresh.com', '$2a$10$kAzwutTopPyOVjCpBLaaXemcfTqKUbFh0K6NOAVR/XN5ytCrp4fNO', 'admin', TRUE);

-- Insert sample products
INSERT INTO products (id, name, description, price, unit, stock, category) VALUES
('prod-001', 'Kentang', 'Kentang berkualitas dari petani lokal', 15000, 'Kg', 500, 'Sayuran'),
('prod-002', 'Wortel', 'Wortel segar pilihan', 12000, 'Kg', 300, 'Sayuran'),
('prod-003', 'Tomat', 'Tomat merah segar', 8000, 'Kg', 400, 'Sayuran'),
('prod-004', 'Bawang Merah', 'Bawang merah kualitas terbaik', 25000, 'Kg', 200, 'Bumbu'),
('prod-005', 'Cabai Merah', 'Cabai merah pedas', 35000, 'Kg', 150, 'Bumbu'),
('prod-006', 'Selada', 'Selada hijau segar', 10000, 'Kg', 100, 'Sayuran');
