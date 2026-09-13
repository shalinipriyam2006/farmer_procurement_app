const express = require('express');
const router = express.Router();
const db = require('../data/database');
const smsAdapter = require('../adapters/sms_adapter');

/**
 * POST /api/v1/auth/otp/send
 * Request 6-digit SMS OTP for farmer login/registration
 */
router.post('/otp/send', async (req, res) => {
  try {
    const { mobileNumber } = req.body;
    if (!mobileNumber) {
      return res.status(400).json({ success: false, error: 'mobileNumber is required' });
    }

    const result = await smsAdapter.sendOtp(mobileNumber);
    res.json({
      success: true,
      data: result
    });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

/**
 * POST /api/v1/auth/otp/verify
 * Verify farmer SMS OTP & generate session JWT
 */
router.post('/otp/verify', async (req, res) => {
  try {
    const { mobileNumber, otp } = req.body;
    if (!mobileNumber || !otp) {
      return res.status(400).json({ success: false, error: 'mobileNumber and otp are required' });
    }

    const verification = await smsAdapter.verifyOtp(mobileNumber, otp);
    if (!verification.verified) {
      return res.status(401).json({ success: false, error: verification.reason });
    }

    const farmer = await db.getFarmerByMobile(mobileNumber);
    const token = `JWT_FARMER_${farmer.id}_${Date.now()}`;

    res.json({
      success: true,
      token,
      user: {
        role: 'FARMER',
        farmerProfile: farmer
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

/**
 * POST /api/v1/auth/farmer/login
 * Backward-compatible single-step login
 */
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

/**
 * POST /api/v1/auth/officer/login
 */
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
