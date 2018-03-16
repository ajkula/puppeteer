moment = require 'moment'

class Util

  resolveFunc: (callback) ->
    if callback?
      return callback
    else
      return ->

  resolveBool: (bool) ->
    switch typeof bool
      when 'string'
        bool in ['true', 't', 'yes', 'y']
      when 'number'
        bool == 1
      when 'boolean'
        bool
      else
        throw new Error('Can\'t resolve bool')

  resolveTime: (time) ->
    return moment() unless time
    if typeof time is 'string'
      return moment(time)
    else if moment.isMoment time
      return time
    else
      throw new Error("Can't resolve time: #{time}")

  resolveId: ( objOrId ) ->
    switch typeof objOrId
      when 'string', 'number' then objOrId
      when 'object'
        if objOrId.id
          objOrId.id
        else
          throw new Error("Can't resolve ID: #{objOrId}")
      else
        console.error 'id:', objOrId
        throw new Error("Can't resolve ID: #{objOrId}")

  dispatchError: (req, res, code, message) ->
    res.writeHead code, 'Content-Type': 'application/json'
    res.end JSON.stringify
      error:
        code: code
        error: message

  generateToken: (adId, campaignId, api_key, odid) ->
    # Token form <adId>-<campId>-<apikey>-<odid>
    "#{adId.replace(/\-/g,'')}-#{campaignId}-" +
      "#{api_key}-#{odid.replace(/\-/g,'')}"

  isCity: (code, state, city, level = 0) ->
    return true if code is 'es' and state is '29'
    return true if code is 'es' and state is '56' and city is 'barcelona'
    return true if code is 'it' and state is '09' and city is 'milan'
    return true if code is 'it' and state is '09' and city is 'milano'
    return true if code is 'it' and state is '07' and city is 'rom'
    return true if code is 'it' and state is '07' and city is 'roma'
    return true if code is 'it' and state is '07' and city is 'rome'
    return true if code is 'gb' and state is 'h9'
    return true if code is 'fr' and state is 'a8'
    return true if code is 'us'
    if level is 1
      return true if code is 'it'
    false

  isCity2: (code) ->
    return true if code is 'us'
    false

  indexMinuteOfHour: (minute) ->
    return if minute < 30 then 0
    else if minute < 60 then 1

  indexHourOfPart: (hour) ->
    return if hour > 11 then 0 else hour * 2

  indexPartOfDay: (part) ->
    return if part is 'am' then 0 else 1

  indexDayOfWeek: (day) ->
    switch day
      when "Mon" then return 0
      when "Tue" then return 1
      when "Wed" then return 2
      when "Thu" then return 3
      when "Fri" then return 4
      when "Sat" then return 5
    return 6

module.exports = new Util()
