/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require html2canvas/dist/html2canvas
//= require shared/modal_dialog


class FeedbackDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#feedback-dialog');
  }
  constructor() {
    super();
  }

  action(action) {
    if (action === 'send') {
      const data = { 
        feedback: {
          subject: $("#feedback-subject").val(),
          body: $("#feedback-body").val()
        }
      };
      if ($("#feedback-attach").is(':checked')) {
        data.feedback.image_data = $("#feedback-image-data").val();
      }

      const defer = authorizedRequest({
        url: '/feedbacks.json',
        method: 'POST',
        dataType: 'json',
        data
      });
      defer.fail(() => {
        $.bootstrapGrowl("Failed to post feedback", {type: 'error'});
      });
      return defer.done(() => {
        $.bootstrapGrowl("Thank you for your feedback", {type: 'success'});
        $("#feedback-body").val('');
      });
    }
  }
}
FeedbackDialog.initClass();


const openFeedback = function() {
  try {
    return html2canvas([document.body], {
      onrendered(canvas) {
        const dialog = new FeedbackDialog();
        dialog.show();
        $("#feedback-image-data").val(canvas.toDataURL());
        const capture_el = $("#feedback-capture");
        capture_el.attr('src', canvas.toDataURL());
        capture_el.css('width', capture_el.height() *  (canvas.width/canvas.height) );
      }
    }
    );
  } catch (e) {
    $("#feedback-attach-capture").hide();
    const dialog = new FeedbackDialog();
    dialog.show();
  }
};


$(function() {
  $("#feedback-tab").click(() => openFeedback());
  $("#settings-feedback-button").click(() => openFeedback());
  $("#help-feedback-button").click(() => openFeedback());
});
