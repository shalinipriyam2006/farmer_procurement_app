-- Production Database Schema for Farmer Procurement Platform

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('FARMER', 'OFFICER', 'ADMIN')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Procurement Centres Table
CREATE TABLE IF NOT EXISTS procurement_centres (
    id VARCHAR(64) PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_ta VARCHAR(255) NOT NULL,
    district VARCHAR(100) NOT NULL,
    taluk VARCHAR(100) DEFAULT 'Central',
    location_address TEXT NOT NULL,
    latitude DOUBLE PRECISION DEFAULT 10.7867,
    longitude DOUBLE PRECISION DEFAULT 79.1378,
    working_hours VARCHAR(100) DEFAULT '08:30 AM - 05:30 PM',
    contact_phone VARCHAR(20) NOT NULL,
    status VARCHAR(30) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'PAUSED', 'CLOSED', 'TEMPORARILY_UNAVAILABLE')),
    status_reason TEXT DEFAULT NULL,
    daily_capacity_bags INTEGER DEFAULT 1200,
    active_tokens_count INTEGER DEFAULT 0,
    current_serving_token_num INTEGER DEFAULT 101,
    avg_wait_minutes DOUBLE PRECISION DEFAULT 12.0
);

ALTER TABLE procurement_centres ADD COLUMN IF NOT EXISTS status_reason TEXT;

