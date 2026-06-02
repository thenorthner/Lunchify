const axios = require('axios');
const { mysqlPool } = require('./db');

const BASE_URL = 'http://localhost:3001/api';

async function runSnacksDynamicVerification() {
  console.log("🚀 Starting E2E Verification Suite for Dynamic Snacks Menu & History...");

  try {
    // Ensure EMP001 and CANTEEN001 have canteen_id = 1
    await mysqlPool.query("UPDATE users SET canteen_id = 1 WHERE id IN ('EMP001', 'CANTEEN001')");
    console.log("👉 Set EMP001 and CANTEEN001 canteen_id to 1.");

    // -------------------------------------------------------------------------
    // 1. Authenticate Canteen Admin and Employee
    // -------------------------------------------------------------------------
    console.log("\n🔑 [TEST 1] Logging in as Canteen Admin and Employee...");

    // Canteen admin login
    const canteenLogin = await axios.post(`${BASE_URL}/auth/admin/login`, {
      employeeId: 'CANTEEN001',
      password: 'admin',
      deviceId: 'canteen_test_device'
    });
    const canteenToken = canteenLogin.data.token;
    const canteenAxiosConfig = { headers: { Authorization: `Bearer ${canteenToken}` } };
    console.log("✅ Canteen Admin login successful.");

    // Employee login
    const empLogin = await axios.post(`${BASE_URL}/auth/login`, {
      employeeId: 'EMP001',
      password: 'admin',
      deviceId: 'employee_test_device'
    });
    const empToken = empLogin.data.token;
    const empAxiosConfig = { headers: { Authorization: `Bearer ${empToken}` } };
    console.log("✅ Employee login successful.");

    // -------------------------------------------------------------------------
    // 2. Setup Morning and Evening Snacks Menu (Canteen Admin)
    // -------------------------------------------------------------------------
    console.log("\n🍩 [TEST 2] Setting up Morning and Evening snacks menu...");

    const todayStr = new Date().toLocaleDateString('en-CA'); // 'YYYY-MM-DD'

    // Setup morning snacks
    const morningPayload = {
      menu_date: todayStr,
      session: 'morning',
      items: ['Samosa', 'Tea (Chai)', 'Bread Pakoda']
    };
    const morningPostRes = await axios.post(`${BASE_URL}/menu/snacks`, morningPayload, canteenAxiosConfig);
    if (morningPostRes.data.success) {
      console.log("✅ Morning snacks menu setup succeeded.");
    } else {
      throw new Error("Morning snacks menu setup failed.");
    }

    // Setup evening snacks
    const eveningPayload = {
      menu_date: todayStr,
      session: 'evening',
      items: ['Kachori', 'Coffee', 'Biscuits']
    };
    const eveningPostRes = await axios.post(`${BASE_URL}/menu/snacks`, eveningPayload, canteenAxiosConfig);
    if (eveningPostRes.data.success) {
      console.log("✅ Evening snacks menu setup succeeded.");
    } else {
      throw new Error("Evening snacks menu setup failed.");
    }

    // -------------------------------------------------------------------------
    // 3. Fetch Snacks Menu (Employee)
    // -------------------------------------------------------------------------
    console.log("\n📥 [TEST 3] Fetching snacks menus as Employee...");

    // Fetch morning snacks
    const fetchMorningRes = await axios.get(`${BASE_URL}/menu/snacks?date=${todayStr}&session=morning`, empAxiosConfig);
    const morningItems = fetchMorningRes.data;
    console.log("Morning snacks returned:", morningItems.map(i => i.name));
    if (morningItems.length === 3 && morningItems[0].name === 'Samosa') {
      console.log("✅ Fetch morning snacks succeeded with detailed metadata.");
    } else {
      throw new Error("Fetching morning snacks returned incorrect items.");
    }

    // Fetch evening snacks
    const fetchEveningRes = await axios.get(`${BASE_URL}/menu/snacks?date=${todayStr}&session=evening`, empAxiosConfig);
    const eveningItems = fetchEveningRes.data;
    console.log("Evening snacks returned:", eveningItems.map(i => i.name));
    if (eveningItems.length === 3 && eveningItems[0].name === 'Kachori') {
      console.log("✅ Fetch evening snacks succeeded with detailed metadata.");
    } else {
      throw new Error("Fetching evening snacks returned incorrect items.");
    }

    // -------------------------------------------------------------------------
    // 4. Place Snack Order (Employee)
    // -------------------------------------------------------------------------
    console.log("\n📦 [TEST 4] Placing a snack order as Employee...");

    const orderPayload = {
      employeeId: 'EMP001',
      session: 'morning',
      items: [
        { snack: 'Samosa', quantity: 2, cost: 30 },
        { snack: 'Tea (Chai)', quantity: 1, cost: 10 }
      ],
      total: 40
    };

    const orderRes = await axios.post(`${BASE_URL}/snack-orders`, orderPayload, empAxiosConfig);
    const orderId = orderRes.data.orderId;
    console.log(`✅ Snack order placed successfully. Order ID: #${orderId}`);

    // Verify order exists in DB with status 'pending'
    const [orderRows] = await mysqlPool.query("SELECT status, total FROM snack_orders WHERE id = ?", [orderId]);
    if (orderRows.length > 0 && orderRows[0].status === 'pending' && orderRows[0].total === 40) {
      console.log("✅ Verified order is in database with 'pending' status.");
    } else {
      throw new Error("Snack order DB verification failed.");
    }

    // -------------------------------------------------------------------------
    // 5. Canteen Admin Accepts the Snack Order
    // -------------------------------------------------------------------------
    console.log("\n👨‍🍳 [TEST 5] Canteen Admin accepts the snack order...");

    const acceptRes = await axios.put(`${BASE_URL}/snack-orders/${orderId}`, { status: 'accepted' }, canteenAxiosConfig);
    if (acceptRes.data.success) {
      console.log("✅ Order accepted by Canteen Admin.");
    } else {
      throw new Error("Order acceptance failed.");
    }

    const [acceptRows] = await mysqlPool.query("SELECT status FROM snack_orders WHERE id = ?", [orderId]);
    if (acceptRows.length > 0 && acceptRows[0].status === 'accepted') {
      console.log("✅ Verified order status is updated to 'accepted'.");
    } else {
      throw new Error("Accepted order status verification failed.");
    }

    // -------------------------------------------------------------------------
    // 6. Employee Marks the Snack Order as Received ('delivered')
    // -------------------------------------------------------------------------
    console.log("\n🙋‍♂️ [TEST 6] Employee marks the order as received ('delivered')...");

    const deliverRes = await axios.put(`${BASE_URL}/snack-orders/${orderId}`, { status: 'delivered' }, empAxiosConfig);
    if (deliverRes.data.success) {
      console.log("✅ Order marked received by Employee.");
    } else {
      throw new Error("Marking received failed.");
    }

    // Verify it is NOT deleted, but status is updated to 'delivered'
    const [finalRows] = await mysqlPool.query("SELECT status FROM snack_orders WHERE id = ?", [orderId]);
    if (finalRows.length > 0 && finalRows[0].status === 'delivered') {
      console.log("✅ Verified order remains in database with 'delivered' status (Persistent History!).");
    } else {
      throw new Error("Persistent history verification failed. Order not found or incorrect status.");
    }

    // -------------------------------------------------------------------------
    // 7. Clean up
    // -------------------------------------------------------------------------
    console.log("\n🧹 [TEST 7] Cleaning up test data...");
    await mysqlPool.query("DELETE FROM snack_orders WHERE id = ?", [orderId]);
    console.log("✅ Cleanup successful.");

    console.log("\n🎉 ALL DYNAMIC SNACKS & HISTORY VERIFICATION TESTS PASSED SUCCESSFULLY! 🎉\n");
    process.exit(0);

  } catch (err) {
    console.error("\n❌ Verification failed with error:", err.response ? err.response.data : err.message);
    process.exit(1);
  }
}

runSnacksDynamicVerification();
