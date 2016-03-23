Matrix = require "matrix"
Observable = require "observable"
Renderer = require "./renderer"
Tools = require("./tools")

{localPosition, updateElement} = require "./util"

imageUrls = [
  "https://0.pixiecdn.com/sprites/138612/original.png"
  "https://1.pixiecdn.com/sprites/141985/original."
  "https://3.pixiecdn.com/sprites/138119/original.png"
  "https://2.pixiecdn.com/sprites/137922/original.png"
]

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

    unsaved: -> true

    images: ->
      imageUrls.map (url) ->
        img = new Image
        img.crossOrigin = "Anonymous"
        img.draggable = true
        img.src = url + "?o_0"

        return img

    render: ->
      scene = self.scene

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

      {x, y} = localPosition(e, false)

      x -= data.offset.x
      y -= data.offset.y

      img = new Image
      img.crossOrigin = "Anonymous"
      img.src = data.src

      updateElement img, Matrix.translate(x, y)
      editor.scene.appendChild img
