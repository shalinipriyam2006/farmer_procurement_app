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
  const centre = await db.getCentreById('CENTRE-01');
  const nextServingNum = centre.currentServingTokenNum + 1;
  const updatedCentre = await db.updateCentreServingToken(centre.id, nextServingNum);

  await db.logAudit('OFFICER-101', 'CALL_NEXT_TOKEN', `Advanced queue token to TK-${nextServingNum}`);

  res.json({
    success: true,
    currentServingToken: `TK-${updatedCentre.currentServingTokenNum}`,
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
  const { status } = req.body; // OPEN, PAUSED, CLOSED
  await db.updateCentreStatus('CENTRE-01', status);
  await db.logAudit('OFFICER-101', 'UPDATE_CENTRE_STATUS', `Set centre status to ${status}`);
  res.json({ success: true, status });
});

module.exports = router;
