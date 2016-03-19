style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Template = require "./templates/app"

document.body.appendChild Template({})
