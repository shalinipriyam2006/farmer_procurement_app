const express = require('express');
const router = express.Router();
const db = require('../data/database');

// POST /api/v1/auth/farmer/login
router.post('/farmer/login', async (req, res) => {
  const { mobileNumber } = req.body;
  const farmer = await db.getFarmerByMobile(mobileNumber);
  res.json({
    success: true,
    token: `JWT_FARMER_${farmer.id}_${Date.now()}`,
    user: {
      role: 'FARMER',
      farmerProfile: farmer
    }
  });
});

// POST /api/v1/auth/officer/login
router.post('/officer/login', async (req, res) => {
  const { badgeId, password } = req.body;
  const officer = await db.getOfficerByBadgeId(badgeId);
  res.json({
    success: true,
    token: `JWT_OFFICER_${officer.id}_${Date.now()}`,
    user: {
      role: 'OFFICER',
      officerProfile: officer
    }
  });
});

module.exports = router;
