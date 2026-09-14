const express = require('express');
const router = express.Router();
const db = require('../data/database');

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

// POST /api/v1/officer/queue/call-next
router.post('/queue/call-next', async (req, res) => {
  const { centreId } = req.body || {};
  const targetCentreId = centreId || 'CENTRE-01';
  const centre = await db.getCentreById(targetCentreId);
  const nextServingNum = centre.currentServingTokenNum + 1;
  const updatedCentre = await db.updateCentreServingToken(centre.id, nextServingNum);

  await db.logAudit('OFFICER-101', 'CALL_NEXT_TOKEN', `Advanced queue token to TK-${nextServingNum} for centre ${centre.id}`);

  res.json({
    success: true,
    currentServingToken: `TK-${updatedCentre.currentServingTokenNum}`,
    data: updatedCentre
  });
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

module.exports = router;
