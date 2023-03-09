/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
/*
$(function() {
  const appCache = window.applicationCache;
  if (appCache) {
    const upgrade = function() {
      if (confirm('Could you upgrade to new version now?')) {
        if (appCache.status === app.UPDATEREADY) {
          appCache.swapCache();
          return location.reload();
        }
      }
    };

    $(appCache).bind("updateready", () => upgrade());

    if (appCache.status === app.UPDATEREADY) {
      upgrade();
    }

    return $(window).bind("online", () => appCache.update());
  }
});
*/
