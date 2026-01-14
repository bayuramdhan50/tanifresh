const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Authentication middleware
const authMiddleware = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        if (!token) {
            return res.status(401).json({ message: 'Token tidak ditemukan' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.userId;
        req.userRole = decoded.role;
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token tidak valid' });
    }
};

// Admin middleware
const adminMiddleware = (req, res, next) => {
    if (req.userRole !== 'admin') {
        return res.status(403).json({ message: 'Akses ditolak' });
    }
    next();
};

// ==================== AUTH ROUTES ====================

// Register
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password, role, address, phone } = req.body;

        // Check if email exists
        const [existing] = await pool.query(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );

        if (existing.length > 0) {
            return res.status(400).json({ message: 'Email sudah terdaftar' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert user
        const userId = uuidv4();
        await pool.query(
            'INSERT INTO users (id, name, email, password, role, address, phone) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [userId, name, email, hashedPassword, role || 'client', address, phone]
        );

        res.status(201).json({
            message: 'Registrasi berhasil. Menunggu persetujuan admin.',
            user: { id: userId, name, email, role: role || 'client' }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Login
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user
        const [users] = await pool.query(
            'SELECT * FROM users WHERE email = ?',
            [email]
        );

        if (users.length === 0) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        const user = users[0];

        // Check password
        const isValidPassword = await bcrypt.compare(password, user.password);

        if (!isValidPassword) {
            return res.status(401).json({ message: 'Email atau password salah' });
        }

        // Generate token
        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                is_active: user.is_active,
                address: user.address,
                phone: user.phone,
                created_at: user.created_at
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Get profile
app.get('/api/auth/profile', authMiddleware, async (req, res) => {
    try {
        const [users] = await pool.query(
            'SELECT id, name, email, role, is_active, address, phone, created_at FROM users WHERE id = ?',
            [req.userId]
        );

        if (users.length === 0) {
            return res.status(404).json({ message: 'User tidak ditemukan' });
        }

        res.json({ user: users[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// ==================== PRODUCT ROUTES ====================

// Get all products
app.get('/api/products', authMiddleware, async (req, res) => {
    try {
        const [products] = await pool.query(
            'SELECT * FROM products WHERE stock > 0 ORDER BY name'
        );

        res.json({ products });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Create product (admin only)
app.post('/api/products', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { name, description, price, unit, stock, category } = req.body;

        const productId = uuidv4();
        await pool.query(
            'INSERT INTO products (id, name, description, price, unit, stock, category) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [productId, name, description, price, unit || 'Kg', stock || 0, category]
        );

        res.status(201).json({
            message: 'Produk berhasil ditambahkan',
            product: { id: productId, name, price, unit, stock }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// ==================== ORDER ROUTES ====================

// Create order
app.post('/api/orders', authMiddleware, async (req, res) => {
    try {
        const { items, subtotal, discount, tax, total, notes } = req.body;

        const orderId = uuidv4();

        // Insert order
        await pool.query(
            'INSERT INTO orders (id, user_id, subtotal, discount, tax, total, notes) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [orderId, req.userId, subtotal, discount, tax, total, notes]
        );

        // Insert order items
        for (const item of items) {
            const itemId = uuidv4();
            await pool.query(
                'INSERT INTO order_items (id, order_id, product_id, product_name, price, quantity, unit) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [itemId, orderId, item.product_id, item.product_name, item.price, item.quantity, item.unit]
            );
        }

        res.status(201).json({
            message: 'Pesanan berhasil dibuat',
            order: { id: orderId, total }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Get orders
app.get('/api/orders', authMiddleware, async (req, res) => {
    try {
        let query = `
      SELECT o.*, u.name as user_name
      FROM orders o
      JOIN users u ON o.user_id = u.id
    `;

        const params = [];

        // Filter by user role
        if (req.userRole === 'client') {
            query += ' WHERE o.user_id = ?';
            params.push(req.userId);
        }

        query += ' ORDER BY o.created_at DESC';

        const [orders] = await pool.query(query, params);

        // Get items for each order
        for (const order of orders) {
            const [items] = await pool.query(
                'SELECT * FROM order_items WHERE order_id = ?',
                [order.id]
            );
            order.items = items;
        }

        res.json({ orders });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Update order status (admin only)
app.put('/api/orders/:id/status', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const { status, rejection_reason } = req.body;

        await pool.query(
            'UPDATE orders SET status = ?, rejection_reason = ? WHERE id = ?',
            [status, rejection_reason || null, id]
        );

        res.json({ message: 'Status pesanan berhasil diupdate' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// ==================== ADMIN ROUTES ====================

// Get pending users
app.get('/api/admin/pending-users', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const [users] = await pool.query(
            'SELECT id, name, email, role, address, phone, created_at FROM users WHERE is_active = FALSE'
        );

        res.json({ users });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Approve user
app.put('/api/admin/users/:id/approve', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        await pool.query(
            'UPDATE users SET is_active = TRUE WHERE id = ?',
            [id]
        );

        res.json({ message: 'User berhasil disetujui' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Reject user
app.delete('/api/admin/users/:id/reject', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        await pool.query('DELETE FROM users WHERE id = ?', [id]);

        res.json({ message: 'User berhasil ditolak' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// ==================== ANALYTICS ROUTES ====================

// Get admin analytics (NO AUTH for quick testing)
app.get('/api/admin/analytics', async (req, res) => {
    try {
        // Get order statistics by month (last 6 months)
        const [monthlyOrders] = await pool.query(`
            SELECT 
                DATE_FORMAT(created_at, '%Y-%m') as month,
                COUNT(*) as count,
                SUM(total) as revenue
            FROM orders
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
            GROUP BY DATE_FORMAT(created_at, '%Y-%m')
            ORDER BY month ASC
        `);

        // Get orders by status
        const [statusCounts] = await pool.query(`
            SELECT status, COUNT(*) as count
            FROM orders
            GROUP BY status
        `);

        // Get top products
        const [topProducts] = await pool.query(`
            SELECT 
                oi.product_name,
                SUM(oi.quantity) as total_quantity,
                COUNT(DISTINCT oi.order_id) as order_count
            FROM order_items oi
            GROUP BY oi.product_name
            ORDER BY total_quantity DESC
            LIMIT 5
        `);

        res.json({
            monthlyOrders,
            statusCounts,
            topProducts
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// Get client statistics (NO AUTH for quick testing)
app.get('/api/client/statistics', async (req, res) => {
    try {
        // Get ALL users' order statistics by month (last 6 months)
        // For demo without auth, show aggregate data
        const [monthlyOrders] = await pool.query(`
            SELECT 
                DATE_FORMAT(created_at, '%Y-%m') as month,
                COUNT(*) as count,
                SUM(total) as total_spent
            FROM orders
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
            GROUP BY DATE_FORMAT(created_at, '%Y-%m')
            ORDER BY month ASC
        `);

        // Get orders by status
        const [statusCounts] = await pool.query(`
            SELECT status, COUNT(*) as count
            FROM orders
            GROUP BY status
        `);

        // Get top purchased products (all users)
        const [topProducts] = await pool.query(`
            SELECT 
                oi.product_name,
                SUM(oi.quantity) as total_quantity,
                SUM(oi.price * oi.quantity) as total_spent
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.id
            GROUP BY oi.product_name
            ORDER BY total_quantity DESC
            LIMIT 5
        `);

        res.json({
            monthlyOrders,
            statusCounts,
            topProducts
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

// ==================== WEATHER ROUTE ====================

// Get weather
app.get('/api/weather', async (req, res) => {
    try {
        const city = req.query.city || 'Bandung';
        const apiKey = process.env.OPENWEATHER_API_KEY;
        const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric&lang=id`;

        const response = await axios.get(url);
        res.json(response.data);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil data cuaca' });
    }
});

// ==================== START SERVER ====================

app.listen(PORT, () => {
    console.log(`✅ TatanenFresh Backend running on http://localhost:${PORT}`);
    console.log(`📊 Database: ${process.env.DB_NAME}`);
});
