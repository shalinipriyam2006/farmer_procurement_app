/**
 * Development Seed Data Script
 * 
 * IMPORTANT:
 * - This script is for LOCAL DEVELOPMENT and STAGING TESTING ONLY.
 * - Do NOT run this script in a live production environment.
 * - Test data is synthetic and not presented as real government data.
 */

const { pool, isPostgresConnected } = require('./pool');

async function runSeed() {
  if (process.env.NODE_ENV === 'production') {
    console.warn('[DB Seed] Warning: Seeding is blocked in production environment.');
    return;
  }

  console.log('[DB Seed] Executing local development seed script...');
  const isConnected = await isPostgresConnected();

  if (!isConnected) {
    console.log('[DB Seed] PostgreSQL unavailable. In-memory dev repository initialized automatically.');
    return;
  }

  try {
    // 1. Seed Procurement Centres
    await pool.query(`
      INSERT INTO procurement_centres (id, name_en, name_ta, district, taluk, location_address, latitude, longitude, working_hours, contact_phone, status, daily_capacity_bags, active_tokens_count, current_serving_token_num, avg_wait_minutes)
      VALUES 
      ('CENTRE-01', 'Thanjavur Direct Purchase Centre', 'தஞ்சாவூர் நேரடி நெல் கொள்முதல் நிலையம்', 'Thanjavur', 'Thiruvaiyaru', 'Market Committee Road, Thiruvaiyaru, Thanjavur - 613204', 10.8797, 79.1039, '08:30 AM - 05:30 PM', '+91 4362 278100', 'OPEN', 1200, 38, 101, 12.0),
      ('CENTRE-02', 'Tiruvarur Agricultural Marketing Committee', 'திருவாரூர் வேளாண் விற்பனை குழு மையம்', 'Tiruvarur', 'Kudavasal', 'Kudavasal Main Road, Tiruvarur - 610001', 10.7717, 79.6361, '09:00 AM - 05:00 PM', '+91 4366 220199', 'OPEN', 1000, 42, 88, 15.0),
      ('CENTRE-03', 'Tiruchirappalli Regulated Market', 'திருச்சிராப்பள்ளி ஒழுங்குமுறை விற்பனைக்கூடம்', 'Tiruchirappalli', 'Manachanallur', 'Manachanallur Road, Trichy - 620005', 10.8841, 78.7047, '08:30 AM - 05:30 PM', '+91 431 2410882', 'OPEN', 1500, 19, 54, 8.0),
      ('CENTRE-04', 'Madurai Vadipatti DPC', 'மதுரை வாடிப்பட்டி நேரடி கொள்முதல் மையம்', 'Madurai', 'Vadipatti', 'Bypass Road, Vadipatti, Madurai - 625218', 10.0461, 77.9547, '09:00 AM - 05:00 PM', '+91 452 2541200', 'OPEN', 800, 22, 31, 14.0),
      ('CENTRE-05', 'Nagapattinam Coastal DPC', 'நாகப்பட்டினம் கடலோர கொள்முதல் மையம்', 'Nagapattinam', 'Kilvelur', 'Main Road, Kilvelur, Nagapattinam - 611104', 10.7656, 79.8424, '08:30 AM - 05:00 PM', '+91 4365 224100', 'OPEN', 900, 15, 45, 9.0),
      ('CENTRE-06', 'Cuddalore Regulated Market Yard', 'கடலூர் ஒழுங்குமுறை விற்பனைக்கூட வளாகம்', 'Cuddalore', 'Kurinjipadi', 'Station Road, Kurinjipadi, Cuddalore - 607302', 11.5647, 79.5912, '09:00 AM - 05:30 PM', '+91 4142 288400', 'OPEN', 1100, 31, 70, 11.0),
      ('CENTRE-07', 'Tiruvallur Agricultural Procurement Centre', 'திருவள்ளூர் வேளாண் கொள்முதல் நிலையம்', 'Tiruvallur', 'Tiruttani', 'NH 205 Bypass Road, Tiruvallur - 602001', 13.1432, 79.9074, '08:30 AM - 05:00 PM', '+91 44 2766 1200', 'OPEN', 1300, 27, 62, 10.0),
      ('CENTRE-08', 'Salem Central Regulated Market', 'சேலம் மத்திய ஒழுங்குமுறை விற்பனைக்கூடம்', 'Salem', 'Attur', 'Cuddalore Main Road, Attur, Salem - 636102', 11.5954, 78.5986, '09:00 AM - 05:00 PM', '+91 427 2441900', 'OPEN', 1400, 18, 40, 8.5)
      ON CONFLICT (id) DO UPDATE SET 
        name_en = EXCLUDED.name_en,
        name_ta = EXCLUDED.name_ta,
        district = EXCLUDED.district,
        taluk = EXCLUDED.taluk,
        location_address = EXCLUDED.location_address,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        working_hours = EXCLUDED.working_hours,
        contact_phone = EXCLUDED.contact_phone;
    `);

    // 2. Seed Test Farmers
    await pool.query(`
      INSERT INTO farmers (id, name, mobile_number, farmer_id_number, village, district, preferred_centre_id, bank_account_masked, ifsc_code, land_holding_acres)
      VALUES 
      ('FARMER-001', 'Raja Ramanathan', '9876543210', 'TN-KISAN-84920', 'Thiruvaiyaru', 'Thanjavur', 'CENTRE-01', '•••• •••• 7821', 'SBIN0001234', 3.5)
      ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, mobile_number = EXCLUDED.mobile_number;
    `);

    // 3. Seed Test Officers
    await pool.query(`
      INSERT INTO officers (id, name, badge_id, centre_id, role)
      VALUES 
      ('OFFICER-101', 'S. Ravi', 'OFFICER-TNCSC-409', 'CENTRE-01', 'OFFICER')
      ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    `);

    console.log('[DB Seed] Development seed data populated successfully!');
  } catch (err) {
    console.error('[DB Seed Error] Seed failed:', err.message);
  }
}

if (require.main === module) {
  runSeed().then(() => process.exit(0));
}

module.exports = { runSeed };
