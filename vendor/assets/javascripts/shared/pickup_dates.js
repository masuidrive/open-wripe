var pickup_dates = (function() {
  var date_matcher = (function() {
    // 2012-12-31 - 12/31/2012
    var year_match = "20[0-9]{2}";
    var month_match = "[0-1]{0,1}[0-9]";
    var day_match = "[0-3]{0,1}[0-9]";
    var sep1 = "[.-/]";
    var pattern11 = [year_match, month_match, day_match].join(sep1);
    var pattern12 = [month_match, day_match, year_match].join(sep1);
    var pattern13 = [day_match, month_match, year_match].join(sep1);

    // February 20th 2013 / 1st June 2000
    var text_month_match = "(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)";
    var text_day_match = "[0-3]{0,1}[0-9]{1}(st|nd|rd|th|)";
    var sep2 = "[, ]{1,3}";
    var pattern21 = [text_month_match, text_day_match, year_match].join(sep2);
    var pattern22 = [text_day_match, text_month_match, year_match].join(sep2);

    return "[^-.\/0-9](" + [pattern11, pattern12, pattern13, pattern21, pattern22].join('|') + ")[^-.\/0-9]";
  })();
  var timezone = (new Date).getTimezoneOffset() * 60000;

  return function(text) {
    text = ' ' + text + ' ';
    var dates = [];
    var match = true;
    while(match) {
      match = new RegExp(date_matcher, 'ig').exec(text)
      if(match) {
        var date = Date.parse(match[1].replace(/-/g,'/').replace(/(st|rd|th)/g,''));
        if(date) {
          dates.push((date - timezone) / 1000);
        }
        text = ' ' + text.substring(match.index + match[0].length);
      }
    }
    return dates
  };
})();
