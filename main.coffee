style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

require "./lib/canvas-to-blob"

Renderer = require "./renderer"
renderer = Renderer()

Matrix = require "matrix"

Template = require "./templates/app"

# TouchScreen = require "./lib/touchscreen"
# touchScreen = TouchScreen document.createElement "screen"
# touchScreen.on "touch", (e) -> console.log e

activeElement = null
offset = null
workspace = null
context = null

imageUrls = [
  "https://0.pixiecdn.com/sprites/138612/original.png"
  "https://1.pixiecdn.com/sprites/141985/original."
  "https://3.pixiecdn.com/sprites/138119/original.png"
  "https://2.pixiecdn.com/sprites/137922/original.png"
]

document.addEventListener "mouseup", ->
  activeElement = null

document.body.appendChild Template
  screenElement: [] #touchScreen.element()

  images: ->
    imageUrls.map (url) ->
      img = new Image
      img.crossOrigin = "Anonymous"
      img.draggable = true
      img.src = url + "?o_0"

      return img

  render: ->
    {width, height} = workspace.getBoundingClientRect()
    canvas.width = width
    canvas.height = height

    context.clearRect(0, 0, canvas.width, canvas.height)
    renderer.render(context, workspace)
    console.log canvas.toBlob (blob) ->
      url = URL.createObjectURL(blob)
      console.log url
      window.open url

  materialDrag: (e) ->
    sourceItem = e.target

    return unless sourceItem.parentElement is e.currentTarget

    img = new Image
    img.crossOrigin = "Anonymous"
    img.src = sourceItem.src

    {x, y} = localPosition(e)

    x = (x * sourceItem.naturalWidth)|0
    y = (y * sourceItem.naturalHeight)|0

    e.dataTransfer.setDragImage img, x, y
    e.dataTransfer.setData "drop-image", JSON.stringify
      offset:
        x: x
        y: y
      src: img.src

  mousedown: (e) ->
    return if e.target is e.currentTarget

    e.preventDefault()
    e.currentTarget.appendChild e.target

    offset = localPosition(e, false, false)

    activeElement = e.target
    console.log activeElement

  mousemove: (e) ->
    return unless activeElement

    {x, y} = localPosition(e, false)
    x -= offset.x
    y -= offset.y

    activeElement.matrix = Matrix.translate(x, y)
    activeElement.style = activeElement.matrix.toCSS3Transform()

  workspaceDragover: (e) ->
    e.preventDefault()
    return

  workspaceDrop: (e) ->
    e.preventDefault()

    dataText = e.dataTransfer.getData "drop-image"
    return unless dataText

    data = JSON.parse dataText
    console.log data

    {x, y} = localPosition(e, false)

    x -= data.offset.x
    y -= data.offset.y

    img = new Image
    img.matrix = Matrix.translate(x, y)
    img.crossOrigin = "Anonymous"
    img.src = data.src
    img.style = img.matrix.toCSS3Transform()
    e.currentTarget.appendChild img
    # e.currentTarget.insertBefore img, touchScreen.element()

workspace = document.querySelector("workspace")
canvas = document.createElement("canvas")

context = canvas.getContext("2d")

localPosition = (e, scaled=true, current=true) ->
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

Matrix::toCSS3Transform ?= ->
  """
    transform: #{@toString().toLowerCase()}
  """
