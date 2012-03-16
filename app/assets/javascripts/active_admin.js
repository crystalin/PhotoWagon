//= require active_admin/base
//= require jquery.Jcrop


$(function() {
    $('#cropbox').Jcrop({
        onChange: update_crop,
        onSelect: update_crop,
        setSelect: [0, 0, 1600, 896],
        addClass: 'jcrop-light',
        aspectRatio: 300/ 168
    });
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
//  $("#crop_x").val(Math.round(coords.x * ratio));
//  $("#crop_y").val(Math.round(coords.y * ratio));
//  $("#crop_w").val(Math.round(coords.w * ratio));
//  $("#crop_h").val(Math.round(coords.h * ratio));
}