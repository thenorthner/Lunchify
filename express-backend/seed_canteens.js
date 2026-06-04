require('dotenv').config();
const db = require('./db');

const mapping = [
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

async function seedData() {
    try {
        console.log('Starting canteen and project seeding...');

        for (const item of mapping) {
            // Check if project exists
            let [projects] = await db.query('SELECT id FROM projects WHERE name = ?', [item.name]);
            let projectId;

            if (projects.length === 0) {
                // Insert project
                const [result] = await db.query(
                    'INSERT INTO projects (name, location, state) VALUES (?, ?, ?)',
                    [item.name, item.locations.join(', '), '']
                );
                projectId = result.insertId;
                console.log(`Inserted Project: ${item.name} (ID: ${projectId})`);
            } else {
                projectId = projects[0].id;
                console.log(`Project already exists: ${item.name} (ID: ${projectId})`);
            }

            // Check if canteen exists
            let canteenName = item.name + ' Canteen';
            let [canteens] = await db.query('SELECT id FROM canteens WHERE project_id = ?', [projectId]);
            let canteenId;

            if (canteens.length === 0) {
                // Insert canteen
                const [result] = await db.query(
                    'INSERT INTO canteens (project_id, name, location, is_active, open_time, close_time) VALUES (?, ?, ?, ?, ?, ?)',
                    [projectId, canteenName, item.locations.join(', '), 1, '09:00:00', '18:00:00']
                );
                canteenId = result.insertId;
                console.log(`Inserted Canteen: ${canteenName} (ID: ${canteenId})`);
            } else {
                canteenId = canteens[0].id;
                console.log(`Canteen already exists for project ID: ${projectId} (Canteen ID: ${canteenId})`);
            }

            // Update users based on locations
            if (item.locations.length > 0) {
                const placeholders = item.locations.map(() => '?').join(',');
                const [updateResult] = await db.query(
                    `UPDATE users SET project_id = ?, canteen_id = ? WHERE location IN (${placeholders})`,
                    [projectId, canteenId, ...item.locations]
                );
                console.log(`Updated ${updateResult.affectedRows} users for locations: ${item.locations.join(', ')}`);
            }
        }
        console.log('Seeding completed successfully!');
    } catch (error) {
        console.error('Error during seeding:', error);
    } finally {
        process.exit(0);
    }
}

seedData();
