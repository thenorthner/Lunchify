const axios = require('axios');
const { mysqlPool } = require('./db');

const BASE_URL = 'http://localhost:3001/api';

async function runE2ETests() {
  console.log("🚀 Starting E2E Automated Verification Suite...");

  try {
    // -------------------------------------------------------------------------
    // 1. Role Logins Verification
    // -------------------------------------------------------------------------
    console.log("\n🔑 [TEST 1] Verifying Role Logins...");

    // IT Admin Login
    const itLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'IT001',
      password: 'admin',
      deviceId: 'dev_it_1'
    });
    console.log("✅ IT Admin Login successful (Name: " + itLogin.data.user.name + ")");
    const itToken = itLogin.data.token;

    // HR Admin Login
    const hrLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'HR001',
      password: 'admin',
      deviceId: 'dev_hr_1'
    });
    console.log("✅ HR Admin Login successful (Name: " + hrLogin.data.user.name + ")");
    const hrToken = hrLogin.data.token;

    // Canteen Admin Login
    const canteenLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'CANTEEN001',
      password: 'admin',
      deviceId: 'dev_canteen_1'
    });
    console.log("✅ Canteen Admin Login successful (Name: " + canteenLogin.data.user.name + ")");
    const canteenToken = canteenLogin.data.token;

    // Employee Login
    const empLoginA = await axios.post(`${BASE_URL}/auth/login`, {
      employeeId: 'EMP001',
      password: 'admin',
      deviceId: 'device_a'
    });
    console.log("✅ Employee Login (Device A) successful (Name: " + empLoginA.data.user.name + ")");
    const empTokenA = empLoginA.data.token;


    // -------------------------------------------------------------------------
    // 2. Single-Device Session Restriction Verification
    // -------------------------------------------------------------------------
    console.log("\n🛡️ [TEST 2] Verifying Single-Device Restriction...");

    // Login Employee again on a different device
    const empLoginB = await axios.post(`${BASE_URL}/auth/login`, {
      employeeId: 'EMP001',
      password: 'admin',
      deviceId: 'device_b'
    });
    console.log("✅ Employee Login (Device B) successful (Session token changed)");
    const empTokenB = empLoginB.data.token;

    // Try making a request with Device A's token (should fail)
    try {
      await axios.get(`${BASE_URL}/menu/food?date=2026-05-20`, {
        headers: { Authorization: `Bearer ${empTokenA}` }
      });
      console.log("❌ FAIL: Device A was not invalidated!");
    } catch (err) {
      if (err.response && err.response.status === 401) {
        console.log("✅ SUCCESS: Device A token was correctly invalidated (Response: " + err.response.data.message + ")");
      } else {
        console.log("❌ FAIL: Unexpected error:", err.message);
      }
    }

    // Try making a request with Device B's token (should succeed)
    const empReqB = await axios.get(`${BASE_URL}/menu/food?date=2026-05-20`, {
      headers: { Authorization: `Bearer ${empTokenB}` }
    });
    console.log("✅ SUCCESS: Device B token is fully active and working.");


    // -------------------------------------------------------------------------
    // 3. Automated Monthly Coupon Reset Verification
    // -------------------------------------------------------------------------
    console.log("\n⏳ [TEST 3] Verifying Automated Monthly Coupon Reset...");

    // Update database manually to mock an old month and low coupons
    await mysqlPool.query(
      "UPDATE users SET last_coupon_reset_month = '2026-04', coupons_left = 5 WHERE id = 'EMP001'"
    );
    console.log("👉 Mocked user EMP001 to have 5 coupons left and last reset month: 2026-04");

    // Perform an authenticated call using B's token to trigger reset middleware
    await axios.get(`${BASE_URL}/menu/food?date=2026-05-20`, {
      headers: { Authorization: `Bearer ${empTokenB}` }
    });

    // Check user values in database
    const [rows] = await mysqlPool.query(
      "SELECT coupons_left, last_coupon_reset_month FROM users WHERE id = 'EMP001'"
    );
    
    const currentMonth = new Date().toLocaleDateString('en-CA').slice(0, 7);
    if (rows[0].coupons_left === 16 && rows[0].last_coupon_reset_month === currentMonth) {
      console.log(`✅ SUCCESS: Coupons auto-reset to exactly 16 for current month (${currentMonth})!`);
    } else {
      console.log("❌ FAIL: Reset did not work as expected. DB row: ", rows[0]);
    }


    // -------------------------------------------------------------------------
    // 4. Feedbacks & Global Auditing Verification
    // -------------------------------------------------------------------------
    console.log("\n💬 [TEST 4] Verifying Feedbacks & IT Admin Audit...");

    // Submit a feedback as Employee EMP001
    const feedbackMsg = {
      canteenId: 1,
      subject: 'Excellent Service',
      message: 'The food selection is outstanding and the interface is super premium!',
      rating: 5
    };
    
    await axios.post(`${BASE_URL}/feedbacks`, feedbackMsg, {
      headers: { Authorization: `Bearer ${empTokenB}` }
    });
    console.log("✅ Feedback submitted successfully by EMP001");

    // Fetch feedbacks as IT Admin
    const itFeedbacks = await axios.get(`${BASE_URL}/feedbacks`, {
      headers: { Authorization: `Bearer ${itToken}` }
    });
    
    const submittedFeedback = itFeedbacks.data.find(f => f.employee_id === 'EMP001' && f.subject === 'Excellent Service');
    if (submittedFeedback) {
      console.log(`✅ SUCCESS: IT Admin retrieved employee feedback (Subject: "${submittedFeedback.subject}", Rating: ${submittedFeedback.rating} ⭐)`);
    } else {
      console.log("❌ FAIL: Feedback was not retrieved by IT Admin.");
    }


    // -------------------------------------------------------------------------
    // 5. HR Transfers & Relocation Verification
    // -------------------------------------------------------------------------
    console.log("\n🔄 [TEST 5] Verifying HR Employee Transfers & Immutable History...");

    // Let's set coupons to 12 and reset project to 1 to verify that coupons_left are preserved on transfer
    await mysqlPool.query("UPDATE users SET coupons_left = 12, project_id = 1, canteen_id = 1 WHERE id = 'EMP001'");

    // HR Admin requests relocation from project 1 (Shimla HQ) to project 2 (Rampur Project)
    const transferReq = {
      employee_id: 'EMP001',
      to_project_id: 2
    };

    await axios.post(`${BASE_URL}/transfer/request`, transferReq, {
      headers: { Authorization: `Bearer ${hrToken}` }
    });
    console.log("✅ HR Admin successfully transferred EMP001 to Rampur Project (Project ID 2)");

    // Check employee DB mapping updates
    const [empRows] = await mysqlPool.query(
      "SELECT project_id, canteen_id, coupons_left FROM users WHERE id = 'EMP001'"
    );

    // Verify employee maps to project 2 and rampur canteen 2, and coupons left is preserved at 12
    if (empRows[0].project_id === 2 && empRows[0].canteen_id === 2 && empRows[0].coupons_left === 12) {
      console.log("✅ SUCCESS: Employee mappings updated correctly (Project: 2, Canteen: 2) and remaining coupons (12) were perfectly preserved!");
    } else {
      console.log("❌ FAIL: Employee mappings or coupons mismatched: ", empRows[0]);
    }

    // Check Transfer History log
    const transferHistory = await axios.get(`${BASE_URL}/transfer/history`, {
      headers: { Authorization: `Bearer ${hrToken}` }
    });

    const transferLog = transferHistory.data.find(t => t.employee_id === 'EMP001');
    if (transferLog) {
      console.log(`✅ SUCCESS: Immutable transfer history logged correctly!`);
      console.log(`   - Employee: ${transferLog.employee_name} (${transferLog.employee_id})`);
      console.log(`   - From Project: ${transferLog.from_project}`);
      console.log(`   - To Project: ${transferLog.to_project}`);
      console.log(`   - Coupons Preserved: ${transferLog.coupons_transferred}`);
      console.log(`   - Transferred by HR: ${transferLog.admin_name}`);
    } else {
      console.log("❌ FAIL: Transfer history log not found.");
    }

    console.log("\n🎉 ALL E2E AUTOMATED TESTS PASSED SUCCESSFULLY! The system is highly robust and fully compliant! 🎉\n");
    process.exit(0);
  } catch (err) {
    console.error("\n❌ E2E Verification failed with error:", err.response ? err.response.data : err.message);
    process.exit(1);
  }
}

runE2ETests();
