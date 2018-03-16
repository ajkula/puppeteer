var Util, moment;

moment = require('moment');

class Util {
  resolveFunc(callback) {
    if (callback != null) {
      return callback;
    } else {
      return function() {};
    }
  }

  resolveBool(bool) {
    switch (typeof bool) {
      case 'string':
        return bool === 'true' || bool === 't' || bool === 'yes' || bool === 'y';
      case 'number':
        return bool === 1;
      case 'boolean':
        return bool;
      default:
        throw new Error('Can\'t resolve bool');
    }
  }

  resolveTime(time) {
    if (!time) {
      return moment();
    }
    if (typeof time === 'string') {
      return moment(time);
    } else if (moment.isMoment(time)) {
      return time;
    } else {
      throw new Error(`Can't resolve time: ${time}`);
    }
  }

  resolveId(objOrId) {
    switch (typeof objOrId) {
      case 'string':
      case 'number':
        return objOrId;
      case 'object':
        if (objOrId.id) {
          return objOrId.id;
        } else {
          throw new Error(`Can't resolve ID: ${objOrId}`);
        }
        break;
      default:
        console.error('id:', objOrId);
        throw new Error(`Can't resolve ID: ${objOrId}`);
    }
  }

  dispatchError(req, res, code, message) {
    res.writeHead(code, {
      'Content-Type': 'application/json'
    });
    return res.end(JSON.stringify({
      error: {
        code: code,
        error: message
      }
    }));
  }

  generateToken(adId, campaignId, api_key, odid) {
    // Token form <adId>-<campId>-<apikey>-<odid>
    return `${adId.replace(/\-/g, '')}-${campaignId}-` + `${api_key}-${odid.replace(/\-/g, '')}`;
  }

  isCity(code, state, city, level = 0) {
    if (code === 'es' && state === '29') {
      return true;
    }
    if (code === 'es' && state === '56' && city === 'barcelona') {
      return true;
    }
    if (code === 'it' && state === '09' && city === 'milan') {
      return true;
    }
    if (code === 'it' && state === '09' && city === 'milano') {
      return true;
    }
    if (code === 'it' && state === '07' && city === 'rom') {
      return true;
    }
    if (code === 'it' && state === '07' && city === 'roma') {
      return true;
    }
    if (code === 'it' && state === '07' && city === 'rome') {
      return true;
    }
    if (code === 'gb' && state === 'h9') {
      return true;
    }
    if (code === 'fr' && state === 'a8') {
      return true;
    }
    if (code === 'us') {
      return true;
    }
    if (level === 1) {
      if (code === 'it') {
        return true;
      }
    }
    return false;
  }

  isCity2(code) {
    if (code === 'us') {
      return true;
    }
    return false;
  }

  indexMinuteOfHour(minute) {
    if (minute < 30) {
      return 0;
    } else if (minute < 60) {
      return 1;
    }
  }

  indexHourOfPart(hour) {
    if (hour > 11) {
      return 0;
    } else {
      return hour * 2;
    }
  }

  indexPartOfDay(part) {
    if (part === 'am') {
      return 0;
    } else {
      return 1;
    }
  }

  indexDayOfWeek(day) {
    switch (day) {
      case "Mon":
        return 0;
      case "Tue":
        return 1;
      case "Wed":
        return 2;
      case "Thu":
        return 3;
      case "Fri":
        return 4;
      case "Sat":
        return 5;
    }
    return 6;
  }

};

module.exports = Util
