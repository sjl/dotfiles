$(function() {
    var i = $("img#mainphoto.clickable").attr("src");

    $('body').append("<img width=40 height=40 id='fucking-let-me-drag-you-assholes' src='" + i + "'>");

    $('#fucking-let-me-drag-you-assholes').css('position', 'absolute').css('top', '40px').css('left', '40px');

});
