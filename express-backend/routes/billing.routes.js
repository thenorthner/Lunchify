const express = require("express");
const router = express.Router();
const { mysqlPool } = require("../db");
const { requireAuth, requireHRAdmin } = require("../middleware/auth.middleware");
const PDFDocument = require("pdfkit");
const fs = require("fs");
const path = require("path");
// Require authentication for all billing routes
router.use(requireAuth);

/**
 * 1. POST /api/billing/generate-canteen-bill
 * Generates a consolidated monthly bill for a given canteen.
 * Accessed by Canteen Admin from Flutter App.
 */
router.post("/generate-canteen-bill", async (req, res) => {
  const { bill_month, total_coupons_scanned, coupon_price, total_amount, place_generated } = req.body;
  const user = req.user;

  let targetCanteenId = user.canteen_id;
  let targetProjectId = user.project_id;
  
  if (user.role === 'it_admin' && req.body.canteen_id) {
    targetCanteenId = req.body.canteen_id;
    // Assuming IT Admin generates bill for the canteen's project. We should fetch the project_id.
    // For simplicity, we can pass it or fetch it. Let's fetch it below if needed, or rely on canteen's project_id.
  } else if (user.role !== 'canteen_admin') {
    return res.status(403).json({ error: "Only Canteen Admin or IT Admin can generate canteen bills" });
  }

  if (!bill_month || !coupon_price) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const conn = await mysqlPool.getConnection();
  try {
    await conn.beginTransaction();

    // Fetch project_id for this canteen
    const [canteenRows] = await conn.query("SELECT project_id FROM canteens WHERE id = ?", [targetCanteenId]);
    if (canteenRows.length > 0) {
      targetProjectId = canteenRows[0].project_id;
    }

    // Dynamically calculate the scans server-side to prevent fraud
    const [scanRows] = await conn.query(
      `SELECT COUNT(*) AS total_scans
       FROM qr_scan_logs
       WHERE canteen_id = ? AND created_at >= ? AND created_at < DATE_ADD(CONCAT(?, '-01'), INTERVAL 1 MONTH)`,
      [targetCanteenId, `${bill_month}-01`, bill_month]
    );

    const [foodRows] = await conn.query(
      `SELECT COALESCE(SUM(quantity), 0) AS total_food
       FROM food_lunch_orders
       WHERE canteen_id = ? AND status = 'delivered' AND created_at >= ? AND created_at < DATE_ADD(CONCAT(?, '-01'), INTERVAL 1 MONTH)`,
      [targetCanteenId, `${bill_month}-01`, bill_month]
    );

    const [fruitRows] = await conn.query(
      `SELECT COALESCE(SUM(quantity), 0) AS total_fruit
       FROM fruit_lunch_orders
       WHERE canteen_id = ? AND created_at >= ? AND created_at < DATE_ADD(CONCAT(?, '-01'), INTERVAL 1 MONTH)`,
      [targetCanteenId, `${bill_month}-01`, bill_month]
    );

    const totalCoupons = Number(scanRows[0].total_scans) + Number(foodRows[0].total_food) + Number(fruitRows[0].total_fruit);

    // Fetch official coupon rate from DB
    const [rateRows] = await conn.query(
      `SELECT unit_price FROM coupon_rates
       WHERE canteen_id = ? AND effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?)
       ORDER BY effective_from DESC LIMIT 1`,
      [targetCanteenId, `${bill_month}-01`, `${bill_month}-01`]
    );

    let price;
    if (rateRows.length === 0) {
      if (coupon_price) {
        price = Number(coupon_price);
      } else {
        await conn.rollback();
        return res.status(400).json({ error: "No approved coupon rate found for this billing period." });
      }
    } else {
      price = Number(rateRows[0].unit_price);
    }

    const calculatedTotalAmount = totalCoupons * price;

    // Delete existing bill if any to recreate (prevent duplicates for same month & canteen)
    await conn.query(
      "DELETE FROM monthly_bills WHERE canteen_id = ? AND bill_month = ?",
      [targetCanteenId, bill_month]
    );

    // Insert new monthly bill
    const [result] = await conn.query(
      `INSERT INTO monthly_bills 
       (employee_id, canteen_id, project_id, bill_month, total_coupons_used, coupon_price, total_amount, status, place_generated) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'submitted', ?)`,
      [null, targetCanteenId, targetProjectId, bill_month, totalCoupons, price, calculatedTotalAmount, place_generated || 'Canteen Portal']
    );

    await conn.commit();

    // Audit log
    console.log(JSON.stringify({
      event: "BILL_GENERATED",
      timestamp: new Date().toISOString(),
      actor_id: user.id,
      bill_id: result.insertId,
      canteen_id: user.canteen_id,
      bill_month,
      total_amount: calculatedTotalAmount
    }));

    res.json({
      success: true,
      message: "Canteen Monthly bill generated successfully.",
      bill: {
        id: result.insertId,
        canteen_id: user.canteen_id,
        project_id: user.project_id,
        bill_month,
        total_coupons_used: totalCoupons,
        coupon_price: price,
        total_amount: calculatedTotalAmount,
        status: 'submitted',
        place_generated: place_generated || 'Canteen Portal',
        generated_at: new Date()
      }
    });
  } catch (err) {
    if (conn) await conn.rollback();
    console.error("❌ Error generating canteen monthly bill:", err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    if (conn) conn.release();
  }
});

/**
 * 1.5 GET /api/billing/canteen-bills
 * Retrieve all bills generated by the logged-in canteen
 */
router.get("/canteen-bills", async (req, res) => {
  const user = req.user;
  
  let targetCanteenId = user.canteen_id;
  
  if (user.role === 'it_admin' && req.query.canteen_id) {
    targetCanteenId = req.query.canteen_id;
  } else if (user.role !== 'canteen_admin') {
    return res.status(403).json({ error: "Only Canteen Admin or IT Admin can access this route" });
  }

  try {
    const [rows] = await mysqlPool.query(
      `SELECT * FROM monthly_bills WHERE canteen_id = ? ORDER BY generated_at DESC`,
      [targetCanteenId]
    );
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching canteen bills:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * 2. GET /api/billing/project-bills
 * Retrieve all generated canteen bills for HR Admin's project or all if IT Admin
 */
router.get("/project-bills", requireHRAdmin, async (req, res) => {
  let projectId = req.user.project_id;
  
  if (req.user.role === 'it_admin' && req.query.project_id) {
    projectId = req.query.project_id;
  }

  try {
    let query = `
      SELECT b.*, c.name as canteen_name, p.name as project_name
      FROM monthly_bills b
      JOIN canteens c ON b.canteen_id = c.id
      JOIN projects p ON b.project_id = p.id
    `;
    const params = [];

    if (req.user.role === 'hr_admin' || (req.user.role === 'it_admin' && projectId)) {
      query += " WHERE b.project_id = ?";
      params.push(projectId);
    }

    query += " ORDER BY b.generated_at DESC";

    const [rows] = await mysqlPool.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching monthly bills:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * 3. PATCH /api/billing/:id/status
 * HR Admin approves or rejects the generated monthly bill
 */
router.patch("/:id/status", requireHRAdmin, async (req, res) => {
  const billId = req.params.id;
  const { status, comments } = req.body; // 'approved' or 'rejected' or 'review'

  if (!['approved', 'rejected', 'review'].includes(status)) {
    return res.status(400).json({ error: "Invalid status. Use approved, rejected, or review." });
  }

  try {
    // Verify the bill exists and belongs to the HR Admin's project
    const [billRows] = await mysqlPool.query(
      "SELECT project_id FROM monthly_bills WHERE id = ?",
      [billId]
    );

    if (billRows.length === 0) {
      return res.status(404).json({ error: "Bill not found" });
    }

    const bill = billRows[0];
    if (req.user.role === 'hr_admin' && bill.project_id !== req.user.project_id) {
      return res.status(403).json({ error: "Access denied. Bill belongs to another project." });
    }

    await mysqlPool.query(
      "UPDATE monthly_bills SET status = ?, comments = ? WHERE id = ?",
      [status, comments || null, billId]
    );

    res.json({ success: true, message: `Monthly bill status updated to ${status}` });
  } catch (err) {
    console.error("❌ Error updating bill status:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * 3.5 GET /api/billing/fruit-lunch-pdf
 * Canteen Admin downloads the PDF for fruit lunch orders of the current month
 */
router.get("/fruit-lunch-pdf", async (req, res) => {
  if (req.user.role !== 'canteen_admin') {
    return res.status(403).json({ error: "Only Canteen Admin can access this" });
  }

  try {
    const today = new Date();
    const monthStr = today.toLocaleDateString('en-CA').slice(0, 7); // YYYY-MM
    
    // Get all fruit lunch orders for this canteen in current month
    const [orders] = await mysqlPool.query(
      `SELECT o.*, u.name as employee_name, u.id as emp_id 
       FROM fruit_lunch_orders o
       JOIN users u ON o.employee_id = u.id
       WHERE o.canteen_id = ? 
       AND o.date LIKE ?
       ORDER BY o.date DESC, o.created_at DESC`,
      [req.user.canteen_id, `${monthStr}%`]
    );

    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    res.setHeader('Content-disposition', `attachment; filename=Fruit_Lunch_Orders_${monthStr}.pdf`);
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    // --- Header Background ---
    doc.rect(0, 0, 600, 150).fill('#f4f8fc');
    doc.moveTo(0, 150).lineTo(600, 150).strokeColor('#c0d6f2').lineWidth(2).stroke();
    
    const logoPath = path.resolve(__dirname, '../assets/logo.png');
    if (fs.existsSync(logoPath)) {
      doc.image(fs.readFileSync(logoPath), 470, 30, { width: 80 });
    }
    
    // SJVN Lunchify
    doc.font('Helvetica-Bold').fontSize(24).fillColor('#1a365d').text('SJVN Lunchify', 50, 40);
    doc.font('Helvetica').fontSize(10).fillColor('#4a5568').text('Healthy Meals, Happy Employees', 50, 70);

    // Large Title
    doc.font('Helvetica-Bold').fontSize(24).fillColor('#1e3a8a').text('Fruit Lunch Orders', 50, 180);
    doc.font('Helvetica-Bold').fontSize(14).fillColor('#64748b').text(`Month: ${monthStr}`, 50, 210);
    doc.rect(50, 235, 60, 4).fill('#2563eb');

    // --- Table Header ---
    const startY = 270;
    doc.font('Helvetica-Bold').fontSize(10).fillColor('#ffffff');
    doc.rect(50, startY, 500, 25).fill('#1e3a8a');
    doc.fillColor('#ffffff');
    doc.text('Date', 60, startY + 8);
    doc.text('Employee Name', 160, startY + 8);
    doc.text('Emp ID', 350, startY + 8);
    doc.text('Item', 430, startY + 8);
    doc.text('Qty', 510, startY + 8);

    // --- Table Rows ---
    let y = startY + 25;
    for (let i = 0; i < orders.length; i++) {
      if (y > 750) {
        doc.addPage();
        y = 50;
      }
      const o = orders[i];
      const dateObj = new Date(o.date);
      const formattedDate = `${dateObj.getFullYear()}-${String(dateObj.getMonth() + 1).padStart(2, '0')}-${String(dateObj.getDate()).padStart(2, '0')}`;
      
      // Alternate row background
      if (i % 2 === 0) {
        doc.rect(50, y, 500, 25).fill('#f8fafc');
      }

      doc.font('Helvetica').fontSize(9).fillColor('#333');
      doc.text(formattedDate, 60, y + 8);
      doc.text(o.employee_name, 160, y + 8);
      doc.text(o.emp_id, 350, y + 8);
      doc.text(o.name || '-', 430, y + 8);
      doc.text(o.quantity.toString(), 510, y + 8);
      
      doc.moveTo(50, y + 25).lineTo(550, y + 25).strokeColor('#e2e8f0').lineWidth(1).stroke();
      y += 25;
    }

    if (orders.length === 0) {
      doc.font('Helvetica-Oblique').text('No fruit lunch orders found for this month.', 50, y + 20);
    }

    doc.end();

  } catch (err) {
    console.error("❌ Error generating fruit lunch PDF:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * 4. GET /api/billing/:id/pdf
 * HR Admin downloads the PDF for an approved bill
 */
router.get("/:id/pdf", async (req, res) => {
  const billId = req.params.id;

  try {
    const [billRows] = await mysqlPool.query(
      `SELECT b.*, c.name as canteen_name, p.name as project_name 
       FROM monthly_bills b
       JOIN canteens c ON b.canteen_id = c.id
       JOIN projects p ON b.project_id = p.id
       WHERE b.id = ?`,
      [billId]
    );

    if (billRows.length === 0) {
      return res.status(404).json({ error: "Bill not found" });
    }

    const bill = billRows[0];

    // Access control
    if (req.user.role === 'hr_admin' && bill.project_id !== req.user.project_id) {
      return res.status(403).json({ error: "Access denied. Bill belongs to another project." });
    }
    if (req.user.role === 'canteen_admin' && bill.canteen_id !== req.user.canteen_id) {
      return res.status(403).json({ error: "Access denied. Bill belongs to another canteen." });
    }
    if (req.user.role === 'employee') {
      return res.status(403).json({ error: "Access denied." });
    }

    // Create a PDF document
    const doc = new PDFDocument({ margin: 0, size: 'A4' });
    res.setHeader('Content-disposition', `attachment; filename=Bill_${bill.bill_month}_${bill.canteen_name.replace(/\s+/g, '_')}.pdf`);
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    // Helper functions
    const drawLine = (x, y, length) => {
      doc.moveTo(x, y).lineTo(x + length, y).strokeColor('#e2e8f0').lineWidth(1).stroke();
    };

    // --- Header Background ---
    doc.rect(0, 0, 600, 150).fill('#f4f8fc');
    doc.moveTo(0, 150).lineTo(600, 150).strokeColor('#c0d6f2').lineWidth(2).stroke();

    // --- Header Texts ---
    const logoPath = path.resolve(__dirname, '../assets/logo.png');
    if (fs.existsSync(logoPath)) {
      doc.image(fs.readFileSync(logoPath), 470, 30, { width: 80 });
    }
    // SJVN Lunchify
    doc.font('Helvetica-Bold').fontSize(24).fillColor('#1a365d').text('SJVN Lunchify', 50, 40);
    doc.font('Helvetica').fontSize(10).fillColor('#4a5568').text('Healthy Meals, Happy Employees', 50, 70);

    // Large Title
    doc.font('Helvetica-Bold').fontSize(28).fillColor('#1e3a8a').text('Canteen Monthly Bill', 50, 180);
    doc.rect(50, 215, 60, 4).fill('#2563eb');
    doc.font('Helvetica').fontSize(11).fillColor('#64748b').text('Thank you for choosing SJVN Lunchify!', 50, 230);

    // --- Top Info Bar (Rounded Rect) ---
    doc.roundedRect(50, 270, 495, 80, 8).fillAndStroke('#ffffff', '#e2e8f0');
    
    const yTop = 295;
    
    // BILL ID
    doc.font('Helvetica').fontSize(9).fillColor('#64748b').text('BILL ID', 70, yTop);
    doc.font('Helvetica-Bold').fontSize(14).fillColor('#0f172a').text(`#${bill.id}`, 70, yTop + 15);
    
    // DATE GENERATED
    doc.font('Helvetica').fontSize(9).fillColor('#64748b').text('DATE GENERATED', 160, yTop);
    doc.font('Helvetica-Bold').fontSize(14).fillColor('#0f172a').text(new Date(bill.generated_at).toLocaleDateString(), 160, yTop + 15);
    
    // BILLING MONTH
    doc.font('Helvetica').fontSize(9).fillColor('#64748b').text('BILLING MONTH', 310, yTop);
    doc.font('Helvetica-Bold').fontSize(14).fillColor('#0f172a').text(bill.bill_month, 310, yTop + 15);
    
    // STATUS
    doc.font('Helvetica').fontSize(9).fillColor('#64748b').text('STATUS', 440, yTop);
    
    // Status Pill
    const statusText = bill.status.toUpperCase();
    const isApproved = statusText === 'APPROVED';
    const pillColor = isApproved ? '#dcfce7' : '#fef08a';
    const pillText = isApproved ? '#166534' : '#854d0e';
    
    doc.roundedRect(440, yTop + 12, 85, 20, 10).fill(pillColor);
    doc.font('Helvetica-Bold').fontSize(10).fillColor(pillText).text(statusText, 440, yTop + 18, { width: 85, align: 'center' });

    // --- Middle Section ---
    const yMid = 380;
    
    // Left Box (Details)
    doc.roundedRect(50, yMid, 250, 220, 8).fillAndStroke('#ffffff', '#e2e8f0');
    
    // Items in Left Box
    const leftX = 70;
    let currY = yMid + 25;
    
    const printLeftItem = (label, value) => {
      doc.font('Helvetica').fontSize(9).fillColor('#64748b').text(label, leftX, currY);
      doc.font('Helvetica-Bold').fontSize(11).fillColor('#0f172a').text(value, leftX, currY + 12);
      currY += 40;
      if (currY < yMid + 180) {
        drawLine(leftX, currY - 5, 210);
      }
    };
    
    printLeftItem('PROJECT', bill.project_name);
    printLeftItem('CANTEEN', bill.canteen_name);
    printLeftItem('TOTAL COUPONS SCANNED', bill.total_coupons_used.toString());
    printLeftItem('PRICE PER COUPON', `INR ${bill.coupon_price}`);

    // Right Box (Total Amount)
    doc.roundedRect(320, yMid, 225, 220, 8).fillAndStroke('#f8fafc', '#bfdbfe');
    
    doc.font('Helvetica-Bold').fontSize(14).fillColor('#1e40af').text('Final Bill Amount', 320, yMid + 50, { align: 'center', width: 225 });
    
    doc.moveTo(350, yMid + 80).lineTo(515, yMid + 80).dash(2, { space: 2 }).strokeColor('#93c5fd').stroke();
    doc.undash(); // Reset dash
    
    doc.font('Helvetica-Bold').fontSize(32).fillColor('#1d4ed8').text(`INR ${bill.total_amount}`, 320, yMid + 105, { align: 'center', width: 225 });

    doc.moveTo(350, yMid + 160).lineTo(515, yMid + 160).dash(2, { space: 2 }).strokeColor('#93c5fd').stroke();
    doc.undash();
    
    // HR Comments if present
    if (bill.comments) {
      doc.roundedRect(50, 620, 495, 60, 8).fillAndStroke('#fffbeb', '#fde68a');
      doc.font('Helvetica-Bold').fontSize(10).fillColor('#92400e').text('HR Comments:', 70, 635);
      doc.font('Helvetica').fontSize(10).fillColor('#92400e').text(bill.comments, 70, 650, { width: 450 });
    }

    // --- Page 2: Day-wise Breakdown ---
    doc.addPage();
    
    // Header for Page 2
    doc.rect(0, 0, 600, 100).fill('#f4f8fc');
    doc.moveTo(0, 100).lineTo(600, 100).strokeColor('#c0d6f2').lineWidth(2).stroke();
    
    if (fs.existsSync(logoPath)) {
      doc.image(fs.readFileSync(logoPath), 470, 25, { width: 60 });
    }
    
    doc.font('Helvetica-Bold').fontSize(20).fillColor('#1e3a8a').text('Day-wise Billing Breakdown', 50, 40);
    doc.font('Helvetica').fontSize(12).fillColor('#64748b').text(`Month: ${bill.bill_month} | Canteen: ${bill.canteen_name}`, 50, 65);

    // Fetch Day-wise Data
    const [dailyRows] = await mysqlPool.query(`
      SELECT DATE(created_at) as date, COUNT(id) as count, 'qr' as type
      FROM qr_scan_logs WHERE canteen_id = ? AND created_at LIKE ? GROUP BY DATE(created_at)
      UNION ALL
      SELECT DATE(date) as date, SUM(quantity) as count, 'food' as type
      FROM food_lunch_orders WHERE canteen_id = ? AND status = 'delivered' AND date LIKE ? GROUP BY DATE(date)
      UNION ALL
      SELECT DATE(date) as date, SUM(quantity) as count, 'fruit' as type
      FROM fruit_lunch_orders WHERE canteen_id = ? AND date LIKE ? GROUP BY DATE(date)
    `, [bill.canteen_id, `${bill.bill_month}%`, bill.canteen_id, `${bill.bill_month}%`, bill.canteen_id, `${bill.bill_month}%`]);

    const dailyData = {};
    dailyRows.forEach(r => {
      // Handle Date object correctly by formatting to YYYY-MM-DD
      const d = new Date(r.date);
      const dateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
      if (!dailyData[dateStr]) dailyData[dateStr] = { qr: 0, food: 0, fruit: 0, total: 0 };
      dailyData[dateStr][r.type] += Number(r.count || 0);
      dailyData[dateStr].total += Number(r.count || 0);
    });

    const sortedDates = Object.keys(dailyData).sort();

    // Table Header
    let yTable = 140;
    doc.rect(50, yTable, 500, 25).fill('#1e3a8a');
    doc.font('Helvetica-Bold').fontSize(10).fillColor('#ffffff');
    doc.text('Date', 60, yTable + 8);
    doc.text('QR Scans', 160, yTable + 8);
    doc.text('Food Orders', 260, yTable + 8);
    doc.text('Fruit Orders', 370, yTable + 8);
    doc.text('Daily Total', 480, yTable + 8);

    yTable += 25;

    // Table Rows
    doc.font('Helvetica').fontSize(10).fillColor('#333333');
    for (let i = 0; i < sortedDates.length; i++) {
      if (yTable > 700) {
        doc.addPage();
        yTable = 50;
      }
      
      const dateStr = sortedDates[i];
      const data = dailyData[dateStr];
      
      if (i % 2 === 0) {
        doc.rect(50, yTable, 500, 25).fill('#f8fafc');
        doc.fillColor('#333333');
      }

      doc.text(dateStr, 60, yTable + 8);
      doc.text(data.qr.toString(), 160, yTable + 8);
      doc.text(data.food.toString(), 260, yTable + 8);
      doc.text(data.fruit.toString(), 370, yTable + 8);
      doc.font('Helvetica-Bold').text(data.total.toString(), 480, yTable + 8);
      doc.font('Helvetica');

      doc.moveTo(50, yTable + 25).lineTo(550, yTable + 25).strokeColor('#e2e8f0').lineWidth(1).stroke();
      
      yTable += 25;
    }

    if (sortedDates.length === 0) {
      doc.font('Helvetica-Oblique').text('No daily breakdown data available.', 60, yTable + 20);
      yTable += 40;
    }

    // Grand Totals at bottom of table
    yTable += 10;
    doc.rect(50, yTable, 500, 30).fill('#eff6ff');
    doc.font('Helvetica-Bold').fontSize(11).fillColor('#1e3a8a');
    doc.text('GRAND TOTAL', 60, yTable + 10);
    
    const grandQr = sortedDates.reduce((sum, d) => sum + dailyData[d].qr, 0);
    const grandFood = sortedDates.reduce((sum, d) => sum + dailyData[d].food, 0);
    const grandFruit = sortedDates.reduce((sum, d) => sum + dailyData[d].fruit, 0);
    const grandTotal = sortedDates.reduce((sum, d) => sum + dailyData[d].total, 0);
    
    doc.text(grandQr.toString(), 160, yTable + 10);
    doc.text(grandFood.toString(), 260, yTable + 10);
    doc.text(grandFruit.toString(), 370, yTable + 10);
    doc.text(grandTotal.toString(), 480, yTable + 10);

    // --- Footer ---
    doc.roundedRect(50, 720, 495, 60, 8).fillAndStroke('#f8fafc', '#e2e8f0');
    doc.font('Helvetica-Bold').fontSize(10).fillColor('#0f172a').text('This is a system generated bill. No signature required.', 70, 735);
    doc.font('Helvetica').fontSize(9).fillColor('#64748b').text('For any queries, please contact the SJVN Lunchify support team.', 70, 755);

    doc.end();

  } catch (err) {
    console.error("❌ Error generating PDF:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
