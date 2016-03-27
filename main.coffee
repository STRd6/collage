Drop = require "./lib/drop"
Editor = require "./editor"
Matrix = require "matrix"
Observable = require "observable"
Template = require "./templates/app"

require "./lib/canvas-to-blob"

Drop document, (e) ->
  Array::forEach.call event.dataTransfer.files, (file) ->
    url = URL.createObjectURL(file)
    editor.addMaterial(url)

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

editor = Editor()
document.body.appendChild Template editor
editor.scene = document.querySelector("scene")
editor.scene.matrix = Matrix()

fetch("https://api.pixieengine.com/sprites.json?per_page=20")
.then (response) ->
  response.json()
.then (data) ->
  editor.images data.map ({url}) ->
    url += "?o_0"

    editor.imageFromURL(url)

global.PACKAGE = PACKAGE
global.editor = editor
global.require = require

sceneSize = Observable ->
  [editor.sceneWidth(), editor.sceneHeight()]

sceneSize.observe ([width, height]) ->
  area = document.querySelector('render-area')
  area.style = "width: #{width}px; height: #{height}px"

document.addEventListener 'mouseup', (e) ->
  e.preventDefault()

  editor.activeTool().mouseup(e, self)

setOverlaySize = ->
  canvas = editor.screenElement

  {width, height} = document.querySelector("workspace").getBoundingClientRect()

  canvas.width = width
  canvas.height = height

window.addEventListener "resize", setOverlaySize
setOverlaySize()

window.onbeforeunload = ->
  if editor.unsaved()
    "You have some unsaved changes, if you leave now you will lose your work."
