const https = require('https');
const AdmZip = require('adm-zip');

https.get('https://webgate.ec.europa.eu/eudamed-help/en/files/XSD%20schemas.zip', res => {
    const data = [];
    res.on('data', chunk => data.push(chunk));
    res.on('end', () => {
        const zip = new AdmZip(Buffer.concat(data));
        const xml = zip.getEntry('service/Message/MessageType.xsd').getData().toString('utf8');
        console.log("XSD Service Version:", xml.match(/fixed="([^"]+)"/)[1]);
    });
});