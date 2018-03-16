

const _ = require('underscore');
const config = require('yaml-config');
const settings = config.readConfig('./etc/config.yml', process.env.ENV);

// Docker-Compose environment vars are set to '' if we didnt fill them
// and if we dont fill them, we want the default value of config.yml to be taken
  for (k in settings) {
    const v = settings[k];
    if (!((ref = process.env[k]) != null ? ref.length : void 0)) {
      delete process.env[k];
    }
  }

  _.extend(settings, process.env);

  module.exports = settings;
