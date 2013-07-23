class Factoids
  constructor: (@robot) ->
    @robot.brain.on 'loaded', =>
      @cache = @robot.brain.data.factoids
      @cache = {} unless @cache

  add: (key, val) ->
    @cache[key] = val
    @robot.brain.data.factoids = @cache
    "Okay."

  get: (key) ->
    if @cache[key]
      @cache[key]

  delete: (key) ->
    if @cache[key]
      delete @cache[key]
      "Okay, I've forgotten about " + key + "."


module.exports = (robot) ->
  factoids = new Factoids robot

  robot.respond /forget (about )?(.*)/i, (msg) ->
    result = factoids.delete msg.match[2]
    if result
      msg.reply result

  robot.respond /(.*?) (is|are) (also )?(.*)/i, (msg) ->
    # We are adding to an existing factoid and not deleting one that
    # contains is as the key (needed for cleanup of prior match
    # previously being greedy
    if !msg.message.match(/: forget /i)
      if msg.match[3] and factoids.get msg.match[1]
        result = factoids.add msg.match[1], (factoids.get msg.match[1]) + " and " + msg.match[2] + " also " + msg.match[4]
      else
        result = factoids.add msg.match[1], msg.match[2] + " " + msg.match[4]
      msg.reply result

  robot.hear /^(.+)(\?|!)$/i, (msg) ->
    key = msg.match[1]
    # Don't return a factoid if we're adding a factoid.
    if /(is|are) .+/.exec key
      return
    result = factoids.get key
    if result
      if reply = /(is|are) (<reply>)(.*)/.exec result
        msg.send reply[3]
      else
        msg.send msg.match[1] + " " + result
