msgs = document.getElementById 'messages'
messageTemplate = document.getElementById 'messageTemplate'
message = (vals) ->
  el = messageTemplate.cloneNode true
  el.style.display = 'initial'
  el.set = (k, v) ->
    e = el.querySelector(".#{k}")
    if typeof v is 'string'
      e.textContent = v
    else
      e.innerHTML = ''
      e.appendChild v
  for k,v of vals
    el.set k, v
  el

sharejs.open 'chat', 'json', (err, doc) ->
  window.doc = doc
  if doc.version is 0
    doc.submitOp [{p:[],od:null,oi:[]}], (err, appliedOp) ->
  else
    for m in doc.snapshot
      msgs.appendChild message m
  doc.on 'change', (op) ->
    for c in op
      if c.ld isnt undefined
        idx = c.p[0]
        msgs.children[idx].remove()
      if c.li isnt undefined
        idx = c.p[0]
        newMsg = message name:c.li.name, message: c.li.message
        msgs.insertBefore newMsg, msgs.children[idx]
      if c.si isnt undefined or c.sd isnt undefined
        # p is [0,'message',3]
        idx = c.p[0]
        msg = msgs.children[idx]
        msg.set 'name', doc.snapshot[idx].name
        return if msg.querySelector('textarea')
        msg.set 'message', doc.snapshot[idx].message
    return

  textareaWasEmpty = yes
  textarea = document.getElementsByTagName('textarea')[0]
  textarea.addEventListener 'keydown', keydown = (e) ->
    if e.keyCode is 13 and textarea.value.length
      e.preventDefault()
      textarea.detach_share()
      p = textarea.parentNode
      textarea.remove()
      p.textContent = textarea.value
      textarea.value = ''
      textareaWasEmpty = yes
      document.body.appendChild textarea
      textarea.focus()

  textarea.addEventListener 'input', oninput = (e) ->
    empty = @value.length is 0
    if textareaWasEmpty and not empty
      doc.submitOp [{p:[doc.snapshot.length],li:{message:@value,name:'you'}}]
      msgs.lastChild.set 'message', textarea
      textarea.focus()
      doc.at(doc.snapshot.length-1, 'message').attach_textarea textarea
      # began typing a message
    else if not textareaWasEmpty and empty
      # deleted everything
      asdf
    textareaWasEmpty = empty
