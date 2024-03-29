GLOBAL = global ? window
GLOBAL.BASEDIR = __dirname + '/../'
GLOBAL.APPDIR  = BASEDIR + 'app/'
GLOBAL.LIBDIR  = BASEDIR + 'lib/'

express = require 'express'
config  = require BASEDIR + 'config/config'
routes  = require BASEDIR + 'config/routes'


# Load up base classes and extensions
require LIBDIR + 'core/extensions'
require LIBDIR + 'core/model'
require LIBDIR + 'core/controller'

Model.db = config.db


# Create and configure the application instance
app = module.exports = express.createServer()

app.configure ->
  app.set 'views', APPDIR + 'views'
  app.set 'view engine', config.view_engine
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static BASEDIR + 'public'

app.configure 'development', ->
  app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', ->
  app.use express.errorHandler() 


# Routes are defined in ./config/routes

# Example route definition:
# '/posts'            : ['posts', 'index']
# '/posts/new'        : ['posts', 'new']
# '/posts/create'     : ['posts', 'create', 'post']
# '/posts/:id'        : ['posts', 'show']

# Anatomy of a route:
# {route url}        : [{controller}, {action}, {http method}]


response_formats = config.response_formats or ['html','json']

# Loop over routes, applying each route to the application router
# load up the controller it is calling and invoke the route's action 
for route, [controller, action, method] of routes
  do (route, [controller, action, method])->

    # route '/' as an alternative to html
    if '/' not in response_formats
      response_formats.push '/' 
      
    # loop over each response format and create a route for it
    for response_format in response_formats
      do (response_format, route, controller, action, method)->
        
        # if the response format extension isn't '/' then apply the extension to the route
        route = route + '.' + response_format if response_format isnt '/'
        
        # determine view by controller#action convention
        view = controller + '/' + action
        
        # now apply the route to the application router
        app[method || 'all'] route, (req, res)->
          
          # load up the controller
          _controller = require APPDIR + 'controllers/' + controller

          # create an instance of the controller
          # pass it the request and response objects
          # as well as the view and response format of the route
          _controller =  new _controller req, res, view, response_format

          # call the route's action
          do _controller[action]
          do _controller.render unless _controller.auto_render is false



# Fire up the server
app.listen config.port
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
