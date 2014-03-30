#= require shared/html2canvas
#= require shared/modal_dialog


class FeedbackDialog extends ModalDialog
  el: $('#feedback-dialog')
  constructor: ->
    super()

  action: (action) ->
    if action == 'send'
      data = 
        feedback:
          subject: $("#feedback-subject").val()
          body: $("#feedback-body").val()
      if $("#feedback-attach").is(':checked')
        data.feedback.image_data = $("#feedback-image-data").val()

      defer = authorizedRequest
        url: '/feedbacks.json'
        method: 'POST'
        dataType: 'json'
        data: data
      defer.fail =>
        $.bootstrapGrowl("Failed to post feedback", {type: 'error'});
      defer.done =>
        $.bootstrapGrowl("Thank you for your feedback", {type: 'success'});
        $("#feedback-body").val('')


openFeedback = ->
  try
    html2canvas [document.body],
      onrendered: (canvas) ->
        dialog = new FeedbackDialog()
        dialog.show()
        $("#feedback-image-data").val(canvas.toDataURL())
        $("#feedback-capture").attr('src', canvas.toDataURL())
        $("#feedback-capture").css('width', $("#feedback-capture").height() *  (canvas.width/canvas.height) )
  catch e
    $("#feedback-attach-capture").hide()
    dialog = new FeedbackDialog()
    dialog.show()


$ () ->
  $("#feedback-tab").click ->
    openFeedback()
  $("#settings-feedback-button").click ->
    openFeedback()
  $("#help-feedback-button").click ->
    openFeedback()
