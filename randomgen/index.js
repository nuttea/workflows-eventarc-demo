const functions = require('@google-cloud/functions-framework');

functions.http('randomgen', (req, res) => {
  var rand = Math.floor(Math.random() * 100);
  res.send(JSON.parse('{"random":' + rand + '}'));
});
