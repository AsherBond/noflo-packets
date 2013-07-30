noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  FilterPacket = require '../components/FilterPacket.coffee'
else
  FilterPacket = require 'noflo-adapters/components/FilterPacket.js'

describe 'FilterPacket component', ->
  c = null
  ins = null
  regexp = null
  out = null

  beforeEach ->
    c = FilterPacket.getComponent()
    ins = noflo.internalSocket.createSocket()
    regexp = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.regexp.attach regexp
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'filter', ->
    it 'test default behavior', (done) ->
      packets = ['hello world']

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'hello world'
      ins.disconnect()

    it 'test accept via regexp', (done) ->
      packets = ['grue', true]

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      regexp.send '[tg]rue'

      ins.connect()
      ins.send "grue"
      ins.send false
      ins.send "foo"
      ins.send true
      ins.disconnect()
