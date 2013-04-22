noflo = require("noflo")
_ = require("underscore")
_s = require("underscore.string")

class Defaults extends noflo.Component

  description: _s.clean "if incoming is short of the length of the
  default packets, send the default packets."

  constructor: ->
    @defaults = []

    @inPorts =
      in: new noflo.Port
      default: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.default.on "data", (data) =>
      @defaults.push(data)

    @inPorts.in.on "connect", =>
      @counts = [0]

    @inPorts.in.on "begingroup", (group) =>
      @counts.push(0)
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      count = _.last(@counts)
      data ?= @defaults[count]

      @outPorts.out.send(data)

      @counts[@counts.length - 1]++

    @inPorts.in.on "endgroup", (group) =>
      @padPackets(_.last(@counts))
      @counts.pop()
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @padPackets(@counts[0])
      @outPorts.out.disconnect()

  padPackets: (count) ->
    while count < @defaults.length
      @outPorts.out.send(@defaults[count])
      count++
 
exports.getComponent = -> new Defaults
