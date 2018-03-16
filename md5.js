var data = "RedProdgreg";
var crypto = require('crypto');
console.log(crypto.createHash('md5').update(data).digest("hex"))