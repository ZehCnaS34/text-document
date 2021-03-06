Point = require "./point"
Range = require "./range"
Marker = require "./marker"
MarkerIndex = require "./marker-index"
{intersectSet} = require "./set-helpers"

module.exports =
class MarkerStore
  constructor: (@delegate) ->
    @index = new MarkerIndex
    @markersById = {}
    @nextMarkerId = 0

  ###
  Section: TextDocument API
  ###

  getMarker: (id) ->
    @markersById[id]

  getMarkers: ->
    marker for id, marker of @markersById

  findMarkers: (params) ->
    markerIds = new Set(Object.keys(@markersById))

    if params.startPosition?
      point = Point.fromObject(params.startPosition)
      intersectSet(markerIds, @index.findStartingIn(point))
      delete params.startPosition

    if params.endPosition?
      point = Point.fromObject(params.endPosition)
      intersectSet(markerIds, @index.findEndingIn(point))
      delete params.endPosition

    if params.containsPoint?
      point = Point.fromObject(params.containsPoint)
      intersectSet(markerIds, @index.findContaining(point))
      delete params.containsPoint

    if params.containsRange?
      {start, end} = Range.fromObject(params.containsRange)
      intersectSet(markerIds, @index.findContaining(start, end))
      delete params.containsRange

    if params.intersectsRange?
      {start, end} = Range.fromObject(params.intersectsRange)
      intersectSet(markerIds, @index.findIntersecting(start, end))
      delete params.intersectsRange

    if params.startRow?
      row = params.startRow
      intersectSet(markerIds, @index.findStartingIn(Point(row, 0), Point(row, Infinity)))
      delete params.startRow

    if params.endRow?
      row = params.endRow
      intersectSet(markerIds, @index.findEndingIn(Point(row, 0), Point(row, Infinity)))
      delete params.endRow

    if params.intersectsRow?
      row = params.intersectsRow
      intersectSet(markerIds, @index.findIntersecting(Point(row, 0), Point(row, Infinity)))
      delete params.intersectsRow

    if params.intersectsRowRange?
      [startRow, endRow] = params.intersectsRowRange
      intersectSet(markerIds, @index.findIntersecting(Point(startRow, 0), Point(endRow, Infinity)))
      delete params.intersectsRowRange

    if params.containedInRange?
      {start, end} = Range.fromObject(params.containedInRange)
      intersectSet(markerIds, @index.findContainedIn(start, end))
      delete params.containedInRange

    result = []
    for id, marker of @markersById
      result.push(marker) if markerIds.has(id) and marker.matchesParams(params)
    result.sort (marker1, marker2) -> marker1.compare(marker2)

  markRange: (range, options={}) ->
    range = Range.fromObject(range)
    marker = new Marker(String(@nextMarkerId++), this, range, options)
    @markersById[marker.id] = marker
    @index.insert(marker.id, range.start, range.end)
    if marker.invalidationStrategy is 'inside'
      @index.setExclusive(marker.id, true)
    @delegate.markerCreated(marker)
    marker

  markPosition: (position, options) ->
    properties = {}
    properties[key] = value for key, value of options
    properties.tailed = false
    @markRange(Range(position, position), properties)

  splice: (start, oldExtent, newExtent) ->
    end = start.traverse(oldExtent)

    intersecting = @index.findIntersecting(start, end)
    endingAt = @index.findEndingIn(start)
    startingAt = @index.findStartingIn(end)
    startingIn = @index.findStartingIn(start.traverse(Point(0, 1)), end.traverse(Point(0, -1)))
    endingIn = @index.findEndingIn(start.traverse(Point(0, 1)), end.traverse(Point(0, -1)))

    for id, marker of @markersById
      switch marker.invalidationStrategy
        when 'touch'
          invalid = intersecting.has(id)
        when 'inside'
          invalid = intersecting.has(id) and not (startingAt.has(id) or endingAt.has(id))
        when 'overlap'
          invalid = startingIn.has(id) or endingIn.has(id)
        when 'surround'
          invalid = startingIn.has(id) and endingIn.has(id)
        when 'never'
          invalid = false

      marker.valid = not invalid

    @index.splice(start, oldExtent, newExtent)

  restoreFromSnapshot: (snapshots) ->
    for id, marker of @markersById
      if snapshot = snapshots[id]
        marker.update(snapshot, true)

  emitChangeEvents: ->
    for id, marker of @markersById
      marker.emitChangeEvent(marker.getRange(), true, false)

  createSnapshot: ->
    markerSnapshots = @index.dump()
    for id, marker of @markersById
      snapshot = markerSnapshots[id]
      delete snapshot.isExclusive
      snapshot.reversed = marker.isReversed()
      snapshot.tailed = marker.hasTail()
      snapshot.invalidate = marker.invalidationStrategy
      snapshot.valid = marker.isValid()
      snapshot.properties = marker.properties
    markerSnapshots

  ###
  Section: Marker API
  ###

  destroyMarker: (id) ->
    delete @markersById[id]
    @index.delete(id)

  getMarkerRange: (id) ->
    @index.getRange(id)

  getMarkerStartPosition: (id) ->
    @index.getStart(id)

  getMarkerEndPosition: (id) ->
    @index.getEnd(id)

  setMarkerRange: (id, range) ->
    @index.delete(id)
    {start, end} = Range.fromObject(range)
    @index.insert(id, @delegate.clipPosition(start), @delegate.clipPosition(end))

  setMarkerHasTail: (id, hasTail) ->
    @index.setExclusive(id, not hasTail)
