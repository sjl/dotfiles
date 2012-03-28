$(function() {
    $('.site').prepend('<button id="toggle-merges-button">Review</button>');
    $('#toggle-merges-button').css('position', 'absolute').css('top', '10px').css('left', '10px');

    $('#toggle-merges-button').toggle(function() {
        $('li.commit').each(function() {
            var t = $(this).find('a.message').text().substring(0, 5);
            if (t === 'Merge' || t === 'merge') {
                $(this).hide();
                return;
            }
            t = $(this).find('a.message').text().substring(0, 24);
            if (t === 'Updated integration repo' || t === 'updated integration repo') {
                $(this).hide();
                return;
            }
            t = $(this).find('a.message').text().substring(0, 23);
            if (t === 'Update integration repo' || t === 'update integration repo') {
                $(this).hide();
                return;
            }
            t = $(this).find('a.message').text().substring(0, 26);
            if (t === 'Update unisubs-integration' || t === 'update unisubs-integration') {
                $(this).hide();
                return;
            }
            t = $(this).find('a.message').text().substring(0, 65);
            if (t === 'Updated transiflex translations -- through update_translations.sh') {
                $(this).hide();
                return;
            }
            if ($(this).find('span.author-name').text() === 'sjl') {
                $(this).hide();
                return;
            }
        });
    }, function() {
        $('li.commit').show();
    });
});
