const fs = require('fs');
const path = require('path');

const logFilePath = path.join(__dirname, '../../audit.log');

function logAudit(event, actorId, details) {
  try {
    const logEntry = {
      timestamp: new Date().toISOString(),
      event,
      actor_id: actorId,
      details,
    };
    fs.appendFileSync(logFilePath, JSON.stringify(logEntry) + '\n');
  } catch (err) {
    console.error('Failed to write audit log:', err);
  }
}

module.exports = { logAudit };
