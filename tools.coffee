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

      if state.activeElement
        target = state.activeElement
      else
        target = e.target

      hoverHighlight(target, editor)

      return unless state.activeElement

      extend state,
        event: e
        position: viewMatrix.transformPoint localPosition(e, false)

      transformation = handler(state)

      finalMatrix = transformation.concat(state.originalMatrix).quantize()
      updateElement state.activeElement, finalMatrix

      editor.unsaved(true)

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

  raise:
    name: "Raise"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgNjAgNjAiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDYwIDYwIiB4bWw6c3BhY2U9InByZXNlcnZlIj48cGF0aCBmaWxsPSIjMDAwMDAwIiBkPSJNNTksMzljMC41NSwwLDEtMC40NSwxLTFWMjRjMC0wLjU1LTAuNDUtMS0xLTFIMzh2LTVoOGMwLDAsMC4wMSwwLDAuMDEsMGMwLjYsMC4wMiwxLjAxLTAuNDQsMS4wMS0xICBjMC0wLjM0LTAuMTctMC42My0wLjQyLTAuODJMMzAuNzEsMC4yOWMtMC4zOS0wLjM5LTEuMDItMC4zOS0xLjQxLDBsLTE2LDE2Yy0wLjI5LDAuMjktMC4zNywwLjcyLTAuMjIsMS4wOVMxMy42LDE4LDE0LDE4aDh2NUgxICBjLTAuNTUsMC0xLDAuNDUtMSwxdjE0YzAsMC41NSwwLjQ1LDEsMSwxaDIxdjVIMWMtMC41NSwwLTEsMC40NS0xLDF2MTRjMCwwLjU1LDAuNDUsMSwxLDFoNThjMC41NSwwLDEtMC40NSwxLTFWNDUgIGMwLTAuNTUtMC40NS0xLTEtMUgzOHYtNUg1OXogTTU4LDI1djEySDM4VjI1SDU4eiBNMiwzN1YyNWgyMHYxMkgyeiBNNTgsNDZ2MTJIMlY0NmgyMWMwLjU1LDAsMS0wLjQ1LDEtMXYtN1YyNHYtNyAgYzAtMC41NS0wLjQ1LTEtMS0xaC02LjU5TDMwLDIuNDFMNDMuNTksMTZIMzdjLTAuNTUsMC0xLDAuNDUtMSwxdjd2MTR2N2MwLDAuNTUsMC40NSwxLDEsMUg1OHoiPjwvcGF0aD48L3N2Zz4="
    mousedown: (e, editor) ->
      return unless validTarget(e.target)

      target = e.target

      editor.unsaved(true)

      if e.shiftKey # To the top
        target.parentNode.appendChild target
      else # Up one
        referenceNode = target.nextSibling?.nextSibling

        if referenceNode
          target.parentNode.insertBefore target, referenceNode
        else
          target.parentNode.appendChild target

    mousemove: (e, editor) ->
      hoverHighlight(e.target, editor)

    mouseup: ->

  lower:
    name: "Lower"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgNjAgNjAiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDYwIDYwIiB4bWw6c3BhY2U9InByZXNlcnZlIj48cGF0aCBmaWxsPSIjMDAwMDAwIiBkPSJNNTksMTZjMC41NSwwLDEtMC40NSwxLTFWMWMwLTAuNTUtMC40NS0xLTEtMUgxQzAuNDUsMCwwLDAuNDUsMCwxdjE0YzAsMC41NSwwLjQ1LDEsMSwxaDIxdjVIMSAgYy0wLjU1LDAtMSwwLjQ1LTEsMXYxNGMwLDAuNTUsMC40NSwxLDEsMWgyMXY1aC04Yy0wLjQsMC0wLjc3LDAuMjQtMC45MiwwLjYycy0wLjA3LDAuOCwwLjIyLDEuMDlsMTYsMTZDMjkuNDksNTkuOSwyOS43NCw2MCwzMCw2MCAgczAuNTEtMC4xLDAuNzEtMC4yOWwxNi0xNmMwLjI5LTAuMjksMC4zNy0wLjcyLDAuMjItMS4wOVM0Ni40LDQyLDQ2LDQyaC04di01aDIxYzAuNTUsMCwxLTAuNDUsMS0xVjIyYzAtMC41NS0wLjQ1LTEtMS0xSDM4di01SDU5eiAgIE0zNyw0NGg2LjU5TDMwLDU3LjU5TDE2LjQxLDQ0SDIzYzAuNTUsMCwxLTAuNDUsMS0xdi02aDEydjZDMzYsNDMuNTUsMzYuNDUsNDQsMzcsNDR6IE01OCwzNUgzN0gyM0gyVjIzaDIxaDE0aDIxVjM1eiBNMjQsMjF2LTYgIGMwLTAuNTUtMC40NS0xLTEtMUgyVjJoNTZ2MTJIMzdjLTAuNTUsMC0xLDAuNDUtMSwxdjZIMjR6Ij48L3BhdGg+PC9zdmc+"
    mousedown: (e, editor) ->
      return unless validTarget(e.target)

      target = e.target

      editor.unsaved(true)

      if e.shiftKey # To the bottom
        referenceNode = target.parentNode.firstChild
        target.parentNode.insertBefore target, referenceNode
      else # Down one
        referenceNode = target.previousSibling
  
        if referenceNode
          target.parentNode.insertBefore target, referenceNode

    mousemove: (e, editor) ->
      hoverHighlight(e.target, editor)

    mouseup: ->

  text: do ->
    name: "Text"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMjQgMjQiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDI0IDI0OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PGc+PHBhdGggZD0iTTE1LjUyLDIwYy0wLjAwNSwwLjAwMS0wLjAxMywwLTAuMDIsMGgtN0M4LjIyNCwyMCw4LDE5Ljc3Niw4LDE5LjVTOC4yMjQsMTksOC41LDE5YzAuODI3LDAsMS41LTAuNjczLDEuNS0xLjVWOEg2LjUgICBDNS42NzMsOCw1LDguNjczLDUsOS41QzUsOS43NzYsNC43NzYsMTAsNC41LDEwUzQsOS43NzYsNCw5LjV2LTVDNCw0LjIyNCw0LjIyNCw0LDQuNSw0aDE1QzE5Ljc3Niw0LDIwLDQuMjI0LDIwLDQuNXY1ICAgYzAsMC4yNzYtMC4yMjQsMC41LTAuNSwwLjVTMTksOS43NzYsMTksOS41QzE5LDguNjczLDE4LjMyNyw4LDE3LjUsOEgxNHY5LjVjMCwwLjgyNywwLjY3MywxLjUsMS41LDEuNWMwLjAwNCwwLDAuMDA4LDAsMC4wMSwwICAgaDAuMDFjMC4yNzYsMCwwLjUsMC4yMjQsMC41LDAuNVMxNS43OTYsMjAsMTUuNTIsMjB6IE0xMC40OTksMTloMy4wMDJDMTMuMTg3LDE4LjU4MiwxMywxOC4wNjMsMTMsMTcuNXYtMTAgICBDMTMsNy4yMjQsMTMuMjI0LDcsMTMuNSw3aDRjMC41NjMsMCwxLjA4MiwwLjE4NywxLjUsMC41MDFWNUg1djIuNTAxQzUuNDE4LDcuMTg3LDUuOTM4LDcsNi41LDdoNEMxMC43NzYsNywxMSw3LjIyNCwxMSw3LjV2MTAgICBDMTEsMTguMDYzLDEwLjgxMywxOC41ODIsMTAuNDk5LDE5eiI+PC9wYXRoPjxwYXRoIGQ9Ik03LjUsMmgtMkM1LjIyNCwyLDUsMS43NzYsNSwxLjVTNS4yMjQsMSw1LjUsMWgyQzcuNzc2LDEsOCwxLjIyNCw4LDEuNVM3Ljc3NiwyLDcuNSwyeiI+PC9wYXRoPjxwYXRoIGQ9Ik0xMywyaC0yYy0wLjI3NiwwLTAuNS0wLjIyNC0wLjUtMC41UzEwLjcyNCwxLDExLDFoMmMwLjI3NiwwLDAuNSwwLjIyNCwwLjUsMC41UzEzLjI3NiwyLDEzLDJ6Ij48L3BhdGg+PHBhdGggZD0iTTE4LjUsMmgtMkMxNi4yMjQsMiwxNiwxLjc3NiwxNiwxLjVTMTYuMjI0LDEsMTYuNSwxaDJDMTguNzc2LDEsMTksMS4yMjQsMTksMS41UzE4Ljc3NiwyLDE4LjUsMnoiPjwvcGF0aD48cGF0aCBkPSJNNy41LDIzaC0yQzUuMjI0LDIzLDUsMjIuNzc2LDUsMjIuNVM1LjIyNCwyMiw1LjUsMjJoMkM3Ljc3NiwyMiw4LDIyLjIyNCw4LDIyLjVTNy43NzYsMjMsNy41LDIzeiI+PC9wYXRoPjxwYXRoIGQ9Ik0xMywyM2gtMmMtMC4yNzYsMC0wLjUtMC4yMjQtMC41LTAuNVMxMC43MjQsMjIsMTEsMjJoMmMwLjI3NiwwLDAuNSwwLjIyNCwwLjUsMC41UzEzLjI3NiwyMywxMywyM3oiPjwvcGF0aD48cGF0aCBkPSJNMTguNSwyM2gtMmMtMC4yNzYsMC0wLjUtMC4yMjQtMC41LTAuNXMwLjIyNC0wLjUsMC41LTAuNWgyYzAuMjc2LDAsMC41LDAuMjI0LDAuNSwwLjVTMTguNzc2LDIzLDE4LjUsMjN6Ij48L3BhdGg+PHBhdGggZD0iTTEuNSwxOUMxLjIyNCwxOSwxLDE4Ljc3NiwxLDE4LjV2LTJDMSwxNi4yMjQsMS4yMjQsMTYsMS41LDE2UzIsMTYuMjI0LDIsMTYuNXYyQzIsMTguNzc2LDEuNzc2LDE5LDEuNSwxOXoiPjwvcGF0aD48cGF0aCBkPSJNMS41LDEzLjVDMS4yMjQsMTMuNSwxLDEzLjI3NiwxLDEzdi0yYzAtMC4yNzYsMC4yMjQtMC41LDAuNS0wLjVTMiwxMC43MjQsMiwxMXYyQzIsMTMuMjc2LDEuNzc2LDEzLjUsMS41LDEzLjV6Ij48L3BhdGg+PHBhdGggZD0iTTEuNSw4QzEuMjI0LDgsMSw3Ljc3NiwxLDcuNXYtMkMxLDUuMjI0LDEuMjI0LDUsMS41LDVTMiw1LjIyNCwyLDUuNXYyQzIsNy43NzYsMS43NzYsOCwxLjUsOHoiPjwvcGF0aD48cGF0aCBkPSJNMjIuNSwxOWMtMC4yNzYsMC0wLjUtMC4yMjQtMC41LTAuNXYtMmMwLTAuMjc2LDAuMjI0LTAuNSwwLjUtMC41czAuNSwwLjIyNCwwLjUsMC41djJDMjMsMTguNzc2LDIyLjc3NiwxOSwyMi41LDE5eiI+PC9wYXRoPjxwYXRoIGQ9Ik0yMi41LDEzLjVjLTAuMjc2LDAtMC41LTAuMjI0LTAuNS0wLjV2LTJjMC0wLjI3NiwwLjIyNC0wLjUsMC41LTAuNVMyMywxMC43MjQsMjMsMTF2MkMyMywxMy4yNzYsMjIuNzc2LDEzLjUsMjIuNSwxMy41eiI+PC9wYXRoPjxwYXRoIGQ9Ik0yMi41LDhDMjIuMjI0LDgsMjIsNy43NzYsMjIsNy41di0yQzIyLDUuMjI0LDIyLjIyNCw1LDIyLjUsNVMyMyw1LjIyNCwyMyw1LjV2MkMyMyw3Ljc3NiwyMi43NzYsOCwyMi41LDh6Ij48L3BhdGg+PHBhdGggZD0iTTIzLjUsM2gtMkMyMS4yMjQsMywyMSwyLjc3NiwyMSwyLjV2LTJDMjEsMC4yMjQsMjEuMjI0LDAsMjEuNSwwaDJDMjMuNzc2LDAsMjQsMC4yMjQsMjQsMC41djJDMjQsMi43NzYsMjMuNzc2LDMsMjMuNSwzeiAgICBNMjIsMmgxVjFoLTFWMnoiPjwvcGF0aD48cGF0aCBkPSJNMi41LDNoLTJDMC4yMjQsMywwLDIuNzc2LDAsMi41di0yQzAsMC4yMjQsMC4yMjQsMCwwLjUsMGgyQzIuNzc2LDAsMywwLjIyNCwzLDAuNXYyQzMsMi43NzYsMi43NzYsMywyLjUsM3ogTTEsMmgxVjFIMVYyICAgeiI+PC9wYXRoPjxwYXRoIGQ9Ik0yMy41LDI0aC0yYy0wLjI3NiwwLTAuNS0wLjIyNC0wLjUtMC41di0yYzAtMC4yNzYsMC4yMjQtMC41LDAuNS0wLjVoMmMwLjI3NiwwLDAuNSwwLjIyNCwwLjUsMC41djIgICBDMjQsMjMuNzc2LDIzLjc3NiwyNCwyMy41LDI0eiBNMjIsMjNoMXYtMWgtMVYyM3oiPjwvcGF0aD48cGF0aCBkPSJNMi41LDI0aC0yQzAuMjI0LDI0LDAsMjMuNzc2LDAsMjMuNXYtMkMwLDIxLjIyNCwwLjIyNCwyMSwwLjUsMjFoMkMyLjc3NiwyMSwzLDIxLjIyNCwzLDIxLjV2MkMzLDIzLjc3NiwyLjc3NiwyNCwyLjUsMjR6ICAgIE0xLDIzaDF2LTFIMVYyM3oiPjwvcGF0aD48L2c+PC9zdmc+"
    mousedown: (e, editor) ->
      position = editor.scene.matrix.inverse().transformPoint localPosition(e, false)
      text = prompt "Text", "yolo!"

      canvas = document.createElement "canvas"
      context = canvas.getContext('2d')

      context.font = "24pt Impact"
      canvas.width = context.measureText(text).width
      canvas.height = 48

      context.font = "24pt Impact"
      context.textBaseline = "top"
      context.fillText(text, 0, 0)

      editor.addItem canvas, Matrix.translate(position.x, position.y)

    mousemove: (e, editor) ->
    mouseup: (e, editor) ->

  trash:
    name: "Delete"
    iconURL: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIHg9IjBweCIgeT0iMHB4IiB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTAwIDEwMCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggZD0iTTMwLjEzNSw3NS4yMDZjMCwxLjk4OCwxLjYxNywzLjU5OSwzLjYxMSwzLjU5OWgzMi41MDhjMi4wMDIsMCwzLjYxOC0xLjYxLDMuNjE4LTMuNTk5VjM4LjE2NEgzMC4xMzVWNzUuMjA2eiAgIE01OC43OTgsNDEuNzMzaDUuNnYyOS45NTVjMCwxLjU0Ni0xLjI1NiwyLjc5Ni0yLjc5NSwyLjc5NmMtMS41NDksMC0yLjgwNC0xLjI1LTIuODA0LTIuNzk2VjQxLjczM3ogTTQ3LjIwNCw0MS43MzNoNS42MDR2MjkuOTU1ICBjMCwxLjU0Ni0xLjI1NCwyLjc5Ni0yLjgwMiwyLjc5NnMtMi44MDItMS4yNS0yLjgwMi0yLjc5NlY0MS43MzN6IE0zNS41MjcsNDEuNzMzaDUuNTk2djI5Ljk1NWMwLDEuNTQ2LTEuMjU1LDIuNzk2LTIuNzk4LDIuNzk2ICBzLTIuNzk3LTEuMjUtMi43OTctMi43OTZWNDEuNzMzeiI+PC9wYXRoPjxwYXRoIGQ9Ik02OS44NjQsMjUuMDQ2SDU1LjY4M3YtMi4wNTJjMCwwLTAuMDY0LTEuNzk5LTEuODctMS43OTloLTcuNzQ1Yy0xLjgwNCwwLTEuNzQyLDEuNzk5LTEuNzQyLDEuNzk5djIuMDUyaC0xNC4xOSAgYy0xLjk5MywwLTMuNjEyLDEuNjEzLTMuNjEyLDMuNjAxdjUuOTE5aDQ2Ljk1NHYtNS45MTlDNzMuNDc3LDI2LjY1OSw3MS44NTksMjUuMDQ2LDY5Ljg2NCwyNS4wNDZ6Ij48L3BhdGg+PC9zdmc+"
    mousedown: (e, editor) ->
      return unless validTarget(e.target)

      editor.unsaved(true)

      e.target.remove()
      clearScreen(editor)

    mousemove: (e, editor) ->
      hoverHighlight(e.target, editor)
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
      viewMatrix = editor.scene.matrix.inverse()

      active = true
      targetMap = new Map
      canvas = editor.screenElement
      context = canvas.getContext('2d')

      path = [viewMatrix.transformPoint localPosition(e, false)]

    mousemove: (e, editor) ->
      viewMatrix = editor.scene.matrix.inverse()
      target = e.target

      if active
        # TODO: Should add all targets underneath this point, not just the top
        if validTarget(e.target)
          unless targetMap.has target
            targetMap.set target, []

            drawRect(context, target, editor.scene.matrix)

        prev = path[path.length - 1]
        current = viewMatrix.transformPoint localPosition(e, false)

        line = Line
          start: prev
          end: current

        drawLine context, line, "purple", editor.scene.matrix

        targetMap.forEach (intersections, target) ->
          rectLines(target).forEach (targetLine, i) ->
            intersection = line.intersects(targetLine)

            if intersection
              drawCircle context, intersection, editor.scene.matrix

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

      editor.unsaved true

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

