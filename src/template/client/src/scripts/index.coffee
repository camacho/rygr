require [
  'jquery'
  'welcome'
], ($, template) ->
  # Welcome to Rygr. This is the entry point for your application
  
  $ -> $('body').html template()
