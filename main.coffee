style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Template = require "./templates/app"

TouchScreen = require "./lib/touchscreen"
touchScreen = TouchScreen document.createElement "screen"

touchScreen.on "touch", (e) -> console.log e

document.body.appendChild Template
  screenElement: touchScreen.element()
  imageUrls: [
    "https://0.pixiecdn.com/sprites/138612/original.png"
    "https://1.pixiecdn.com/sprites/141985/original."
    "https://3.pixiecdn.com/sprites/138119/original.png"
    "https://2.pixiecdn.com/sprites/137922/original.png"
  ]
  materialDrag: (e) ->
    sourceItem = event.currentTarget
    
    img = new Image
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

  workspaceDragover: (e) ->
    e.preventDefault()
    return

  workspaceDrop: (e) ->
    e.preventDefault()

    data = JSON.parse e.dataTransfer.getData "drop-image"
    console.log data

    {x, y} = localPosition(e, false)

    x -= data.offset.x
    y -= data.offset.y

    style = """
      top: #{y}px; left: #{x}px;
    """

    img = new Image
    img.src = data.src
    img.style = style
    e.currentTarget.insertBefore img, touchScreen.element()

localPosition = (e, scaled=true) ->
  rect = e.currentTarget.getBoundingClientRect()

  x = e.pageX - rect.left
  y = e.pageY - rect.top

  if scaled
    x: x / rect.width
    y: y / rect.height
  else
    x: x
    y: y
