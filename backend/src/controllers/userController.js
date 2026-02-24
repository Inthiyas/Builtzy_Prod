const db = require('../config/db');

exports.getMe = async (req, res) => {
    try {
        const userId = req.user.id;
        const result = await db.query(
            'SELECT id, username, role FROM users WHERE id = $1',
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};
