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
    const mobileNumber = req.body.mobileNumber || req.body.phone || req.body.mobile;
    if (!mobileNumber) {
      return res.status(400).json({ success: false, error: 'mobileNumber (or phone) is required' });
    }

    const result = await smsAdapter.sendOtp(mobileNumber);
    if (!result.success) {
      return res.status(503).json({ success: false, error: result.error });
    }

    res.json({
      success: true,
      data: result
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

/**
 * POST /api/v1/auth/otp/verify
 * Verify farmer SMS OTP & generate session JWT
 */
router.post('/otp/verify', async (req, res) => {
  try {
    const mobileNumber = req.body.mobileNumber || req.body.phone || req.body.mobile;
    const otp = req.body.otp;
    if (!mobileNumber || !otp) {
      return res.status(400).json({ success: false, error: 'mobileNumber (or phone) and otp are required' });
    }

    const verification = await smsAdapter.verifyOtp(mobileNumber, otp);
    if (!verification.verified) {
      return res.status(401).json({ success: false, error: verification.reason });
    }

    const farmer = await db.getFarmerByMobile(mobileNumber);

    if (!farmer) {
      return res.json({
        success: true,
        isRegistered: false,
        message: 'OTP verified successfully. Mobile number is not registered in farmer database.',
        mobileNumber
      });
    }

    const token = `JWT_FARMER_${farmer.id}_${Date.now()}`;

    res.json({
      success: true,
      isRegistered: true,
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
 * POST /api/v1/auth/demo/login
 * Isolated Demo Farmer Login
 */
router.post('/demo/login', async (req, res) => {
  const farmer = await db.getFarmerByMobile('9876543210');
  res.json({
    success: true,
    token: `JWT_FARMER_DEMO_${farmer ? farmer.id : '001'}_${Date.now()}`,
    user: {
      role: 'FARMER',
      farmerProfile: farmer
    }
  });
});

/**
 * POST /api/v1/auth/farmer/login
 * Single-step mobile login
 */
router.post('/farmer/login', async (req, res) => {
  const mobileNumber = req.body.mobileNumber || req.body.phone || req.body.mobile;
  const farmer = await db.getFarmerByMobile(mobileNumber);
  if (!farmer) {
    return res.status(404).json({ success: false, error: 'Farmer account not found' });
  }
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
