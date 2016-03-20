{localPosition} = require "./util"

Line = require "./lib/line"
Matrix = require "matrix"
Point = require "point"

module.exports = (document) ->
  move: do ->
    activeElement = null
    offset = null

    document.addEventListener 'mouseup', () ->
      activeElement = null

    name: "Move"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4bWxuczpza2V0Y2g9Imh0dHA6Ly93d3cuYm9oZW1pYW5jb2RpbmcuY29tL3NrZXRjaC9ucyIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHZlcnNpb249IjEuMSIgeD0iMHB4IiB5PSIwcHgiPjx0aXRsZT4xMDwvdGl0bGU+PGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+PGcgc3Ryb2tlPSJub25lIiBzdHJva2Utd2lkdGg9IjEiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIgc2tldGNoOnR5cGU9Ik1TUGFnZSI+PHBhdGggZD0iTTk0LjIyMTE1NDQsNTEuNDcxMTE5OCBMNzcuMDYyODA2Myw2My4xMjkyNjY3IEM3NS41NjQ0Nzg0LDY0LjE0NzE0ODMgNzMuNjgxNDc2Nyw2Mi41MzcyMTc0IDc0LjQ1Mzk5MDIsNjAuODk4NzkyMyBMNzguMTAyODUwMSw1My4xNjU3NDIxIEw1My4xNjYzMzU4LDUzLjE2NTc0MjEgTDUzLjE2NjMzNTgsNzguMTAyMjU2NSBMNjAuODk5Mzg1OSw3NC40NTMzOTY2IEM2Mi41MzcwMTk2LDczLjY4MDg4MzEgNjQuMTQ3NzQxOSw3NS41NjQ2NzYyIDYzLjEyOTg2MDQsNzcuMDYyMjEyNyBMNTEuNDcxNzEzNCw5NC4yMjA1NjA4IEM1MC43NjU2ODY3LDk1LjI1OTgxMzEgNDkuMjM0OTA2OSw5NS4yNTk4MTMxIDQ4LjUyODg4MDIsOTQuMjIwNTYwOCBMMzYuODcwNzMzMyw3Ny4wNjIyMTI3IEMzNS44NTI4NTE3LDc1LjU2NDY3NjIgMzcuNDYzNTc0MSw3My42ODA4ODMxIDM5LjEwMTIwNzcsNzQuNDUzMzk2NiBMNDYuODM0MjU3OSw3OC4xMDIyNTY1IEw0Ni44MzQyNTc5LDUzLjE2NTc0MjEgTDIxLjg5Nzc0MzUsNTMuMTY1NzQyMSBMMjUuNTQ2NjAzNCw2MC44OTg3OTIzIEMyNi4zMTkxMTY5LDYyLjUzNzIxNzQgMjQuNDM2MTE1Myw2NC4xNDcxNDgzIDIyLjkzNzc4NzMsNjMuMTI5MjY2NyBMNS43Nzk0MzkyMiw1MS40NzExMTk4IEM0Ljc0MDE4NjkzLDUwLjc2NTA5MzEgNC43NDAxODY5Myw0OS4yMzQzMTMzIDUuNzc5NDM5MjIsNDguNTI4Mjg2NiBMMjIuOTM3Nzg3MywzNi44NzAxMzk2IEMyNC40MzYxMTUzLDM1Ljg1MjI1ODEgMjYuMzE5MTE2OSwzNy40NjI5ODA0IDI1LjU0NjYwMzQsMzkuMTAwNjE0MSBMMjEuODk3NzQzNSw0Ni44MzM2NjQyIEw0Ni44MzQyNTc5LDQ2LjgzMzY2NDIgTDQ2LjgzNDI1NzksMjEuODk3MTQ5OSBMMzkuMTAxMjA3NywyNS41NDYwMDk4IEMzNy40NjM1NzQxLDI2LjMxODUyMzMgMzUuODUyODUxNywyNC40MzU1MjE2IDM2Ljg3MDczMzMsMjIuOTM3MTkzNyBMNDguNTI4ODgwMiw1Ljc3ODg0NTU4IEM0OS4yMzQ5MDY5LDQuNzQwMzg0ODEgNTAuNzY1Njg2Nyw0Ljc0MDM4NDgxIDUxLjQ3MTcxMzQsNS43Nzg4NDU1OCBMNjMuMTI5ODYwNCwyMi45MzcxOTM3IEM2NC4xNDc3NDE5LDI0LjQzNTUyMTYgNjIuNTM3MDE5NiwyNi4zMTg1MjMzIDYwLjg5OTM4NTksMjUuNTQ2MDA5OCBMNTMuMTY2MzM1OCwyMS44OTcxNDk5IEw1My4xNjYzMzU4LDQ2LjgzMzY2NDIgTDc4LjEwMjg1MDEsNDYuODMzNjY0MiBMNzQuNDUzOTkwMiwzOS4xMDA2MTQxIEM3My42ODE0NzY3LDM3LjQ2Mjk4MDQgNzUuNTY0NDc4NCwzNS44NTIyNTgxIDc3LjA2MjgwNjMsMzYuODcwMTM5NiBMOTQuMjIxMTU0NCw0OC41MjgyODY2IEM5NS4yNTk2MTUyLDQ5LjIzNDMxMzMgOTUuMjU5NjE1Miw1MC43NjUwOTMxIDk0LjIyMTE1NDQsNTEuNDcxMTE5OCIgZmlsbD0iIzAwMDAwMCIgc2tldGNoOnR5cGU9Ik1TU2hhcGVHcm91cCI+PC9wYXRoPjwvZz48L3N2Zz4="
    mousedown: (e) ->
      # Raise to top
      return if e.target is e.currentTarget
      e.currentTarget.appendChild e.target

      # Track offset
      offset = localPosition(e, false, false)

      # Track active element
      activeElement = e.target
    mousemove: (e) ->
      return unless activeElement

      {x, y} = localPosition(e, false)
      x -= offset.x
      y -= offset.y

      activeElement.matrix = Matrix.translate(x, y)
      activeElement.style = activeElement.matrix.toCSS3Transform()

    mouseup: (e) ->

  cut: do ->
    path = []
    active = false
    targetMap = null
    canvas = null
    context = null

    document.addEventListener 'mouseup', () ->
      return unless active
      active = false

      # For each target in our set we want to cut it into smaller pieces
      # if the cut crosses the boundary of the image in two places then we can cut it
      # if the cut crosses the boundary in 1 place it is not complete and we can't cut it
      # if the cut crosses the boundary in more than two places we may be able to cut it into more than two pieces

      # Find the first two intersections of the path and the image boundary
      # Create a path and a complement path
      # split into two

      context.clearRect(0, 0, canvas.width, canvas.height)

      targetMap.forEach (intersections, target) ->
        # TODO: Repeat for next two intersections
        if intersections.length >= 2
          [beginPathIndex, endImageEdge] = intersections.shift()
          [endPathIndex, beginImageEdge] = intersections.shift()

          maskPath = []

          # Trace the path across
          i = beginPathIndex
          while i < endPathIndex
            start = path[i]
            maskPath.push start
            i += 1

          # Trace around image
          edgePath = pathPoints(target)

          if endImageEdge is beginImageEdge
            maskPath.push path[endPathIndex], path[beginPathIndex]
          else
            i = beginImageEdge + 1 % edgePath.length
            maskPath.push path[endPathIndex]

            while i != endImageEdge
              nextPathIndex = (i + 1) % edgePath.length
              start = edgePath[i]
              maskPath.push start

              i = nextPathIndex

            maskPath.push edgePath[i], path[beginPathIndex]

          clipMask(target, maskPath)

        return

    name: "Cut"
    iconURL: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAA6lJREFUeJzt3E2KHHUAxuHX6FLU6MqtG4MLQSe5hCJuXZmPA0TwKCa4Eg/gBVS8gaAHUHDj2g8Ql34snE5qJvX2TE9XVazu54GGWdQ0/Yf6wUv39CQAAAAAAAAAAAAAAADM5LUk1572i4D/o7eT/Jrk84gEztjE8c/pQyRw6nwcIoFTLQ6RcPQuikMkHK3LxiESjs6ucYiEo3HVOETCwds3DpFwsKaKQyQcnKnj2Dw+W/IQMIe54vg7yb0FzwGTEwcU4oBCHFCIAwpxQCEOKMQBhTigEAcU4oBCHFCIAwpxQCEOKMQBhTigEAcU4oBCHFCIAwpxQCEOKMQBhTigEAcU4oBCHFCIAwpxQCEOKMQBxZxx3F3wHDA5cUAhDijEAYU4oBAHFOKAQhxQiAMKcUAhDijEAYU4oBAHFOKAQhxQiAMKcUAhDijEAYU4oBAHFOKAQhxQiAMKcUAhDijEAYU4oBAHFOKAQhxQiAOKOeO4s9wxYHrigEIcUIgDCnFAIQ4oxAGFOKAQBxTigEIcUIgDCnFAIQ4oxAGFOKAQBxTigEIcUIgDCnFAIQ4oxAGFOKAQBxTigEIcUIgDCnFAIQ4oxAGFOKAQBxRzxnF7wXPA5MQBhTigEAcU4oBCHFCIAwpxQCEOKMQBhTigEAcU4oBCHFCIAwpxQCEOKMQBhTigEAcU4oDizYgDqpeTfB9xwBkvDX6eMhJxsHq3kvySszfyFJGIg9W7leT3jN/Q+0QiDlZvGMfwxr4zuOYqkYiD1RuLY1sk35VrxcHB2RbHPpGIg9W7TBzDG/7u4He3RSIOVm+XOHaJRBys3s3sHkeL5HoeRyIOVm+fOIaR3Bs85/Uk30YcrNwUcbRInlvkBDCTKeNokcAqzRHHn0k+TfLGgueAyU0dx09JPs7ZP2iEVZoyjm+SvJfk2UVPADO5meS3TD+jnk/yzCIngJnsG8fYjLqR5JMk7y9yApjJPnGcn1HXkryb5OskfyX5cKlDwByuEsfYjHoxyUdJfszjt3NvL3ICmMmucbQZ9TDJH+eu+2CRE8BMdomjzaivLrgOVukkF8dxmRnlwz8OzkVx7DKjfPjHQdkWx9iMeidmFEdiLA4zCvJkHGPz6PUkD2JGcWSGcZhRMHCS5Oc8OY9eSHI/ZhRH7JX89z1wMwq22MyoL2NGwSObGfVDzCh4xIyCEW/FjIJRw/94aEbBwOY75GYUnHOS5IuYUTDq1af9AgAAAAAAAAAAAAAAAMi/0aQPy7R/vZsAAAAASUVORK5CYII="
    mousedown: (e, editor) ->
      active = true
      targetMap = new Map
      canvas = editor.screenElement
      context = canvas.getContext('2d')

      path = [Point localPosition(e, false)]

    mousemove: (e, editor) ->
      target = e.target

      if active
        # TODO: Should add all targets underneath this point, not just the top
        if target != e.currentTarget
          unless targetMap.has target
            targetMap.set target, []

            drawRect(context, target)

        prev = path[path.length - 1]
        current = Point localPosition(e, false)

        line = Line
          start: prev
          end: current
        
        drawLine context, line, "purple"

        targetMap.forEach (intersections, target) ->
          rectLines(target).forEach (targetLine, i) ->
            intersection = line.intersects(targetLine)

            if intersection
              drawCircle context, intersection

              intersections.push [path.length, i]
              path.push intersection

        path.push current

    mouseup: (e) ->

