{ View } = require 'atom'

module.exports =
  class MessageBubble extends View
    @content: (params) ->
      @div class:"inline-message #{params.klass}", style:params.style, =>
        for msg in params.messages
          @div class:"message-content",=>
            @div class:"message-source", =>
              @raw msg.src
            @div class:"message-body", =>
              @raw msg.content

    constructor:({editor, editorView, title, line, start, end, content, klass, min}) ->
      @title = title
      @line = line-1
      @start = start
      @end = end
      @content = content
      @klass = klass
      @editor = editor
      @editorView = editorView
      @messages = [{content:@content, src:@title}]
      style = @calculateStyle(@line,@start)
      super({messages:@messages,klass:@klass, style:style})

      if @min
        @minimize()

      editorView = atom.workspaceView.getActiveView()
      pageData = editorView.find(".overlayer")
      if pageData
        pageData.first().prepend(this)

    calculateStyle:(line, start) ->
      if @editorView and @editor
        last = @editor.getBuffer().lineLengthForRow(line)
        fstPos = @editorView.pixelPositionForBufferPosition({row:line+1,column:0})
        lastPos = @editorView.pixelPositionForBufferPosition({row:line, column:start})
        top = fstPos.top
        left = lastPos.left
        # if left < 640
          # left = 640
        # left = left + 25
        return "position:absolute;left:#{left}px;top:#{top}px;"

    update: () ->
      lastSrc = null
      this.find(".message-content").remove()
      msgs = ""
      for msg in @messages
        # if msg.src == lastSrc
        #   body = "<div class='message-body'>#{msg.content}</div>"
        #   content = "<div class='message-content'>#{body}</div>"
        # else
        src = "<div class='message-source'>#{msg.src}</div>"
        body = "<div class='message-body'>#{msg.content}</div>"
        content = "<div class='message-content'>#{src}#{body}</div>"
        lastSrc = msg.src
        msgs = msgs + content
      this.append msgs

    add: (title, content) ->
      @messages.push({content:content, src:title})
      @update()
