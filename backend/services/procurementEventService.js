const db = require('../data/database');
const { SimulatorWeighingAdapter, SimulatorQualityAdapter } = require('../adapters/hardwareAdapters');

class ProcurementEventService {
  /**
   * Dispatch a central procurement event and trigger state machine updates
   */
  async handleEvent(eventType, payload = {}) {
    console.log(`[ProcurementEventService] Processing event: ${eventType}`, payload);

    switch (eventType) {
      case 'TOKEN_CALLED':
        return await this._handleTokenCalled(payload);
      case 'ARRIVED_AT_CENTRE':
        return await this._handleArrivedAtCentre(payload);
      case 'WEIGHT_RECEIVED':
      case 'WEIGHING_COMPLETED':
        return await this._handleWeightReceived(payload);
      case 'QUALITY_TEST_RECEIVED':
      case 'QUALITY_COMPLETED':
        return await this._handleQualityCompleted(payload);
      case 'PROCUREMENT_ACCEPTED':
        return await this._handleProcurementAccepted(payload);
      case 'PROCUREMENT_REJECTED':
        return await this._handleProcurementRejected(payload);
      case 'PROCUREMENT_COMPLETED':
        return await this._handleProcurementCompleted(payload);
      case 'PAYMENT_INITIATED':
        return await this._handlePaymentInitiated(payload);
      case 'PAYMENT_COMPLETED':
        return await this._handlePaymentCompleted(payload);
      case 'RUN_FULL_SIMULATED_FLOW':
        return await this._handleFullSimulatedFlow(payload);
      default:
        throw new Error(`Unsupported procurement event type: ${eventType}`);
    }
  }

  // 1. TOKEN_CALLED
  async _handleTokenCalled({ centreId = 'CENTRE-01', officerId = 'OFFICER-101' }) {
    const centre = await db.getCentreById(centreId);
    const nextNum = (centre.currentServingTokenNum || 101) + 1;
    await db.updateCentreServingToken(centreId, nextNum);

    const targetTokenNum = `TK-${nextNum}`;
    const token = await db.getTokenByNumber(targetTokenNum);

    if (token) {
      const fromStatus = token.status;
      token.status = 'CALLED';
      token.currentStageIndex = 3;

      await db.updateTokenStage(token.id, 3, token.estimatedQuintals, token.estimatedBags, 'CALLED');

      await db.recordStatusHistory({
        id: `HIST-${Date.now()}`,
        tokenId: token.id,
        farmerId: token.farmerId,
        fromStatus: fromStatus,
        toStatus: 'CALLED',
        triggerEvent: 'TOKEN_CALLED',
        triggeredBy: officerId
      });

      await db.createNotification({
        id: `NOTIF-${Date.now()}`,
        farmerId: token.farmerId,
        titleEn: `Token Called: ${token.tokenNumber}`,
        titleTa: `டோக்கன் அழைக்கப்பட்டது: ${token.tokenNumber}`,
        messageEn: `Your token ${token.tokenNumber} has been called. Please proceed to Weighbridge Bay #02.`,
        messageTa: `உங்கள் டோக்கன் ${token.tokenNumber} அழைக்கப்பட்டது. எடை பகுதி #02-க்கு செல்லவும்.`
      });
    }

    await db.logAudit(officerId, 'TOKEN_CALLED', `Advanced current serving token to TK-${nextNum}`);
    const queueState = await db.getQueueStatusForFarmer(token ? token.farmerId : 'FARMER-001');

    return {
      success: true,
      event: 'TOKEN_CALLED',
      servingToken: `TK-${nextNum}`,
      token: token || null,
      queueState
    };
  }

