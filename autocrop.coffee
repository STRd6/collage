# Take a canvas element with an attached transform
# modify it and update the transform to be a cropped canvas
module.exports = (canvas) ->
  context = canvas.getContext('2d')

  transform = canvas.matrix

  imageData = context.getImageData(0, 0, canvas.width, canvas.height)

  console.log getContentBounds(imageData)

getContentBounds = (imageData) ->
  {width, height} = imageData
  y = 0
  x = 0

  xMin = Infinity
  yMin = Infinity
  xMax = -Infinity
  yMax = -Infinity

  while y < height
    while x < width
      index = y * width + x + 3
      
      alpha = imageData[index]
      
      if alpha > 0
        if x < xMin
          xMin = x
        if x > xMax
          xMax = x
        if y < yMin
          yMin = y
        if y > yMax
          yMax = y

      x += 1
    y += 1

  x: xMin ? 0
  y: yMin ? 0
  width: (xMax - xMin) ? 0
  height: (yMax - yMin) ? 0
