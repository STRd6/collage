{localPosition} = require "./util"

Line = require "./lib/line"
Matrix = require "matrix"
Point = require "point"

module.exports = ->
  move: do ->
    activeElement = null
    offset = null

    name: "Move"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4bWxuczpza2V0Y2g9Imh0dHA6Ly93d3cuYm9oZW1pYW5jb2RpbmcuY29tL3NrZXRjaC9ucyIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHZlcnNpb249IjEuMSIgeD0iMHB4IiB5PSIwcHgiPjx0aXRsZT4xNjwvdGl0bGU+PGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+PGcgc3Ryb2tlPSJub25lIiBzdHJva2Utd2lkdGg9IjEiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIgc2tldGNoOnR5cGU9Ik1TUGFnZSI+PHBhdGggZD0iTTk1LDUwLjAxODk4NDggTDgxLjQ1MDA2OTYsNjMuNTY4ODAwOCBMNzcuMTU0MTU3Nyw1OS4yNzM2ODQ2IEw4My4zODk1NzA5LDUzLjAzODMyMzkgTDUzLjAzNzIxMDUsNTMuMDM4MzIzOSBMNTMuMDM3MjEwNSw4My4zNzA2ODQxIEw1OS4yNTQzOTgyLDc3LjE1NDMwODMgTDYzLjU1MDMxMDEsODEuNDUwMTgzOSBMNDkuOTk5NjIwMyw5NSBMMzYuNDQ5Njg5OSw4MS40NTAxODM5IEw0MC43NDU2MDE4LDc3LjE1NDMwODMgTDQ2Ljk2MjAzMDEsODMuMzcwNjg0MSBMNDYuOTYyMDMwMSw1My4wMzgzMjM5IEwxNi42MTA0MjkxLDUzLjAzODMyMzkgTDIyLjg0NTg0MjMsNTkuMjczNjg0NiBMMTguNTQ5OTMwNCw2My41Njg4MDA4IEw1LDUwLjAxODk4NDggTDE4LjU0OTkzMDQsMzYuNDY4NDA5MyBMMjIuODQ1ODQyMyw0MC43NjM1MjU2IEwxNi42NDY4ODAxLDQ2Ljk2MzE5NDggTDQ2Ljk2MjAzMDEsNDYuOTYzMTk0OCBMNDYuOTYyMDMwMSwxNi42MjkzMTU5IEw0MC43NDU2MDE4LDIyLjg0NjQ1MTEgTDM2LjQ0OTY4OTksMTguNTUxMzM0OCBMNDkuOTk5NjIwMyw1IEw2My41NTAzMTAxLDE4LjU1MTMzNDggTDU5LjI1NDM5ODIsMjIuODQ2NDUxMSBMNTMuMDM3MjEwNSwxNi42MjkzMTU5IEw1My4wMzcyMTA1LDQ2Ljk2MzE5NDggTDgzLjM1MjM2MDUsNDYuOTYzMTk0OCBMNzcuMTU0MTU3Nyw0MC43NjM1MjU2IEw4MS40NTAwNjk2LDM2LjQ2ODQwOTMgTDk1LDUwLjAxODk4NDggWiIgZmlsbD0iIzAwMDAwMCIgc2tldGNoOnR5cGU9Ik1TU2hhcGVHcm91cCI+PC9wYXRoPjwvZz48L3N2Zz4="
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
      activeElement = null

  rotate: do ->
    name: "Rotate"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjAiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMjQgMjQiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDI0IDI0IiB4bWw6c3BhY2U9InByZXNlcnZlIj48cG9seWdvbiBwb2ludHM9IjMsMyAyLDEwLjMgOC45LDggIj48L3BvbHlnb24+PHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwMDAwIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZD0iTTUuOCw1LjQgIEM3LjQsMy45LDkuNiwzLDEyLDNjNSwwLDksNCw5LDkiPjwvcGF0aD48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAwMDAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBzdHJva2UtZGFzaGFycmF5PSIzLDIiIGQ9IiAgTTIxLDEyYzAsNS00LDktOSw5Yy0zLjIsMC01LjktMS42LTcuNS00LjEiPjwvcGF0aD48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAwMDAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBkPSJNNC4yLDcuNiAgQzUuNyw0LjgsOC42LDMsMTIsM2M1LDAsOSw0LDksOSI+PC9wYXRoPjwvc3ZnPg=="
    mousedown: ->
    mousemove: ->
    mouseup: ->

  cut: do ->
    path = []
    active = false
    targetMap = null
    canvas = null
    context = null

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
