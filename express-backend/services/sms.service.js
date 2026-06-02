const axios = require('axios');
require('dotenv').config();

/**
 * Sends an SMS text message to a mobile number.
 * Supports TextGuru API.
 * Falls back to console logging if no API keys are configured.
 * 
 * @param {string} phoneNumber - The recipient's phone number.
 * @param {string} message - The text message body.
 */
async function sendSMS(phoneNumber, message) {
  let formattedPhone = phoneNumber.trim().replace(/[^0-9]/g, '');
  
  // TextGuru requires '91' prefix for Indian numbers
  if (formattedPhone.length === 10) {
    formattedPhone = '91' + formattedPhone;
  } else if (formattedPhone.startsWith('0') && formattedPhone.length === 11) {
    formattedPhone = '91' + formattedPhone.substring(1);
  }

  // 1. TextGuru Integration
  if (process.env.TEXTGURU_USERNAME && process.env.TEXTGURU_PASSWORD) {
    try {
      console.log(`📡 Sending SMS via TextGuru to ${formattedPhone}...`);
      
      const params = {
        username: process.env.TEXTGURU_USERNAME,
        password: process.env.TEXTGURU_PASSWORD,
        source: process.env.TEXTGURU_SENDER_ID || 'SJVNIT',
        dmobile: formattedPhone,
        message: message
      };

      // DLT Template ID is usually mandatory
      if (process.env.TEXTGURU_DLT_TEMP_ID) {
        params.dlttempid = process.env.TEXTGURU_DLT_TEMP_ID;
      }

      const response = await axios.get('https://www.textguru.in/api/v22.0/', { params });

      console.log(`✅ TextGuru API Response for ${formattedPhone}:`, response.data);
      return true;
    } catch (err) {
      console.error(`❌ TextGuru gateway failed:`, err.message);
      // Fall through to console log if API fails
    }
  }

  // 2. Fallback: Log to console
  console.log(`\n======================================================`);
  console.log(`⚠️  SMS SERVICE LOG (API not configured or failed)`);
  console.log(`📱 TO: ${formattedPhone}`);
  console.log(`💬 MESSAGE: "${message}"`);
  console.log(`======================================================\n`);
  return false;
}

module.exports = { sendSMS };
