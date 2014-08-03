require [], ->
  # Welcome to Rygr. This is the entry point for your application
  require ['welcome/main'], (welcome) ->
    welcome.render()
