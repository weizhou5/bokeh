{expect} = require "chai"
utils = require "../../utils"

FuncTickFormatter = utils.require("models/formatters/func_tick_formatter").Model
Range1d = utils.require("models/ranges/range1d").Model

describe "func_tick_formatter module", ->

  describe "values computed property", ->
    rng1 = new Range1d()
    formatter = new FuncTickFormatter({args: {foo: rng1}})

    it "should contain the args values", ->
      expect(formatter.get('values')).to.be.deep.equal([rng1])

    it "should update when args changes", ->
      rng2 = new Range1d()
      formatter.set('args', {foo: rng2})
      expect(formatter.get('values')).to.be.deep.equal([rng2])

  describe "func computed property", ->
    formatter = new FuncTickFormatter({code: "return 10"})
    it "should return a Function", ->
      expect(formatter.get('func')).to.be.an.instanceof(Function)

    it "should have code property as function body", ->
      func = new Function("tick", "require", "return 10")
      expect(formatter.get('func').toString()).to.be.equal(func.toString())

    it "should have values as function args", ->
      rng = new Range1d()
      formatter.set('args', {foo: rng.ref()})
      func = new Function("tick", "foo", "require", "return 10")
      expect(formatter.get('func').toString()).to.be.equal(func.toString())

  describe "doFormat method", ->
    it "should format numerical ticks appropriately", ->
      formatter = new FuncTickFormatter({code: "return tick * 10"})
      labels = formatter.doFormat([-10, -0.1, 0, 0.1, 10])
      expect(labels).to.deep.equal([-100, -1.0, 0, 1, 100])

    it "should format categorical ticks appropriately", ->
      formatter = new FuncTickFormatter({code: "return tick + '_lat'"})
      labels = formatter.doFormat(["a", "b", "c", "d", "e"])
      expect(labels).to.deep.equal(["a_lat", "b_lat", "c_lat", "d_lat", "e_lat"])

    it "should support imports using require", ->
      formatter = new FuncTickFormatter({
        code: "var _ = require('underscore'); return _.max([1,2,3])"
      })
      labels = formatter.doFormat([0, 0, 0])
      expect(labels).to.be.deep.equal([3,3,3])

    it "should handle args appropriately", ->
      rng = new Range1d({start: 5, end: 10})
      formatter = new FuncTickFormatter({
        code: "return foo.get('start') + foo.get('end') + tick"
        args: {foo: rng}
      })
      labels = formatter.doFormat([-10, -0.1, 0, 0.1, 10])
      expect(labels).to.deep.equal([5, 14.9, 15, 15.1, 25])
