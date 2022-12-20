const fs = require('fs');

const PLUGIN_NAME = "cordova-plugin-androidx";
// const enableR8 = "android.enableR8=false";
const gradlePropertiesPath = "./platforms/android/gradle.properties";

function log(message) {
    console.log(PLUGIN_NAME + ": " + message);
}

function onError(error) {
    log("ERROR: " + error);
}

function run() {
    let gradleProperties = fs.readFileSync(gradlePropertiesPath);

    if (gradleProperties) {
        let updatedGradleProperties = false;
        gradleProperties = gradleProperties.toString();
        //if (!gradleProperties.match(enableR8)) {
        //    gradleProperties += "\n" + enableR8;
        //    updatedGradleProperties = true;
        //}
        if (updatedGradleProperties) {
            fs.writeFileSync(gradlePropertiesPath, gradleProperties, 'utf8');
            log("Updated gradle.properties to enable AndroidX");
        }
    } else {
        log("gradle.properties file not found!")
    }
}

module.exports = function () {
    return new Promise((resolve, reject) => {
        try {
            run();
            resolve();
        } catch (e) {
            onError("EXCEPTION: " + e.toString());
            reject(e);
        }
    });
};
