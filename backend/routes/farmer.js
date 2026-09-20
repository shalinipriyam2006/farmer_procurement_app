const express = require('express');
const router = express.Router();
const db = require('../data/database');

// GET /api/v1/farmers/:id
router.get('/:id', async (req, res) => {
  const farmer = await db.getFarmerById(req.params.id);
  res.json({ success: true, data: farmer });
});

// GET /api/v1/farmers/:id/token
router.get('/:id/token', async (req, res) => {
  const token = await db.getTokenByFarmerId(req.params.id);
  res.json({ success: true, data: token });
});

// POST /api/v1/farmers/token/book
router.post('/token/book', async (req, res) => {
  const { farmerId, centreId, bookingDate, timeSlot, cropNameEn, cropNameTa, estimatedQuintals, estimatedBags } = req.body;
  const centre = await db.getCentreById(centreId || 'CENTRE-01');
  
  if (centre.status === 'CLOSED') {
    return res.status(400).json({
      success: false,
      error: `Token booking is unavailable. ${centre.nameEn} is currently closed. ${centre.statusReason || ''}`.trim()
    });
  }

  const farmer = await db.getFarmerById(farmerId || 'FARMER-001');
  const newTokenNum = `TK-${centre.currentServingTokenNum + 5}`;
  
  const newToken = {
    id: `TOKEN-${Date.now()}`,
    tokenNumber: newTokenNum,
    farmerId: farmer.id,
    farmerName: farmer.name || 'Raja Ramanathan',
    centreId: centre.id,
    centreNameEn: centre.nameEn,
    centreNameTa: centre.nameTa,
    bookingDate,
    timeSlot,
    cropNameEn,
    cropNameTa,
    estimatedQuintals,
    estimatedBags,
    status: 'GENERATED',
    currentStageIndex: 0,
    createdAt: new Date().toISOString(),
  };

  await db.createToken(newToken);

  // Add Notification
  await db.createNotification({
    id: `NOTIF-${Date.now()}`,
    farmerId: newToken.farmerId,
    titleEn: `Digital Token Generated: ${newTokenNum}`,
    titleTa: `டிஜிட்டல் டோக்கன் உருவாக்கப்பட்டது: ${newTokenNum}`,
    messageEn: `Slot confirmed at ${centre.nameEn} on ${bookingDate}`,
    messageTa: `${centre.nameTa}-ல் ${bookingDate} முன்பதிவு உறுதியானது.`,
    timestamp: new Date().toISOString(),
    isRead: false,
  });

  res.json({ success: true, data: newToken });
});

// GET /api/v1/farmers/:id/queue
router.get('/:id/queue', async (req, res) => {
  const queueData = await db.getQueueStatusForFarmer(req.params.id);
  res.json({
    success: true,
    data: queueData
  });
});

// GET /api/v1/farmers/:id/payments
router.get('/:id/payments', async (req, res) => {
  const payment = await db.getPaymentsByFarmer(req.params.id);
  res.json({ success: true, data: payment });
});

// GET /api/v1/farmers/:id/notifications
router.get('/:id/notifications', async (req, res) => {
  const notifs = await db.getNotificationsByFarmer(req.params.id);
  res.json({ success: true, data: notifs });
});

// GET /api/v1/farmers/:id/receipts (Digital Procurement Receipts)
router.get('/:id/receipts', async (req, res) => {
  const receipts = await db.getReceiptsByFarmer(req.params.id);
  res.json({ success: true, data: receipts });
});

// GET /api/v1/farmers/receipts/detail/:receiptId
router.get('/receipts/detail/:receiptId', async (req, res) => {
  const receipt = await db.getReceiptById(req.params.receiptId);
  if (!receipt) {
    return res.status(404).json({ success: false, error: 'Procurement receipt not found.' });
  }
  res.json({ success: true, data: receipt });
});

module.exports = router;
