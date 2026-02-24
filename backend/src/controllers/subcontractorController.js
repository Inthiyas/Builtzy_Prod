const db = require('../config/db');

const getAllSubcontractors = async (req, res) => {
    try {
        let query = `
            SELECT 
                s.id, 
                s.user_id,
                u.username,
                s.company_name, 
                s.contact_person, 
                s.phone,
                (SELECT COUNT(*) FROM manpower m WHERE m.subcontractor_id = s.id) as total_manpower,
                (SELECT COUNT(*) FROM equipment e WHERE e.subcontractor_id = s.id) as total_equipment
            FROM subcontractors s
            JOIN users u ON s.user_id = u.id
            WHERE 1=1
        `;
        let params = [];
        let paramIndex = 1;

        const { search, min_manpower, max_manpower, min_equipment, max_equipment } = req.query;

        if (search) {
            query += ` AND s.company_name ILIKE $${paramIndex++}`;
            params.push(`%${search}%`);
        }

        if (min_manpower) {
            query += ` AND (SELECT COUNT(*) FROM manpower m WHERE m.subcontractor_id = s.id) >= $${paramIndex++}`;
            params.push(parseInt(min_manpower));
        }
        if (max_manpower) {
            query += ` AND (SELECT COUNT(*) FROM manpower m WHERE m.subcontractor_id = s.id) <= $${paramIndex++}`;
            params.push(parseInt(max_manpower));
        }
        if (min_equipment) {
            query += ` AND (SELECT COUNT(*) FROM equipment e WHERE e.subcontractor_id = s.id) >= $${paramIndex++}`;
            params.push(parseInt(min_equipment));
        }
        if (max_equipment) {
            query += ` AND (SELECT COUNT(*) FROM equipment e WHERE e.subcontractor_id = s.id) <= $${paramIndex++}`;
            params.push(parseInt(max_equipment));
        }

        query += ` ORDER BY s.company_name ASC`;

        const { rows } = await db.query(query, params);

        const data = rows.map(r => ({
            id: String(r.id),
            userId: String(r.user_id),
            username: r.username,
            companyName: r.company_name,
            contactPerson: r.contact_person,
            phoneNumber: r.phone,
            totalManpower: parseInt(r.total_manpower || 0),
            totalEquipment: parseInt(r.total_equipment || 0)
        }));

        res.json({
            success: true,
            data: data
        });
    } catch (err) {
        console.error('Error fetching subcontractors:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const createSubcontractor = async (req, res) => {
    const { username, password, companyName, contactPerson, phoneNumber } = req.body;

    if (!username || !password || !companyName) {
        return res.status(400).json({
            success: false,
            message: 'Username, password and company name are required'
        });
    }

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // Check if username exists
        const userCheck = await client.query('SELECT id FROM users WHERE username = $1', [username]);
        if (userCheck.rows.length > 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({
                success: false,
                message: 'Username already exists'
            });
        }

        // 1. Create User
        const userResult = await client.query(
            'INSERT INTO users (username, password, role) VALUES ($1, $2, $3) RETURNING id, username',
            [username, password, 'subcontractor']
        );
        const userId = userResult.rows[0].id;

        // 2. Create Subcontractor
        const subResult = await client.query(
            'INSERT INTO subcontractors (user_id, company_name, contact_person, phone) VALUES ($1, $2, $3, $4) RETURNING *',
            [userId, companyName, contactPerson, phoneNumber]
        );
        const subId = subResult.rows[0].id;

        await client.query('COMMIT');

        res.status(201).json({
            success: true,
            data: {
                id: String(subId),
                userId: String(userId),
                username,
                companyName,
                contactPerson,
                phoneNumber: subResult.rows[0].phone,
                totalManpower: 0,
                totalEquipment: 0
            }
        });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('Error creating subcontractor:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    } finally {
        client.release();
    }
};

const updateSubcontractor = async (req, res) => {
    const { id } = req.params;
    const { companyName, contactPerson, phoneNumber } = req.body;

    try {
        const result = await db.query(
            'UPDATE subcontractors SET company_name = $1, contact_person = $2, phone = $3 WHERE id = $4 RETURNING *',
            [companyName, contactPerson, phoneNumber, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Subcontractor not found'
            });
        }

        res.json({ success: true, data: result.rows[0] });
    } catch (err) {
        console.error('Error updating subcontractor:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const deleteSubcontractor = async (req, res) => {
    const { id } = req.params;

    const client = await db.pool.connect();
    try {
        await client.query('BEGIN');

        // Get the associated user_id before deleting
        const subRes = await client.query('SELECT user_id FROM subcontractors WHERE id = $1', [id]);
        if (subRes.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({
                success: false,
                message: 'Subcontractor not found'
            });
        }
        const userId = subRes.rows[0].user_id;

        // Ensure proper cascading manually just in case PostgreSQL schema lacks ON DELETE CASCADE

        // 1. Delete Attendance tied to their manpower
        await client.query('DELETE FROM attendance WHERE manpower_id IN (SELECT id FROM manpower WHERE subcontractor_id = $1)', [id]);

        // 2. Delete Manpower
        await client.query('DELETE FROM manpower WHERE subcontractor_id = $1', [id]);

        // 3. Delete Equipment Status tied to their equipment
        await client.query('DELETE FROM equipment_status WHERE equipment_id IN (SELECT id FROM equipment WHERE subcontractor_id = $1)', [id]);

        // 4. Delete Equipment
        await client.query('DELETE FROM equipment WHERE subcontractor_id = $1', [id]);

        // 5. Delete Subcontractor
        await client.query('DELETE FROM subcontractors WHERE id = $1', [id]);

        // 6. Delete User
        await client.query('DELETE FROM users WHERE id = $1', [userId]);

        await client.query('COMMIT');
        res.json({ success: true });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('Error deleting subcontractor:', err);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    } finally {
        client.release();
    }
};

module.exports = {
    getAllSubcontractors,
    createSubcontractor,
    updateSubcontractor,
    deleteSubcontractor
};
