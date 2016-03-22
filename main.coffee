Editor = require "./editor"
Template = require "./templates/app"

require "./lib/canvas-to-blob"

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

editor = Editor()
document.body.appendChild Template editor

global.PACKAGE = PACKAGE
global.editor = editor
global.require = require

document.addEventListener 'mouseup', (e) ->
  e.preventDefault()

  editor.activeTool().mouseup(e, self)

scene = document.querySelector("scene")

setOverlaySize = ->
  canvas = editor.screenElement

  {width, height} = scene.getBoundingClientRect()

  canvas.width = width
  canvas.height = height

window.addEventListener "resize", setOverlaySize
setOverlaySize()

window.onbeforeunload = ->
  if editor.unsaved()
    "You have some unsaved changes, if you leave now you will lose your work."
