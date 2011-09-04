BASEDIR = __dirname + '/../'
APPDIR  = BASEDIR + 'app/'
LIBDIR  = BASEDIR + 'lib/'

fs      = require 'fs'
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
# '/posts/create'     : ['posts', 'create', [], 'post']
# '/posts/:id'        : ['posts', 'show']

# Anatomy of a route:
# {route url}        : [{controller}, {action}, {content types}, {http method}]

# content types is an array of file extensions to respond to. ex: ['html','json','xml']
# if omitted or left empty, will default to html



# Loop over routes, applying each route to the application router
# load up the controller it is calling and invoke the route's action 
for route, [controller, action, content_types, method] of routes
  do (route, [controller, action, content_types, method])->
    
    # supply the route with html by default
    if not content_types? or not content_types.length
      content_types = ['html']

    # route '/' as an alternative to html
    if 'html' in content_types and '/' not in content_types
      content_types.push '/' 
      
    # loop over each content type and create a route for it
    for content_type in content_types
      do (route, controller, action, content_type, method)->
        
        # if the content type extension isn't '/' then apply the extension to the route
        route = route + '.' + content_type if content_type isnt '/'
        
        # determine view by controller#action convention
        view = controller + '/' + action
        
        # now apply the route to the application router
        app[method || 'all'] route, (req, res)->
          
          # load up the controller
          _controller = require APPDIR + 'controllers/' + controller

          # create an instance of the controller
          # pass it the request and response objects
          # as well as the view and content type of the route
          _controller =  new _controller req, res, view, content_type

          # call the route's action
          do _controller[action]



# Fire up the server
app.listen config.port
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
