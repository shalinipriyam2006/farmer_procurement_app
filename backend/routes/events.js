const express = require('express');
const router = express.Router();
const eventService = require('../services/procurementEventService');
const { verifyDeviceAuth } = require('../middleware/deviceAuth');

// 1. Dispatch Central Procurement Event
router.post('/dispatch', async (req, res) => {
  try {
    const { eventType, payload } = req.body;
    if (!eventType) {
      return res.status(400).json({ success: false, error: 'eventType is required.' });
    }
    const result = await eventService.handleEvent(eventType, payload || {});
    res.json({ success: true, result });
  } catch (err) {
    console.error('[Event API] Dispatch error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 2. Ingest Digital Weighing Scale Event (Secured Device Ingestion)
router.post('/device/weighing/ingest', verifyDeviceAuth, async (req, res) => {
  try {
    const { tokenId, farmerId, weightKg, bagCount } = req.body;
    const deviceId = req.device.deviceId;

    const result = await eventService.handleEvent('WEIGHT_RECEIVED', {
      tokenId,
      farmerId: farmerId || 'FARMER-001',
      deviceId,
      weightKg: weightKg || 50.25,
      bagCount: bagCount || 45
    });

    res.json({ success: true, message: 'Weighing event processed automatically.', result });
  } catch (err) {
    console.error('[Event API] Weighing Ingest error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 3. Ingest Digital Quality Sensor Event (Secured Device Ingestion)
router.post('/device/quality/ingest', verifyDeviceAuth, async (req, res) => {
  try {
    const { tokenId, farmerId, moisturePercentage, foreignMatterPercentage, inspectorId } = req.body;
    const deviceId = req.device.deviceId;

    const result = await eventService.handleEvent('QUALITY_COMPLETED', {
      tokenId,
      farmerId: farmerId || 'FARMER-001',
      deviceId,
      moisturePercentage: moisturePercentage || 14.2,
      foreignMatterPercentage: foreignMatterPercentage || 0.5,
      inspectorId
    });

    res.json({ success: true, message: 'Quality event processed automatically.', result });
  } catch (err) {
    console.error('[Event API] Quality Ingest error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 4. Run Full Hardware Simulation Pipeline (Development / Testing)
router.post('/simulator/run-flow', async (req, res) => {
  try {
    const { farmerId, customWeightKg, customMoisture } = req.body;
    const result = await eventService.handleEvent('RUN_FULL_SIMULATED_FLOW', {
      farmerId: farmerId || 'FARMER-001',
      customWeightKg: customWeightKg || 50.25,
      customMoisture: customMoisture || 14.2
    });

    res.json({ success: true, message: 'Full simulated hardware workflow executed.', result });
  } catch (err) {
    console.error('[Event API] Simulator flow error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
