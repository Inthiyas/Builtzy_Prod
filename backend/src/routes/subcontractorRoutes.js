const express = require('express');
const router = express.Router();
const subcontractorController = require('../controllers/subcontractorController');
const manpowerController = require('../controllers/manpowerController');
const equipmentController = require('../controllers/equipmentController');
const { authenticateToken, requireRole } = require('../middleware/auth');

router.use(authenticateToken);
router.use(requireRole('admin'));

router.get('/', subcontractorController.getAllSubcontractors);
router.post('/', subcontractorController.createSubcontractor);
router.put('/:id', subcontractorController.updateSubcontractor);
router.delete('/:id', subcontractorController.deleteSubcontractor);

// Hierarchical Nested Routes
router.get('/:id/manpower', manpowerController.getAllManpower);
router.get('/:id/equipment', equipmentController.getAllEquipment);

module.exports = router;
