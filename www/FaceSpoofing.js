var exec = require('cordova/exec');

exports.detect = function (arg0, success, error) {
    exec(success, error, 'FaceSpoofing', 'detect', [arg0]);
};
