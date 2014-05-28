/**
 * Environment Variables affecting this config.
 * --------------------------------------------
 *
 * DARTIUM: The full path to the Dartium binary.
 *
 * NGDART_EXAMPLE_BASEURL: Overrides the default baseUrl to one of your
 *     choosing.  (The default is http://localhost:8080 which is the
 *     correct if you simply run "pub serve" inside the example folder
 *     of the AngularDart repo.)
 */

var configQuery = require('./configQuery.js');

exports.config = {
  seleniumAddress: 'http://127.0.0.1:4444/wd/hub',

  specs: [
    'animation_spec.dart',
    'hello_world_spec.dart',
    'todo_spec.dart'
  ],

  splitTestsBetweenCapabilities: true,

  multiCapabilities: [{
    'browserName': 'chrome',
    'chromeOptions': configQuery.getChromeOptions(),
    count: 4
  }],

  baseUrl: configQuery.getBaseUrl(),

  jasmineNodeOpts: {
    isVerbose: true, // display spec names.
    showColors: true, // print colors to the terminal.
    includeStackTrace: true, // include stack traces in failures.
    defaultTimeoutInterval: 40000 // wait time in ms before failing a test.
  },
};
