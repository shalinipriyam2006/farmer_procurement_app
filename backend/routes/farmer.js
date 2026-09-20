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

// POST /api/v1/farmers/token/reschedule
router.post('/token/reschedule', async (req, res) => {
  const { tokenId, farmerId, newDate, newTimeSlot } = req.body;
  const token = await db.getTokenById(tokenId);
  if (!token) {
    return res.status(404).json({ success: false, error: 'Original token record not found.' });
  }

  // Record missed slot audit entry
  await db.createMissedSlotRecord({
    id: `MISSED-${Date.now()}`,
    tokenId: token.id,
    farmerId: farmerId || token.farmerId,
    centreId: token.centreId,
    originalBookingDate: token.bookingDate,
    originalTimeSlot: token.timeSlot,
    missedReason: 'Farmer requested automated slot rescheduling.',
    rescheduledTokenId: token.id
  });

  // Update token booking date & slot
  token.bookingDate = newDate || 'Tomorrow';
  token.timeSlot = newTimeSlot || '09:00 AM - 11:00 AM';
  token.status = 'SCHEDULED';
  await db.updateTokenStage(token.id, 0, token.estimatedQuintals, token.estimatedBags, 'SCHEDULED');

  await db.createNotification({
    id: `NOTIF-${Date.now()}`,
    farmerId: token.farmerId,
    titleEn: `Token Rescheduled: ${token.tokenNumber}`,
    titleTa: `டோக்கன் தேதி மாற்றப்பட்டது: ${token.tokenNumber}`,
    messageEn: `Rescheduled slot confirmed for ${token.bookingDate} (${token.timeSlot}).`,
    messageTa: `மாற்றப்பட்ட தேதி மற்றும் நேரம் உறுதியானது.`
  });

  res.json({ success: true, data: token, message: 'Token rescheduled successfully.' });
});

// POST /api/v1/farmers/feedback
router.post('/feedback', async (req, res) => {
  const { farmerId, farmerName, receiptId, overallRating, queueRating, centreRating, staffRating, paymentRating, comment } = req.body;
  const fb = await db.createFeedback({
    id: `FB-${Date.now()}`,
    farmerId: farmerId || 'FARMER-001',
    farmerName: farmerName || 'Raja Ramanathan',
    receiptId: receiptId || null,
    overallRating: parseInt(overallRating || 5, 10),
    queueRating: parseInt(queueRating || 5, 10),
    centreRating: parseInt(centreRating || 5, 10),
    staffRating: parseInt(staffRating || 5, 10),
    paymentRating: parseInt(paymentRating || 5, 10),
    comment: comment || ''
  });

  res.json({ success: true, data: fb, message: 'Feedback submitted successfully.' });
});

module.exports = router;

