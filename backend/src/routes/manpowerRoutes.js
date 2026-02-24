const express = require('express');
const router = express.Router();
const manpowerController = require('../controllers/manpowerController');
const { authenticateToken, requireRole } = require('../middleware/auth');

router.use(authenticateToken); // Protect all routes

router.get('/', manpowerController.getAllManpower);
router.post('/', requireRole('subcontractor'), manpowerController.createManpower);
router.put('/:id/approve', requireRole('admin'), (req, res) => {
    req.body.status = 'approved';
    manpowerController.updateApproval(req, res);
});
router.put('/:id/reject', requireRole('admin'), (req, res) => {
    req.body.status = 'rejected';
    manpowerController.updateApproval(req, res);
});
router.put('/:id/attendance', requireRole('subcontractor'), manpowerController.updateAttendance);

module.exports = router;
