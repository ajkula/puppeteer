_ = require 'underscore'
config = require 'yaml-config'
settings = config.readConfig('./etc/config.yml', process.env.ENV)

# Docker-Compose environment vars are set to '' if we didnt fill them
# and if we dont fill them, we want the default value of config.yml to be taken
for k, v of settings
  delete process.env[k] unless process.env[k]?.length

_.extend settings, process.env

module.exports = settings