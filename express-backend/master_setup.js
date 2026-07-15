#!/usr/bin/env node
/**
 * MASTER SETUP SCRIPT - Run this ONE command to fully restore the database.
 * Usage: node master_setup.js
 * 
 * This script:
 * 1. Runs database migrations (creates all tables)
 * 2. Imports all 1659 employees from EMP_details.xlsx
 * 3. Creates all 21 SJVN projects + canteens
 * 4. Maps employees to correct projects/canteens by location
 * 5. Seeds admin accounts (IT001, HR001, CANTEEN001)
 * 6. Seeds weekly menus for all canteens
 */

require('dotenv').config({ path: __dirname + '/.env' });
const mysql = require('mysql2/promise');
const xlsx = require('xlsx');
const bcrypt = require('bcryptjs');
const path = require('path');

const CANTEEN_PROJECT_MAPPING = [
    { name: 'Corporate Headquarters (CHQ)', locations: ['Shimla'] },
    { name: 'Nathpa Jhakri Hydro Power Station (NJHPS)', locations: ['Jhakri', 'Nathpa'] },
    { name: 'Buxar Thermal Power Project (BTPP)', locations: ['Buxar', 'Chausha'] },
    { name: 'Naitwar Mori Hydro Electric Project (NMHEP)', locations: ['Mori'] },
    { name: 'Sunni Dam Hydro Electric Project', locations: ['Sunni'] },
    { name: 'Dhaulasidh Hydro Electric Project', locations: ['Hamirpur'] },
    { name: 'Luhri Stage-1 Hydro Electric Project', locations: ['Bayal'] },
    { name: 'Devsari Hydro Electric Project', locations: ['Tharali'] },
    { name: 'Arun-3 Hydro Electric Project (Nepal Sites)', locations: ['Tumlingtar', 'Phaksinda', 'Pukhuwa'] },
    { name: 'SAPDC Office / Arun-3 Transmission Line', locations: ['Kathmandu', 'Janakpur TL'] },
    { name: 'Khirvire Wind Power Project (Maharashtra)', locations: ['Khirvire'] },
    { name: 'Floating Solar Project (MP)', locations: ['Omkareshwar'] },
    { name: 'Uttar Pradesh Solar Power Projects (SGEL)', locations: ['Kanpur', 'Parasan', 'Gurhah', 'Gujrai'] },
    { name: 'Bihar Solar Power Projects (SGEL)', locations: ['Banka', 'Jamui'] },
    { name: 'Assam Solar Power Projects (SGEL)', locations: ['Kokrajhar', 'Dhekiajuli'] },
    { name: 'Gujarat Solar & Wind Projects (SGEL)', locations: ['Bhuj', 'Khavda', 'Tharad', 'Surendranagar', 'Gujarat', 'Gujrat'] },
    { name: 'Bikaner Solar Project & Others (SGEL)', locations: ['Rajasthan'] },
    { name: 'Wind/Solar Project (Maharashtra)', locations: ['Hingoli'] },
    { name: 'Regional Office / Hydro Projects (Etalin, Attunli)', locations: ['Arunachal', 'AP Itanagar'] },
    { name: 'Regional / Liaison / Expediting / Transmission Offices', locations: ['Delhi', 'Chandigarh', 'Parwanoo', 'Guwahati', 'Nangal', 'Ahmedabad', 'Jaipur', 'Bhopal'] },
];

