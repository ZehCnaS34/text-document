Point = require "../src/point"

describe "Point", ->
  describe "::fromObject(object, copy)", ->
    it "returns a new Point if object is point-compatible array ", ->
      expect(Point.fromObject([1, 3]).isEqual(Point(1, 3)))
      expect(Point.fromObject([Infinity, Infinity]).isEqual(Point.infinity()))

    it "returns the copy of object if it is an instanceof Point", ->
      origin = Point(0, 0)
      expect(Point.fromObject(origin, false) is origin).toBe true
      expect(Point.fromObject(origin, true) is origin).toBe false

  describe "::copy()", ->
    it "returns a copy of the object", ->
      expect(Point(3, 4).copy().isEqual(Point(3, 4)))
      expect(Point.zero().copy().isEqual([0, 0]))

  describe "::negate()", ->
    it "returns a new point with row and column negated", ->
      expect(Point(3, 4).negate().isEqual(Point(-3, -4)))
      expect(Point.zero().negate().isEqual(Point.zero()))

  describe "::freeze()", ->
    it "returns the immutable copy of object", ->
      expect(Object.isFrozen(Point(3, 4).freeze()))
      expect(Object.isFrozen(Point.zero().freeze()))

  describe "::compare(other)", ->
    it "returns -1 for <, 0 for =, 1 for > comparisions", ->
      expect(Point(2, 3).compare(Point(2, 6)) is -1)
      expect(Point(2, 3).compare(Point(3, 4)) is -1)
      expect(Point(1, 1).compare(Point(1, 1)) is 0)
      expect(Point(2, 3).compare(Point(2, 0)) is 1)
      expect(Point(2, 3).compare(Point(1, 3)) is 1)

      expect(Point(2, 3).compare([2, 6]) is -1)
      expect(Point(2, 3).compare([3, 4]) is -1)
      expect(Point(1, 1).compare([1, 1]) is 0)
      expect(Point(2, 3).compare([2, 0]) is 1)
      expect(Point(2, 3).compare([1, 3]) is 1)

  describe "::isLessThan(other)", ->
    it "returns a boolean indicating whether a point precedes the given Point ", ->
      expect(Point(2, 3).isLessThan(Point(2, 5))).toBe true
      expect(Point(2, 3).isLessThan(Point(3, 4))).toBe true
      expect(Point(2, 3).isLessThan(Point(2, 3))).toBe false
      expect(Point(2, 3).isLessThan(Point(2, 1))).toBe false
      expect(Point(2, 3).isLessThan(Point(1, 2))).toBe false

      expect(Point(2, 3).isLessThan([2, 5])).toBe true
      expect(Point(2, 3).isLessThan([3, 4])).toBe true
      expect(Point(2, 3).isLessThan([2, 3])).toBe false
      expect(Point(2, 3).isLessThan([2, 1])).toBe false
      expect(Point(2, 3).isLessThan([1, 2])).toBe false

  describe "::isLessThanOrEqual(other)", ->
    it "returns a boolean indicating whether a point precedes or equal the given Point ", ->
      expect(Point(2, 3).isLessThanOrEqual(Point(2, 5))).toBe true
      expect(Point(2, 3).isLessThanOrEqual(Point(3, 4))).toBe true
      expect(Point(2, 3).isLessThanOrEqual(Point(2, 3))).toBe true
      expect(Point(2, 3).isLessThanOrEqual(Point(2, 1))).toBe false
      expect(Point(2, 3).isLessThanOrEqual(Point(1, 2))).toBe false

      expect(Point(2, 3).isLessThanOrEqual([2, 5])).toBe true
      expect(Point(2, 3).isLessThanOrEqual([3, 4])).toBe true
      expect(Point(2, 3).isLessThanOrEqual([2, 3])).toBe true
      expect(Point(2, 3).isLessThanOrEqual([2, 1])).toBe false
      expect(Point(2, 3).isLessThanOrEqual([1, 2])).toBe false

  describe "::isGreaterThan(other)", ->
    it "returns a boolean indicating whether a point follows the given Point ", ->
      expect(Point(2, 3).isGreaterThan(Point(2, 5))).toBe false
      expect(Point(2, 3).isGreaterThan(Point(3, 4))).toBe false
      expect(Point(2, 3).isGreaterThan(Point(2, 3))).toBe false
      expect(Point(2, 3).isGreaterThan(Point(2, 1))).toBe true
      expect(Point(2, 3).isGreaterThan(Point(1, 2))).toBe true

      expect(Point(2, 3).isGreaterThan([2, 5])).toBe false
      expect(Point(2, 3).isGreaterThan([3, 4])).toBe false
      expect(Point(2, 3).isGreaterThan([2, 3])).toBe false
      expect(Point(2, 3).isGreaterThan([2, 1])).toBe true
      expect(Point(2, 3).isGreaterThan([1, 2])).toBe true

  describe "::isGreaterThanOrEqual(other)", ->
    it "returns a boolean indicating whether a point follows or equal the given Point ", ->
      expect(Point(2, 3).isGreaterThanOrEqual(Point(2, 5))).toBe false
      expect(Point(2, 3).isGreaterThanOrEqual(Point(3, 4))).toBe false
      expect(Point(2, 3).isGreaterThanOrEqual(Point(2, 3))).toBe true
      expect(Point(2, 3).isGreaterThanOrEqual(Point(2, 1))).toBe true
      expect(Point(2, 3).isGreaterThanOrEqual(Point(1, 2))).toBe true

      expect(Point(2, 3).isGreaterThanOrEqual([2, 5])).toBe false
      expect(Point(2, 3).isGreaterThanOrEqual([3, 4])).toBe false
      expect(Point(2, 3).isGreaterThanOrEqual([2, 3])).toBe true
      expect(Point(2, 3).isGreaterThanOrEqual([2, 1])).toBe true
      expect(Point(2, 3).isGreaterThanOrEqual([1, 2])).toBe true

  describe "::isEqual()", ->
    it "returns if whether two points are equal", ->
      expect(Point(1, 1).isEqual(Point(1, 1))).toBe true
      expect(Point(1, 1).isEqual([1, 1])).toBe true
      expect(Point(1, 2).isEqual(Point(3, 3))).toBe false
      expect(Point(1, 2).isEqual([3, 3])).toBe false

  describe "::isPositive()", ->
    it "returns true if the point represents a forward traversal", ->
      expect(Point(-1, -1).isPositive()).toBe false
      expect(Point(-1, 0).isPositive()).toBe false
      expect(Point(-1, Infinity).isPositive()).toBe false
      expect(Point(0, 0).isPositive()).toBe false

      expect(Point(0, 1).isPositive()).toBe true
      expect(Point(5, 0).isPositive()).toBe true
      expect(Point(5, -1).isPositive()).toBe true

  describe "::isZero()", ->
    it "returns true if the point is zero", ->
      expect(Point(1, 1).isZero()).toBe false
      expect(Point(0, 1).isZero()).toBe false
      expect(Point(1, 0).isZero()).toBe false
      expect(Point(0, 0).isZero()).toBe true

  describe "::min(a, b)", ->
    it "returns the minimum of two points", ->
      expect(Point.min(Point(3, 4), Point(1, 1)).isEqual(Point(1, 1)))
      expect(Point.min(Point(1, 2), Point(5, 6)).isEqual(Point(1, 2)))
      expect(Point.min([3, 4], [1, 1]).isEqual([1, 1]))
      expect(Point.min([1, 2], [5, 6]).isEqual([1, 2]))

  describe "::max(a, b)", ->
    it "returns the minimum of two points", ->
      expect(Point.max(Point(3, 4), Point(1, 1)).isEqual(Point(3, 4)))
      expect(Point.max(Point(1, 2), Point(5, 6)).isEqual(Point(5, 6)))
      expect(Point.min([3, 4], [1, 1]).isEqual([3, 4]))
      expect(Point.min([1, 2], [5, 6]).isEqual([5, 6]))

  describe "::sanitizeNegatives()", ->
    it "returns the point so that it has valid buffer coordinates", ->
      expect(Point(-1, -1).sanitizeNegatives().isEqual(Point(0, 0)))
      expect(Point(-1, 0).sanitizeNegatives().isEqual(Point(0, 0)))
      expect(Point(-1, Infinity).sanitizeNegatives().isEqual(Point(0, 0)))

      expect(Point(5, -1).sanitizeNegatives().isEqual(Point(5, 0)))
      expect(Point(5, -Infinity).sanitizeNegatives().isEqual(Point(5, 0)))
      expect(Point(5, 5).sanitizeNegatives().isEqual(Point(5, 5)))

  describe "::translate(delta)", ->
    it "returns a new point by adding corresponding coordinates", ->
      expect(Point(1, 1).translate(Point(2, 3)).isEqual(Point(3, 4)))
      expect(Point.infinity().translate(Point(2, 3)).isEqual(Point.infinity()))

      expect(Point.zero().translate([5, 6]).isEqual([5, 6]))
      expect(Point(1, 1).translate([3, 4]).isEqual([4, 5]))

  describe "::traverse(delta)", ->
    it "returns a new point by traversing given rows and columns", ->
      expect(Point(2, 3).traverse(Point(0, 3)).isEqual(Point(2, 5)))
      expect(Point(2, 3).traverse([0, 3]).isEqual([2, 5]))

      expect(Point(1, 3).traverse(Point(4, 2)).isEqual([5, 2]))
      expect(Point(1, 3).traverse([5, 4]).isEqual([6, 4]))

  describe "::traversalFrom(other)", ->
    it "returns a point that other has to traverse to get to given point", ->
      expect(Point(2, 5).traversalFrom(Point(2, 3)).isEqual(Point(0, 2)))
      expect(Point(2, 3).traversalFrom(Point(2, 5)).isEqual(Point(0, -2)))
      expect(Point(2, 3).traversalFrom(Point(2, 3)).isEqual(Point(0, 0)))

      expect(Point(3, 4).traversalFrom(Point(2, 3)).isEqual(Point(1, 4)))
      expect(Point(2, 3).traversalFrom(Point(3, 5)).isEqual(Point(-1, 3)))

      expect(Point(2, 5).traversalFrom([2, 3]).isEqual([0, 2]))
      expect(Point(2, 3).traversalFrom([2, 5]).isEqual([0, -2]))
      expect(Point(2, 3).traversalFrom([2, 3]).isEqual([0, 0]))

      expect(Point(3, 4).traversalFrom([2, 3]).isEqual([1, 4]))
      expect(Point(2, 3).traversalFrom([3, 5]).isEqual([-1, 3]))

  describe "::toArray()", ->
    it "returns an array of row and column", ->
      expect(Point(1, 3).toArray() is [1, 3])
      expect(Point.zero().toArray() is [0, 0])
      expect(Point.infinity().toArray() is [Infinity, Infinity])

  describe "::serialize()", ->
    it "returns an array of row and column", ->
      expect(Point(1, 3).serialize()  is [1, 3])
      expect(Point.zero().serialize() is [0, 0])
      expect(Point.infinity().serialize() is [Infinity, Infinity])

  describe "::toString()", ->
    it "returns string representation of Point", ->
      expect(Point(4, 5).toString()  is "(4, 5)")
      expect(Point.zero().toString() is "(0, 0)")
      expect(Point.infinity().toString() is "(Infinity, Infinity)")
