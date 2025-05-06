const express = require('express');
const router = express.Router();
const jobRoutes = require('./jobRoutes');
const earningsRoutes = require('./earningsRoutes');

router.use('/jobs', jobRoutes);
router.use('/earnings', earningsRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Technician Service is up and running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;