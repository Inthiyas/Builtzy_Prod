const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const { authenticateToken, requireRole } = require('../middleware/auth');

router.use(authenticateToken); // Protect all routes

router.get('/metrics', dashboardController.getMetrics);

module.exports = router;
