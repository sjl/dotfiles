$(function() {
    if ($('li.commit').length) {

        $('ul.pagehead-actions').prepend('<li><a class="minibutton btn-watch" href="#reviewing" id="toggle-merges-button"><span><span class="icon"></span><span class="text">Review</span></span></a></li>');

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
                if (t === 'Updated transifex translations -- through update_translations.sh') {
                    $(this).hide();
                    return;
                }
                if ($(this).find('span.author-name').text() === 'sjl') {
                    $(this).hide();
                    return;
                }
            });
            $('span.text', this).text('Stop reviewing');
            $('a#toggle-merges-button').attr('href', '#');

            window.location.hash = '#reviewing';

            return false;
        }, function() {
            $('li.commit').show();
            $('span.text', this).text('Review');

            window.location.hash = '';

            return false;
        });
    }

    if (window.location.hash === '#reviewing') {
        $('a#toggle-merges-button').click();
    }

    if ($('.view-pull-request').length) {
        var url = $('table.commits tr.commit .commit-meta a').attr('href');
        var parts = url.split('/');
        var repo = 'git://github.com/' + parts[1] + '/' + parts[2] + '.git';
        $('#pull-head').append('<textarea id="goddamned-repo-url">' + repo + '</textarea>');
        $('#goddamned-repo-url').css('width', '897px')
                                .css('height', '20px')
                                .css('border', '1px solid #ccc')
                                .css('padding', '5px 0px 3px 4px')
                                .css('margin', '3px 0px 5px 8px')
                                .css('font-size', '18px')
                                .css('color', '#555')
                                .css('border-radius', '3px');
    }
});
