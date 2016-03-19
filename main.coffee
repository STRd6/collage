style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Template = require "./templates/app"

TouchScreen = require "./lib/touchscreen"
touchScreen = TouchScreen document.createElement "workspace"

touchScreen.on "touch", (e) -> console.log e

document.body.appendChild Template
  screenElement: touchScreen.element()
  imageUrls: [
    "https://0.pixiecdn.com/sprites/138612/original.png"
    "https://1.pixiecdn.com/sprites/141985/original."
    "https://3.pixiecdn.com/sprites/138119/original.png"
    "https://2.pixiecdn.com/sprites/137922/original.png"
  ]
