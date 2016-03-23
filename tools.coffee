{extend, localPosition, updateElement} = require "./util"

Line = require "./lib/line"
Matrix = require "matrix"
Point = require "point"

autocrop = require "./autocrop"

transformTool = (toolData, handler) ->
  state =
    activeElement: null
    originalMatrix: null
    originalPosition: null
    midpoint: null

  extend toolData,
    mousedown: (e, editor) ->
      return unless validTarget(e.target)
      target = e.target
      viewMatrix = editor.scene.matrix.inverse()

      extend state,
        activeElement: target
        midpoint: getMidpoint(target)
        originalMatrix: target.matrix
        originalPosition: viewMatrix.transformPoint localPosition(e, false)

      return

    mousemove: (e, editor) ->
      viewMatrix = editor.scene.matrix.inverse()

      # Highlight Target Element
      screen = editor.screenElement
      context = editor.overlayContext()
      context.clearRect(0, 0, screen.width, screen.height)

      if state.activeElement
        target = state.activeElement
      else
        target = e.target

      if validTarget(target)
        context.withTransform editor.scene.matrix, (context) ->
          drawRect(context, target)

      return unless state.activeElement

      extend state,
        event: e
        position: viewMatrix.transformPoint localPosition(e, false)

      transformation = handler(state)

      finalMatrix = transformation.concat(state.originalMatrix).quantize()
      updateElement state.activeElement, finalMatrix

      return

    mouseup: (e) ->
      state.activeElement = null

      return

