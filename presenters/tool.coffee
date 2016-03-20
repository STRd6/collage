ToolTemplate = require "../templates/tool"

module.exports = (tool, editor) ->
  ToolTemplate
    click: ->
      editor.activeTool tool
  
    style: ->
      "background-image: url(#{tool.iconURL})"

    title: ->
      tool.name

    active: ->
      "active" if editor.activeTool() is tool
