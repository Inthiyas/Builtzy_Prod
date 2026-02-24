const db = require('../config/db');

const getAllEquipment = async (req, res) => {
    try {
        let query = `
            SELECT e.id, e.name, e.approval_status, e.created_at, 
                   s.user_id as subcontractor_id, 
                   es.status as deployment_status
            FROM equipment e
            JOIN subcontractors s ON e.subcontractor_id = s.id
            LEFT JOIN equipment_status es ON es.equipment_id = e.id AND es.date = CURRENT_DATE
            WHERE 1=1
        `;
        let params = [];
        let paramIndex = 1;

        // Support both /api/equipment?subcontractorId=X (query) and /api/subcontractors/:id/equipment (params)
        const subcontractorId = req.query.subcontractorId || req.params.id;

        // Admin sees all, subcontractor sees only their own
        if (req.user.role === 'subcontractor') {
            query += ` AND s.user_id = $${paramIndex++}`;
            params.push(req.user.id);
        } else if (subcontractorId) {
            query += ` AND e.subcontractor_id = $${paramIndex++}`;
            params.push(subcontractorId);
        }

        const { search, approval_status, deployment_status } = req.query;

        if (search) {
            query += ` AND e.name ILIKE $${paramIndex++}`;
            params.push(`%${search}%`);
        }

        if (approval_status && approval_status !== 'all') {
            query += ` AND e.approval_status = $${paramIndex++}`;
            params.push(approval_status);
        }

        if (deployment_status && deployment_status !== 'all') {
            if (deployment_status === 'non_deployed') {
                query += ` AND (es.status IS NULL OR es.status = 'non_deployed')`;
            } else {
                query += ` AND es.status = $${paramIndex++}`;
                params.push(deployment_status);
            }
        }

        query += ` ORDER BY e.created_at DESC`;

        const { rows } = await db.query(query, params);

        // Transform to match Flutter model structure exactly
        const data = rows.map(r => ({
            id: String(r.id),
            subcontractorId: String(r.subcontractor_id),
            name: r.name,
            type: 'General Equipment', // Using a default type since the SQL provided didn't have 'type' column
            approvalStatus: r.approval_status,
            deploymentStatus: r.deployment_status || 'non_deployed',
            date: r.created_at
        }));

        res.json({
            success: true,
            data: data
        });
    } catch (err) {
        console.error('Error fetching equipment:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const createEquipment = async (req, res) => {
    const { name, type } = req.body;

    if (!name) {
        return res.status(400).json({
            success: false,
            message: 'Name is required'
        });
    }

    try {
        const subRes = await db.query('SELECT id FROM subcontractors WHERE user_id = $1', [req.user.id]);
        if (subRes.rows.length === 0) {
            return res.status(403).json({
                success: false,
                message: 'Only subcontractors can add equipment'
            });
        }

        const subId = subRes.rows[0].id;

        const result = await db.query(
            'INSERT INTO equipment (subcontractor_id, name, approval_status) VALUES ($1, $2, $3) RETURNING *',
            [subId, name, 'pending']
        );

        const r = result.rows[0];
        res.status(201).json({
            success: true,
            data: {
                id: String(r.id),
                subcontractorId: String(req.user.id),
                name: r.name,
                type: type || 'General Equipment',
                approvalStatus: r.approval_status,
                deploymentStatus: 'non_deployed',
                date: r.created_at
            }
        });
    } catch (err) {
        console.error('Error creating equipment:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const updateApproval = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    if (status !== 'approved' && status !== 'rejected') {
        return res.status(400).json({
            success: false,
            message: 'Invalid status'
        });
    }

    try {
        const result = await db.query(
            'UPDATE equipment SET approval_status = $1 WHERE id = $2 RETURNING *',
            [status, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Equipment not found'
            });
        }

        res.json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('Error updating equipment approval:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const updateStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // 'deployed', 'non_deployed', 'under_repair'

    try {
        // Upsert status for today
        const query = `
      INSERT INTO equipment_status (equipment_id, date, status)
      VALUES ($1, CURRENT_DATE, $2)
      ON CONFLICT (equipment_id, date) 
      DO UPDATE SET status = EXCLUDED.status
      RETURNING *
    `;

        await db.query(query, [id, status]);

        res.json({ success: true });
    } catch (err) {
        console.error('Error updating equipment status:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

module.exports = {
    getAllEquipment,
    createEquipment,
    updateApproval,
    updateStatus
};