clipMask = (target, maskPath) ->
  width = target.naturalWidth or target.width
  height = target.naturalHeight or target.height
  matrix = target.matrix
  inverseMatrix = matrix.inverse()

  maskPath = maskPath.map(inverseMatrix.transformPoint.bind(inverseMatrix))

  # Apply the mask
  c = document.createElement "canvas"
  c.width = width
  c.height = height
  ct = c.getContext('2d')

  applyClip(ct, maskPath)
  ct.drawImage(target, 0, 0)

  c.matrix = matrix
  c.style = matrix.toCSS3Transform()
  target.parentElement.appendChild(c)

  # Apply the negative
  c = document.createElement "canvas"
  c.width = width
  c.height = height
  ct = c.getContext('2d')

  ct.drawImage(target, 0, 0)
  applyClip(ct, maskPath)
  ct.globalCompositeOperation = "destination-out"
  ct.fillStyle = "#000"
  ct.fillRect(0, 0, c.width, c.height)
  
  c.matrix = matrix
  c.style = matrix.toCSS3Transform()
  target.parentElement.appendChild(c)

  # TODO: Autocrop whitespace

  target.remove()

applyClip = (ct, maskPath) ->
  maskPath.forEach ({x, y}, i) ->
    if i is 0
      ct.beginPath()
      ct.moveTo(x, y)
    else
      ct.lineTo(x, y)

  ct.closePath()
  ct.clip()

drawCircle = (context, p) ->
  context.beginPath()
  context.arc(p.x, p.y, 5, 0, 2*Math.PI)
  context.fillStyle = "magenta"
  context.fill()

pathPoints = (target) ->
  width = target.naturalWidth or target.width
  height = target.naturalHeight or target.height

  matrix = target.matrix

  points = [
    Point(0, 0)
    Point(width, 0)
    Point(width, height)
    Point(0, height)
  ].map(matrix.transformPoint.bind(matrix))

rectLines = (target) ->
  points = pathPoints(target)

  points.map (currentPoint, i) ->
    nextPoint = points[i + 1] or points[0]

    Line
      start: currentPoint
      end: nextPoint

drawLine = (context, line, color="orange") ->
  context.beginPath()
  context.moveTo(line.start.x, line.start.y)
  context.lineTo(line.end.x, line.end.y)
  context.lineWidth = 5
  context.strokeStyle = color
  context.stroke()

drawRect = (context, target) ->
  rectLines(target)
  .forEach (line) ->
    drawLine context, line
