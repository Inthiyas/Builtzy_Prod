require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./src/routes/authRoutes');
const manpowerRoutes = require('./src/routes/manpowerRoutes');
const equipmentRoutes = require('./src/routes/equipmentRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const userRoutes = require('./src/routes/userRoutes');
const subcontractorRoutes = require('./src/routes/subcontractorRoutes');

// Main Routes
app.use('/api/auth', authRoutes);
app.use('/api/manpower', manpowerRoutes);
app.use('/api/equipment', equipmentRoutes);
app.use('/api/dashboard', dashboardRoutes);

app.use('/api/users', userRoutes);
app.use('/api/subcontractors', subcontractorRoutes);

app.get('/health', (req, res) => {
    res.json({ status: 'ok', time: new Date() });
});

app.listen(PORT, () => {
    console.log(`🚀 Buildzy API Server running on port ${PORT}`);
});
