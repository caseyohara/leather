GLOBAL = global ? window 
GLOBAL.attach = (name)->
  GLOBAL[name] = GLOBAL[name] or {}