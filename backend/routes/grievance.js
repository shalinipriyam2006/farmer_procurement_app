const express = require('express');
const router = express.Router();
const db = require('../data/database');

// GET /api/v1/grievances
router.get('/', async (req, res) => {
  const grievances = await db.getGrievances();
  res.json({ success: true, data: grievances });
});

// POST /api/v1/grievances
router.post('/', async (req, res) => {
  const { farmerId, category, description } = req.body;
  const newGrievance = {
    id: `GRV-${Math.floor(1000 + Math.random() * 9000)}`,
    farmerId: farmerId || 'FARMER-001',
    farmerName: 'Murugan Ramanathan',
    category: category || 'General Help',
    description: description || 'Issue logged via digital application.',
    status: 'SUBMITTED',
    submittedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    remarks: 'Ticket received and logged into government grievance tracking system.',
  };

  await db.createGrievance(newGrievance);
  res.json({ success: true, data: newGrievance });
});

module.exports = router;
