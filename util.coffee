Matrix = require "matrix"
Matrix.Point = require "point"

Matrix::toCSS3Transform ?= ->
  """
    transform: #{@toString().toLowerCase()}
  """

Object.defineProperty HTMLCanvasElement.prototype, "naturalWidth",
  get: ->
    @width

Object.defineProperty HTMLCanvasElement.prototype, "naturalHeight",
  get: ->
    @height

module.exports =
  localPosition: (e, scaled=true, current=true) ->
    if current
      target = e.currentTarget
    else
      target = e.target
  
    rect = target.getBoundingClientRect()
  
    x = e.pageX - rect.left
    y = e.pageY - rect.top
  
    if scaled
      x: x / rect.width
      y: y / rect.height
    else
      x: x
      y: y
