$(function() {
    $('ul.state li.priority').each(function(idx, el) {
        $(el).closest('.issue').find('h2').append(
            '<span class="new-priority">' + $(el).text() + '</span>');
        $(el).remove();
    });

    $('div.comment').each(function (idx, el) {
        var id = $(el).attr('id');
        var link = '<a href="#' + id + '">permalink</a>';
        $(el).find('.timestamp').append(link);
    });
});

