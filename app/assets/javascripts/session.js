/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require'splash'
class EnableAutoSaveDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#edit-page-enable-autosave');
  }
}
EnableAutoSaveDialog.initClass();


let session_data = undefined;

const get_session = function(callback) {
  const res = $.ajax({
    url: '/session.json',
    data: {version: $("#wripe-version").text()},
    dataType: 'json'
  });

  res.done(function(data) {
    localStorage.session = JSON.stringify(data);
    session_data = data;

    // nav
    $('#nav-username').text(data.user.username);
    if (navigator.onLine) {
      $('#nav-usericon').attr('src', data.user.icon_url);
    }

    // csrf
    $("meta[name='csrf-param']").attr('content', data.csrf_param);
    $("meta[name='csrf-token']").attr('content', data.csrf_token);
    $(`input[name='${data.csrf_param}']`).val(data.csrf_token);

    if (session_data.show_updates) {
      (new SplashDialog()).show();
    }

    if ((typeof(session_data.properties.autosave) === 'undefined') || (session_data.properties.autosave === null)) {
      const dialog = (new EnableAutoSaveDialog).show();
      dialog.done(action => {
        return session.autosave(true);
      });
      dialog.fail(action => {
        return session.autosave(false);
      });
    } else {
      session.autosave(session_data.properties.autosave, true);
    }
    return callback(data);
  });

  return res.fail(check_auth);
};


class Session {
  constructor() {
    _.extend(this, Backbone.Events);
  }

  autosave(autosave, advertise) {
    if (advertise == null) { advertise = false; }
    if (typeof(autosave) === 'undefined') {
      return session_data.properties.autosave;
    } else if (advertise) {
      session_data.properties.autosave = autosave;
      this.trigger('update_autosave', autosave);
      return autosave;
    } else {
      if (session_data.properties.autosave !== autosave) {
        session_data.properties.autosave = autosave;
        window.authorizedRequest({
          method: 'PUT',
          url: '/settings.json',
          data: { autosave }});
        this.trigger('update_autosave', autosave);
      }
      return autosave;
    }
  }

  username() {
    return session_data.user.username;
  }
}

window.session = new Session();

window.authorizedRequest = function(options, defer) {
  if (!defer) { defer = jQuery.Deferred(); }
  options.beforeSend = function(xhr) {
    if (session_data) {
      return xhr.setRequestHeader('X-CSRF-Token', session_data.csrf_token);
    }
  };

  const xhr = $.ajax(options);
  xhr.done(data => defer.resolve(data));

  xhr.fail(function(xhr, textStatus, errorThrows) {
    if (xhr.status === 412) { // CSRF and retry
      return get_session(() => {
        return authorizedRequest(this, defer);
      });

    } else if(xhr.status === 401) { // Unauthorized
      return sign_out();

    } else {
      return defer.reject(xhr, textStatus, errorThrows);
    }
  });

  const promise = defer.promise();
  promise.abort = () => xhr.abort();

  return promise;
};


const show_helps = function(helps, pages_count) {
  $('.alert-help').hide();

  helps.forEach(function(help) {
    $(`.help-${help.key}`).show();
    const close_btn_el = $(`.help-${help.key} a.close`);
    close_btn_el.attr('name', help.key);
    close_btn_el.click(e => authorizedRequest({url: `/helps/${$(e.target).attr('name')}.json`, method: 'DELETE'}));
  });

  if (typeof pages_count !== 'undefined') {
    if (pages_count === 0) {
      $(".help-welcome").show();
    } else {
      $(".help-welcome").hide();
    }
  }

  if (session_data && session_data.properties && session_data.properties['export-key']) {
    const path = `/calendar/exports/${session_data.properties['export-key']}.ics`;
    const url = `http://wri.pe${path}`;
    const ssl_url = `https://wri.pe${path}`;
    $("#calendar-sync-external-url-ssl").val(ssl_url);
    $("#calendar-sync-external-url").val(url);
    $("#calendar-sync-gcal").attr('href', `http://www.google.com/calendar/render?cid=${escape(`${url}?app=gcal`)}`);
  }
};


window.local_session = function(callback) {
  if (localStorage.session) {
    try {
      const sess = JSON.parse(localStorage.session);
      return callback(sess);
    } catch (e) {
      return callback(undefined);
    }
  } else {
    return get_session(data => callback(data));
  }
};


window.load_session = () => get_session(data => show_helps(data.helps, data.pages_count));


$(function() {
  if (localStorage.session) {
    try {
      const data = JSON.parse(localStorage.session);
      $('#nav-username').text(data.user.username);
      show_helps(data.helps, data.pages_count);
    } catch (e) {}
  }
      // no-op

  load_session();

  $(".help-show-all").click(() => authorizedRequest({url: "/helps/reset", method: 'POST'}).done(data => show_helps(data)));
});


window.sign_out = function() {
  localStorage.clear();
  sessionStorage.clear();
  return location.href = '/';
};


window.check_auth = function(xhr, textStatus, errorThrows) {
  if (xhr.status === 412) { // CSRF
    get_session(() => {
      return $.ajax(this);
    });
  }
  if (xhr.status === 401) { // Unauthorized
    return sign_out();
  }
};