  // 2. ARRIVED_AT_CENTRE
  async _handleArrivedAtCentre({ tokenId, farmerId = 'FARMER-001' }) {
    let token = tokenId ? await db.getTokenById(tokenId) : await db.getTokenByFarmerId(farmerId);
    if (!token) throw new Error('Active token not found.');

    const fromStatus = token.status;
    await db.updateTokenStage(token.id, 2, token.estimatedQuintals, token.estimatedBags);

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus,
      toStatus: 'ARRIVED_AT_CENTRE',
      triggerEvent: 'ARRIVED_AT_CENTRE',
      triggeredBy: 'GATE_AUTOMATION'
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Arrived at DPC Yard: ${token.tokenNumber}`,
      titleTa: `கொள்முதல் மையத்தை வந்தடைந்தது: ${token.tokenNumber}`,
      messageEn: `Vehicle gate clearance verified for ${token.tokenNumber}. Proceeding to electronic weighing scale.`,
      messageTa: `வாகன நுழைவு சரிபார்க்கப்பட்டது. எடை மேடைக்கு செல்லவும்.`
    });

    return { success: true, event: 'ARRIVED_AT_CENTRE', token };
  }

  // 3. WEIGHT_RECEIVED
  async _handleWeightReceived({ tokenId, farmerId = 'FARMER-001', deviceId = 'SCALE-SIM-01', weightKg = 50.25, bagCount = 45 }) {
    let token = tokenId ? await db.getTokenById(tokenId) : await db.getTokenByFarmerId(farmerId);
    if (!token) throw new Error('Active token not found for weighing.');

    const wKg = parseFloat(weightKg);
    const bCount = parseInt(bagCount, 10);
    const wQuintals = parseFloat(((wKg * bCount) / 100).toFixed(2));

    // Save weighing record
    const weighRecord = await db.createWeighingRecord({
      id: `WEIGH-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      centreId: token.centreId,
      deviceId,
      weightKg: wKg * bCount,
      weightQuintals: wQuintals,
      bagCount: bCount,
      readingStatus: 'STABLE_FINAL'
    });

    const fromStatus = token.status;
    await db.updateTokenStage(token.id, 4, wQuintals, bCount, 'WEIGHING_COMPLETED');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus,
      toStatus: 'WEIGHING_COMPLETED',
      triggerEvent: 'WEIGHT_RECEIVED',
      triggeredBy: deviceId
    });

    // Recalculate payment dynamically
    const mspRate = 2320.0;
    const deductions = 450.0;
    const grossAmount = wQuintals * mspRate;
    const netAmount = grossAmount - deductions;

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Weighing completed. Recorded weight: ${wKg} kg`,
      titleTa: `எடை நிறைவடைந்தது. பதிவு செய்யப்பட்ட எடை: ${wKg} கிலோ`,
      messageEn: `Weighing completed. Recorded weight: ${wKg} kg (${bCount} bags, ${wQuintals} Qtl). Gross Payout calculated: ₹${netAmount.toFixed(2)}.`,
      messageTa: `எடை பதிவு செய்யப்பட்டது. பதிவு செய்யப்பட்ட எடை: ${wKg} கிலோ (${bCount} மூட்டைகள்).`
    });

    await db.logAudit(deviceId, 'WEIGHING_COMPLETED', `Digital scale recorded ${wQuintals} Qtl (${bCount} bags) for ${token.tokenNumber}`);

    return {
      success: true,
      event: 'WEIGHING_COMPLETED',
      weighRecord,
      token,
      calculatedPayment: { grossAmount, deductions, netAmount }
    };
  }

  // 4. QUALITY_COMPLETED
  async _handleQualityCompleted({ tokenId, farmerId = 'FARMER-001', deviceId = 'QUAL-SIM-01', moisturePercentage = 14.2, foreignMatterPercentage = 0.5, inspectorId = 'INS-AUTO' }) {
    let token = tokenId ? await db.getTokenById(tokenId) : await db.getTokenByFarmerId(farmerId);
    if (!token) throw new Error('Active token not found for quality check.');

    const weighing = await db.getWeighingRecordByToken(token.id);
    const weightQuintals = weighing ? weighing.weightQuintals : (token.estimatedQuintals || 25.50);
    const bagCount = weighing ? weighing.bagCount : (token.estimatedBags || 45);

    const moisture = parseFloat(moisturePercentage);
    const fm = parseFloat(foreignMatterPercentage);
    const isAccepted = moisture <= 17.0 && fm <= 2.0;

    let grade = 'Grade A (FAQ Standard)';
    if (moisture > 15.0 && moisture <= 17.0) {
      grade = 'Paddy Common';
    }

    const rejectionReason = isAccepted ? null : `Moisture (${moisture}%) exceeds government FAQ maximum limit of 17.0%.`;

    const qualRecord = await db.createQualityRecord({
      id: `QUAL-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      centreId: token.centreId,
      deviceId,
      inspectorId,
      moisturePercentage: moisture,
      foreignMatterPercentage: fm,
      qualityGrade: grade,
      qualityStatus: isAccepted ? 'ACCEPTED' : 'REJECTED',
      rejectionReason
    });

    // Auto-generate Quality Test Certificate
    const qCertNum = `QCRT-${token.tokenNumber}-${Date.now().toString().slice(-4)}`;
    await db.createQualityCertificate({
      id: `CERT-QLT-${Date.now()}`,
      certificateNumber: qCertNum,
      tokenId: token.id,
      farmerId: token.farmerId,
      farmerName: token.farmerName,
      centreName: token.centreNameEn,
      cropName: token.cropNameEn,
      weightQuintals,
      moisturePercentage: moisture,
      foreignMatterPercentage: fm,
      qualityGrade: grade,
      result: isAccepted ? 'ACCEPTED' : 'REJECTED',
      rejectionReason,
      testingDevice: deviceId,
      officerName: 'S. Ravi (Quality Inspector)'
    });

    await db.createDocumentVerification({
      id: `VER-QLT-${Date.now()}`,
      docRefNumber: `BUYWISE-QLT-${qCertNum}`,
      docType: 'QUALITY_CERTIFICATE',
      tokenId: token.id,
      farmerId: token.farmerId,
      signatureHash: `SIG-QLT-SHA256-${Date.now()}`,
      verificationUrl: `/api/v1/verify/document/BUYWISE-QLT-${qCertNum}`
    });

    const fromStatus = token.status;
    await db.updateTokenStage(token.id, 4, weightQuintals, bagCount, 'QUALITY_COMPLETED');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus,
      toStatus: 'QUALITY_COMPLETED',
      triggerEvent: 'QUALITY_TEST_RECEIVED',
      triggeredBy: deviceId
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Quality check completed. Procurement status updated.`,
      titleTa: `தர பரிசோதனை முடிந்தது. கொள்முதல் நிலை புதுப்பிக்கப்பட்டது.`,
      messageEn: `Quality check completed. Procurement status updated. Moisture content: ${moisture}%. Status: ${isAccepted ? 'PASSED (Grade A)' : 'REJECTED'}.`,
      messageTa: `தர பரிசோதனை முடிந்தது. கொள்முதல் நிலை புதுப்பிக்கப்பட்டது. ஈரப்பதம்: ${moisture}%.`
    });

    // Auto-advance to ACCEPTED or REJECTED
    if (isAccepted) {
      return await this._handleProcurementAccepted({ token, qualRecord, weightQuintals, bagCount });
    } else {
      return await this._handleProcurementRejected({ token, qualRecord, rejectionReason, weightQuintals, bagCount });
    }
  }

  // 5. PROCUREMENT_ACCEPTED
  async _handleProcurementAccepted({ token, qualRecord, weightQuintals, bagCount }) {
    await db.updateTokenStage(token.id, 5, weightQuintals, bagCount, 'ACCEPTED');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus: 'WEIGHING_COMPLETED',
      toStatus: 'ACCEPTED',
      triggerEvent: 'PROCUREMENT_ACCEPTED',
      triggeredBy: 'AUTO_QUALITY_RULE'
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Quality check completed. Procurement status updated.`,
      titleTa: `தர பரிசோதனை முடிந்தது. கொள்முதல் நிலை புதுப்பிக்கப்பட்டது.`,
      messageEn: `Quality check completed. Procurement status updated.`,
      messageTa: `தர பரிசோதனை முடிந்தது. கொள்முதல் நிலை புதுப்பிக்கப்பட்டது.`
    });

    const wQuintals = weightQuintals || 22.61;
    const bCount = bagCount || 45;
    const mspRate = 2320.0;
    const deductions = 450.0;
    const grossAmount = wQuintals * mspRate;
    const netAmount = grossAmount - deductions;
    const receiptNum = `PR-TN-2026-${Math.floor(100000 + Math.random() * 900000)}`;

    const receipt = await db.createProcurementReceipt({
      id: `RCPT-${Date.now()}`,
      receiptNumber: receiptNum,
      tokenId: token.id,
      farmerId: token.farmerId,
      farmerName: token.farmerName,
      centreId: token.centreId,
      centreName: token.centreNameEn,
      cropName: token.cropNameEn,
      weightQuintals: wQuintals,
      bagCount: bCount,
      qualityGrade: qualRecord ? qualRecord.qualityGrade : 'Grade A (FAQ Standard)',
      moisturePercentage: qualRecord ? qualRecord.moisturePercentage : 14.2,
      applicableRate: mspRate,
      grossAmount,
      deductions,
      netAmount
    });

    // Auto-advance to procurement completion & payment processing
    return await this._handleProcurementCompleted({ token, qualRecord });
  }

  // 6. PROCUREMENT_REJECTED
  async _handleProcurementRejected({ token, qualRecord, rejectionReason, weightQuintals, bagCount }) {
    await db.updateTokenStage(token.id, 5, weightQuintals, bagCount, 'REJECTED');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus: 'QUALITY_COMPLETED',
      toStatus: 'REJECTED',
      triggerEvent: 'PROCUREMENT_REJECTED',
      triggeredBy: 'AUTO_QUALITY_RULE'
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Procurement Rejected: ${token.tokenNumber}`,
      titleTa: `கொள்முதல் நிராகரிக்கப்பட்டது: ${token.tokenNumber}`,
      messageEn: `Reason: ${rejectionReason}`,
      messageTa: `காரணம்: ${rejectionReason}`
    });

    return { success: false, event: 'PROCUREMENT_REJECTED', token, qualRecord, rejectionReason };
  }

  // 7. PROCUREMENT_COMPLETED & DIGITAL RECEIPT GENERATION
  async _handleProcurementCompleted({ token, qualRecord }) {
    const weighing = await db.getWeighingRecordByToken(token.id) || {
      weightQuintals: token.estimatedQuintals || 30.0,
      bagCount: token.estimatedBags || 45
    };
    const quality = qualRecord || await db.getQualityRecordByToken(token.id) || {
      qualityGrade: 'Grade A (FAQ Standard)',
      moisturePercentage: 14.2
    };

    const mspRate = 2320.0;
    const deductions = 450.0;
    const grossAmount = weighing.weightQuintals * mspRate;
    const netAmount = grossAmount - deductions;

    const receiptNum = `PR-TN-2026-${Math.floor(100000 + Math.random() * 900000)}`;

    const receipt = await db.createProcurementReceipt({
      id: `RCPT-${Date.now()}`,
      receiptNumber: receiptNum,
      tokenId: token.id,
      farmerId: token.farmerId,
      farmerName: token.farmerName,
      centreId: token.centreId,
      centreName: token.centreNameEn,
      cropName: token.cropNameEn,
      weightQuintals: weighing.weightQuintals,
      bagCount: weighing.bagCount,
      qualityGrade: quality.qualityGrade,
      moisturePercentage: quality.moisturePercentage,
      applicableRate: mspRate,
      grossAmount,
      deductions,
      netAmount
    });

    await db.createDocumentVerification({
      id: `VER-RCP-${Date.now()}`,
      docRefNumber: `BUYWISE-RCP-${receiptNum}`,
      docType: 'PROCUREMENT_RECEIPT',
      tokenId: token.id,
      farmerId: token.farmerId,
      signatureHash: `SIG-RCP-SHA256-${Date.now()}`,
      verificationUrl: `/api/v1/verify/document/BUYWISE-RCP-${receiptNum}`
    });

    await db.updateTokenStage(token.id, 5, weighing.weightQuintals, weighing.bagCount, 'COMPLETED');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus: 'ACCEPTED',
      toStatus: 'PROCUREMENT_COMPLETED',
      triggerEvent: 'PROCUREMENT_COMPLETED',
      triggeredBy: 'SYSTEM'
    });

    // Auto-trigger payment processing
    await this._handlePaymentInitiated({ token, receipt, netAmount });

    return {
      success: true,
      event: 'PROCUREMENT_COMPLETED',
      token,
      receipt
    };
  }

  // 8. PAYMENT_INITIATED & PAYMENT_COMPLETED
  async _handlePaymentInitiated({ token, receipt, netAmount }) {
    await db.updateTokenStage(token.id, 6, receipt.weightQuintals, receipt.bagCount, 'PROCESSING');

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus: 'PROCUREMENT_COMPLETED',
      toStatus: 'PAYMENT_PROCESSING',
      triggerEvent: 'PAYMENT_INITIATED',
      triggeredBy: 'PFMS_DIRECT_BENEFIT_GATEWAY'
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Payment Processing: ₹${netAmount.toFixed(2)}`,
      titleTa: `பணப்பரிமாற்றம் தொடங்கப்பட்டது: ₹${netAmount.toFixed(2)}`,
      messageEn: `DBT payout ₹${netAmount.toFixed(2)} initiated to bank account ending •••• 7821. Reference: PFMS-${receipt.receiptNumber}`,
      messageTa: `வங்கிக் கணக்கிற்கு ₹${netAmount.toFixed(2)} பணம் அனுப்புதல் தொடங்கப்பட்டது.`
    });

    // Auto complete payment
    return await this._handlePaymentCompleted({ token, receipt, netAmount });
  }

  async _handlePaymentCompleted({ token, receipt, netAmount }) {
    await db.updateTokenStage(token.id, 7, receipt.weightQuintals, receipt.bagCount, 'COMPLETED');

    const voucherNum = `PV-${token.tokenNumber}-${Date.now().toString().slice(-4)}`;
    const voucher = await db.createPaymentVoucher({
      id: `VOUCH-${Date.now()}`,
      voucherNumber: voucherNum,
      tokenId: token.id,
      farmerId: token.farmerId,
      farmerName: token.farmerName,
      procurementReceiptNumber: receipt.receiptNumber,
      centreName: token.centreNameEn,
      cropName: token.cropNameEn,
      weightQuintals: receipt.weightQuintals,
      mspRate: receipt.applicableRate || 2320.0,
      grossAmount: receipt.grossAmount || (receipt.weightQuintals * 2320.0),
      deductions: receipt.deductions || 450.0,
      netAmount,
      status: 'COMPLETED',
      bankReferenceNumber: `DBT-TN-2026-${Math.floor(100000 + Math.random() * 900000)}`
    });

    await db.createDocumentVerification({
      id: `VER-PAY-${Date.now()}`,
      docRefNumber: `BUYWISE-PAY-${voucherNum}`,
      docType: 'PAYMENT_VOUCHER',
      tokenId: token.id,
      farmerId: token.farmerId,
      signatureHash: `SIG-PAY-SHA256-${Date.now()}`,
      verificationUrl: `/api/v1/verify/document/BUYWISE-PAY-${voucherNum}`
    });

    await db.recordStatusHistory({
      id: `HIST-${Date.now()}`,
      tokenId: token.id,
      farmerId: token.farmerId,
      fromStatus: 'PAYMENT_PROCESSING',
      toStatus: 'PAYMENT_COMPLETED',
      triggerEvent: 'PAYMENT_COMPLETED',
      triggeredBy: 'BANK_DBT_CREDIT'
    });

    await db.createNotification({
      id: `NOTIF-${Date.now()}`,
      farmerId: token.farmerId,
      titleEn: `Payment Credit Confirmed: ₹${netAmount.toFixed(2)}`,
      titleTa: `வங்கி கணக்கில் பணம் வரவு வைக்கப்பட்டது: ₹${netAmount.toFixed(2)}`,
      messageEn: `Payment of ₹${netAmount.toFixed(2)} has been successfully credited to your bank account! Receipt: ${receipt.receiptNumber}.`,
      messageTa: `உங்கள் வங்கிக் கணக்கில் ₹${netAmount.toFixed(2)} வெற்றிகரமாக வரவு வைக்கப்பட்டது! ரசீது: ${receipt.receiptNumber}.`
    });

    return {
      success: true,
      event: 'PAYMENT_COMPLETED',
      token,
      receipt,
      voucher,
      netAmount
    };
  }

  // 9. FULL SIMULATED HARDWARE FLOW
  async _handleFullSimulatedFlow({ farmerId = 'FARMER-001', customWeightKg = 50.25, customMoisture = 14.2 }) {
    console.log('[ProcurementEventService] Executing FULL SIMULATED HARDWARE FLOW...');
    const scaleAdapter = new SimulatorWeighingAdapter();
    const qualityAdapter = new SimulatorQualityAdapter();

    const callRes = await this.handleEvent('TOKEN_CALLED', { centreId: 'CENTRE-01', officerId: 'OFFICER-101' });
    const tokenId = callRes.token ? callRes.token.id : null;

    const scaleData = await scaleAdapter.readWeight(customWeightKg, 45);
    const weighRes = await this.handleEvent('WEIGHT_RECEIVED', {
      tokenId,
      farmerId,
      deviceId: scaleData.deviceId,
      weightKg: scaleData.weightKgPerBag,
      bagCount: scaleData.bagCount
    });

    const qualData = await qualityAdapter.analyzeQuality(customMoisture, 0.5);
    const qualRes = await this.handleEvent('QUALITY_COMPLETED', {
      tokenId,
      farmerId,
      deviceId: qualData.deviceId,
      moisturePercentage: qualData.moisturePercentage,
      foreignMatterPercentage: qualData.foreignMatterPercentage
    });

    const token = qualRes.token || await db.getTokenByFarmerId(farmerId);
    const weightQuintals = weighRes.weighRecord ? weighRes.weighRecord.weightQuintals : 22.61;
    const bagCount = weighRes.weighRecord ? weighRes.weighRecord.bagCount : 45;

    const acceptRes = await this._handleProcurementAccepted({ token, qualRecord: qualRes.qualRecord, weightQuintals, bagCount });

    return {
      success: true,
      flow: 'FULL_SIMULATED_HARDWARE_FLOW',
      tokenCalled: callRes,
      weighing: weighRes,
      quality: qualRes,
      accepted: acceptRes
    };
  }
}

module.exports = new ProcurementEventService();
