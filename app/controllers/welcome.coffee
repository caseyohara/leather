module.exports = class WelcomeController extends Controller.Base
  
  index : -> 
    @req.title = 'Welcome'
    do @render


