GLOBAL.Controller =

  Base : class
    constructor : (@request, @response, @view, @content_type)->
      @data = {}

    render : ->
      if @content_type is 'json'
        @response.contentType 'application/json'
        @response.send JSON.stringify @data
      else
        @response.render @view, @data

    redirect : (destination)->
      @response.redirect destination
