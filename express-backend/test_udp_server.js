const dgram = require('dgram');
const server = dgram.createSocket('udp4');
server.on('message', (msg, rinfo) => {
  console.log(`Server got: ${msg} from ${rinfo.address}:${rinfo.port}`);
  if (msg.toString() === 'DISCOVER') {
    server.send('HERE:3001', rinfo.port, rinfo.address);
  }
});
server.bind(4000, () => {
  console.log('UDP Server listening on 4000');
});
