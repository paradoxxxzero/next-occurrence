module.exports =

  activate: (state) ->

    @matches = []
    atom.workspaceView.command "next-occurrence:next", =>
      @init()
      @next()
    atom.workspaceView.command "next-occurrence:prev", =>
      @init()
      @prev()

  init: ->
    @matches = []
    @editor = atom.workspace.getActivePaneItem()
    selection = @editor.getSelection().getText()
    unless selection
      selection = @editor.selectWord()[0].getText()
    return unless selection
    selection = selection.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
    @matches = []
    @editor.scan new RegExp(selection, 'g'), (o) => @matches.push o

  beep: ->
    atom.workspaceView.trigger 'beep'

  after: (p1, p2, strict=true) ->
    (p1.row is p2.row and
      (if strict then p1.column > p2.column else p1.column >= p2.column) or
      p1.row > p2.row)

  next: ->
    cursor = @editor.getCursorBufferPosition()
    if @after cursor, @matches.slice(-1)[0].range.start, false
      cursor =
        column: 0
        row: 0
      @beep()
    @lookup cursor, 1

  prev: ->
    cursor = @editor.getCursorBufferPosition()
    if @after @matches[0].range.end, cursor, false
      cursor = @editor.getEofBufferPosition()
      @beep()
    @lookup cursor, -1

  lookup: (cursor, step)->
    return unless @matches.length

    for match in @matches by step
      match = match.range
      if (step is 1 and @after(match.start, cursor)) or (
        step is -1 and @after(cursor, match.end))

        @editor.setCursorBufferPosition [
          match.start.row,
          match.start.column
        ]
        @editor.addSelectionForBufferRange [[
          match.start.row,
          match.start.column
        ], [
          match.end.row,
          match.end.column
        ]]
        break
