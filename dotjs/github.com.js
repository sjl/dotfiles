$(function() {
    if ($('body').hasClass('page-commits')) {

        $('ul.pagehead-actions').prepend('<li><a class="minibutton btn-watch" href="#" id="toggle-merges-button"><span><span class="icon"></span><span class="text">Review</span></span></a></li>');

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
            $('span.text', this).text('Stop reviewing');
        }, function() {
            $('li.commit').show();
            $('span.text', this).text('Review');
        });
    }
});
