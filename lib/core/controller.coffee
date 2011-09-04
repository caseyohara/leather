GLOBAL.Controller =

  Base : class
    constructor : (@req, @res, @view)->

    render : ->
      @res.render @view, @req    

    redirect : (destination)->
      @res.redirect destination

