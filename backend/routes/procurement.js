const express = require('express');
const router = express.Router();
const db = require('../data/database');
const govtAdapter = require('../adapters/government_adapter');

// GET /api/v1/procurement/centres
router.get('/centres', async (req, res) => {
  const govtCentres = await govtAdapter.fetchAuthorizedCentres();
  const dbCentres = await db.getCentres();
  res.json({
    success: true,
    source: govtCentres ? 'Government Portal' : 'Authorized Procurement System',
    data: govtCentres || dbCentres
  });
});

// GET /api/v1/procurement/rates
router.get('/rates', async (req, res) => {
  const rates = await db.getProcurementRates();
  res.json({
    success: true,
    source: 'e-NAM Benchmark / Local Administrative Board',
    data: rates
  });
});

// GET /api/v1/procurement/centres/:id
router.get('/centres/:id', async (req, res) => {
  const centre = await db.getCentreById(req.params.id);
  if (!centre) {
    return res.status(404).json({ success: false, message: 'Centre not found' });
  }
  res.json({ success: true, data: centre });
});

module.exports = router;
