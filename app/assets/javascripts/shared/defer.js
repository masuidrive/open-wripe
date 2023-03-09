/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
window.Deferred = function(callback) {
  const defer = $.Deferred();
  if (callback) {
    //try {
      callback(defer);
    //} catch (error) {
    //  if (console && console.log) {
    //    console.log(error, error.message);
    //    defer.reject('fatal', error);
    //  }
    //  defer.promise();
    //}
  }
  return defer;
};
