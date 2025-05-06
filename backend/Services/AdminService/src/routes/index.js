const express = require('express');
const router = express.Router();
const dashboardRoutes = require('./dashboardRoutes');
const userRoutes = require('./userRoutes');

router.use('/dashboard', dashboardRoutes);
router.use('/users', userRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Admin Service is up and running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;