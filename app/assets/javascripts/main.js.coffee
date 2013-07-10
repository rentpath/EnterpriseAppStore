class FormHandler

  constructor: ->
    # Do nothing

  bindAppVersionFormSubmit: =>
    new_version_form = $('#new_app_version')
    new_version_button = $('#submitBtnVersion')
    loading_message = $('#loading')
    new_version_button.click (e) =>
      formhandler.stop_event(e)
      loading_message.fadeIn();
      setTimeout( =>
        new_version_form.submit()
      , 1000)

  stop_event: (e) =>
    e.preventDefault()
    e.stopPropagation()

@formhandler = new FormHandler()

@formhandler.bindAppVersionFormSubmit()
