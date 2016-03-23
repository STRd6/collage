Point = require "point"

Line = (I={}) ->
  {start, end} = I

  __proto__: Line::
  start: start || Point.ZERO
  end: end || Point.ZERO

Line:: =
  directionVector: ->
    @end.subtract(@start)

  normal: ->
    v = @directionVector()

    return Point(v.y, -v.x).norm()

  length: ->
    @start.distance(@end)

  endpoints: ->
    [@start, @end]

  intersects: (other) ->
    dv = @directionVector()
    odv = other.directionVector()

    crossProduct = dv.cross(odv)
    delta = @start.subtract(other.start)

    s = dv.cross(delta) / crossProduct
    t = odv.cross(delta) / crossProduct

    if 0 <= s <= 1 and 0 <= t <= 1
      return Point.interpolate(@start, @end, t)

    return null

  containsPoint: (p) ->
    p.subtract(@start).dot(@normal())

module.exports = Line
