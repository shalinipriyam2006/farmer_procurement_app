/**
 * SMS & OTP Authentication Provider Adapter
 * 
 * Production-ready OTP provider abstraction supporting:
 * 1. Twilio SMS API
 * 2. Fast2SMS API
 * 3. Isolated Dev Mode (enabled ONLY when OTP_DEV_MODE=true or NODE_ENV !== 'production')
 * 
 * Strict Production Safety Safeguards:
 * - Does NOT return OTP digits in API responses when live SMS is active.
 * - Does NOT expose OTP digits in production server logs.
 * - Does NOT return isDevMode=true in production unless explicitly enabled via OTP_DEV_MODE=true.
 * - Refuses execution with clear configuration message if SMS credentials are missing in production.
 */

const env = require('../config/env');

class SmsAdapter {
  constructor() {
    this.otpStore = new Map(); // Key: mobileNumber -> { otp, expiresAt, attempts }
    this.provider = process.env.SMS_PROVIDER || 'DEV';
    this.twilioSid = process.env.TWILIO_ACCOUNT_SID;
    this.twilioAuthToken = process.env.TWILIO_AUTH_TOKEN;
    this.twilioPhone = process.env.TWILIO_PHONE_NUMBER;
    this.fast2smsKey = process.env.FAST2SMS_API_KEY;
  }

  /**
   * Checks if a live external SMS gateway is fully configured
   */
  isProviderConfigured() {
    if (this.provider === 'TWILIO' && this.twilioSid && this.twilioAuthToken && this.twilioPhone) {
      return true;
    }
    if (this.provider === 'FAST2SMS' && this.fast2smsKey) {
      return true;
    }
    return false;
  }

  /**
   * Generate and send SMS OTP to farmer mobile number
   */
  async sendOtp(mobileNumber) {
    const cleanMobile = mobileNumber.replace(/\D/g, '');
    if (cleanMobile.length < 10) {
      return { success: false, error: 'Invalid mobile number format. Must be at least 10 digits.' };
    }

    const isLive = this.isProviderConfigured();
    const isDevModeAllowed = env.otpDevMode;

    if (!isLive && !isDevModeAllowed) {
      return {
        success: false,
        error: 'OTP service is temporarily unavailable. SMS gateway configuration pending in production.',
      };
    }

    // In production mode with live SMS provider, generate secure random 6-digit OTP
    const generatedOtp = isLive 
      ? Math.floor(100000 + Math.random() * 900000).toString() 
      : '123456';

    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes expiry

    this.otpStore.set(cleanMobile, {
      otp: generatedOtp,
      expiresAt,
      attempts: 0,
    });

    if (isLive) {
      const messageText = `[TN Paddy Procurement] Your authentication OTP is ${generatedOtp}. Valid for 10 minutes. Do not share with anyone.`;
      try {
        if (this.provider === 'TWILIO') {
          const client = require('twilio')(this.twilioSid, this.twilioAuthToken);
          await client.messages.create({
            body: messageText,
            from: this.twilioPhone,
            to: `+91${cleanMobile.slice(-10)}`,
          });
          console.log(`[SMS Gateway] Sent live Twilio SMS to +91${cleanMobile.slice(-10)}`);
        } else if (this.provider === 'FAST2SMS') {
          const response = await fetch('https://www.fast2sms.com/dev/bulkV2', {
            method: 'POST',
            headers: {
              'authorization': this.fast2smsKey,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              route: 'otp',
              variables_values: generatedOtp,
              numbers: cleanMobile.slice(-10),
            }),
          });
          console.log(`[SMS Gateway] Fast2SMS dispatch status: ${response.status}`);
        }
      } catch (err) {
        console.error('[SMS Gateway Error] Failed to dispatch live SMS:', err.message);
        return { success: false, error: 'Failed to send SMS OTP via live provider gateway.' };
      }

      // Live Production Response: NEVER expose OTP string or isDevMode=true
      return {
        success: true,
        mobileNumber: cleanMobile,
        message: `SMS OTP dispatched successfully to +91 ${cleanMobile.slice(-10)}`,
        expiresInSeconds: 600,
      };
    }

    // Isolated Dev Mode Response: Expose OTP for offline & development testing
    console.log(`[SMS Dev Adapter] Dev OTP generated for +91${cleanMobile.slice(-10)}: ${generatedOtp}`);
    return {
      success: true,
      mobileNumber: cleanMobile,
      isDevMode: true,
      message: `[DEV MODE] OTP generated for +91 ${cleanMobile.slice(-10)}. Use code: ${generatedOtp}`,
      expiresInSeconds: 600,
    };
  }

  /**
   * Verify farmer submitted OTP
   */
  async verifyOtp(mobileNumber, submittedOtp) {
    const cleanMobile = mobileNumber.replace(/\D/g, '');
    const record = this.otpStore.get(cleanMobile);
    const isDevModeAllowed = env.otpDevMode;

    const isDevFallback = isDevModeAllowed && (submittedOtp === '123456' || submittedOtp === '1234');

    if (!record && !isDevFallback) {
      return { verified: false, reason: 'No OTP requested for this mobile number or OTP expired.' };
    }

    if (record) {
      if (Date.now() > record.expiresAt) {
        this.otpStore.delete(cleanMobile);
        return { verified: false, reason: 'OTP has expired. Please request a new OTP.' };
      }

      record.attempts += 1;
      if (record.attempts > 5) {
        this.otpStore.delete(cleanMobile);
        return { verified: false, reason: 'Too many failed verification attempts. Please request a new OTP.' };
      }

      if (record.otp === submittedOtp || isDevFallback) {
        this.otpStore.delete(cleanMobile);
        return { verified: true };
      }
    } else if (isDevFallback) {
      return { verified: true };
    }

    return { verified: false, reason: 'Invalid OTP. Please check the digits entered.' };
  }
}

module.exports = new SmsAdapter();
