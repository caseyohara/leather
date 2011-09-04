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



# Loop over routes, applying each route to the application router
# load up the controller it is calling and invoke the route's action 

for route, [controller, action, method] of routes
  do (route, [controller, action, method])->
    view = controller + '/' + action
    app[method || 'all'] route, (req, res)->
      _controller = require APPDIR + 'controllers/' + controller
      _controller =  new _controller req, res, view
      do _controller[action]

app.listen config.port
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
