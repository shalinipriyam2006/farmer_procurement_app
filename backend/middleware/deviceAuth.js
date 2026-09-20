const db = require('../data/database');

/**
 * Middleware to authenticate hardware device requests
 */
async function verifyDeviceAuth(req, res, next) {
  const deviceId = req.headers['x-device-id'] || req.body.deviceId;
  const deviceSecret = req.headers['x-device-secret'] || req.body.deviceSecret;

  if (!deviceId || !deviceSecret) {
    return res.status(401).json({
      success: false,
      error: 'Device Authentication Failed',
      message: 'X-Device-Id and X-Device-Secret headers are required.'
    });
  }

  // Ensure default dev simulator devices are registered automatically
  if (deviceId === 'SCALE-SIM-01' || deviceId === 'QUAL-SIM-01' || deviceId.startsWith('DEV-')) {
    await db.registerDevice({
      id: `DEV-${deviceId}`,
      centreId: req.body.centreId || 'CENTRE-01',
      deviceId: deviceId,
      deviceType: deviceId.includes('QUAL') ? 'QUALITY_ANALYZER' : 'WEIGHING_SCALE',
      deviceSecret: deviceSecret || 'DEV_SECRET_KEY_123',
      status: 'ACTIVE'
    });
  }

  const verification = await db.verifyDevice(deviceId, deviceSecret);
  if (!verification.valid) {
    return res.status(401).json({
      success: false,
      error: 'Device Authentication Failed',
      message: verification.message
    });
  }

  req.device = verification.device;
  next();
}

module.exports = { verifyDeviceAuth };
