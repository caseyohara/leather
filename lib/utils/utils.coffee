Utils = {}

class Utils.Utils
  constructor: ->

class Utils.Time extends Utils.Utils

  days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
  months = ["January","February","March","April","May","June","July","August","September","October","November","December"];

  constructor: (datetext)->
    super
    @now            = new Date
    @datetext       = datetext || @now
    @date           = new Date @datetext
    @hours          = @date.getHours()
    @year           = @date.getFullYear()
    @month          = @date.getMonth()
    @day            = @date.getDate()
    @minutes        = @date.getMinutes()
    @seconds        = @date.getSeconds()
    @milliseconds   = @date.getMilliseconds()
    @day_of_week    = days[@date.getDay()]
    @month_of_year  = months[@date.getMonth()]
    @epoch          = @date.getTime()  
    @ampm           = if @date.getHours() >= 12 then "pm" else "am"
    @time           = "#{@hours}:#{@minutes} #{@ampm}"
     


module.exports = Utils