drawCircle = (context, p, transform=Matrix.IDENTITY) ->
  p = transform.transformPoint(p)
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

drawLine = (context, line, color="#8BF", transform=Matrix.IDENTITY) ->
  p1 = transform.transformPoint(line.start)
  p2 = transform.transformPoint(line.end)

  context.beginPath()
  context.moveTo(p1.x, p1.y)
  context.lineTo(p2.x, p2.y)
  context.lineWidth = 2
  context.strokeStyle = color
  context.stroke()

drawRect = (context, target, transform=Matrix.IDENTITY) ->
  rectLines(target)
  .forEach (line) ->
    drawLine context, line, null, transform

clearScreen = (editor) ->
  screen = editor.screenElement
  context = editor.overlayContext()
  context.clearRect(0, 0, screen.width, screen.height)

hoverHighlight = (target, editor) ->
  # Highlight Target Element
  screen = editor.screenElement
  context = editor.overlayContext()
  context.clearRect(0, 0, screen.width, screen.height)

  if validTarget(target)
    drawRect(context, target, editor.scene.matrix)

angleBetween = (a, b, origin=Point.ZERO) ->
  Point.direction(origin, b) - Point.direction(origin, a)

validTarget = (target) ->
  ["IMG", "CANVAS"].indexOf(target.nodeName) >= 0
