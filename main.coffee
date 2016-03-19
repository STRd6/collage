style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Template = require "./templates/app"

# TouchScreen = require "./lib/touchscreen"
# touchScreen = TouchScreen document.createElement "screen"
# touchScreen.on "touch", (e) -> console.log e

activeElement = null
offset = null

document.addEventListener "mouseup", ->
  activeElement = null

document.body.appendChild Template
  screenElement: [] #touchScreen.element()
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

    activeElement.style = toTransform(1, 0, 0, 1, x, y)

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

    style = """
      transform: matrix(1, 0, 0, 1, #{x}, #{y});
    """

    img = new Image
    img.src = data.src
    img.style = style
    e.currentTarget.appendChild img
    # e.currentTarget.insertBefore img, touchScreen.element()

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

toTransform = (args...) ->
  """
    transform: matrix(#{args.join(",")})
  """
