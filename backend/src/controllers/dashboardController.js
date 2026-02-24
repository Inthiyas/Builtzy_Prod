const db = require('../config/db');

// Reusable queries since they depend only on subcontractor_id filter
const getMetricsQuery = (subIdConstraint = '') => `
  SELECT 
    (SELECT COUNT(*) FROM manpower m 
      ${subIdConstraint ? 'JOIN subcontractors s ON m.subcontractor_id = s.id WHERE s.user_id = $1' : ''}) as "totalManpower",
    (SELECT COUNT(*) FROM attendance a 
      JOIN manpower m ON a.manpower_id = m.id 
      ${subIdConstraint ? 'JOIN subcontractors s ON m.subcontractor_id = s.id WHERE a.date = CURRENT_DATE AND a.status = \'present\' AND s.user_id = $1' : 'WHERE a.date = CURRENT_DATE AND a.status = \'present\''}) as "presentManpower",
    (SELECT COUNT(*) FROM attendance a 
      JOIN manpower m ON a.manpower_id = m.id 
      ${subIdConstraint ? 'JOIN subcontractors s ON m.subcontractor_id = s.id WHERE a.date = CURRENT_DATE AND a.status = \'absent\' AND s.user_id = $1' : 'WHERE a.date = CURRENT_DATE AND a.status = \'absent\''}) as "absentManpower",
    
    (SELECT COUNT(*) FROM equipment e 
      ${subIdConstraint ? 'JOIN subcontractors s ON e.subcontractor_id = s.id WHERE s.user_id = $1' : ''}) as "totalEquipment",
    (SELECT COUNT(*) FROM equipment_status es 
      JOIN equipment e ON es.equipment_id = e.id 
      ${subIdConstraint ? 'JOIN subcontractors s ON e.subcontractor_id = s.id WHERE es.date = CURRENT_DATE AND es.status = \'deployed\' AND s.user_id = $1' : 'WHERE es.date = CURRENT_DATE AND es.status = \'deployed\''}) as "deployedEquipment",
    (SELECT COUNT(*) FROM equipment_status es 
      JOIN equipment e ON es.equipment_id = e.id 
      ${subIdConstraint ? 'JOIN subcontractors s ON e.subcontractor_id = s.id WHERE es.date = CURRENT_DATE AND es.status = \'under_repair\' AND s.user_id = $1' : 'WHERE es.date = CURRENT_DATE AND es.status = \'under_repair\''}) as "underRepairEquipment"
`;

const getMetrics = async (req, res) => {
  try {
    const isSub = req.user.role === 'subcontractor';
    const { rows } = isSub
      ? await db.query(getMetricsQuery('FILTERED'), [req.user.id])
      : await db.query(getMetricsQuery());

    const metrics = {
      totalManpower: parseInt(rows[0].totalManpower || 0),
      presentManpower: parseInt(rows[0].presentManpower || 0),
      absentManpower: parseInt(rows[0].absentManpower || 0),
      totalEquipment: parseInt(rows[0].totalEquipment || 0),
      deployedEquipment: parseInt(rows[0].deployedEquipment || 0),
      underRepairEquipment: parseInt(rows[0].underRepairEquipment || 0)
    };
    res.json({
      success: true,
      data: metrics
    });
  } catch (err) {
    console.error('Error fetching dashboard metrics:', err);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = {
  getMetrics
};
