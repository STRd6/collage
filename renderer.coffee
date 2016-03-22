Matrix = require "matrix"

module.exports = ->
  render: (context, workspace) ->
    Array::forEach.call workspace.children, (child) ->
      context.withTransform child.matrix, (context) ->
        context.drawImage(child, 0, 0)

CanvasRenderingContext2D::withTransform ?= (matrix, block) ->
  @save()

  @transform(
    matrix.a,
    matrix.b,
    matrix.c,
    matrix.d,
    matrix.tx,
    matrix.ty
  )

  try
    block(this)
  finally
    @restore()

  return this
