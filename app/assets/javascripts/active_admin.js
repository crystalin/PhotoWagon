//= require active_admin/base
//= require jquery.Jcrop


$(function() {
    img = new Image();
    img.onload  = function() {
        var x = parseInt($("#post_crop_cover_x").val());
        var y = parseInt($("#post_crop_cover_y").val());
        var w = parseInt($("#post_crop_cover_w").val());
        var h = parseInt($("#post_crop_cover_h").val());
        var x2 = x + w;
        var y2 = y + h;
        $('#cropbox').Jcrop({
            onChange: update_crop,
            onSelect: update_crop,
            setSelect: [x, y, x2, y2],
            addClass: 'jcrop-light',
            aspectRatio: 300/ 168 ,
            boxWidth: 600, boxHeight: 400
        });


    };
    img.src = $('#cropbox').attr('src');

});

function update_crop(coords) {
    var rx = 300/coords.w;
    var ry = 168/coords.h;
    var lw = $('#cropbox').width();
    var lh = $('#cropbox').height();
    var ratio = 300.0 / lw ;

    $('.preview img').css({
      width: Math.round(rx * lw) + 'px',
      height: Math.round(ry * lh) + 'px',
      marginLeft: '-' + Math.round(rx * coords.x) + 'px',
      marginTop: '-' + Math.round(ry * coords.y) + 'px'
    });
    console.log(coords);
    $("#post_crop_cover_x").val(Math.round(coords.x));
    $("#post_crop_cover_y").val(Math.round(coords.y));
    $("#post_crop_cover_w").val(Math.round(coords.w));
    $("#post_crop_cover_h").val(Math.round(coords.h));
}