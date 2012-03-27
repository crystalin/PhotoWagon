//= require active_admin/base
//= require jquery.Jcrop

function init_crop(picasa_post)  {

    var cropbox = picasa_post.find('.cropbox');
    var img = cropbox.get(0);
    var inputX = picasa_post.find('.crop_x');
    var inputY = picasa_post.find('.crop_y');
    var inputW = picasa_post.find('.crop_w');
    var inputH = picasa_post.find('.crop_h');
    var canvas = picasa_post.find('canvas');

    if (inputX.val() == -1) {
        var ratio =  canvas.width() / canvas.height();
        inputX.val(0);
        inputY.val(Math.round((img.height - img.width / ratio)/2));
        inputW.val(img.width);
        inputH.val(Math.round(img.width / ratio));
    }
//    $('.debug').append([inputX.val(), inputY.val(), inputW.val(), inputH.val()].join(', ') + '<br />');

    var ctx = canvas.get(0).getContext('2d');

    var x = parseInt(inputX.val());
    var y = parseInt(inputY.val());
    var w = parseInt(inputW.val());
    var h = parseInt(inputH.val());

    var x2 = x + w;
    var y2 = y + h;
    cropbox.Jcrop({
        onChange: function(coords){update_crop(canvas, ctx, img, inputX, inputY, inputW, inputH, coords)},
        onSelect: function(coords){update_crop(canvas, ctx, img, inputX, inputY, inputW, inputH, coords)},
        setSelect: [x, y, x2, y2],
        addClass: 'jcrop-light',
        aspectRatio: canvas.width() / canvas.height() ,
        boxWidth: 300, boxHeight: 300,
        keySupport: false
    });
}

$(document).ready(function() {

//    $('form#session_new').bind('ajax:complete', function(e, data, status, xhr) {
//        console.log(data);
//        if(data.success()) {
//            $('#user_login_box').html(data);
//            $('#login').hide();
//        } else {
//            $('#user_login_box').prepend(data.errors.join('<br />'));
//        }
//    });

});

$(function() {
    $('.picasa_post_front, .picasa_post_cover').each(function() {
        var picasa_post = $(this);
        var cropbox = picasa_post.find('.cropbox');
        var img = cropbox.get(0);
        if (img.complete) {
            init_crop(picasa_post);
        }  else {
            img.onload = function() {init_crop(picasa_post);};
        }
    });

});

function update_crop(canvas, ctx, img, inputX, inputY, inputW, inputH, coords) {
    if (coords.w > 0 && coords.h) {
      ctx.drawImage(img, coords.x, coords.y, coords.w, coords.h, 0, 0, canvas.width(), canvas.height());
    }

    inputX.val(Math.round(coords.x));
    inputY.val(Math.round(coords.y));
    inputW.val(Math.round(coords.w));
    inputH.val(Math.round(coords.h));
//    $('.debug').append([inputX.val(), inputY.val(), inputW.val(), inputH.val()].join(', ') + '<br />');
}