module.exports = ->
  move: transformTool
    name: "Move"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4bWxuczpza2V0Y2g9Imh0dHA6Ly93d3cuYm9oZW1pYW5jb2RpbmcuY29tL3NrZXRjaC9ucyIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHZlcnNpb249IjEuMSIgeD0iMHB4IiB5PSIwcHgiPjx0aXRsZT4xNjwvdGl0bGU+PGRlc2M+Q3JlYXRlZCB3aXRoIFNrZXRjaC48L2Rlc2M+PGcgc3Ryb2tlPSJub25lIiBzdHJva2Utd2lkdGg9IjEiIGZpbGw9Im5vbmUiIGZpbGwtcnVsZT0iZXZlbm9kZCIgc2tldGNoOnR5cGU9Ik1TUGFnZSI+PHBhdGggZD0iTTk1LDUwLjAxODk4NDggTDgxLjQ1MDA2OTYsNjMuNTY4ODAwOCBMNzcuMTU0MTU3Nyw1OS4yNzM2ODQ2IEw4My4zODk1NzA5LDUzLjAzODMyMzkgTDUzLjAzNzIxMDUsNTMuMDM4MzIzOSBMNTMuMDM3MjEwNSw4My4zNzA2ODQxIEw1OS4yNTQzOTgyLDc3LjE1NDMwODMgTDYzLjU1MDMxMDEsODEuNDUwMTgzOSBMNDkuOTk5NjIwMyw5NSBMMzYuNDQ5Njg5OSw4MS40NTAxODM5IEw0MC43NDU2MDE4LDc3LjE1NDMwODMgTDQ2Ljk2MjAzMDEsODMuMzcwNjg0MSBMNDYuOTYyMDMwMSw1My4wMzgzMjM5IEwxNi42MTA0MjkxLDUzLjAzODMyMzkgTDIyLjg0NTg0MjMsNTkuMjczNjg0NiBMMTguNTQ5OTMwNCw2My41Njg4MDA4IEw1LDUwLjAxODk4NDggTDE4LjU0OTkzMDQsMzYuNDY4NDA5MyBMMjIuODQ1ODQyMyw0MC43NjM1MjU2IEwxNi42NDY4ODAxLDQ2Ljk2MzE5NDggTDQ2Ljk2MjAzMDEsNDYuOTYzMTk0OCBMNDYuOTYyMDMwMSwxNi42MjkzMTU5IEw0MC43NDU2MDE4LDIyLjg0NjQ1MTEgTDM2LjQ0OTY4OTksMTguNTUxMzM0OCBMNDkuOTk5NjIwMyw1IEw2My41NTAzMTAxLDE4LjU1MTMzNDggTDU5LjI1NDM5ODIsMjIuODQ2NDUxMSBMNTMuMDM3MjEwNSwxNi42MjkzMTU5IEw1My4wMzcyMTA1LDQ2Ljk2MzE5NDggTDgzLjM1MjM2MDUsNDYuOTYzMTk0OCBMNzcuMTU0MTU3Nyw0MC43NjM1MjU2IEw4MS40NTAwNjk2LDM2LjQ2ODQwOTMgTDk1LDUwLjAxODk4NDggWiIgZmlsbD0iIzAwMDAwMCIgc2tldGNoOnR5cGU9Ik1TU2hhcGVHcm91cCI+PC9wYXRoPjwvZz48L3N2Zz4="
  , ({position, originalPosition}) ->
      {x, y} = position.subtract(originalPosition)

      return Matrix.translate(x, y)

  rotate: transformTool
    name: "Rotate"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjAiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMjQgMjQiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDI0IDI0IiB4bWw6c3BhY2U9InByZXNlcnZlIj48cG9seWdvbiBwb2ludHM9IjMsMyAyLDEwLjMgOC45LDggIj48L3BvbHlnb24+PHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAwMDAwIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHN0cm9rZS1taXRlcmxpbWl0PSIxMCIgZD0iTTUuOCw1LjQgIEM3LjQsMy45LDkuNiwzLDEyLDNjNSwwLDksNCw5LDkiPjwvcGF0aD48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAwMDAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBzdHJva2UtZGFzaGFycmF5PSIzLDIiIGQ9IiAgTTIxLDEyYzAsNS00LDktOSw5Yy0zLjIsMC01LjktMS42LTcuNS00LjEiPjwvcGF0aD48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAwMDAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgc3Ryb2tlLW1pdGVybGltaXQ9IjEwIiBkPSJNNC4yLDcuNiAgQzUuNyw0LjgsOC42LDMsMTIsM2M1LDAsOSw0LDksOSI+PC9wYXRoPjwvc3ZnPg=="
  , ({position, originalPosition, midpoint}) ->
      rotation = angleBetween(originalPosition, position, midpoint)

      return Matrix.rotation(rotation, midpoint)

  scale: transformTool
    name: "Scale"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgOTkgOTkiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDk5IDk5OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggZD0iTTQxLjIsNjAuMmMtMC42LDAtMS4zLTAuMi0xLjctMC43Yy0xLTEtMS0yLjUsMC0zLjVjMS0xLDIuNi0xLDMuNi0wLjFjMSwxLDEsMi41LDAuMSwzLjRsLTAuMSwwLjEgIEM0Mi41LDYwLDQxLjgsNjAuMiw0MS4yLDYwLjJ6IE00Ni43LDU0LjdjLTAuNiwwLTEuMy0wLjItMS44LTAuN2MtMS0xLTEtMi41LDAtMy41bDAuMS0wLjFjMS0xLDIuNS0xLDMuNSwwYzEsMSwxLDIuNSwwLDMuNSAgTDQ4LjQsNTRDNDgsNTQuNSw0Ny4zLDU0LjcsNDYuNyw1NC43eiBNNTIuMiw0OS4yYy0wLjYsMC0xLjMtMC4yLTEuNy0wLjdjLTEtMS0xLTIuNSwwLTMuNWMxLTEsMi42LTEsMy42LTAuMWMxLDEsMSwyLjUsMC4xLDMuNCAgbC0wLjEsMC4xQzUzLjUsNDksNTIuOCw0OS4yLDUyLjIsNDkuMnogTTU3LjcsNDMuN2MtMC42LDAtMS4zLTAuMi0xLjctMC43Yy0xLTEtMS0yLjUsMC0zLjVjMS0xLDIuNi0xLDMuNi0wLjFjMSwxLDEsMi41LDAuMSwzLjQgIEw1OS41LDQzQzU5LDQzLjUsNTguMyw0My43LDU3LjcsNDMuN3oiPjwvcGF0aD48cGF0aCBkPSJNOTEuMiw1SDY2LjVjLTEuNiwwLTIuOCwxLjMtMi44LDIuOHMxLjMsMi44LDIuOCwyLjhoMTguM0w2NSwzMC41Yy0xLjEsMS4xLTEuMSwyLjksMCw0ICBjMC42LDAuNiwxLjMsMC44LDIsMC44YzAuNywwLDEuNS0wLjMsMi0wLjhsMTkuMy0xOS4zdjE3LjNjMCwxLjYsMS4zLDIuOCwyLjgsMi44YzEuNiwwLDIuOC0xLjMsMi44LTIuOFY3LjhDOTQsNi4zLDkyLjcsNSw5MS4yLDV6ICAiPjwvcGF0aD48cGF0aCBkPSJNMzIuNSw4OC4zSDE0LjJMMzQsNjguNWMxLjEtMS4xLDEuMS0yLjksMC00Yy0xLjEtMS4xLTIuOS0xLjEtNCwwTDEwLjcsODMuOFY2Ni41YzAtMS42LTEuMy0yLjgtMi44LTIuOCAgUzUsNjQuOSw1LDY2LjV2MjQuN0M1LDkyLjcsNi4zLDk0LDcuOCw5NGgyNC43YzEuNiwwLDIuOC0xLjMsMi44LTIuOFMzNC4xLDg4LjMsMzIuNSw4OC4zeiI+PC9wYXRoPjwvc3ZnPg=="
  , ({event, position, originalPosition, midpoint}) ->
    {x:x1, y:y1} = originalPosition.subtract(midpoint)
    {x:x2, y:y2} = position.subtract(midpoint)

    xScale = x2 / x1
    yScale = y2 / y1

    if event.shiftKey
      yScale = xScale = (xScale + yScale) / 2

    return Matrix.scale(xScale, yScale, midpoint)

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
        if validTarget(e.target)
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
            i = (beginImageEdge + 1) % edgePath.length
            maskPath.push path[endPathIndex]

            while i != endImageEdge
              nextPathIndex = (i + 1) % edgePath.length
              start = edgePath[i]
              console.log start, i
              maskPath.push start

              i = nextPathIndex

            maskPath.push edgePath[i], path[beginPathIndex]

          clipMask(target, maskPath)

        return

  pan: do ->
    originalPosition = null
    originalMatrix = null

    name: "Pan"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTAwIDEwMCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBvbHlnb24gcG9pbnRzPSIyMi45MDMsNDUuNjg3IDE3LjQ2NCw0NS42ODcgMTcuNDY0LDM3LjYzMSA1LDUwLjA5OCAxNy40NjQsNjIuNTU4IDE3LjQ2NCw1NC40OTggMjIuOTAzLDU0LjQ5OCAiPjwvcG9seWdvbj48cG9seWdvbiBwb2ludHM9Ijc3LjA5Nyw1NC41MDQgODIuNTQzLDU0LjUwNCA4Mi41NDMsNjIuNTU4IDk1LDUwLjEwMSA4Mi41NDMsMzcuNjMxIDgyLjU0Myw0NS42OTQgNzcuMDk3LDQ1LjY5NCAiPjwvcG9seWdvbj48cG9seWdvbiBwb2ludHM9IjU0LjQwMywyNy41OTIgNTQuNDAzLDIyLjE1MyA2Mi40NjgsMjIuMTUzIDUwLjAwMyw5LjY4NSAzNy41MzksMjIuMTUzIDQ1LjU5MywyMi4xNTMgNDUuNTkzLDI3LjU5MiAiPjwvcG9seWdvbj48cG9seWdvbiBwb2ludHM9IjQ1LjU5Myw3Mi40MTkgNDUuNTkzLDc3Ljg1NiAzNy41MzksNzcuODU2IDUwLDkwLjMxNSA2Mi40NjgsNzcuODU2IDU0LjQwMyw3Ny44NTYgNTQuNDAzLDcyLjQxOSAiPjwvcG9seWdvbj48cGF0aCBkPSJNNjYuNzg2LDMxLjkxN0gzMy41NThjLTMuNDQ5LDAtNi4yNDgsMi43OTEtNi4yNDgsNi4yNDd2MjMuODYzYzAsMy40NTUsMi43OTksNi4yNSw2LjI0OCw2LjI1aDMzLjIyOCAgYzMuNDQ4LDAsNi4yNTEtMi43OTUsNi4yNTEtNi4yNVYzOC4xNjRDNzMuMDM3LDM0LjcwOCw3MC4yMzQsMzEuOTE3LDY2Ljc4NiwzMS45MTd6IE02Ni4zNDYsNjEuMjk0SDMzLjY1VjM4LjcxM2gzMi42OTVWNjEuMjk0eiI+PC9wYXRoPjxwb2x5Z29uIHBvaW50cz0iNTcuNDc5LDQ3Ljg5OSA1Mi4wOTcsNDcuODk5IDUyLjA5Nyw0Mi41MjEgNDcuOTAzLDQyLjUyMSA0Ny45MDMsNDcuODk5IDQyLjUyMSw0Ny44OTkgNDIuNTIxLDUyLjEgNDcuOTAzLDUyLjEgICA0Ny45MDMsNTcuNDc5IDUyLjA5Nyw1Ny40NzkgNTIuMDk3LDUyLjEgNTcuNDc5LDUyLjEgIj48L3BvbHlnb24+PC9zdmc+"
    mousedown: (e, editor) ->
      originalPosition = Point localPosition(e, false)
      originalMatrix = editor.scene.matrix

    mousemove: (e, editor) ->
      return unless originalPosition

      currentPosition = Point localPosition(e, false)
      delta = currentPosition.subtract originalPosition
      updateElement editor.scene, Matrix.translate(delta.x, delta.y).concat(originalMatrix)

    mouseup: ->
      originalPosition = null
  
  zoom: do ->
    originalPosition = null
    originalMatrix = null

    name: "Zoom"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTAwIDEwMCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggZD0iTTY2LjQsMzguNmMwLjUsMS4xLDAuNywyLjMsMC43LDMuNWMwLDAuNS0wLjIsMC45LTAuNSwxLjNjLTAuMywwLjMtMC44LDAuNS0xLjQsMC41Yy0wLjUsMC0wLjktMC4yLTEuMy0wLjUgIGMtMC4zLTAuNC0wLjUtMC44LTAuNS0xLjNjMC0xLjUtMC41LTIuOS0xLjYtMy45Yy0xLjEtMS4xLTIuNC0xLjYtMy45LTEuNmMtMC41LDAtMC45LTAuMi0xLjMtMC41Yy0wLjMtMC4zLTAuNS0wLjgtMC41LTEuMyAgYzAtMC41LDAuMi0xLDAuNS0xLjNjMC4zLTAuMywwLjgtMC41LDEuMy0wLjVjMS4zLDAsMi41LDAuMiwzLjYsMC43YzEuMSwwLjUsMi4xLDEuMSwyLjksMkM2NS4yLDM2LjUsNjUuOSwzNy40LDY2LjQsMzguNnogICBNNzcuMiwzNS44Yy0xLjMtMi45LTMtNS41LTUuMi03LjdjLTIuMi0yLjItNC44LTMuOS03LjctNS4yYy0yLjktMS4zLTYuMS0xLjktOS40LTEuOWMtMy4zLDAtNi40LDAuNi05LjQsMS45ICBjLTIuOSwxLjMtNS41LDMtNy43LDUuMmMtMi4yLDIuMi00LDQuOC01LjIsNy43Yy0xLjMsMi45LTEuOSw2LjEtMS45LDkuNGMwLDIuNCwwLjMsNC43LDEsN2MwLjcsMi4zLDEuNyw0LjQsMyw2LjNsLTEzLDEzLjEgIGMtMC40LDAuNC0wLjcsMS0wLjcsMS43YzAsMC40LDAuMiwwLjksMC43LDEuNmMwLjQsMC43LDEsMS4zLDEuNiwxLjljMC43LDAuNiwxLjMsMS4yLDEuOSwxLjZjMC42LDAuNSwxLjIsMC43LDEuNiwwLjcgIGMwLjcsMCwxLjMtMC4yLDEuNy0wLjdsMTMuMS0xM2MyLDEuMyw0LjEsMi4zLDYuNCwzYzIuMywwLjcsNC42LDEsNi45LDFjMy4zLDAsNi41LTAuNiw5LjQtMS45YzIuOS0xLjMsNS41LTMsNy43LTUuMiAgYzIuMi0yLjIsNC00LjgsNS4yLTcuN2MxLjMtMi45LDEuOS02LjEsMS45LTkuNEM3OSw0MS44LDc4LjQsMzguNyw3Ny4yLDM1Ljh6IE03Mi43LDUyLjhjLTEsMi4zLTIuNCw0LjQtNC4yLDYuMSAgYy0xLjcsMS43LTMuOCwzLjEtNi4yLDQuMWMtMi40LDEtNC45LDEuNS03LjUsMS41UzQ5LjcsNjQsNDcuMyw2M2MtMi40LTEtNC40LTIuNC02LjEtNC4xYy0xLjgtMS43LTMuMS0zLjgtNC4yLTYuMSAgYy0xLTIuMy0xLjYtNC45LTEuNi03LjZjMC0yLjcsMC41LTUuMSwxLjYtNy41YzEtMi40LDIuNC00LjQsNC4yLTYuMmMxLjctMS44LDMuOC0zLjEsNi4xLTQuMmMyLjMtMSw0LjgtMS41LDcuNS0xLjUgIHM1LjIsMC41LDcuNSwxLjVjMi40LDEsNC40LDIuNCw2LjIsNC4yYzEuNywxLjgsMy4xLDMuOCw0LjIsNi4yYzEsMi4zLDEuNiw0LjgsMS42LDcuNUM3NC4yLDQ3LjksNzMuNyw1MC40LDcyLjcsNTIuOHogTTk0LjEsODkuMyAgYzAtMS44LDAtMy41LDAtNC42bDAtMTIuM0w3Mi40LDk0LjFoMjEuN1Y4OS4zeiBNNS45LDcyLjR2MjEuN2gyMS43TDUuOSw3Mi40eiBNMjcuNiw1LjlINS45djIxLjdMMjcuNiw1Ljl6IE05NC4xLDUuOUg3Mi40ICBsMjEuNywyMS43TDk0LjEsNS45eiI+PC9wYXRoPjwvc3ZnPg=="
    mousedown: (e, editor) ->
      originalPosition = Point localPosition(e, false)
      originalMatrix = editor.scene.matrix

    mousemove: (e, editor) ->
      return unless originalPosition

      currentPosition = Point localPosition(e, false)
      delta = currentPosition.subtract originalPosition

      scale = 1 + (delta.x - delta.y) / (256 * originalMatrix.a)

      updateElement editor.scene, Matrix.scale(scale, scale, originalPosition).concat(originalMatrix)

    mouseup: ->
      originalPosition = null

clipMask = (target, maskPath) ->
  width = target.naturalWidth
  height = target.naturalHeight
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
  autocrop(c)
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
  autocrop(c)
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

getMidpoint = (target) ->
  width = target.naturalWidth
  height = target.naturalHeight

  target.matrix.transformPoint(Point(width/2, height/2))

drawCircle = (context, p) ->
  context.beginPath()
  context.arc(p.x, p.y, 5, 0, 2*Math.PI)
  context.fillStyle = "magenta"
  context.fill()

pathPoints = (target) ->
  width = target.naturalWidth
  height = target.naturalHeight

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

drawLine = (context, line, color="#8BF") ->
  context.beginPath()
  context.moveTo(line.start.x, line.start.y)
  context.lineTo(line.end.x, line.end.y)
  context.lineWidth = 2
  context.strokeStyle = color
  context.stroke()

drawRect = (context, target) ->
  rectLines(target)
  .forEach (line) ->
    drawLine context, line

angleBetween = (a, b, origin=Point.ZERO) ->
  Point.direction(origin, b) - Point.direction(origin, a)

validTarget = (target) ->
  ["IMG", "CANVAS"].indexOf(target.nodeName) >= 0
