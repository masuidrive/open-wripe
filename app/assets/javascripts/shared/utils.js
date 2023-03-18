/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require jquery
//= require underscore/underscore

const userAgent = window.navigator.userAgent.toLowerCase();
let _device_type = 'desktop';
if (userAgent.indexOf('ipad') > 0) {
  _device_type = 'tablet';
} else if ((userAgent.indexOf('iphone') > 0) || (userAgent.indexOf('ipod') > 0)) { 
  _device_type = 'phone'; 
} else if (userAgent.indexOf('android') > 0) {
  _device_type = 'android'; 
}

const win = $(window);
const device_type = function() {
  if ((_device_type === 'android') || (_device_type === 'tablet')) {
    if (win.width() > win.height()) {
      return 'tablet';
    } else {
      return 'phone';
    }
  } else {
    return _device_type;
  }
};

const _is_iphone = (userAgent.indexOf('applewebkit') > 0) && (userAgent.indexOf('iphone') > 0);
const is_iphone = () => _is_iphone;

const _is_ios = (userAgent.indexOf('applewebkit') > 0) && (userAgent.indexOf('mobile') > 0);
const is_ios = () => _is_ios;

const escape_html = _.escape;

const delay = (wait, callback) => setTimeout(callback, wait);

const is_app = () => !!window.navigator.standalone;
  // true # debug

const window_height = function() {
  if (is_iphone() && !is_app()) {
    return window.innerHeight;
  } else {
    return (document.documentElement.clientHeight || $(window).height());
  }
};

const today_string = function() {
  const today = new Date();
  return `${today.getFullYear()}/${today.getMonth()+1}/${today.getDate()}`;
};

const resize_el = function(el, height, recur) {
  el.height(height);
  if (!recur && ((el[0].clientHeight || el.height()) !== height)) {
    delay(100, () => resize_el(el, height, true));
  }
};

$.fn.isVisible = function() {
  return $.expr.filters.visible(this[0]);
};

$.fn.isTextSelected = function() {
  return this[0] && (this[0].selectionStart !== this[0].selectionEnd);
};

$.fn.insertToSelection = function(ins){
  if (this[0] && (this[0].selectionStart !== this[0].selectionEnd)) {
    const val = this.val();
    const sstart = this[0].selectionStart;
    const send = this[0].selectionEnd;
    const line_head = (sstart === 0) || (val.substr(sstart-1, 1) === "\n");
    const selected = val.substring(sstart, send-1).replace(/\n/g, `\n${ins}`); 
    const str = val.substr(0, sstart) + (line_head ? ins : '') + selected + val.substr(send-1);
    this.val(str);
    this[0].selectionStart = sstart;
    this[0].selectionEnd = sstart + (line_head ? 1 : 0) + selected.length + 1;
  }
};

$.fn.removeToSelection = function(ins){
  if (this[0] && (this[0].selectionStart !== this[0].selectionEnd)) {
    const val = this.val();
    const sstart = this[0].selectionStart;
    const send = this[0].selectionEnd;
    const line_head = (val.substr(sstart-1, 1) === "\n") && (val.substr(sstart, ins.length) === ins);
    let selected = val.substring(sstart, send-1).replace(new RegExp(`\n${ins}`, "g"), "\n");
    if (line_head) { selected = selected.substr(ins.length); }
    const str = val.substr(0, sstart) + selected + val.substr(send-1);
    this.val(str);
    this[0].selectionStart = sstart;
    this[0].selectionEnd = sstart + selected.length + 1;
  }
};

window.delay = delay;
window.device_type = device_type;
window.is_iphone = is_iphone;
window.is_ios = is_ios;
window.escape_html = escape_html;
window.today_string = today_string;
window.window_height = window_height;
window.resize_el = resize_el;
window.is_app = is_app;
