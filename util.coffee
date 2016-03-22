Matrix = require "matrix"
Matrix.Point = require "point"

Matrix::toCSS3Transform ?= ->
  """
    transform: #{@toString().toLowerCase()}
  """

round = (num) ->
  Math.round(num * 10000) / 10000

# Not too happy with the tx,ty being snapped to whole numbers, it can
# cause repeated operations to drift towards zero, but it does keep the
# rendering looking sharper rather than blurry
Matrix::quantize ?= ->
  Matrix.apply(null, [@a, @b, @c, @d].map(round).concat(0|@tx, 0|@ty))

Object.defineProperty HTMLCanvasElement.prototype, "naturalWidth",
  get: ->
    @width

Object.defineProperty HTMLCanvasElement.prototype, "naturalHeight",
  get: ->
    @height

module.exports =
  extend: (target, sources...) ->
    for source in sources
      for name of source
        target[name] = source[name]

    return target

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

  updateElement: (element, matrix) ->
    element.matrix = matrix
    element.style = matrix.toCSS3Transform()

    return element
