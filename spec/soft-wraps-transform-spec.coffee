Point = require "../src/point"
SoftWrapsTransform = require "../src/soft-wraps-transform"
StringLayer = require "../src/string-layer"
SpyLayer = require "./spy-layer"
TransformLayer = require "../src/transform-layer"

{expectMapsSymmetrically} = require "./spec-helper"

describe "SoftWrapsTransform", ->
  it "inserts a line-break at the end of the last whitespace sequence that starts before the max column", ->
    layer = new TransformLayer(
      new StringLayer("abc def ghi jklmno\tpqr"),
      new SoftWrapsTransform(10)
    )

    iterator = layer.buildIterator()
    expect(iterator.next()).toEqual(value: "abc def ", done: false)
    expect(iterator.getPosition()).toEqual(Point(1, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 8))

    expect(iterator.next()).toEqual(value: "ghi jklmno\t", done: false)
    expect(iterator.getPosition()).toEqual(Point(2, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 19))

    expect(iterator.next()).toEqual(value: "pqr", done: false)
    expect(iterator.getPosition()).toEqual(Point(2, 3))
    expect(iterator.getInputPosition()).toEqual(Point(0, 22))

    expect(iterator.next()).toEqual {value: undefined, done: true}
    expect(iterator.next()).toEqual {value: undefined, done: true}
    expect(iterator.getPosition()).toEqual(Point(2, 3))
    expect(iterator.getInputPosition()).toEqual(Point(0, 22))

    iterator.seek(Point(0, 4))
    expect(iterator.getInputPosition()).toEqual(Point(0, 4))

    expect(iterator.next()).toEqual(value: "def ", done: false)
    expect(iterator.getPosition()).toEqual(Point(1, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 8))

  it "breaks lines within words if there is no whitespace starting before the max column", ->
    layer = new TransformLayer(
      new StringLayer("abcdefghijkl"),
      new SoftWrapsTransform(5)
    )

    iterator = layer.buildIterator()
    expect(iterator.next()).toEqual(value: "abcde", done: false)
    expect(iterator.getPosition()).toEqual(Point(1, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 5))

    expect(iterator.next()).toEqual(value: "fghij", done: false)
    expect(iterator.getPosition()).toEqual(Point(2, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 10))

    expect(iterator.next()).toEqual(value: "kl", done: false)
    expect(iterator.getPosition()).toEqual(Point(2, 2))
    expect(iterator.getInputPosition()).toEqual(Point(0, 12))

    expect(iterator.next()).toEqual {value: undefined, done: true}
    expect(iterator.next()).toEqual {value: undefined, done: true}
    expect(iterator.getPosition()).toEqual(Point(2, 2))
    expect(iterator.getInputPosition()).toEqual(Point(0, 12))

  it "reads from the input layer until it reads a newline or it exceeds the max column", ->
    layer = new TransformLayer(
      new SpyLayer("abc defghijkl", 5),
      new SoftWrapsTransform(10)
    )

    iterator = layer.buildIterator()
    expect(iterator.next()).toEqual(value: "abc ", done: false)
    expect(iterator.getPosition()).toEqual(Point(1, 0))
    expect(iterator.getInputPosition()).toEqual(Point(0, 4))

    expect(iterator.next()).toEqual(value: "defghijkl", done: false)
    expect(iterator.getPosition()).toEqual(Point(1, 9))
    expect(iterator.getInputPosition()).toEqual(Point(0, 13))

  it "maps target positions to input positions and vice-versa", ->
    layer = new TransformLayer(
      new StringLayer("abcdefghijkl"),
      new SoftWrapsTransform(5)
    )

    expectMapsSymmetrically(layer, Point(0, 0), Point(0, 0))
    expectMapsSymmetrically(layer, Point(0, 1), Point(0, 1))
    expectMapsSymmetrically(layer, Point(0, 5), Point(1, 0))
    expectMapsSymmetrically(layer, Point(0, 6), Point(1, 1))
    expectMapsSymmetrically(layer, Point(0, 10), Point(2, 0))
