{localPosition} = require "./util"

Matrix = require "matrix"

module.exports = (document) ->
  move: do ->
    activeElement = null
    offset = null

    document.addEventListener 'mouseup', () ->
      activeElement = null

    name: "Move"
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
      
      console.log path
      
      canvas = document.querySelector('canvas')
      
      context = canvas.getContext('2d')

      path.forEach ({x, y}, i) ->
        if i is 0
          context.beginPath()
          context.moveTo(x, y)
        else
          context.lineTo(x, y)
      
      context.lineWidth = 5
      context.strokeStyle = 'blue'
      context.stroke()

    name: "Cut"
    mousedown: (e) ->
      active = true
      path = [localPosition(e, false)]

    mousemove: (e) ->
      path.push localPosition(e, false)

    mouseup: (e) ->
      