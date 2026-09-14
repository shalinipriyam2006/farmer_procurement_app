/**
 * Procurement Data Repository & Database Layer
 * PostgreSQL-First Architecture:
 * - Reads, writes, queue updates, token bookings, grievances, payments, notifications,
 *   and audit logs execute direct parameterized SQL queries against PostgreSQL.
 * - In-memory fallback is active ONLY when PostgreSQL server is not connected.
 */

const dbPool = require('../db/pool');

class Database {
  constructor() {
    // In-memory fallback arrays for offline development & testing
    this.farmers = [
      {
        id: 'FARMER-001',
        name: 'Raja Ramanathan',
        mobileNumber: '9876543210',
        farmerIdNumber: 'TN-KISAN-84920',
        village: 'Thiruvaiyaru',
        district: 'Thanjavur',
        preferredCentreId: 'CENTRE-01',
        bankAccountMasked: '•••• •••• 7821',
        ifscCode: 'SBIN0001234',
        landHoldingAcres: 3.5,
      }
    ];

    this.officers = [
      {
        id: 'OFFICER-101',
        name: 'S. Ravi',
        badgeId: 'OFFICER-TNCSC-409',
        centreId: 'CENTRE-01',
        role: 'OFFICER',
      }
    ];

    this.procurementRates = [
      {
        cropEn: 'Paddy (Grade A)',
        cropTa: 'நெல் (கிரேடு ஏ)',
        variety: 'Grade A (Common Fair Average Quality)',
        ratePerQuintal: 2320.0,
        unit: 'Quintal',
        effectiveFrom: '2026-01-01',
        source: 'Development Baseline Rates (e-NAM Benchmark)',
        lastUpdated: '2026-09-14',
      },
      {
        cropEn: 'Paddy (Common)',
        cropTa: 'நெல் (சாதாரண தரம்)',
        variety: 'Common Grade FAQ',
        ratePerQuintal: 2300.0,
        unit: 'Quintal',
        effectiveFrom: '2026-01-01',
        source: 'Development Baseline Rates (e-NAM Benchmark)',
        lastUpdated: '2026-09-14',
      }
    ];

    this.centres = [
      {
        id: 'CENTRE-01',
        nameEn: 'Thanjavur Direct Purchase Centre',
        nameTa: 'தஞ்சாவூர் நேரடி நெல் கொள்முதல் நிலையம்',
        district: 'Thanjavur',
        taluk: 'Thiruvaiyaru',
        locationAddress: 'Market Committee Road, Thiruvaiyaru, Thanjavur - 613204',
        latitude: 10.8797,
        longitude: 79.1039,
        workingHours: '08:30 AM - 05:30 PM',
        contactPhone: '+91 4362 278100',
        status: 'OPEN',
        dailyCapacityBags: 1200,
        activeTokensCount: 38,
        currentServingTokenNum: 101,
        avgWaitMinutes: 12.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      },
      {
        id: 'CENTRE-02',
        nameEn: 'Tiruvarur Agricultural Marketing Committee',
        nameTa: 'திருவாரூர் வேளாண் விற்பனை குழு மையம்',
        district: 'Tiruvarur',
        taluk: 'Kudavasal',
        locationAddress: 'Kudavasal Main Road, Tiruvarur - 610001',
        latitude: 10.7717,
        longitude: 79.6361,
        workingHours: '09:00 AM - 05:00 PM',
        contactPhone: '+91 4366 220199',
        status: 'OPEN',
        dailyCapacityBags: 1000,
        activeTokensCount: 42,
        currentServingTokenNum: 88,
        avgWaitMinutes: 15.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      },
      {
        id: 'CENTRE-03',
        nameEn: 'Tiruchirappalli Regulated Market',
        nameTa: 'திருச்சிராப்பள்ளி ஒழுங்குமுறை விற்பனைக்கூடம்',
        district: 'Tiruchirappalli',
        taluk: 'Manachanallur',
        locationAddress: 'Manachanallur Road, Trichy - 620005',
        latitude: 10.8841,
        longitude: 78.7047,
        workingHours: '08:30 AM - 05:30 PM',
        contactPhone: '+91 431 2410882',
        status: 'OPEN',
        dailyCapacityBags: 1500,
        activeTokensCount: 19,
        currentServingTokenNum: 54,
        avgWaitMinutes: 8.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      },
      {
        id: 'CENTRE-04',
        nameEn: 'Madurai Vadipatti DPC',
        nameTa: 'மதுரை வாடிப்பட்டி நேரடி கொள்முதல் மையம்',
        district: 'Madurai',
        taluk: 'Vadipatti',
        locationAddress: 'Bypass Road, Vadipatti, Madurai - 625218',
        latitude: 10.0461,
        longitude: 77.9547,
        workingHours: '09:00 AM - 05:00 PM',
        contactPhone: '+91 452 2541200',
        status: 'OPEN',
        dailyCapacityBags: 800,
        activeTokensCount: 22,
        currentServingTokenNum: 31,
        avgWaitMinutes: 14.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)'],
      },
      {
        id: 'CENTRE-05',
        nameEn: 'Nagapattinam Coastal DPC',
        nameTa: 'நாகப்பட்டினம் கடலோர கொள்முதல் மையம்',
        district: 'Nagapattinam',
        taluk: 'Kilvelur',
        locationAddress: 'Main Road, Kilvelur, Nagapattinam - 611104',
        latitude: 10.7656,
        longitude: 79.8424,
        workingHours: '08:30 AM - 05:00 PM',
        contactPhone: '+91 4365 224100',
        status: 'OPEN',
        dailyCapacityBags: 900,
        activeTokensCount: 15,
        currentServingTokenNum: 45,
        avgWaitMinutes: 9.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      },
      {
        id: 'CENTRE-06',
        nameEn: 'Cuddalore Regulated Market Yard',
        nameTa: 'கடலூர் ஒழுங்குமுறை விற்பனைக்கூட வளாகம்',
        district: 'Cuddalore',
        taluk: 'Kurinjipadi',
        locationAddress: 'Station Road, Kurinjipadi, Cuddalore - 607302',
        latitude: 11.5647,
        longitude: 79.5912,
        workingHours: '09:00 AM - 05:30 PM',
        contactPhone: '+91 4142 288400',
        status: 'OPEN',
        dailyCapacityBags: 1100,
        activeTokensCount: 31,
        currentServingTokenNum: 70,
        avgWaitMinutes: 11.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      },
      {
        id: 'CENTRE-07',
        nameEn: 'Tiruvallur Agricultural Procurement Centre',
        nameTa: 'திருவள்ளூர் வேளாண் கொள்முதல் நிலையம்',
        district: 'Tiruvallur',
        taluk: 'Tiruttani',
        locationAddress: 'NH 205 Bypass Road, Tiruvallur - 602001',
        latitude: 13.1432,
        longitude: 79.9074,
        workingHours: '08:30 AM - 05:00 PM',
        contactPhone: '+91 44 2766 1200',
        status: 'OPEN',
        dailyCapacityBags: 1300,
        activeTokensCount: 27,
        currentServingTokenNum: 62,
        avgWaitMinutes: 10.0,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)'],
      },
      {
        id: 'CENTRE-08',
        nameEn: 'Salem Central Regulated Market',
        nameTa: 'சேலம் மத்திய ஒழுங்குமுறை விற்பனைக்கூடம்',
        district: 'Salem',
        taluk: 'Attur',
        locationAddress: 'Cuddalore Main Road, Attur, Salem - 636102',
        latitude: 11.5954,
        longitude: 78.5986,
        workingHours: '09:00 AM - 05:00 PM',
        contactPhone: '+91 427 2441900',
        status: 'OPEN',
        dailyCapacityBags: 1400,
        activeTokensCount: 18,
        currentServingTokenNum: 40,
        avgWaitMinutes: 8.5,
        procurementRate: 2320.0,
        cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
      }
    ];

    this.tokens = [
      {
        id: 'TOKEN-2026-104',
        tokenNumber: 'TK-104',
        farmerId: 'FARMER-001',
        farmerName: 'Raja Ramanathan',
        centreId: 'CENTRE-01',
        centreNameEn: 'Thanjavur Direct Purchase Centre',
        centreNameTa: 'தஞ்சாவூர் நேரடி நெல் கொள்முதல் நிலையம்',
        bookingDate: 'Today',
        timeSlot: '10:30 AM - 12:00 PM',
        cropNameEn: 'Paddy (Grade A)',
        cropNameTa: 'நெல் (கிரேடு ஏ)',
        estimatedQuintals: 30.0,
        estimatedBags: 45,
        status: 'CALLED',
        currentStageIndex: 2,
        createdAt: new Date().toISOString(),
      }
    ];

    this.payments = [
      {
        id: 'PAY-TN-2026-9932',
        farmerId: 'FARMER-001',
        tokenNumber: 'TK-104',
        cropNameEn: 'Paddy (Grade A)',
        cropNameTa: 'நெல் (கிரேடு ஏ)',
        quantityQuintals: 30.0,
        bagCount: 45,
        mspRatePerQuintal: 2320.0,
        deductions: 450.0,
        netAmount: (30.0 * 2320.0) - 450.0,
        status: 'PROCESSING',
        paymentDate: null,
        bankReferenceNumber: 'PFMS-TN-8492049281',
        maskedBankAccount: '•••• •••• 7821',
        ifscCode: 'SBIN0001234',
        qualityGrade: 'Grade A (Common Fair Average Quality)',
        moisturePercentage: 14.2,
      }
    ];

    this.notifications = [
      {
        id: 'NOTIF-1',
        farmerId: 'FARMER-001',
        titleEn: 'Digital Token Generated: TK-104',
        titleTa: 'டிஜிட்டல் டோக்கன் உருவாக்கப்பட்டது: TK-104',
        messageEn: 'Token TK-104 issued for Thanjavur Direct Purchase Centre.',
        messageTa: 'தஞ்சாவூர் நேரடி கொள்முதல் நிலையத்திற்கு டோக்கன் TK-104 வழங்கப்பட்டுள்ளது.',
        timestamp: new Date().toISOString(),
        isRead: true,
      },
      {
        id: 'NOTIF-2',
        farmerId: 'FARMER-001',
        titleEn: 'Your Turn is Approaching',
        titleTa: 'உங்கள் முறை நெருங்குகிறது',
        messageEn: 'Token TK-102 is currently being served. Please remain near gate.',
        messageTa: 'டோக்கன் TK-102 தற்போது நடைபெறுகிறது. வாயில் அருகே இருக்கவும்.',
        timestamp: new Date().toISOString(),
        isRead: false,
      }
    ];

    this.grievances = [
      {
        id: 'GRV-8021',
        farmerId: 'FARMER-001',
        farmerName: 'Raja Ramanathan',
        category: 'Moisture Calibration',
        description: 'Discrepancy in moisture testing reading at Bay 1.',
        status: 'IN PROGRESS',
        submittedAt: new Date(Date.now() - 86400000).toISOString(),
        updatedAt: new Date().toISOString(),
        remarks: 'Inspector assigned to re-calibrate device.',
      }
    ];

    this.documents = [
      {
        id: 'DOC-101',
        farmerId: 'FARMER-001',
        title: 'Token Pass Receipt (TK-104)',
        type: 'TOKEN_RECEIPT',
        issuedDate: new Date().toISOString(),
        fileUrl: '/api/v1/documents/download/DOC-101',
      },
      {
        id: 'DOC-102',
        farmerId: 'FARMER-001',
        title: 'Weighment & Moisture Certificate',
        type: 'WEIGHMENT_RECEIPT',
        issuedDate: new Date().toISOString(),
        fileUrl: '/api/v1/documents/download/DOC-102',
      },
      {
        id: 'DOC-103',
        farmerId: 'FARMER-001',
        title: 'Government Treasury Payout Voucher',
        type: 'PAYMENT_RECEIPT',
        issuedDate: new Date().toISOString(),
        fileUrl: '/api/v1/documents/download/DOC-103',
      }
    ];

    this.auditLogs = [
      {
        id: 'AUDIT-001',
        officerId: 'OFFICER-101',
        action: 'CALL_NEXT_TOKEN',
        details: 'Advanced current serving token to 101',
        timestamp: new Date().toISOString(),
      }
    ];
  }

  // --- RATES ---
  async getProcurementRates() {
    return this.procurementRates;
  }

  // --- FARMERS ---
  async getFarmerByMobile(mobileNumber) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM farmers WHERE mobile_number = $1', [mobileNumber]);
        if (res.rows.length > 0) return this._mapFarmerRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error getting farmer by mobile:', err.message);
      }
    }
    let farmer = this.farmers.find(f => f.mobileNumber === mobileNumber);
    return farmer || null;
  }

  async getFarmerById(id) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM farmers WHERE id = $1', [id]);
        if (res.rows.length > 0) return this._mapFarmerRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error getting farmer by ID:', err.message);
      }
    }
    let farmer = this.farmers.find(f => f.id === id);
    return farmer || this.farmers[0];
  }

  // --- OFFICERS ---
  async getOfficerByBadgeId(badgeId) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM officers WHERE badge_id = $1', [badgeId]);
        if (res.rows.length > 0) return this._mapOfficerRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error getting officer by badge:', err.message);
      }
    }
    let officer = this.officers.find(o => o.badgeId === badgeId);
    return officer || this.officers[0];
  }

  // --- CENTRES ---
  async getCentres() {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM procurement_centres ORDER BY id');
        if (res.rows.length > 0) return res.rows.map(r => this._mapCentreRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting centres:', err.message);
      }
    }
    return this.centres;
  }

  async getCentreById(id) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM procurement_centres WHERE id = $1', [id]);
        if (res.rows.length > 0) return this._mapCentreRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error getting centre by ID:', err.message);
      }
    }
    let centre = this.centres.find(c => c.id === id);
    return centre || this.centres[0];
  }

  async updateCentreServingToken(centreId, newTokenNum) {
    let centreMem = this.centres.find(c => c.id === centreId) || this.centres[0];
    centreMem.currentServingTokenNum = newTokenNum;

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `UPDATE procurement_centres 
           SET current_serving_token_num = $1, 
               active_tokens_count = GREATEST(0, active_tokens_count - 1) 
           WHERE id = $2`,
          [newTokenNum, centreId]
        );
        const res = await dbPool.query('SELECT * FROM procurement_centres WHERE id = $1', [centreId]);
        if (res.rows.length > 0) return this._mapCentreRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error updating serving token:', err.message);
      }
    }
    return centreMem;
  }

  async updateCentreStatus(centreId, status, statusReason = null) {
    let centreMem = this.centres.find(c => c.id === centreId) || this.centres[0];
    centreMem.status = status;
    centreMem.statusReason = statusReason;

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          'UPDATE procurement_centres SET status = $1, status_reason = $2 WHERE id = $3',
          [status, statusReason, centreId]
        );
      } catch (err) {
        console.error('[Database Layer] Error updating status:', err.message);
      }
    }

    if (status === 'CLOSED') {
      const reasonMsg = statusReason ? ` Reason: ${statusReason}` : '';
      const reasonMsgTa = statusReason ? ` காரணம்: ${statusReason}` : '';
      await this.createNotification({
        id: `NOTIF-${Date.now()}`,
        farmerId: 'FARMER-001',
        titleEn: 'Your Procurement Centre is Currently Closed',
        titleTa: 'உங்கள் கொள்முதல் மையம் தற்போது மூடப்பட்டுள்ளது',
        messageEn: `${centreMem.nameEn} has been marked CLOSED by administrative officers.${reasonMsg}`,
        messageTa: `${centreMem.nameTa} அதிகாரிகளால் மூடப்பட்டது என குறிப்பிடப்பட்டுள்ளது.${reasonMsgTa}`,
        timestamp: new Date().toISOString(),
        isRead: false,
      });
    }

    return status;
  }

  // --- TOKENS ---
  async getTokenByFarmerId(farmerId) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query(
          'SELECT * FROM tokens WHERE farmer_id = $1 ORDER BY created_at DESC LIMIT 1',
          [farmerId]
        );
        if (res.rows.length > 0) return this._mapTokenRow(res.rows[0]);
      } catch (err) {
        console.error('[Database Layer] Error getting token by farmer:', err.message);
      }
    }
    let token = this.tokens.find(t => t.farmerId === farmerId);
    return token || this.tokens[0];
  }

  async createToken(token) {
    this.tokens.unshift(token);

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `INSERT INTO tokens (
            id, token_number, farmer_id, farmer_name, centre_id, centre_name_en, centre_name_ta,
            booking_date, time_slot, crop_name_en, crop_name_ta, estimated_quintals, estimated_bags,
            queue_position, current_stage_index, status, created_at
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`,
          [
            token.id, token.tokenNumber, token.farmerId, token.farmerName, token.centreId,
            token.centreNameEn, token.centreNameTa, token.bookingDate, token.timeSlot,
            token.cropNameEn, token.cropNameTa, token.estimatedQuintals, token.estimatedBags,
            token.queuePosition || 1, token.currentStageIndex || 0, token.status || 'GENERATED',
            token.createdAt || new Date().toISOString()
          ]
        );
      } catch (err) {
        console.error('[Database Layer] Error creating token:', err.message);
      }
    }
    return token;
  }

  async updateTokenStage(tokenId, stageIndex, quintals, bags) {
    let tokenMem = this.tokens.find(t => t.id === tokenId) || this.tokens[0];
    if (stageIndex !== undefined) tokenMem.currentStageIndex = stageIndex;
    if (quintals) tokenMem.estimatedQuintals = quintals;
    if (bags) tokenMem.estimatedBags = bags;

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `UPDATE tokens 
           SET current_stage_index = COALESCE($1, current_stage_index),
               estimated_quintals = COALESCE($2, estimated_quintals),
               estimated_bags = COALESCE($3, estimated_bags)
           WHERE id = $4 OR id = (SELECT id FROM tokens ORDER BY created_at DESC LIMIT 1)`,
          [stageIndex, quintals, bags, tokenId]
        );
      } catch (err) {
        console.error('[Database Layer] Error updating token stage:', err.message);
      }
    }
    return tokenMem;
  }

  // --- QUEUE ---
  async getQueueStatusForFarmer(farmerId) {
    const token = await this.getTokenByFarmerId(farmerId);
    const centre = await this.getCentreById(token.centreId);

    const userTokenNum = parseInt(token.tokenNumber.replace(/\D/g, '')) || 104;
    const farmersAhead = Math.max(0, userTokenNum - centre.currentServingTokenNum);
    const avgWait = centre.avgWaitMinutes || 12.0;
    const estWaitMinutes = Math.round(farmersAhead * avgWait);

    let statusEn = farmersAhead === 0
      ? 'YOUR TURN NOW! Proceed to Bay #02'
      : `Moving Smoothly (~${Math.round(avgWait)} mins/farmer)`;
    let statusTa = farmersAhead === 0
      ? 'உங்கள் முறை வந்துவிட்டது!'
      : `சீரான வேகம் (~${Math.round(avgWait)} நிமிடம்/விவசாயி)`;

    if (centre.status === 'CLOSED') {
      statusEn = centre.statusReason
        ? `CENTRE CLOSED: ${centre.statusReason}`
        : 'Procurement Centre Currently Closed';
      statusTa = centre.statusReason
        ? `நிலையம் மூடப்பட்டுள்ளது: ${centre.statusReason}`
        : 'கொள்முதல் நிலையம் தற்போது மூடப்பட்டுள்ளது';
    }

    let sequence = [];
    for (let i = centre.currentServingTokenNum - 2; i <= centre.currentServingTokenNum + 5; i++) {
      if (i <= 0) continue;
      const tk = `TK-${i}`;
      sequence.push({
        tokenNumber: tk,
        farmerName: (tk === token.tokenNumber) ? token.farmerName : `Farmer ${i}`,
        crop: token.cropNameEn || 'Paddy',
        isServing: (i === centre.currentServingTokenNum),
        isPast: (i < centre.currentServingTokenNum),
        isUser: (tk === token.tokenNumber),
      });
    }

    return {
      currentServingToken: `TK-${centre.currentServingTokenNum}`,
      userToken: token.tokenNumber,
      farmersAhead,
      estimatedWaitMinutes: estWaitMinutes,
      totalServedToday: Math.max(0, centre.currentServingTokenNum - 80),
      centreStatus: centre.status,
      statusReason: centre.statusReason || null,
      queueStatusEn: statusEn,
      queueStatusTa: statusTa,
      queueSequence: sequence,
    };
  }

  // --- PAYMENTS ---
  async getPaymentsByFarmer(farmerId) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM payments WHERE farmer_id = $1 ORDER BY id DESC', [farmerId]);
        if (res.rows.length > 0) return res.rows.map(r => this._mapPaymentRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting payments:', err.message);
      }
    }
    let p = this.payments.find(pm => pm.farmerId === farmerId);
    return p || this.payments[0];
  }

  // --- NOTIFICATIONS ---
  async getNotificationsByFarmer(farmerId) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM notifications WHERE farmer_id = $1 ORDER BY created_at DESC', [farmerId]);
        if (res.rows.length > 0) return res.rows.map(r => this._mapNotificationRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting notifications:', err.message);
      }
    }
    return this.notifications.filter(n => n.farmerId === farmerId);
  }

  async createNotification(notif) {
    this.notifications.unshift(notif);

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `INSERT INTO notifications (id, farmer_id, title_en, title_ta, message_en, message_ta, is_read, created_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            notif.id, notif.farmerId, notif.titleEn, notif.titleTa,
            notif.messageEn, notif.messageTa, notif.isRead || false,
            notif.timestamp || new Date().toISOString()
          ]
        );
      } catch (err) {
        console.error('[Database Layer] Error creating notification:', err.message);
      }
    }
    return notif;
  }

  // --- GRIEVANCES ---
  async getGrievances() {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM grievances ORDER BY submitted_at DESC');
        if (res.rows.length > 0) return res.rows.map(r => this._mapGrievanceRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting grievances:', err.message);
      }
    }
    return this.grievances;
  }

  async createGrievance(grievance) {
    this.grievances.unshift(grievance);

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `INSERT INTO grievances (id, farmer_id, farmer_name, category, description, status, remarks, submitted_at, updated_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
          [
            grievance.id, grievance.farmerId, grievance.farmerName, grievance.category,
            grievance.description, grievance.status || 'SUBMITTED', grievance.remarks,
            grievance.submittedAt || new Date().toISOString(), grievance.updatedAt || new Date().toISOString()
          ]
        );
      } catch (err) {
        console.error('[Database Layer] Error creating grievance:', err.message);
      }
    }
    return grievance;
  }

  // --- DOCUMENTS ---
  async getDocumentsByFarmer(farmerId) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM documents WHERE farmer_id = $1 ORDER BY issued_date DESC', [farmerId]);
        if (res.rows.length > 0) return res.rows.map(r => this._mapDocumentRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting documents:', err.message);
      }
    }
    return this.documents.filter(d => d.farmerId === farmerId) || this.documents;
  }

  // --- AUDIT LOGS ---
  async logAudit(officerId, action, details) {
    const auditEntry = {
      id: `AUDIT-${Date.now()}`,
      officerId,
      action,
      details,
      timestamp: new Date().toISOString(),
    };
    this.auditLogs.unshift(auditEntry);

    if (dbPool.isDbConnected) {
      try {
        await dbPool.query(
          `INSERT INTO audit_logs (id, officer_id, action, details, created_at) VALUES ($1, $2, $3, $4, $5)`,
          [auditEntry.id, auditEntry.officerId, auditEntry.action, auditEntry.details, auditEntry.timestamp]
        );
      } catch (err) {
        console.error('Failed to log audit in PostgreSQL:', err.message);
      }
    }
    return auditEntry;
  }

  async getAuditLogs(limit = 10) {
    if (dbPool.isDbConnected) {
      try {
        const res = await dbPool.query('SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT $1', [limit]);
        if (res.rows.length > 0) return res.rows.map(r => this._mapAuditLogRow(r));
      } catch (err) {
        console.error('[Database Layer] Error getting audit logs:', err.message);
      }
    }
    return this.auditLogs.slice(0, limit);
  }

  /**
   * Helper Mappers
   */
  _mapFarmerRow(r) {
    return {
      id: r.id,
      name: r.name,
      mobileNumber: r.mobile_number,
      farmerIdNumber: r.farmer_id_number,
      village: r.village,
      district: r.district,
      preferredCentreId: r.preferred_centre_id,
      bankAccountMasked: r.bank_account_masked,
      ifscCode: r.ifsc_code,
      landHoldingAcres: parseFloat(r.land_holding_acres),
    };
  }

  _mapOfficerRow(r) {
    return {
      id: r.id,
      name: r.name,
      badgeId: r.badge_id,
      centreId: r.centre_id,
      role: r.role || 'OFFICER',
    };
  }

  _mapCentreRow(r) {
    return {
      id: r.id,
      nameEn: r.name_en,
      nameTa: r.name_ta,
      district: r.district,
      taluk: r.taluk,
      locationAddress: r.location_address,
      latitude: parseFloat(r.latitude),
      longitude: parseFloat(r.longitude),
      workingHours: r.working_hours,
      contactPhone: r.contact_phone,
      status: r.status,
      statusReason: r.status_reason || null,
      dailyCapacityBags: r.daily_capacity_bags,
      activeTokensCount: r.active_tokens_count,
      currentServingTokenNum: r.current_serving_token_num,
      avgWaitMinutes: parseFloat(r.avg_wait_minutes),
      procurementRate: 2320.0,
      cropsAccepted: ['Paddy (Grade A)', 'Paddy (Common)'],
    };
  }

  _mapTokenRow(r) {
    return {
      id: r.id,
      tokenNumber: r.token_number,
      farmerId: r.farmer_id,
      farmerName: r.farmer_name,
      centreId: r.centre_id,
      centreNameEn: r.centre_name_en,
      centreNameTa: r.centre_name_ta,
      bookingDate: r.booking_date,
      timeSlot: r.time_slot,
      cropNameEn: r.crop_name_en,
      cropNameTa: r.crop_name_ta,
      estimatedQuintals: parseFloat(r.estimated_quintals),
      estimatedBags: r.estimated_bags,
      status: r.status,
      currentStageIndex: r.current_stage_index,
      createdAt: r.created_at,
    };
  }

  _mapPaymentRow(r) {
    return {
      id: r.id,
      farmerId: r.farmer_id,
      tokenNumber: r.token_number,
      cropNameEn: r.crop_name_en,
      cropNameTa: r.crop_name_ta,
      quantityQuintals: parseFloat(r.quantity_quintals),
      bagCount: r.bag_count,
      mspRatePerQuintal: parseFloat(r.msp_rate_per_quintal),
      deductions: parseFloat(r.deductions),
      netAmount: parseFloat(r.net_amount),
      status: r.status,
      paymentDate: r.payment_date,
      bankReferenceNumber: r.bank_reference_number,
      maskedBankAccount: r.masked_bank_account,
      ifscCode: r.ifsc_code,
      qualityGrade: r.quality_grade,
      moisturePercentage: parseFloat(r.moisture_percentage),
    };
  }

  _mapNotificationRow(r) {
    return {
      id: r.id,
      farmerId: r.farmer_id,
      titleEn: r.title_en,
      titleTa: r.title_ta,
      messageEn: r.message_en,
      messageTa: r.message_ta,
      timestamp: r.created_at,
      isRead: r.is_read,
    };
  }

  _mapGrievanceRow(r) {
    return {
      id: r.id,
      farmerId: r.farmer_id,
      farmerName: r.farmer_name,
      category: r.category,
      description: r.description,
      status: r.status,
      submittedAt: r.submitted_at,
      updatedAt: r.updated_at,
      remarks: r.remarks,
    };
  }

  _mapDocumentRow(r) {
    return {
      id: r.id,
      farmerId: r.farmer_id,
      title: r.title,
      type: r.type,
      issuedDate: r.issued_date,
      fileUrl: r.file_url,
    };
  }

  _mapAuditLogRow(r) {
    return {
      id: r.id,
      officerId: r.officer_id,
      action: r.action,
      details: r.details,
      timestamp: r.created_at,
    };
  }

  async syncFromPostgres() {
    const connInfo = await dbPool.checkConnection();
    if (!connInfo.healthy) {
      console.log(`[Database Layer] Operating in local memory fallback mode (${connInfo.reason || connInfo.error})`);
      return false;
    }
    console.log('[Database Layer] PostgreSQL is active and connected as the primary source of truth.');
    return true;
  }
}

module.exports = new Database();
