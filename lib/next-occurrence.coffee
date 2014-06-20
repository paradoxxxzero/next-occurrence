module.exports =

  activate: (state) ->
    @matches = []
    atom.workspaceView.command "next-occurrence:next", =>
      @init()
      @next()

  init: ->
    @matches = []
    @editor = atom.workspace.getActivePaneItem()
    selection = @editor.getSelection().getText()
    unless selection
      selection = @editor.selectWord()[0].getText()
    return unless selection
    selection = selection.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
    @matches = []

    @editor.scan new RegExp(selection, 'g'), (o) =>
      @matches.push o

  after: (p1, p2) ->
    (p1.row is p2.row and
        p1.column >= p2.column or
        p1.row > p2.row)

  next: ->
    return unless @matches.length

    cursor = @editor.getCursorBufferPosition()
    if @after(cursor, @matches.slice(-1)[0].range.end)
      cursor =
        column: 0
        row: 0

    for match in @matches
      match = match.range
      if @after(match.start, cursor)
        @editor.setCursorBufferPosition([
          match.start.row,
          match.start.column
        ])
        @editor.addSelectionForBufferRange([[
          match.start.row,
          match.start.column
        ], [
          match.end.row,
          match.end.column
        ]])
        break
