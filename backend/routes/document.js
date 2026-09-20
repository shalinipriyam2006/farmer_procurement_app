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

function generatePdfBuffer({ title, docId, farmerName, farmerId, centreName, cropName, weight, moisture, rate, grossAmount, deductions, netAmount, category, disclaimer }) {
  const contentText = `
BT
/F1 16 Tf
50 780 Td
(${title || 'FARMER PROCUREMENT DIGITAL RECORD'}) Tj
/F1 11 Tf
0 -30 Td
(Document Ref: ${docId || 'DOC-001'}) Tj
0 -20 Td
(Farmer Name: ${farmerName || 'Raja Ramanathan'}) Tj
0 -20 Td
(Farmer ID: ${farmerId || 'TN-KISAN-84920'}) Tj
0 -20 Td
(Procurement Centre: ${centreName || 'Thanjavur Direct Purchase Centre'}) Tj
0 -20 Td
(Crop Name: ${cropName || 'Paddy (Grade A)'}) Tj
0 -20 Td
(Measured Weight: ${weight || '25.50 Quintals (34 Bags)'}) Tj
0 -20 Td
(Moisture Content: ${moisture || '14.2% (Grade A Standard)'}) Tj
0 -20 Td
(Applicable MSP Rate: ${rate || 'Rs. 2,320.00 / Quintal'}) Tj
0 -20 Td
(Gross Amount: ${grossAmount || 'Rs. 59,160.00'}) Tj
0 -20 Td
(Deductions: ${deductions || 'Rs. 0.00'}) Tj
/F1 13 Tf
0 -30 Td
(NET PAYABLE AMOUNT: ${netAmount || 'Rs. 59,160.00'}) Tj
/F1 10 Tf
0 -40 Td
(Category: ${category || 'Application Digital Record'}) Tj
0 -15 Td
(${disclaimer || 'Official Application Digital Record produced by Farmer Procurement Platform.'}) Tj
ET
  `.trim();

  const streamLength = Buffer.byteLength(contentText);

  const pdfString = `%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>
endobj
4 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
5 0 obj
<< /Length ${streamLength} >>
stream
${contentText}
endstream
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000244 00000 n 
0000000315 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
${315 + streamLength + 30}
%%EOF`;

  return Buffer.from(pdfString, 'utf-8');
}

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
    const cleanId = documentId.replace(/[^a-zA-Z0-9_-]/g, '_');
    
    let prefix = 'BUYWISE_Document';
    const upperDoc = documentId.toUpperCase();
    if (upperDoc.includes('TOKEN') || upperDoc.startsWith('TK')) {
      prefix = 'BUYWISE_Token';
    } else if (upperDoc.includes('RECEIPT') || upperDoc.includes('WEIGH') || upperDoc.startsWith('WS') || upperDoc.startsWith('RCP')) {
      prefix = 'BUYWISE_Receipt';
    } else if (upperDoc.includes('QUALITY') || upperDoc.includes('ACCEPT') || upperDoc.includes('REJECT') || upperDoc.startsWith('QTC') || upperDoc.startsWith('ACC')) {
      prefix = 'BUYWISE_Quality';
    } else if (upperDoc.includes('PAYMENT') || upperDoc.includes('COMPLETION') || upperDoc.startsWith('PCC') || upperDoc.startsWith('PAY')) {
      prefix = 'BUYWISE_Payment';
    }

    const filename = `${prefix}_${cleanId}.pdf`;
    const pdfBuffer = generatePdfBuffer({ docId: documentId });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(pdfBuffer);
  } catch (err) {
    console.error('[Document Route] Error downloading document:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
