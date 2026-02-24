const express = require('express');
const router = express.Router();
const equipmentController = require('../controllers/equipmentController');
const { authenticateToken, requireRole } = require('../middleware/auth');

router.use(authenticateToken);

router.get('/', equipmentController.getAllEquipment);
router.post('/', requireRole('subcontractor'), equipmentController.createEquipment);
router.put('/:id/approve', requireRole('admin'), (req, res) => {
    req.body.status = 'approved';
    equipmentController.updateApproval(req, res);
});
router.put('/:id/reject', requireRole('admin'), (req, res) => {
    req.body.status = 'rejected';
    equipmentController.updateApproval(req, res);
});
router.put('/:id/status', requireRole('subcontractor'), equipmentController.updateStatus);

module.exports = router;
