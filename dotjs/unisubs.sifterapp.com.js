$(function() {
    $('ul.state li.priority').each(function(idx, el) {
        $(el).closest('.issue').find('h2').append(
            '<span class="new-priority">' + $(el).text() + '</span>'
        );
        $(el).remove();
    });
});
