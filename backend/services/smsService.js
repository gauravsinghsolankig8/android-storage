const twilio = require('twilio');

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Store OTPs temporarily (in production, use Redis)
const otpStore = new Map();

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const sendOTP = async (phone) => {
  try {
    const otp = generateOTP();
    
    // Store OTP with expiration (5 minutes)
    otpStore.set(phone, {
      otp,
      expiresAt: Date.now() + 5 * 60 * 1000
    });

    // Send SMS
    await client.messages.create({
      body: `Your Saranam verification code is: ${otp}. This code will expire in 5 minutes.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: phone
    });

    return otp;
  } catch (error) {
    console.error('SMS sending error:', error);
    throw new Error('Failed to send SMS');
  }
};

const verifyOTP = async (phone, otp) => {
  try {
    const storedData = otpStore.get(phone);
    
    if (!storedData) {
      return false;
    }

    // Check if OTP has expired
    if (Date.now() > storedData.expiresAt) {
      otpStore.delete(phone);
      return false;
    }

    // Verify OTP
    if (storedData.otp === otp) {
      otpStore.delete(phone);
      return true;
    }

    return false;
  } catch (error) {
    console.error('OTP verification error:', error);
    return false;
  }
};

module.exports = {
  sendOTP,
  verifyOTP
};