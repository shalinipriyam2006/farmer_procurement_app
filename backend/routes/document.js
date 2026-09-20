const express = require('express');
const router = express.Router();
const db = require('../data/database');

// GET /api/v1/documents/:farmerId
router.get('/:farmerId', async (req, res) => {
  try {
    const docs = await db.getDigitalDocumentsByFarmer(req.params.farmerId);
    res.json({ success: true, data: docs });
  } catch (err) {
    console.error('[Document Route] Error getting documents:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/documents/detail/:documentId
router.get('/detail/:documentId', async (req, res) => {
  try {
    const { documentId } = req.params;
    const farmer = await db.getFarmerById('FARMER-001') || { id: 'FARMER-001', name: 'Raja Ramanathan' };
    const tokens = await db.getTokensByFarmer(farmer.id) || [];
    const token = tokens[0] || { tokenNumber: 'TK-104', cropNameEn: 'Paddy (Grade A)', centreNameEn: 'Thanjavur Direct Purchase Centre', bookingDate: '2026-09-20', timeSlot: '09:00 AM - 11:00 AM' };
    const receipt = await db.getReceiptByToken(token.id) || { receiptNumber: 'PR-TN-2026-849201', weightQuintals: 25.50, bagCount: 34, qualityGrade: 'Grade A (FAQ Standard)', moisturePercentage: 14.2, applicableRate: 2320.0, grossAmount: 59610.0, deductions: 450.0, netAmount: 59160.0 };

    res.json({
      success: true,
      documentId,
      farmer,
      token,
      receipt,
      documentCategory: 'Application Digital Record',
      disclaimer: 'This is an application-generated digital record produced by the Farmer Procurement Platform.'
    });
  } catch (err) {
    console.error('[Document Route] Error getting document detail:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/documents/download/:documentId
router.get('/download/:documentId', async (req, res) => {
  try {
    const { documentId } = req.params;
    const filename = `BUYWISE_${documentId.replace(/[^a-zA-Z0-9_-]/g, '_')}.html`;

    const htmlContent = `<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Official Digital Document - ${documentId}</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 30px; color: #1a252c; background-color: #f8fafc; }
        .card { background: #ffffff; padding: 30px; border-radius: 12px; border: 1px solid #cbd5e1; max-width: 700px; margin: auto; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .header { text-align: center; border-bottom: 2px solid #1e5631; padding-bottom: 15px; margin-bottom: 20px; }
        .header h2 { color: #1e5631; margin: 0; font-size: 24px; }
        .header p { color: #64748b; font-size: 13px; margin: 5px 0 0 0; font-weight: 600; }
        .badge { display: inline-block; background: #e2e8f0; color: #334155; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; margin-top: 8px; }
        .row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 6px; }
        .label { color: #64748b; font-weight: 500; }
        .val { font-weight: 700; color: #0f172a; }
        .total-box { background: #f0fdf4; border: 1.5px solid #22c55e; border-radius: 8px; padding: 15px; text-align: center; margin-top: 20px; }
        .total-val { font-size: 24px; font-weight: 900; color: #15803d; }
        .footer { text-align: center; margin-top: 25px; font-size: 11px; color: #94a3b8; }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <h2>DIRECT PROCUREMENT CENTRE</h2>
            <p>FARMER PROCUREMENT DIGITAL RECORD</p>
            <div class="badge">Application Digital Record</div>
        </div>
        <div class="row"><span class="label">Document Ref:</span><span class="val">${documentId}</span></div>
        <div class="row"><span class="label">Farmer Name:</span><span class="val">Raja Ramanathan</span></div>
        <div class="row"><span class="label">Farmer ID:</span><span class="val">TN-KISAN-84920</span></div>
        <div class="row"><span class="label">Procurement Centre:</span><span class="val">Thanjavur Direct Purchase Centre</span></div>
        <div class="row"><span class="label">Crop Name:</span><span class="val">Paddy (Grade A)</span></div>
        <div class="row"><span class="label">Measured Weight:</span><span class="val">25.50 Quintals (34 Bags)</span></div>
        <div class="row"><span class="label">Moisture Content:</span><span class="val">14.2% (Grade A Standard)</span></div>
        <div class="row"><span class="label">Applicable MSP Rate:</span><span class="val">₹2,320.00 / Quintal</span></div>
        <div class="row"><span class="label">Gross Amount:</span><span class="val">₹59,160.00</span></div>
        <div class="row"><span class="label">Deductions:</span><span class="val">₹0.00</span></div>
        <div class="total-box">
            <div style="font-size: 12px; color: #166534; font-weight: 700;">NET PAYABLE AMOUNT (DBT CREATED)</div>
            <div class="total-val">₹59,160.00</div>
        </div>
        <div class="footer">
            Generated on ${new Date().toLocaleString('en-IN')} by Farmer Procurement Application Gateway.<br>
            Note: This is an application-generated digital record. Verification Ref: BUYWISE-${documentId}.
        </div>
    </div>
</body>
</html>`;

    res.setHeader('Content-Type', 'text/html');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(htmlContent);
  } catch (err) {
    console.error('[Document Route] Error downloading document:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
