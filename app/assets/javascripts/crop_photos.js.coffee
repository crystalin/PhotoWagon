window.show_photo_popup = ->
  windowWidth = document.documentElement.clientWidth
  windowHeight = document.documentElement.clientHeight
  popupHeight = $("#new_photo_popup").height()
  popupWidth = $("#new_photo_popup").width()

  $("#new_photo_popup").css {
    "position": "absolute"
    "top": windowHeight/2-popupHeight/2
    "left": windowWidth/2-popupWidth/2
  }
  $("#new_photo_popup").fadeIn()
  $("#background_popup").fadeIn()

window.hide_photo_popup = ->
  $("#new_photo_popup").fadeOut()
  $("#background_popup").fadeOut()

jQuery ->
  $(".button_photo").click ->
    show_photo_popup()
    false
  $(".button_close_photo").click ->
    hide_photo_popup()
    false
  $("#background_popup").click ->
    hide_photo_popup()


jQuery ->
  $.extend $.fn.disableTextSelect = ->
    return this.each ->
      if $.browser.mozilla
        $(this).css 'MozUserSelect','none'
      else if $.browser.msie
        $(this).bind 'selectstart', -> return false
      else
      $(this).mousedown -> return false

  $('.crop_canvas')
  .each (index, element) ->
    canvas = element
    image = new Image()
    ctx = canvas.getContext '2d'

    $(this).disableTextSelect()


    #alert element.innerHTML
    $(image).load ->
      ratio_x = this.width / ctx.canvas.width
      ratio_y = this.height / ctx.canvas.height

      canvas.dragging = false
      canvas.imgRatio = Math.min(ratio_x, ratio_y)
      canvas.imgX = 0
      canvas.imgY = 0
      canvas.imgZoom = 1
      canvas.imgW = this.width
      canvas.imgH = this.height
      canvas.imgFrameW = 300 * ratio_x / canvas.imgRatio
      canvas.imgFrameH = 168 * ratio_y / canvas.imgRatio



      ctx.drawImage this, 0, 0, canvas.imgW, canvas.imgH, canvas.imgX, canvas.imgY, canvas.imgFrameW, canvas.imgFrameH

      $(canvas)
      .click (event) ->
        this.dragging = !this.dragging
        this.mouseX = event.pageX
        this.mouseY = event.pageY
      .mousemove (event) ->
        if this.dragging == true
          this.imgX = this.imgX- (this.mouseX - event.pageX)
          this.mouseX = event.pageX
          this.imgY = this.imgY- (this.mouseY - event.pageY)
          this.mouseY = event.pageY

          canvas.imgX = Math.min(Math.max(300 - canvas.imgFrameW * canvas.imgZoom, canvas.imgX), 0)
          canvas.imgY = Math.min(Math.max(168 - canvas.imgFrameH * canvas.imgZoom, canvas.imgY), 0)
          ctx.drawImage image, 0, 0, canvas.imgW, canvas.imgH, canvas.imgX, canvas.imgY, canvas.imgFrameW * canvas.imgZoom, canvas.imgFrameH * canvas.imgZoom

      .dblclick (event) ->
        canvas.imgZoom += 0.2
        if canvas.imgZoom > 3
          canvas.imgZoom = 1
        ctx.drawImage image, 0, 0, canvas.imgW, canvas.imgH, canvas.imgX, canvas.imgY, canvas.imgFrameW * canvas.imgZoom, canvas.imgFrameH * canvas.imgZoom

        event.cancelBubble = true
        if event.stopPropagation
          event.stopPropagation()


    image.src =  element.innerHTML
    ctx.fillStyle = 'rgba(200, 200, 200, 0.5)';
    ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)