-- 3. Farmers Table
CREATE TABLE IF NOT EXISTS farmers (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    farmer_id_number VARCHAR(100) UNIQUE NOT NULL,
    village VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    preferred_centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    bank_account_masked VARCHAR(50) NOT NULL,
    ifsc_code VARCHAR(20) NOT NULL,
    land_holding_acres DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Officers Table
CREATE TABLE IF NOT EXISTS officers (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    badge_id VARCHAR(100) UNIQUE NOT NULL,
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    role VARCHAR(50) DEFAULT 'OFFICER',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Tokens Table
CREATE TABLE IF NOT EXISTS tokens (
    id VARCHAR(64) PRIMARY KEY,
    token_number VARCHAR(50) NOT NULL,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    centre_name_en VARCHAR(255) NOT NULL,
    centre_name_ta VARCHAR(255) NOT NULL,
    booking_date VARCHAR(50) NOT NULL,
    time_slot VARCHAR(100) NOT NULL,
    crop_name_en VARCHAR(100) NOT NULL,
    crop_name_ta VARCHAR(100) NOT NULL,
    estimated_quintals DOUBLE PRECISION NOT NULL,
    estimated_bags INTEGER NOT NULL,
    queue_position INTEGER DEFAULT 1,
    current_stage_index INTEGER DEFAULT 0,
    status VARCHAR(30) DEFAULT 'GENERATED' CHECK (status IN ('REQUESTED', 'GENERATED', 'SCHEDULED', 'WAITING', 'CALLED', 'PROCESSING', 'COMPLETED', 'MISSED', 'CANCELLED', 'ARRIVED_AT_CENTRE', 'UNDER_WEIGHING', 'WEIGHING_COMPLETED', 'UNDER_QUALITY_CHECK', 'QUALITY_COMPLETED', 'ACCEPTED', 'REJECTED', 'PROCUREMENT_COMPLETED', 'PAYMENT_PROCESSING', 'PAYMENT_COMPLETED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Queue Entries Table
CREATE TABLE IF NOT EXISTS queue_entries (
    id VARCHAR(64) PRIMARY KEY,
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    token_number VARCHAR(50) NOT NULL,
    farmer_name VARCHAR(255) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) DEFAULT 'WAITING',
    position_index INTEGER NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Procurement Records Table
CREATE TABLE IF NOT EXISTS procurement_records (
    id VARCHAR(64) PRIMARY KEY,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    actual_quintals DOUBLE PRECISION NOT NULL,
    actual_bags INTEGER NOT NULL,
    moisture_percentage DOUBLE PRECISION DEFAULT 14.2,
    quality_grade VARCHAR(100) DEFAULT 'Grade A (FAQ Standard)',
    weighment_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    officer_id VARCHAR(64) REFERENCES officers(id)
);

-- 8. Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    token_number VARCHAR(50) NOT NULL,
    crop_name_en VARCHAR(100) NOT NULL,
    crop_name_ta VARCHAR(100) NOT NULL,
    quantity_quintals DOUBLE PRECISION NOT NULL,
    bag_count INTEGER NOT NULL,
    msp_rate_per_quintal DOUBLE PRECISION DEFAULT 2320.0,
    deductions DOUBLE PRECISION DEFAULT 0.0,
    net_amount DOUBLE PRECISION NOT NULL,
    status VARCHAR(30) DEFAULT 'PROCESSING' CHECK (status IN ('NOT_INITIATED', 'PROCESSING', 'COMPLETED', 'FAILED')),
    payment_date TIMESTAMP WITH TIME ZONE,
    bank_reference_number VARCHAR(100) NOT NULL,
    masked_bank_account VARCHAR(50) NOT NULL,
    ifsc_code VARCHAR(20) NOT NULL,
    quality_grade VARCHAR(100) DEFAULT 'Grade A',
    moisture_percentage DOUBLE PRECISION DEFAULT 14.2,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    title_en VARCHAR(255) NOT NULL,
    title_ta VARCHAR(255) NOT NULL,
    message_en TEXT NOT NULL,
    message_ta TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Grievances Table
CREATE TABLE IF NOT EXISTS grievances (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'SUBMITTED' CHECK (status IN ('SUBMITTED', 'UNDER_REVIEW', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    remarks TEXT DEFAULT 'Ticket received and logged.',
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Documents Table
CREATE TABLE IF NOT EXISTS documents (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    title VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    issued_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    file_url TEXT NOT NULL
);

-- 12. Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id VARCHAR(64) PRIMARY KEY,
    officer_id VARCHAR(64) NOT NULL,
    action VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 13. Device Registrations Table
CREATE TABLE IF NOT EXISTS device_registrations (
    id VARCHAR(64) PRIMARY KEY,
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    device_id VARCHAR(100) UNIQUE NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    device_secret VARCHAR(255) NOT NULL,
    status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 14. Weighing Records Table
CREATE TABLE IF NOT EXISTS weighing_records (
    id VARCHAR(64) PRIMARY KEY,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    device_id VARCHAR(100) NOT NULL,
    weight_kg DOUBLE PRECISION NOT NULL,
    weight_quintals DOUBLE PRECISION NOT NULL,
    bag_count INTEGER NOT NULL,
    reading_status VARCHAR(50) DEFAULT 'STABLE_FINAL',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 15. Quality Records Table
CREATE TABLE IF NOT EXISTS quality_records (
    id VARCHAR(64) PRIMARY KEY,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    device_id VARCHAR(100) NOT NULL,
    inspector_id VARCHAR(64),
    moisture_percentage DOUBLE PRECISION NOT NULL,
    foreign_matter_percentage DOUBLE PRECISION DEFAULT 0.5,
    quality_grade VARCHAR(100) NOT NULL,
    quality_status VARCHAR(50) NOT NULL,
    rejection_reason TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 16. Procurement Status History Table
CREATE TABLE IF NOT EXISTS procurement_status_history (
    id VARCHAR(64) PRIMARY KEY,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    from_status VARCHAR(50),
    to_status VARCHAR(50) NOT NULL,
    trigger_event VARCHAR(100) NOT NULL,
    triggered_by VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 17. Procurement Receipts Table
CREATE TABLE IF NOT EXISTS procurement_receipts (
    id VARCHAR(64) PRIMARY KEY,
    receipt_number VARCHAR(100) UNIQUE NOT NULL,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    centre_name VARCHAR(255) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    weight_quintals DOUBLE PRECISION NOT NULL,
    bag_count INTEGER NOT NULL,
    quality_grade VARCHAR(100) NOT NULL,
    moisture_percentage DOUBLE PRECISION NOT NULL,
    applicable_rate DOUBLE PRECISION NOT NULL,
    gross_amount DOUBLE PRECISION NOT NULL,
    deductions DOUBLE PRECISION NOT NULL,
    net_amount DOUBLE PRECISION NOT NULL,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    document_url TEXT
);

-- 18. Quality Certificates Table
CREATE TABLE IF NOT EXISTS quality_certificates (
    id VARCHAR(64) PRIMARY KEY,
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    centre_name VARCHAR(255) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    weight_quintals DOUBLE PRECISION NOT NULL,
    moisture_percentage DOUBLE PRECISION NOT NULL,
    foreign_matter_percentage DOUBLE PRECISION DEFAULT 0.5,
    quality_grade VARCHAR(100) NOT NULL,
    result VARCHAR(30) NOT NULL,
    rejection_reason TEXT,
    testing_device VARCHAR(100) DEFAULT 'Digital Grain Moisture Analyzer HAL-200',
    officer_name VARCHAR(255) DEFAULT 'S. Ravi (Quality Inspector)',
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 19. Payment Vouchers Table
CREATE TABLE IF NOT EXISTS payment_vouchers (
    id VARCHAR(64) PRIMARY KEY,
    voucher_number VARCHAR(100) UNIQUE NOT NULL,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    procurement_receipt_number VARCHAR(100) NOT NULL,
    centre_name VARCHAR(255) NOT NULL,
    crop_name VARCHAR(100) NOT NULL,
    weight_quintals DOUBLE PRECISION NOT NULL,
    msp_rate DOUBLE PRECISION NOT NULL,
    gross_amount DOUBLE PRECISION NOT NULL,
    deductions DOUBLE PRECISION NOT NULL,
    net_amount DOUBLE PRECISION NOT NULL,
    status VARCHAR(30) DEFAULT 'COMPLETED',
    bank_reference_number VARCHAR(100) NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 20. Missed Slots Table
CREATE TABLE IF NOT EXISTS missed_slots (
    id VARCHAR(64) PRIMARY KEY,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    centre_id VARCHAR(64) REFERENCES procurement_centres(id),
    original_booking_date VARCHAR(50) NOT NULL,
    original_time_slot VARCHAR(100) NOT NULL,
    missed_reason TEXT DEFAULT 'Farmer did not arrive within scheduled window.',
    rescheduled_token_id VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 21. Feedback Table
CREATE TABLE IF NOT EXISTS feedback (
    id VARCHAR(64) PRIMARY KEY,
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    farmer_name VARCHAR(255) NOT NULL,
    receipt_id VARCHAR(64),
    overall_rating INTEGER NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    queue_rating INTEGER NOT NULL CHECK (queue_rating BETWEEN 1 AND 5),
    centre_rating INTEGER NOT NULL CHECK (centre_rating BETWEEN 1 AND 5),
    staff_rating INTEGER NOT NULL CHECK (staff_rating BETWEEN 1 AND 5),
    payment_rating INTEGER NOT NULL CHECK (payment_rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 22. Document Verifications Table
CREATE TABLE IF NOT EXISTS document_verifications (
    id VARCHAR(64) PRIMARY KEY,
    doc_ref_number VARCHAR(100) UNIQUE NOT NULL,
    doc_type VARCHAR(50) NOT NULL,
    token_id VARCHAR(64) REFERENCES tokens(id),
    farmer_id VARCHAR(64) REFERENCES farmers(id),
    signature_hash VARCHAR(255) NOT NULL,
    verification_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indices for Production Query Performance
CREATE INDEX IF NOT EXISTS idx_farmers_mobile ON farmers(mobile_number);
CREATE INDEX IF NOT EXISTS idx_tokens_farmer ON tokens(farmer_id);
CREATE INDEX IF NOT EXISTS idx_tokens_centre ON tokens(centre_id);
CREATE INDEX IF NOT EXISTS idx_payments_farmer ON payments(farmer_id);
CREATE INDEX IF NOT EXISTS idx_notifications_farmer ON notifications(farmer_id);
CREATE INDEX IF NOT EXISTS idx_grievances_farmer ON grievances(farmer_id);
CREATE INDEX IF NOT EXISTS idx_weighing_token ON weighing_records(token_id);
CREATE INDEX IF NOT EXISTS idx_quality_token ON quality_records(token_id);
CREATE INDEX IF NOT EXISTS idx_status_history_token ON procurement_status_history(token_id);
CREATE INDEX IF NOT EXISTS idx_receipts_farmer ON procurement_receipts(farmer_id);
CREATE INDEX IF NOT EXISTS idx_quality_certs_token ON quality_certificates(token_id);
CREATE INDEX IF NOT EXISTS idx_payment_vouchers_token ON payment_vouchers(token_id);
CREATE INDEX IF NOT EXISTS idx_feedback_farmer ON feedback(farmer_id);
CREATE INDEX IF NOT EXISTS idx_doc_verifications_ref ON document_verifications(doc_ref_number);


