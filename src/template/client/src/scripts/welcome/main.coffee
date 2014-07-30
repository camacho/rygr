define [
  'jquery'
  './template'
], ($, template) ->
  render: ->
    $('body').html template()
