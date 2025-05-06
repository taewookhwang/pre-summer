const express = require('express');
const router = express.Router();
const serviceRoutes = require('./serviceRoutes');
const reservationRoutes = require('./reservationRoutes');

router.use('/services', serviceRoutes);
router.use('/reservations', reservationRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Consumer Service is up and running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;