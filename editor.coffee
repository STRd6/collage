Matrix = require "matrix"
Modal = require "modal"
Observable = require "observable"
Postmaster = require "postmaster"
Renderer = require "./renderer"
Tools = require("./tools")

OptionsTemplate = require "./templates/options"

{localPosition, updateElement} = require "./util"

images = [
  "https://0.pixiecdn.com/sprites/138612/original.png"
  "https://1.pixiecdn.com/sprites/141985/original."
  "https://3.pixiecdn.com/sprites/138119/original.png"
  "https://2.pixiecdn.com/sprites/137922/original.png"
].map (url) ->
  img = new Image
  img.crossOrigin = "Anonymous"
  img.draggable = true
  img.src = url + "?o_0"

  return img

module.exports = ->
  tools = Tools()
  renderer = Renderer()

  self =
    activeTool: Observable(tools.move)
    screenElement: document.createElement('canvas')

    overlayContext: ->
      self.screenElement.getContext('2d')

    tools: Observable ->
      Object.keys(tools).map (name) ->
        tools[name]

    unsaved: Observable false

    images: Observable(images)

    addMaterial: (url) ->
      img = self.imageFromURL(url)

      self.images.push img

    imageFromURL: (url) ->
      img = new Image
      img.crossOrigin = "Anonymous"
      img.draggable = true
      img.src = url

      return img

    sceneWidth: Observable 400
    sceneHeight: Observable 400

    render: ->
      scene = self.scene

      height = self.sceneHeight()
      width = self.sceneWidth()

      viewRect = document.querySelector('render-area').getBoundingClientRect()
      workRect = document.querySelector('workspace').getBoundingClientRect()
      view = Matrix.translate(viewRect.left - workRect.left, viewRect.top - workRect.top)

      canvas = document.createElement("canvas")
      canvas.width = width
      canvas.height = height

      context = canvas.getContext("2d")

      context.clearRect(0, 0, canvas.width, canvas.height)
      context.withTransform view.inverse(), (context) ->
        renderer.render(context, scene)

      canvas.toBlob (blob) ->
        self.unsaved false

        self.invokeRemote "save",
          image: blob
          width: width
          height: height

    options: ->
      Modal.show OptionsTemplate self

    dragstart: (e) ->
      sourceItem = e.target

      return unless sourceItem.parentElement is e.currentTarget

      img = new Image
      img.crossOrigin = "Anonymous"
      img.src = sourceItem.src

      {x, y} = localPosition(e, true, false)

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

    dragover: (e) ->
      e.preventDefault()
      return

    drop: (e) ->
      e.preventDefault()

      dataText = e.dataTransfer.getData "drop-image"
      return unless dataText

      data = JSON.parse dataText

      {x, y} = self.scene.matrix.inverse().transformPoint localPosition(e, false)

      x -= data.offset.x
      y -= data.offset.y

      img = new Image
      img.crossOrigin = "Anonymous"
      img.src = data.src

      self.addItem img, Matrix.translate(x, y)

      return

    addItem: (item, matrix=Matrix.IDENTITY) ->
      updateElement item, matrix
      self.scene.appendChild item

      self.unsaved(true)

      return

  Postmaster(self)

  return self