Point = require "./point"
Layer = require "./layer"
Patch = require "./patch"

module.exports =
class BufferLayer extends Layer
  constructor: (@inputLayer) ->
    super
    @patch = new Patch
    @activeRegionStart = null
    @activeRegionEnd = null

  buildIterator: ->
    new BufferLayerIterator(this, @inputLayer.buildIterator(), @patch.buildIterator())

  setActiveRegion: (start, end) ->
    @activeRegionStart = start
    @activeRegionEnd = end

  contentOverlapsActiveRegion: ({column}, content) ->
    return false unless @activeRegionStart? and @activeRegionEnd?
    not (column + content.length < @activeRegionStart.column) and
      not (column > @activeRegionEnd.column)

class BufferLayerIterator
  constructor: (@layer, @inputIterator, @patchIterator) ->
    @position = Point.zero()
    @inputPosition = Point.zero()

  next: ->
    comparison = @patchIterator.getPosition().compare(@position)
    if comparison <= 0
      @patchIterator.seek(@position) if comparison < 0
      next = @patchIterator.next()
      if next.value?
        @position = @patchIterator.getPosition()
        @inputPosition = @patchIterator.getInputPosition()
        return {value: next.value, done: next.done}

    @inputIterator.seek(@inputPosition)
    next = @inputIterator.next()
    nextInputPosition = @inputIterator.getPosition()

    inputOvershoot = @inputIterator.getPosition().traversalFrom(@patchIterator.getInputPosition())
    if inputOvershoot.compare(Point.zero()) > 0
      next.value = next.value.substring(0, next.value.length - inputOvershoot.column)
      nextPosition = @patchIterator.getPosition()
    else
      nextPosition = @position.traverse(nextInputPosition.traversalFrom(@inputPosition))

    if next.value? and @layer.contentOverlapsActiveRegion(@position, next.value)
      @patchIterator.seek(@position)
      extent = Point(0, next.value.length ? 0)
      @patchIterator.splice(extent, next.value)

    @inputPosition = nextInputPosition
    @position = nextPosition
    next

  seek: (@position) ->
    @patchIterator.seek(@position)
    @inputPosition = @patchIterator.getInputPosition()
    @inputIterator.seek(@inputPosition)

  getPosition: ->
    @position.copy()

  getInputPosition: ->
    @inputPosition.copy()

  splice: (extent, content) ->
    @patchIterator.splice(extent, content)
    @position = @patchIterator.getPosition()
    @inputPosition = @patchIterator.getInputPosition()
    @inputIterator.seek(@inputPosition)
