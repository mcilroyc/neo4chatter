var crypto = require('crypto');
var _ = require("underscore");

exports.parse = function(signed_request, secret) {
    signed_request = signed_request.split('.');
    var encoded_sig = signed_request[0];
    var payload = signed_request[1];

    var data = JSON.parse(new Buffer(payload, 'base64').toString());

    if (data.algorithm.toUpperCase() !== 'HMACSHA256')
        return null;

    var hmac = crypto.createHmac('sha256', secret);
    var encoded_payload = hmac.update(payload).digest('base64')

    if (encoded_sig !== encoded_payload)
        return null;

    return data;
};