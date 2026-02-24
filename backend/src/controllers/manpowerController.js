const db = require('../config/db');

const getAllManpower = async (req, res) => {
    try {
        let query = `
            SELECT m.id, m.name, m.approval_status, m.created_at, 
                   s.user_id as subcontractor_id, 
                   a.status as attendance_status
            FROM manpower m
            JOIN subcontractors s ON m.subcontractor_id = s.id
            LEFT JOIN attendance a ON a.manpower_id = m.id AND a.date = CURRENT_DATE
            WHERE 1=1
        `;
        let params = [];
        let paramIndex = 1;

        // Support both /api/manpower?subcontractorId=X (query) and /api/subcontractors/:id/manpower (params)
        const subcontractorId = req.query.subcontractorId || req.params.id;

        // Admin sees all, subcontractor sees only their own
        if (req.user.role === 'subcontractor') {
            query += ` AND s.user_id = $${paramIndex++}`;
            params.push(req.user.id);
        } else if (subcontractorId) {
            query += ` AND m.subcontractor_id = $${paramIndex++}`;
            params.push(subcontractorId);
        }

        const { search, approval_status, attendance_status } = req.query;

        if (search) {
            query += ` AND m.name ILIKE $${paramIndex++}`;
            params.push(`%${search}%`);
        }

        if (approval_status && approval_status !== 'all') {
            query += ` AND m.approval_status = $${paramIndex++}`;
            params.push(approval_status);
        }

        if (attendance_status && attendance_status !== 'all') {
            if (attendance_status === 'not_marked') {
                query += ` AND a.status IS NULL`;
            } else {
                query += ` AND a.status = $${paramIndex++}`;
                params.push(attendance_status);
            }
        }

        query += ` ORDER BY m.created_at DESC`;

        const { rows } = await db.query(query, params);

        // Transform to match Flutter model structure exactly
        const data = rows.map(r => ({
            id: String(r.id),
            subcontractorId: String(r.subcontractor_id),
            name: r.name,
            approvalStatus: r.approval_status,
            attendanceStatus: r.attendance_status || 'not_marked',
            date: r.created_at
        }));

        res.json({
            success: true,
            data: data
        });
    } catch (err) {
        console.error('Error fetching manpower:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const createManpower = async (req, res) => {
    const { name } = req.body;

    if (!name) {
        return res.status(400).json({
            success: false,
            message: 'Name is required'
        });
    }

    try {
        // Requires getting the subcontractor DB ID from the user.id
        const subRes = await db.query('SELECT id FROM subcontractors WHERE user_id = $1', [req.user.id]);
        if (subRes.rows.length === 0) {
            return res.status(403).json({
                success: false,
                message: 'Only subcontractors can add manpower'
            });
        }

        const subId = subRes.rows[0].id;

        const result = await db.query(
            'INSERT INTO manpower (subcontractor_id, name, approval_status) VALUES ($1, $2, $3) RETURNING *',
            [subId, name, 'pending']
        );

        const r = result.rows[0];
        res.status(201).json({
            success: true,
            data: {
                id: String(r.id),
                subcontractorId: String(req.user.id),
                name: r.name,
                approvalStatus: r.approval_status,
                attendanceStatus: 'not_marked',
                date: r.created_at
            }
        });
    } catch (err) {
        console.error('Error creating manpower:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const updateApproval = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // 'approved' or 'rejected'

    if (status !== 'approved' && status !== 'rejected') {
        return res.status(400).json({
            success: false,
            message: 'Invalid status'
        });
    }

    try {
        const result = await db.query(
            'UPDATE manpower SET approval_status = $1 WHERE id = $2 RETURNING *',
            [status, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Manpower not found'
            });
        }

        res.json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('Error updating manpower approval:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const updateAttendance = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body; // 'present' or 'absent'

    try {
        // Upsert attendance for today
        const query = `
      INSERT INTO attendance (manpower_id, date, status)
      VALUES ($1, CURRENT_DATE, $2)
      ON CONFLICT (manpower_id, date) 
      DO UPDATE SET status = EXCLUDED.status
      RETURNING *
    `;

        await db.query(query, [id, status]);

        res.json({ success: true });
    } catch (err) {
        console.error('Error updating attendance:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

module.exports = {
    getAllManpower,
    createManpower,
    updateApproval,
    updateAttendance
};
