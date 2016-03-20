{localPosition} = require "./util"

Matrix = require "matrix"

module.exports = (document) ->
  move: do ->
    activeElement = null
    offset = null

    document.addEventListener 'mouseup', () ->
      activeElement = null

    mousedown: (e) ->
      # Raise to top
      return if e.target is e.currentTarget
      e.currentTarget.appendChild e.target

      # Track offset
      offset = localPosition(e, false, false)

      # Track active element
      activeElement = e.target
    mousemove: (e) ->
      return unless activeElement

      {x, y} = localPosition(e, false)
      x -= offset.x
      y -= offset.y

      activeElement.matrix = Matrix.translate(x, y)
      activeElement.style = activeElement.matrix.toCSS3Transform()

    mouseup: (e) ->

  cut: do ->
    path = []
    active = false

    document.addEventListener 'mouseup', () ->
      active = false

    mousedown: (e) ->
      active = true
      path = [localPosition(e, false)]

    mousemove: (e) ->
      path.push localPosition(e, false)

    mouseup: (e) ->
      console.log path
