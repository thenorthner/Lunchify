const axios = require('axios');
const { mysqlPool } = require('./db');
const bcrypt = require('bcryptjs');

const BASE_URL = 'http://localhost:3001/api';

async function runNewFeaturesVerification() {
  console.log("🚀 Starting E2E Verification Suite for Custom New Features...");

  try {
    // -------------------------------------------------------------------------
    // 1. Forgot Password & OTP Reset Verification
    // -------------------------------------------------------------------------
    console.log("\n🔑 [TEST 1] Verifying Forgot Password & OTP Reset flow...");
    
    // Ensure EMP001 has phone set to '9876543210' and is reset
    const defaultHash = await bcrypt.hash('admin', 10);
    await mysqlPool.query("UPDATE users SET phone = '9876543210', password = ?, is_registered = 1 WHERE id = 'EMP001'", [defaultHash]); 
    // note: above password hash corresponds to 'admin' using standard bcrypt

    // Request OTP for forgot password
    const forgotRes = await axios.post(`${BASE_URL}/auth/forgot-password`, {
      employeeId: 'EMP001',
      phone: '9876543210'
    });
    
    if (forgotRes.data.success) {
      console.log("✅ Forgot password request succeeded. OTP generated.");
    } else {
      throw new Error("Forgot password request failed.");
    }

    // Retrieve OTP from DB to bypass SMS simulator
    const [otpRows] = await mysqlPool.query(
      "SELECT otp_code FROM otp_verifications WHERE phone_number = '9876543210' ORDER BY created_at DESC LIMIT 1"
    );
    
    if (otpRows.length === 0) {
      throw new Error("OTP was not saved to database.");
    }
    
    const otp = otpRows[0].otp_code;
    console.log(`ℹ️ Retrieved OTP from database: ${otp}`);

    // Reset password using the OTP
    const resetRes = await axios.post(`${BASE_URL}/auth/reset-password`, {
      employeeId: 'EMP001',
      phone: '9876543210',
      otp: otp,
      newPassword: 'new_super_password'
    });

    if (resetRes.data.success) {
      console.log("✅ Password reset using OTP completed successfully.");
    } else {
      throw new Error("Password reset failed.");
    }

    // Try logging in with the new password
    const newLoginRes = await axios.post(`${BASE_URL}/auth/login`, {
      employeeId: 'EMP001',
      password: 'new_super_password',
      deviceId: 'temp_device'
    });

    console.log("✅ Login with new password successful! (Token generated)");
    
    // Reset password back to 'admin' to avoid breaking other tests
    await mysqlPool.query("UPDATE users SET password = ? WHERE id = 'EMP001'", [defaultHash]);
    console.log("👉 Restored user EMP001 password back to default 'admin'.");


    // -------------------------------------------------------------------------
    // 2. IT Admin Upsert User Verification
    // -------------------------------------------------------------------------
    console.log("\n🔑 [TEST 2] Verifying IT Admin Upsert User API...");

    // Login as IT Admin to get JWT token
    const itLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'IT001',
      password: 'admin',
      deviceId: 'it_device'
    });
    const itToken = itLogin.data.token;
    const axiosConfig = { headers: { Authorization: `Bearer ${itToken}` } };

    // Create a new user using upsert API
    const upsertPayload = {
      employeeId: 'IT_TEST_01',
      name: 'Upsert Test User',
      department: 'QA & Testing',
      phone: '9998887776',
      password: 'testpassword123',
      role: 'hr_admin',
      project_id: 1,
      canteen_id: 1
    };

    const upsertRes = await axios.post(`${BASE_URL}/auth/upsert-user`, upsertPayload, axiosConfig);
    console.log(`✅ Upsert User Succeeded: ${upsertRes.data.message}`);

    // Verify DB entry and attributes
    const [userRows] = await mysqlPool.query("SELECT role, is_admin, is_registered FROM users WHERE id = 'IT_TEST_01'");
    if (userRows.length > 0 && userRows[0].role === 'hr_admin' && userRows[0].is_admin === 1 && userRows[0].is_registered === 1) {
      console.log("✅ SUCCESS: IT Admin Upsert created the user with correct role and HR Admin permission fields.");
    } else {
      throw new Error("Upserted user database record validation failed.");
    }

    // Try logging in as the upserted user
    const testUserLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'IT_TEST_01',
      password: 'testpassword123',
      deviceId: 'test_dev_01'
    });
    console.log(`✅ Login as upserted user successful! (Name: ${testUserLogin.data.user.name}, Role: ${testUserLogin.data.user.role})`);

    // Clean up upserted test user
    await mysqlPool.query("DELETE FROM users WHERE id = 'IT_TEST_01'");
    console.log("👉 Cleaned up IT_TEST_01 user from database.");


    // -------------------------------------------------------------------------
    // 3. Fruit Lunch Acceptance-Based Coupon Deduction Verification
    // -------------------------------------------------------------------------
    console.log("\n🍎 [TEST 3] Verifying Fruit Lunch Acceptance-Based Coupon Deduction...");

    // Get a fresh login token for employee EMP001
    const empLogin = await axios.post(`${BASE_URL}/auth/login`, {
      employeeId: 'EMP001',
      password: 'admin',
      deviceId: 'emp_device_x'
    });
    const empToken = empLogin.data.token;
    const empAxiosConfig = { headers: { Authorization: `Bearer ${empToken}` } };

    // Login as Canteen Admin
    const canteenLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'CANTEEN001',
      password: 'admin',
      deviceId: 'canteen_device_x'
    });
    const canteenToken = canteenLogin.data.token;
    const canteenAxiosConfig = { headers: { Authorization: `Bearer ${canteenToken}` } };

    // Reset coupons of EMP001 to exactly 16
    await mysqlPool.query("UPDATE users SET coupons_left = 16, project_id = 1, canteen_id = 1 WHERE id = 'EMP001'");
    console.log("👉 Reset EMP001 coupons to 16 and canteen to 1.");

    // Create Today's Fruit Menu if not exists
    const todayStr = new Date().toLocaleDateString('en-CA'); // 'YYYY-MM-DD'
    await mysqlPool.query(
      "INSERT INTO fruit_menu (menu_date, fruits, canteen_id) VALUES (?, ?, 1) ON DUPLICATE KEY UPDATE fruits=?",
      [todayStr, JSON.stringify(['Apple', 'Orange', 'Banana']), JSON.stringify(['Apple', 'Orange', 'Banana'])]
    );

    // Place a Fruit Lunch order
    const orderPayload = {
      employeeId: 'EMP001',
      name: 'Demo Employee',
      quantity: 1,
      orderType: 'dineIn',
      roomNumber: null,
      deliveryTime: null,
      date: todayStr
    };

    const orderRes = await axios.post(`${BASE_URL}/fruit-lunch/order-fruit-lunch`, orderPayload, empAxiosConfig);
    const orderId = orderRes.data.orderId;
    console.log(`✅ Fruit Lunch order created successfully. Order ID: #${orderId}`);

    // Verify coupon balance immediately after ordering (should still be 16)
    const [c1] = await mysqlPool.query("SELECT coupons_left FROM users WHERE id = 'EMP001'");
    if (c1[0].coupons_left === 16) {
      console.log("✅ SUCCESS: Coupons NOT deducted immediately on pending Fruit Lunch creation.");
    } else {
      throw new Error(`FAIL: Coupon balance decremented immediately to ${c1[0].coupons_left}`);
    }

    // Canteen Admin accepts the order
    await axios.patch(`${BASE_URL}/fruit-lunch/${orderId}/status`, { status: 'accepted' }, canteenAxiosConfig);
    console.log(`✅ Canteen Admin accepted the order #${orderId}.`);

    // Verify coupon balance now (should be 15)
    const [c2] = await mysqlPool.query("SELECT coupons_left FROM users WHERE id = 'EMP001'");
    if (c2[0].coupons_left === 15) {
      console.log("✅ SUCCESS: Coupon correctly deducted upon order acceptance (Balance: 15).");
    } else {
      throw new Error(`FAIL: Coupon balance is ${c2[0].coupons_left} instead of 15 after acceptance.`);
    }

    // Canteen Admin cancels or rejects the accepted order
    await axios.patch(`${BASE_URL}/fruit-lunch/${orderId}/status`, { status: 'cancelled' }, canteenAxiosConfig);
    console.log(`✅ Accepted order #${orderId} was cancelled/rejected.`);

    // Verify coupon balance is refunded (should be 16 again)
    const [c3] = await mysqlPool.query("SELECT coupons_left FROM users WHERE id = 'EMP001'");
    if (c3[0].coupons_left === 16) {
      console.log("✅ SUCCESS: Coupon successfully refunded upon cancellation of an accepted order (Balance: 16).");
    } else {
      throw new Error(`FAIL: Coupon balance is ${c3[0].coupons_left} instead of 16 after refund.`);
    }

    // Clean up order
    await mysqlPool.query("DELETE FROM fruit_lunch_orders WHERE id = ?", [orderId]);
    console.log("👉 Cleaned up test order.");

    console.log("\n🎉 ALL CUSTOM NEW FEATURES E2E TESTS PASSED SUCCESSFULLY! 🎉\n");
    process.exit(0);
  } catch (err) {
    console.error("\n❌ Verification failed with error:", err.response ? err.response.data : err.message);
    process.exit(1);
  }
}

runNewFeaturesVerification();
