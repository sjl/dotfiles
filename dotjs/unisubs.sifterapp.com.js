$(function() {
    $('ul.state li.priority').each(function(idx, el) {
        $(el).closest('.issue').find('h2').append(
            '<span class="new-priority">' + $(el).text() + '</span>'
        );
        $(el).remove();
    });

    $('body').keydown(function(e) {

        $tickets = $('tr.issue td.subject a');

        cmds = {
            '49': function() {
                document.location = $tickets.eq(0).attr('href');
            },
            '50': function() {
                document.location = $tickets.eq(1).attr('href');
            },
            '51': function() {
                document.location = $tickets.eq(2).attr('href');
            }
        };

        if (typeof cmds[e.keyCode] === 'function') {
            cmds[e.keyCode]();
        }
    });
});

