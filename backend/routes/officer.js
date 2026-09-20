const express = require('express');
const router = express.Router();
const db = require('../data/database');
const eventService = require('../services/procurementEventService');

// GET /api/v1/officer/dashboard
router.get('/dashboard', async (req, res) => {
  const centre = await db.getCentreById('CENTRE-01');
  const auditLogs = await db.getAuditLogs(10);
  res.json({
    success: true,
    data: {
      centre,
      waitingFarmersCount: 14,
      completedTodayCount: Math.max(0, centre.currentServingTokenNum - 80),
      totalBagsProcuredToday: 1850,
      currentServingToken: `TK-${centre.currentServingTokenNum}`,
      nextServingToken: `TK-${centre.currentServingTokenNum + 1}`,
      auditLogs,
    }
  });
});

// POST /api/v1/officer/queue/call-next (Event-driven single action token call)
router.post('/queue/call-next', async (req, res) => {
  try {
    const { centreId } = req.body || {};
    const result = await eventService.handleEvent('TOKEN_CALLED', {
      centreId: centreId || 'CENTRE-01',
      officerId: 'OFFICER-101'
    });
    res.json({
      success: true,
      currentServingToken: result.servingToken,
      data: result.queueState,
      result
    });
  } catch (err) {
    console.error('[Officer API] Call next error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/officer/procurement/update
router.post('/procurement/update', async (req, res) => {
  const { stageIndex, remark, quintals, bags } = req.body;
  const updatedToken = await db.updateTokenStage('TOKEN-2026-104', stageIndex, quintals, bags);

  await db.logAudit('OFFICER-101', 'UPDATE_STAGE', `Updated stage index to ${stageIndex} with remark: ${remark || 'N/A'}`);

  res.json({ success: true, data: updatedToken });
});

// POST /api/v1/officer/centre/status
router.post('/centre/status', async (req, res) => {
  const { status, reason, centreId } = req.body || {}; // OPEN, PAUSED, CLOSED
  const targetCentreId = centreId || 'CENTRE-01';
  await db.updateCentreStatus(targetCentreId, status || 'OPEN', reason || null);
  await db.logAudit('OFFICER-101', 'UPDATE_CENTRE_STATUS', `Set centre ${targetCentreId} status to ${status} (Reason: ${reason || 'None'})`);
  res.json({ success: true, status, reason, centreId: targetCentreId });
});

// --- HARDWARE SIMULATOR TRIGGER ENDPOINTS (DEV-ONLY) ---
router.post('/simulator/scale', async (req, res) => {
  try {
    const { weightKg, bagCount, farmerId } = req.body;
    const result = await eventService.handleEvent('WEIGHT_RECEIVED', {
      farmerId: farmerId || 'FARMER-001',
      deviceId: 'SCALE-SIM-01',
      weightKg: weightKg || 50.25,
      bagCount: bagCount || 45
    });
    res.json({ success: true, message: 'Simulated Scale Reading Ingested Successfully', result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post('/simulator/quality', async (req, res) => {
  try {
    const { moisturePercentage, farmerId } = req.body;
    const result = await eventService.handleEvent('QUALITY_COMPLETED', {
      farmerId: farmerId || 'FARMER-001',
      deviceId: 'QUAL-SIM-01',
      moisturePercentage: moisturePercentage || 14.2
    });
    res.json({ success: true, message: 'Simulated Quality Sensor Reading Ingested Successfully', result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post('/simulator/auto-flow', async (req, res) => {
  try {
    const { farmerId, customWeightKg, customMoisture } = req.body;
    const result = await eventService.handleEvent('RUN_FULL_SIMULATED_FLOW', {
      farmerId: farmerId || 'FARMER-001',
      customWeightKg: customWeightKg || 50.25,
      customMoisture: customMoisture || 14.2
    });
    res.json({ success: true, message: 'Full Simulated Procurement Flow Executed', result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/officer/feedback
router.get('/feedback', async (req, res) => {
  try {
    const summary = await db.getFeedbackSummary();
    const list = await db.getFeedbackList();
    res.json({
      success: true,
      summary,
      list
    });
  } catch (err) {
    console.error('[Officer API] Error fetching feedback:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;


