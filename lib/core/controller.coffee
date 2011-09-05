GLOBAL.Controller =

  Base : class
    constructor : (@request, @response, @view, @response_format)->
      @data = {}

    render : ->
      if @response_format is 'json'
        @response.contentType 'application/json'
        @response.send JSON.stringify @data
      else
        @response.render @view, @data

    redirect : (destination)->
      @response.redirect destination