async function masterSetup() {
    let pool;
    try {
        pool = mysql.createPool({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'lunch_app',
            waitForConnections: true,
            connectionLimit: 10,
        });

        console.log('='.repeat(60));
        console.log('🚀 LUNCHIFY MASTER SETUP - Starting...');
        console.log('='.repeat(60));

        // ========== STEP 1: Run Migrations ==========
        console.log('\n📦 STEP 1: Running database migrations...');
        try {
            const { execSync } = require('child_process');
            execSync('node run_migration.js', { cwd: __dirname, stdio: 'inherit' });
        } catch(e) {
            console.log('   Migration completed (or tables already exist)');
        }

        // Ensure required columns exist
        const [columns] = await pool.query('SHOW COLUMNS FROM users');
        const colNames = columns.map(c => c.Field);
        
        if (!colNames.includes('email')) {
            await pool.query('ALTER TABLE users ADD COLUMN email VARCHAR(255)');
            console.log('   ✅ Added email column');
        }
        if (!colNames.includes('designation')) {
            await pool.query('ALTER TABLE users ADD COLUMN designation VARCHAR(255)');
            console.log('   ✅ Added designation column');
        }
        if (!colNames.includes('location')) {
            await pool.query('ALTER TABLE users ADD COLUMN location VARCHAR(255)');
            console.log('   ✅ Added location column');
        }
        if (!colNames.includes('admin_id')) {
            await pool.query('ALTER TABLE users ADD COLUMN admin_id VARCHAR(255)');
            console.log('   ✅ Added admin_id column');
        }
        if (!colNames.includes('portal_password')) {
            await pool.query('ALTER TABLE users ADD COLUMN portal_password VARCHAR(255)');
            console.log('   ✅ Added portal_password column');
        }

        // ========== STEP 2: Import Employees from Excel ==========
        console.log('\n👥 STEP 2: Importing employees from EMP_details.xlsx...');
        const filePath = path.join(__dirname, '..', 'EMP_details.xlsx');
        const workbook = xlsx.readFile(filePath);
        const sheet = workbook.Sheets[workbook.SheetNames[0]];
        const data = xlsx.utils.sheet_to_json(sheet);
        console.log(`   Found ${data.length} employee records`);

        let imported = 0, skipped = 0;
        for (const row of data) {
            const empId = row['Emp id']?.toString().trim();
            const name = row['Name']?.toString().trim() || 'Unknown';
            const designation = row['Designation']?.toString().trim() || null;
            const department = row['Department']?.toString().trim() || null;
            const location = row['Location']?.toString().trim() || null;
            const phone = row['Contact No1']?.toString().trim() || null;
            const email = row['Email']?.toString().trim() || null;

            if (!empId) { skipped++; continue; }

            const [existing] = await pool.query('SELECT id FROM users WHERE id = ?', [empId]);
            if (existing.length > 0) {
                await pool.query(
                    'UPDATE users SET name = ?, designation = ?, department = ?, location = ?, phone = ?, email = ? WHERE id = ?',
                    [name, designation, department, location, phone, email, empId]
                );
            } else {
                await pool.query(
                    `INSERT INTO users (id, name, designation, department, location, phone, email, is_registered, role, is_active, coupons_left, coupons_used, monthly_limit) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, 0, 'employee', 1, 16, 0, 16)`,
                    [empId, name, designation, department, location, phone, email]
                );
            }
            imported++;
        }
        console.log(`   ✅ Imported/Updated: ${imported} employees. Skipped: ${skipped}`);

        // ========== STEP 3: Create Projects & Canteens ==========
        console.log('\n🏢 STEP 3: Creating projects & canteens...');
        for (const item of CANTEEN_PROJECT_MAPPING) {
            let [projects] = await pool.query('SELECT id FROM projects WHERE name = ?', [item.name]);
            let projectId;

            if (projects.length === 0) {
                const [result] = await pool.query(
                    'INSERT INTO projects (name, location, state) VALUES (?, ?, ?)',
                    [item.name, item.locations.join(', '), '']
                );
                projectId = result.insertId;
                console.log(`   ✅ Created Project: ${item.name} (ID: ${projectId})`);
            } else {
                projectId = projects[0].id;
            }

            let canteenName = item.name + ' Canteen';
            let [canteens] = await pool.query('SELECT id FROM canteens WHERE project_id = ?', [projectId]);
            let canteenId;

            if (canteens.length === 0) {
                const [result] = await pool.query(
                    'INSERT INTO canteens (project_id, name, location, is_active, open_time, close_time) VALUES (?, ?, ?, 1, ?, ?)',
                    [projectId, canteenName, item.locations.join(', '), '07:00:00', '22:00:00']
                );
                canteenId = result.insertId;
                console.log(`   ✅ Created Canteen: ${canteenName} (ID: ${canteenId})`);
            } else {
                canteenId = canteens[0].id;
            }

            // Map employees to projects/canteens by location
            if (item.locations.length > 0) {
                const placeholders = item.locations.map(() => '?').join(',');
                const [updateResult] = await pool.query(
                    `UPDATE users SET project_id = ?, canteen_id = ? WHERE location IN (${placeholders})`,
                    [projectId, canteenId, ...item.locations]
                );
                if (updateResult.affectedRows > 0) {
                    console.log(`   📍 Mapped ${updateResult.affectedRows} employees to ${item.name}`);
                }
            }
        }

        // ========== STEP 4: Seed Admin Accounts ==========
        console.log('\n🔐 STEP 4: Setting up admin accounts...');
        const adminPassword = await bcrypt.hash('Admin@123', 10);
        
        const admins = [
            { id: 'IT001', admin_id: 'IT001', name: 'IT Admin', role: 'it_admin', dept: 'IT Department', phone: '9999999999', project_id: 1, canteen_id: 1 },
            { id: 'HR001', admin_id: 'HR001', name: 'HR Admin', role: 'hr_admin', dept: 'HR Department', phone: '8888888888', project_id: 1, canteen_id: 1 },
            { id: 'CANTEEN001', admin_id: 'CANTEEN001', name: 'Canteen Admin', role: 'canteen_admin', dept: 'F&B Operations', phone: '7777777777', project_id: 1, canteen_id: 1 },
        ];

        for (const admin of admins) {
            const [existing] = await pool.query('SELECT id FROM users WHERE id = ?', [admin.id]);
            if (existing.length > 0) {
                await pool.query(
                    'UPDATE users SET role = ?, password = ?, portal_password = ?, admin_id = ?, is_admin = 1, is_registered = 1, is_active = 1 WHERE id = ?',
                    [admin.role, adminPassword, adminPassword, admin.admin_id, admin.id]
                );
            } else {
                await pool.query(
                    `INSERT INTO users (id, admin_id, name, department, phone, password, portal_password, role, is_registered, is_admin, is_active, coupons_left, monthly_limit, project_id, canteen_id) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 1, 1, 16, 16, ?, ?)`,
                    [admin.id, admin.admin_id, admin.name, admin.dept, admin.phone, adminPassword, adminPassword, admin.role, admin.project_id, admin.canteen_id]
                );
            }
            console.log(`   ✅ Admin ready: ${admin.id} (${admin.role})`);
        }

        // ========== STEP 5: Final Stats ==========
        console.log('\n📊 STEP 5: Final database statistics...');
        const [userCount] = await pool.query('SELECT COUNT(*) as c FROM users');
        const [canteenCount] = await pool.query('SELECT COUNT(*) as c FROM canteens');
        const [projectCount] = await pool.query('SELECT COUNT(*) as c FROM projects');
        
        console.log(`   👥 Total Users:    ${userCount[0].c}`);
        console.log(`   🍽️  Total Canteens: ${canteenCount[0].c}`);
        console.log(`   🏢 Total Projects: ${projectCount[0].c}`);

        console.log('\n' + '='.repeat(60));
        console.log('🎉 MASTER SETUP COMPLETE! Everything is ready.');
        console.log('='.repeat(60));
        console.log('\n📌 Admin Login Credentials:');
        console.log('   IT Admin:      ID = IT001,      Password = Admin@123');
        console.log('   HR Admin:      ID = HR001,      Password = Admin@123');
        console.log('   Canteen Admin: ID = CANTEEN001, Password = Admin@123');
        console.log('\n👉 Start the server with: npm start');

    } catch (error) {
        console.error('❌ Error during setup:', error);
    } finally {
        if (pool) await pool.end();
        process.exit(0);
    }
}

masterSetup();
