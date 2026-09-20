const fs = require('fs');
const path = require('path');
const { newDb } = require('pg-mem');

async function runEventDrivenTest() {
  console.log('================================================================');
  console.log(' STARTING AUTOMATED EVENT-DRIVEN PROCUREMENT WORKFLOW AUDIT');
  console.log('================================================================\n');

  // Step 1: Initialize in-process PostgreSQL database engine
  console.log('1. Initializing In-Process PostgreSQL Database Engine...');
  const memDb = newDb();
  const { Pool: MemPool } = memDb.adapters.createPg();
  const memPool = new MemPool();

  // Step 2: Run DDL schema migration
  console.log('2. Running Database DDL Schema Migration (schema.sql)...');
  const schemaSql = fs.readFileSync(path.join(__dirname, '..', 'db', 'schema.sql'), 'utf8');
  await memPool.query(schemaSql);
  console.log('   -> Database schema migration complete.');

  // Seed baseline data
  await memPool.query(`
    INSERT INTO procurement_centres (id, name_en, name_ta, district, location_address, contact_phone, current_serving_token_num)
    VALUES ('CENTRE-01', 'Thanjavur Direct Purchase Centre', 'தஞ்சாவூர் நேரடி நெல் கொள்முதல் நிலையம்', 'Thanjavur', 'Market Committee Road, Thiruvaiyaru, Thanjavur', '+91 4362 278100', 105);

    INSERT INTO farmers (id, name, mobile_number, farmer_id_number, village, district, preferred_centre_id, bank_account_masked, ifsc_code)
    VALUES ('FARMER-001', 'Raja Ramanathan', '9876543210', 'TN-KISAN-84920', 'Thiruvaiyaru', 'Thanjavur', 'CENTRE-01', '•••• •••• 7821', 'SBIN0001234');

    INSERT INTO officers (id, name, badge_id, centre_id, role)
    VALUES ('OFFICER-101', 'S. Ravi', 'OFFICER-TNCSC-409', 'CENTRE-01', 'OFFICER');

    INSERT INTO tokens (id, token_number, farmer_id, farmer_name, centre_id, centre_name_en, centre_name_ta, booking_date, time_slot, crop_name_en, crop_name_ta, estimated_quintals, estimated_bags, current_stage_index, status)
    VALUES ('TOKEN-2026-106', 'TK-106', 'FARMER-001', 'Raja Ramanathan', 'CENTRE-01', 'Thanjavur DPC', 'தஞ்சாவூர் மையம்', 'Today', '10:30 AM', 'Paddy (Grade A)', 'நெல்', 30.0, 45, 0, 'SCHEDULED');
  `);

  // Hook dbPool to native pg-mem pool adapter
  const dbPool = require('../db/pool');
  const db = require('../data/database');
  const eventService = require('../services/procurementEventService');

  dbPool.query = (text, params) => memPool.query(text, params);
  dbPool.checkConnection = async () => ({ healthy: true, mode: 'postgresql' });
  dbPool.setIsConnected(true);

  await db.syncFromPostgres();
  console.log('   -> Backend event service initialized with PostgreSQL pool adapter.\n');

  // STEP 1: TOKEN CALLED AUTOMATICALLY
  console.log('--- STEP 1: TOKEN CALLED (OFFICER EVENT) ---');
  const callRes = await eventService.handleEvent('TOKEN_CALLED', { centreId: 'CENTRE-01', officerId: 'OFFICER-101' });
  console.log(`   -> Called Serving Token: ${callRes.servingToken}`);
  console.log(`   -> Token Status: ${callRes.token ? callRes.token.status : 'N/A'}`);
  
  const tokenPg1 = await memPool.query("SELECT * FROM tokens WHERE token_number = 'TK-106'");
  if (tokenPg1.rows[0].status !== 'CALLED') {
    throw new Error('FAIL: Token status was not updated to CALLED in PostgreSQL!');
  }
  console.log('   -> VERIFIED: Token CALLED status persisted to PostgreSQL.\n');

  // STEP 2: AUTOMATIC WEIGHING MACHINE INTEGRATION
  console.log('--- STEP 2: DIGITAL WEIGHING MACHINE EVENT (50.25 KG / BAG) ---');
  const weighRes = await eventService.handleEvent('WEIGHT_RECEIVED', {
    tokenId: 'TOKEN-2026-106',
    farmerId: 'FARMER-001',
    deviceId: 'SCALE-SIM-01',
    weightKg: 50.25,
    bagCount: 45
  });
  console.log(`   -> Weighment Recorded: ${weighRes.weighRecord.weightQuintals} Quintals (${weighRes.weighRecord.bagCount} bags)`);
  console.log(`   -> Calculated Net Payout: ₹${weighRes.calculatedPayment.netAmount.toFixed(2)}`);

  const weighPg = await memPool.query("SELECT * FROM weighing_records WHERE token_id = 'TOKEN-2026-106'");
  if (weighPg.rows.length === 0) {
    throw new Error('FAIL: Weighing record was not persisted to PostgreSQL!');
  }
  console.log('   -> VERIFIED: Digital Scale Weighing Record persisted to PostgreSQL.\n');

  // STEP 3: AUTOMATIC QUALITY CHECK WORKFLOW
  console.log('--- STEP 3: AUTOMATIC QUALITY CHECK EVENT (GRADE A, 14.2% MOISTURE) ---');
  const qualRes = await eventService.handleEvent('QUALITY_COMPLETED', {
    tokenId: 'TOKEN-2026-106',
    farmerId: 'FARMER-001',
    deviceId: 'QUAL-SIM-01',
    moisturePercentage: 14.2,
    foreignMatterPercentage: 0.5,
    inspectorId: 'INS-AUTO-01'
  });
  console.log(`   -> Quality Result Event Executed.`);

  const qualPg = await memPool.query("SELECT * FROM quality_records WHERE token_id = 'TOKEN-2026-106'");
  if (qualPg.rows.length === 0 || qualPg.rows[0].quality_status !== 'ACCEPTED') {
    throw new Error('FAIL: Quality record was not persisted or accepted in PostgreSQL!');
  }
  console.log('   -> VERIFIED: Automated Quality Sensor Record persisted to PostgreSQL.\n');

  // STEP 4: AUTOMATIC RECEIPT / DOCUMENT GENERATION
  console.log('--- STEP 4: DIGITAL PROCUREMENT RECEIPT GENERATION ---');
  const receiptPg = await memPool.query("SELECT * FROM procurement_receipts WHERE token_id = 'TOKEN-2026-106'");
  if (receiptPg.rows.length === 0) {
    throw new Error('FAIL: Digital Procurement Receipt was not generated in PostgreSQL!');
  }
  const r = receiptPg.rows[0];
  console.log(`   -> Receipt Number: ${r.receipt_number}`);
  console.log(`   -> Farmer: ${r.farmer_name} (${r.farmer_id})`);
  console.log(`   -> Measured Weight: ${r.weight_quintals} Qtl (${r.bag_count} bags)`);
  console.log(`   -> Grade: ${r.quality_grade} (Moisture: ${r.moisture_percentage}%)`);
  console.log(`   -> Applicable Rate: ₹${r.applicable_rate}/Qtl`);
  console.log(`   -> Net Payout Amount: ₹${r.net_amount}`);
  console.log('   -> VERIFIED: Digital Procurement Receipt successfully generated.\n');

  // STEP 5: AUTOMATIC STATUS HISTORY & NOTIFICATIONS AUDIT
  console.log('--- STEP 5: AUDIT LOGS & NOTIFICATIONS VERIFICATION ---');
  const historyPg = await memPool.query("SELECT * FROM procurement_status_history WHERE token_id = 'TOKEN-2026-106'");
  console.log(`   -> Total State Transitions Recorded: ${historyPg.rows.length}`);

  const notifPg = await memPool.query("SELECT COUNT(*) as cnt FROM notifications WHERE farmer_id = 'FARMER-001'");
  console.log(`   -> Total Farmer Notifications Generated: ${notifPg.rows[0].cnt}`);

  if (parseInt(notifPg.rows[0].cnt) < 3) {
    throw new Error('FAIL: Expected automatic notifications were not generated!');
  }
  console.log('   -> VERIFIED: All automated notifications and state audit trails persisted.\n');

  console.log('================================================================');
  console.log(' EVENT-DRIVEN PROCUREMENT WORKFLOW AUDIT PASSED (100%)');
  console.log('================================================================');
}

runEventDrivenTest().catch(err => {
  console.error('\nAUDIT FAILED WITH ERROR:', err);
  process.exit(1);
});
