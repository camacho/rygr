require [], ->
  # Welcome to Bedrock. This is the entry point for your application
  require ['welcome/main'], (welcome) ->
    welcome.render()
