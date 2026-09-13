const express = require('express');
const router = express.Router();
const db = require('../data/database');

// GET /api/v1/documents/:farmerId
router.get('/:farmerId', async (req, res) => {
  const docs = await db.getDocumentsByFarmer(req.params.farmerId);
  res.json({ success: true, data: docs });
});

module.exports = router;
