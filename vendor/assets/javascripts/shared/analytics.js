/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class Analytics {
  static initClass() {
    this.prototype.collect_url = "https://ssl.google-analytics.com/collect";
  }

  constructor(tracking_id) {
    this.tracking_id = tracking_id;
    if (this.tracking_id) {
      const storage = window.localStorage || {};
      if (!storage.analytics_cid) { storage.analytics_cid = parseInt((new Date()).getTime()*Math.random()); }
      this.cid = parseInt(storage.analytics_cid);
    }
  }

  pageview(path) {
    if (!this.tracking_id) { return; }
    if (!navigator.onLine) { return; }
    const data = {
      v: 1, // Version
      t: 'pageview', // Hit type
      tid: this.tracking_id,
      cid: this.cid, // anonymous customer ID
      dp: path
    };

    $.ajax({
      url: this.collect_url,
      method: 'POST',
      data
    });
  }

  event(options) {
    if (!this.tracking_id) { return; }
    if (!navigator.onLine) { return; }
    const data = {
      v: 1, // Version
      t: 'event', // Hit type
      tid: this.tracking_id,
      cid: this.cid // anonymous customer ID
    };
    for (var value in options) {
      var key = options[value];
      data[key] = value;
    }

    $.ajax({
      url: this.collect_url,
      method: 'POST',
      data
    });
  }
}
Analytics.initClass();

/*
https://ssl.google-analytics.com/collect
  ?v=1
  &t=event // Hit type
  &tid=UA-7634164-5 // my profil ID
  &cid=555 // anonymous customer ID
  &dh=myofflinestore.com // my "hostname" =)
  &ec=Motion%20Detector // Event category
  &ea=In // Customer direction: going in or out?
  &ev=1 // Event value
  &cm5=1 // Custom metric (+1 increment)

v=1             // Version.
&tid=UA-XXXX-Y  // Tracking ID / Web property / Property ID.
&cid=555        // Anonymous Client ID.

&t=event        // Event hit type
&ec=video       // Event Category. Required.
&ea=play        // Event Action. Required.
&el=holiday     // Event label.
&ev=300         // Event value.

https://ssl.google-analytics.com/collect?v=1&t=event&tid=UA-40504922-4&cid=555&dh=wri.pe&ec=test
*/

if (location.host === 'wri.pe') {
  window.analytics = new Analytics("UA-40504922-4");
} else {
  window.analytics = new Analytics();
}
