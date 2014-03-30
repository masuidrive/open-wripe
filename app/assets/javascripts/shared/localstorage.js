if(typeof window.localStorage == 'undefined') {
  window.localStorage = {
    clear: function() {},
    getItem: function(key) {},
    setItem: function(key, val) {},
    removeItem: function(key) {},
    key: function(key) {}
  };
}

if(typeof window.sessionStorage == 'undefined') {
  window.sessionStorage = {
    clear: function() {},
    getItem: function(key) {},
    setItem: function(key, val) {},
    removeItem: function(key) {},
    key: function(key) {}
  };
}
