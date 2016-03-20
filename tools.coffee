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
