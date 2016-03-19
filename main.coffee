style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Template = require "./templates/app"

TouchScreen = require "./lib/touchscreen"
touchScreen = TouchScreen document.createElement "workspace"

touchScreen.on "touch", (e) -> console.log e

document.body.appendChild Template
  screenElement: touchScreen.element()
