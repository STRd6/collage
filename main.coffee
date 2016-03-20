style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

global.PACKAGE = PACKAGE

require "./lib/canvas-to-blob"

{localPosition} = require "./util"

Renderer = require "./renderer"
renderer = Renderer()

Matrix = require "matrix"
Observable = require "observable"

Template = require "./templates/app"

tools = require("./tools")()

imageUrls = [
  "https://0.pixiecdn.com/sprites/138612/original.png"
  "https://1.pixiecdn.com/sprites/141985/original."
  "https://3.pixiecdn.com/sprites/138119/original.png"
  "https://2.pixiecdn.com/sprites/137922/original.png"
]

screenElement = document.createElement('canvas')

document.addEventListener 'mouseup', (e) ->
  e.preventDefault()

  app.activeTool().mouseup(e, self)

app = self =
  activeTool: Observable(tools.move)
  screenElement: screenElement

  tools: Observable ->
    Object.keys(tools).map (name) ->
      tools[name]

  images: ->
    imageUrls.map (url) ->
      img = new Image
      img.crossOrigin = "Anonymous"
      img.draggable = true
      img.src = url + "?o_0"

      return img

  render: ->
    {width, height} = scene.getBoundingClientRect()

    canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height

    context = canvas.getContext("2d")

    context.clearRect(0, 0, canvas.width, canvas.height)
    renderer.render(context, scene)
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
    e.preventDefault()

    self.activeTool().mousedown(e, self)

  mousemove: (e) ->
    e.preventDefault()

    self.activeTool().mousemove(e, self)

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

document.body.appendChild Template app

scene = document.querySelector("scene")

setOverlaySize = ->
  canvas = document.querySelector('canvas')
  
  {width, height} = scene.getBoundingClientRect()

  canvas.width = width
  canvas.height = height

window.addEventListener "resize", setOverlaySize
setOverlaySize()
