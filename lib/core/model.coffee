{Db, Connection, Server, BSON, ObjectID} = require 'mongodb' 
{en} = require 'lingo'

GLOBAL.Model =
  db : 
    host : null
    port : null
    name : null
    
  Base : class
    constructor : ->
      @_name = en.pluralize this.constructor.name.toLowerCase()
      @db = new Db Model.db.name, new Server(Model.db.host, Model.db.port, {auto_reconnect: true}, {})
      @db.open(()->)

    collect : (callback)->
      @db.collection @_name, (error, collection)->
        if error
          callback error
        else 
          callback null, collection
      
    get : (callback)->
      @collect (error, collection)->
        if error
          callback error
        else
          collection.find().toArray (error, results)->
            if error
              callback error
            else 
              callback null, results

    find : (id, callback)->
      @collect (error, collection)->
        if error
          callback error
        else
          collection.findOne _id: collection.db.bson_serializer.ObjectID.createFromHexString id, (error, result)->
            if error
              callback error
            else
              callback null, result

    save : (objects, callback) ->      
      @collect (error, collection)=>
        if error
          callback error
        else
          objects = [objects] if typeof objects.length is "undefined"
          objects = @before_save(objects) if @before_save
          collection.insert objects, ->
            callback null, objects