#
# Copyright (c) 2008-2011 by SÃ©bastien Helleu <flashcode@flashtux.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Display sidebar with list of buffers.
#
# History:
#
# 2012-01-04, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     2.7: fix regex lookup in whitelist buffers list
# 2011-12-04, Nils G <weechatter@arcor.de>:
#     2.6: add own config file (buffers.conf)
#          add new behavior for indenting (under_name)
#          add new option to set different color for server buffers and buffers with free content
# 2011-10-30, Nils G <weechatter@arcor.de>:
#     2.5: add new options "show_number_char" and "color_number_char",
#          add help-description for options
# 2011-08-24, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v2.4: add mouse support
# 2011-06-06, Nils G <weechatter@arcor.de>:
#     v2.3: added: missed option "color_whitelist_default"
# 2011-03-23, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v2.2: fix color of nick prefix with WeeChat >= 0.3.5
# 2011-02-13, Nils G <weechatter@arcor.de>:
#     v2.1: add options "color_whitelist_*"
# 2010-10-05, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v2.0: add options "sort" and "show_number"
# 2010-04-12, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.9: replace call to log() by length() to align buffer numbers
# 2010-04-02, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.8: fix bug with background color and option indenting_number
# 2010-04-02, Helios <helios@efemes.de>:
#     v1.7: add indenting_number option
# 2010-02-25, m4v <lambdae2@gmail.com>:
#     v1.6: add option to hide empty prefixes
# 2010-02-12, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.5: add optional nick prefix for buffers like IRC channels
# 2009-09-30, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.4: remove spaces for indenting when bar position is top/bottom
# 2009-06-14, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.3: add option "hide_merged_buffers"
# 2009-06-14, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.2: improve display with merged buffers
# 2009-05-02, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.1: sync with last API changes
# 2009-02-21, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v1.0: remove timer used to update bar item first time (not needed any more)
# 2009-02-17, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.9: fix bug with indenting of private buffers
# 2009-01-04, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.8: update syntax for command /set (comments)
# 2008-10-20, Jiri Golembiovsky <golemj@gmail.com>:
#     v0.7: add indenting option
# 2008-10-01, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.6: add default color for buffers, and color for current active buffer
# 2008-09-18, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.5: fix color for "low" level entry in hotlist
# 2008-09-18, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.4: rename option "show_category" to "short_names",
#           remove option "color_slash"
# 2008-09-15, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.3: fix bug with priority in hotlist (var not defined)
# 2008-09-02, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.2: add color for buffers with activity and config options for
#           colors, add config option to display/hide categories
# 2008-03-15, SÃ©bastien Helleu <flashcode@flashtux.org>:
#     v0.1: script creation
#
# Help about settings:
#   display all settings for script (or use iset.pl script to change settings):
#      /set buffers*
#   show help text for option buffers.look.whitelist_buffers:
#      /help buffers.look.whitelist_buffers
#

use strict;

# -------------------------------[ internal ]-------------------------------------
my $version = "2.7";

my $BUFFERS_CONFIG_FILE_NAME = "buffers";
my $buffers_config_file;

my %mouse_keys = ("\@item(buffers):button1*" => "hsignal:buffers_mouse");
my %options;
my %hotlist_level = (0 => "low", 1 => "message", 2 => "private", 3 => "highlight");
my @whitelist_buffers = "";
my @buffers_focus = ();

# --------------------------------[ init ]--------------------------------------
weechat::register("buffers", "SÃ©bastien Helleu <flashcode\@flashtux.org>", $version,
                  "GPL3", "Sidebar with list of buffers", "", "");
my $weechat_version = weechat::info_get("version_number", "") || 0;

buffers_config_init();
buffers_config_read();

weechat::bar_item_new("buffers", "build_buffers", "");
weechat::bar_new("buffers", "0", "0", "root", "", "left", "horizontal",
                 "vertical", "0", "0", "default", "default", "default", "1",
                 "buffers");
weechat::hook_signal("buffer_*", "buffers_signal_buffer", "");
weechat::hook_signal("hotlist_*", "buffers_signal_hotlist", "");
weechat::bar_item_update("buffers");
if ($weechat_version >= 0x00030600)
{
    weechat::hook_focus("buffers", "buffers_focus_buffers", "");
    weechat::hook_hsignal("buffers_mouse", "buffers_hsignal_mouse", "");
    weechat::key_bind("mouse", \%mouse_keys);
}

# -------------------------------- [ config ] --------------------------------
sub buffers_config_read
{
    return weechat::config_read($buffers_config_file) if ($buffers_config_file ne "");
}
sub buffers_config_write
{
    return weechat::config_write($buffers_config_file) if ($buffers_config_file ne "");
}
sub buffers_config_reload_cb
{
    my ($data,$config_file) = ($_[0], $_[1]);
    return weechat::config_read($config_file)
}
sub buffers_config_init
{
    $buffers_config_file = weechat::config_new($BUFFERS_CONFIG_FILE_NAME,"buffers_config_reload_cb","");
    return if ($buffers_config_file eq "");

    # section "color"
    my $section_color = weechat::config_new_section($buffers_config_file,"color", 0, 0, "", "", "", "", "", "", "", "", "", "");
    if ($section_color eq "")
    {
        weechat::config_free($buffers_config_file);
        return;
    }
    $options{"color_current_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "current_fg", "color", "foreground color for current buffer", "", 0, 0,
        "lightcyan", "lightcyan", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_current_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "current_bg", "color", "background color for current buffer", "", 0, 0,
        "red", "red", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_default_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "default_fg", "color", "default foreground color for buffer name", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_default_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "default_bg", "color", "default background color for buffer name", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_highlight_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_highlight_fg", "color", "change foreground color of buffer name if a highlight messaged received", "", 0, 0,
        "magenta", "magenta", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_highlight_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_highlight_bg", "color", "change background color of buffer name if a highlight messaged received", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_low_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_low_fg", "color", "change foreground color of buffer name if a low message received", "", 0, 0,
        "white", "white", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_low_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_low_bg", "color", "change background color of buffer name if a low message received", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_message_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_message_fg", "color", "change foreground color of buffer name if a normal message received", "", 0, 0,
        "yellow", "yellow", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_message_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_message_bg", "color", "change background color of buffer name if a normal message received", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_private_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_private_fg", "color", "change foreground color of buffer name if a private message received", "", 0, 0,
        "lightgreen", "lightgreen", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_hotlist_private_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "hotlist_private_bg", "color", "change background color of buffer name if a private message received", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_number"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "number", "color", "color for buffer number", "", 0, 0,
        "lightgreen", "lightgreen", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_number_char"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "number_char", "color", "color for buffer number char", "", 0, 0,
        "lightgreen", "lightgreen", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_default"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_default", "color", "default color for whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_low_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_low_fg", "color", "low color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_low_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_low_bg", "color", "low color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_message_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_message_fg", "color", "message color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_message_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_message_bg", "color", "message color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_private_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_private_fg", "color", "private color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_private_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_private_bg", "color", "private color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_highlight_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_highlight_fg", "color", "highlight color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_whitelist_highlight_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "whitelist_highlight_bg", "color", "highlight color of whitelist buffer name", "", 0, 0,
        "", "", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_none_channel_fg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "none_channel_fg", "color", "foreground color for none channel buffer (e.g.: core/server/plugin buffer)", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"color_none_channel_bg"} = weechat::config_new_option(
        $buffers_config_file, $section_color,
        "none_channel_bg", "color", "background color for none channel buffer (e.g.: core/server/plugin buffer)", "", 0, 0,
        "default", "default", 0, "", "", "buffers_signal_config", "", "", "");

    # section "look"
    my $section_look = weechat::config_new_section($buffers_config_file,"look", 0, 0, "", "", "", "", "", "", "", "", "", "");
    if ($section_look eq "")
    {
        weechat::config_free($buffers_config_file);
        return;
    }
    $options{"color_whitelist_buffers"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "whitelist_buffers", "string", "comma separated list of buffers for using a differnt color scheme (for example: freenode.#weechat,freenode.#weechat-fr)", "", 0, 0,"", "", 0, "", "", "buffers_signal_config_whitelist", "", "", "");
    $options{"hide_merged_buffers"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "hide_merged_buffers", "boolean", "hide merged buffers", "", 0, 0,
        "off", "off", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"indenting"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "indenting", "integer", "use indenting for some buffers like IRC channels", "off|on|under_name", 0, 0,
        "off", "off", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"indenting_number"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "indenting_number", "boolean", "use indenting for numbers", "", 0, 0,
        "on", "on", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"short_names"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "short_names", "boolean", "display short names (remove text before first \".\" in buffer name)", "", 0, 0,
        "on", "on", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"show_number"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "show_number", "boolean", "display channel number in front of buffername", "", 0, 0,
        "on", "on", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"show_number_char"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "number_char", "string", "display a char after channel number", "", 0, 0,
        ".", ".", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"show_prefix"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "prefix", "boolean", "show your prefix for channel", "", 0, 0,
        "off", "off", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"show_prefix_empty"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "prefix_empty", "boolean", "use a placeholder for channels without prefix", "", 0, 0,
        "on", "on", 0, "", "", "buffers_signal_config", "", "", "");
    $options{"sort"} = weechat::config_new_option(
        $buffers_config_file, $section_look,
        "sort", "integer", "sort buffer-list by \"number\" or \"name\"", "number|name", 0, 0,
        "number", "number", 0, "", "", "buffers_signal_config", "", "", "");
}

sub build_buffers
{
    my $str = "";

    # get bar position (left/right/top/bottom)
    my $position = "left";
    my $option_position = weechat::config_get("weechat.bar.buffers.position");
    if ($option_position ne "")
    {
        $position = weechat::config_string($option_position);
    }

    # read hotlist
    my %hotlist;
    my $infolist = weechat::infolist_get("hotlist", "", "");
    while (weechat::infolist_next($infolist))
    {
        $hotlist{weechat::infolist_pointer($infolist, "buffer_pointer")} =
            weechat::infolist_integer($infolist, "priority");
    }
    weechat::infolist_free($infolist);

    # read buffers list
    @buffers_focus = ();
    my @buffers;
    my @current1 = ();
    my @current2 = ();
    my $old_number = -1;
    my $max_number = 0;
    my $max_number_digits = 0;
    my $active_seen = 0;
    $infolist = weechat::infolist_get("buffer", "", "");
    while (weechat::infolist_next($infolist))
    {
        my $buffer;
        my $number = weechat::infolist_integer($infolist, "number");
        if ($number ne $old_number)
        {
            @buffers = (@buffers, @current2, @current1);
            @current1 = ();
            @current2 = ();
            $active_seen = 0;
        }
        if ($number > $max_number)
        {
            $max_number = $number;
        }
        $old_number = $number;
        my $active = weechat::infolist_integer($infolist, "active");
        if ($active)
        {
            $active_seen = 1;
        }
        $buffer->{"pointer"} = weechat::infolist_pointer($infolist, "pointer");
        $buffer->{"number"} = $number;
        $buffer->{"active"} = $active;
        $buffer->{"current_buffer"} = weechat::infolist_integer($infolist, "current_buffer");
        $buffer->{"plugin_name"} = weechat::infolist_string($infolist, "plugin_name");
        $buffer->{"name"} = weechat::infolist_string($infolist, "name");
        $buffer->{"short_name"} = weechat::infolist_string($infolist, "short_name");
        $buffer->{"full_name"} = $buffer->{"plugin_name"}.".".$buffer->{"name"};
        if ($active_seen)
        {
            push(@current2, $buffer);
        }
        else
        {
            push(@current1, $buffer);
        }
    }
    if ($max_number >= 1)
    {
        $max_number_digits = length(int($max_number));
    }
    @buffers = (@buffers, @current2, @current1);
    weechat::infolist_free($infolist);

    # sort buffers by number, name or shortname
    my %sorted_buffers;
    if (1)
    {
        my $number = 0;
        for my $buffer (@buffers)
        {
            my $key;
            if (weechat::config_integer( $options{"sort"} ) eq 1) # number = 0, name = 1
            {
                my $name = $buffer->{"name"};
                $name = $buffer->{"short_name"} if (weechat::config_boolean( $options{"short_names"} ) eq 1);
                $key = sprintf("%s%08d", lc($name), $buffer->{"number"});
            }
            else
            {
                $key = sprintf("%08d", $number);
            }
            $sorted_buffers{$key} = $buffer;
            $number++;
        }
    }

    # build string with buffers
    $old_number = -1;
    foreach my $key (sort keys %sorted_buffers)
    {
        my $buffer = $sorted_buffers{$key};
        if ( (weechat::config_boolean( $options{"hide_merged_buffers"} ) eq 1) && (! $buffer->{"active"}) )
        {
            next;
        }

        push(@buffers_focus, $buffer);
        my $color = "";
        my $bg = "";

        $color = weechat::config_color( $options{"color_default_fg"} );
        $bg = weechat::config_color( $options{"color_default_bg"} );
        # check for none channel and private buffer
        if ( (weechat::buffer_get_string($buffer->{"pointer"}, "localvar_type") ne "channel" ) and ( weechat::buffer_get_string($buffer->{"pointer"}, "localvar_type") ne "private") )
        {
            $color = weechat::config_color( $options{"color_none_channel_fg"} );
            $bg = weechat::config_color( $options{"color_none_channel_bg"} );
        }
        # default whitelist buffer?
        if (grep {$_ eq $buffer->{"name"}} @whitelist_buffers)
        {
            $color = weechat::config_color( $options{"color_whitelist_default"} );
        }

        $color = "default" if ($color eq "");

        if (exists $hotlist{$buffer->{"pointer"}})
        {
            if (grep {$_ eq $buffer->{"name"}} @whitelist_buffers)
            {
                $bg = weechat::config_color( $options{"color_whitelist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}."_bg"} );
                $color = weechat::config_color( $options{"color_whitelist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}."_fg"}  );
            }
            else
            {
                $bg = weechat::config_color( $options{"color_hotlist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}."_bg"} );
                $color = weechat::config_color( $options{"color_hotlist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}."_fg"}  );
            }
        }

        if ($buffer->{"current_buffer"})
        {
            $color = weechat::config_color( $options{"color_current_fg"} );
            $bg = weechat::config_color( $options{"color_current_bg"} );
        }
        my $color_bg = "";
        $color_bg = weechat::color(",".$bg) if ($bg ne "");
        if ( weechat::config_boolean( $options{"show_number"} ) eq 1)
        {
            if (( weechat::config_boolean( $options{"indenting_number"} ) eq 1)
                && (($position eq "left") || ($position eq "right")))
            {
                $str .= weechat::color("default").$color_bg
                    .(" " x ($max_number_digits - length(int($buffer->{"number"}))));
            }
            if ($old_number ne $buffer->{"number"})
            {
                $str .= weechat::color( weechat::config_color( $options{"color_number"} ) )
                    .$color_bg
                    .$buffer->{"number"}
                    .weechat::color("default")
                    .$color_bg
                    .weechat::color( weechat::config_color( $options{"color_number_char"} ) )
                    .weechat::config_string( $options{"show_number_char"} )
                    .$color_bg;
            }
            else
            {
                my $indent = "";
                $indent = ((" " x length($buffer->{"number"}))." ") if (($position eq "left") || ($position eq "right"));
                $str .= weechat::color("default")
                    .$color_bg
                    .$indent;
            }
        }
        if (( weechat::config_integer( $options{"indenting"} ) ne 0 )            # indenting NOT off
            && (($position eq "left") || ($position eq "right")))
        {
            my $type = weechat::buffer_get_string($buffer->{"pointer"}, "localvar_type");
            if (($type eq "channel") || ($type eq "private"))
            {
                if ( weechat::config_integer( $options{"indenting"} ) eq 1 )
                {
                    $str .= "  ";
                }
                elsif ( (weechat::config_integer($options{"indenting"}) eq 2) and (weechat::config_integer($options{"indenting_number"}) eq 0) )
                {
                    $str .= ( (" " x ( $max_number_digits - length($buffer->{"number"}) ))." " );
                }
            }
        }
        if (weechat::config_boolean( $options{"show_prefix"} ) eq 1)
        {
            my $nickname = weechat::buffer_get_string($buffer->{"pointer"}, "localvar_nick");
            if ($nickname ne "")
            {
                # with version >= 0.3.2, this infolist will return only nick
                # with older versions, whole nicklist is returned for buffer, and this can be very slow
                my $infolist_nick = weechat::infolist_get("nicklist", $buffer->{"pointer"}, "nick_".$nickname);
                if ($infolist_nick ne "")
                {
                    my $version = weechat::info_get("version_number", "");
                    $version = 0 if ($version eq "");
                    while (weechat::infolist_next($infolist_nick))
                    {
                        if ((weechat::infolist_string($infolist_nick, "type") eq "nick")
                            && (weechat::infolist_string($infolist_nick, "name") eq $nickname))
                        {
                            my $prefix = weechat::infolist_string($infolist_nick, "prefix");
                            if (($prefix ne " ") or (weechat::config_boolean( $options{"show_prefix_empty"} ) eq 1))
                            {
                                # with version >= 0.3.5, it is now a color name (for older versions: option name with color)
                                if (int($version) >= 0x00030500)
                                {
                                    $str .= weechat::color(weechat::infolist_string($infolist_nick, "prefix_color"));
                                }
                                else
                                {
                                    $str .= weechat::color(weechat::config_color(
                                                               weechat::config_get(
                                                                   weechat::infolist_string($infolist_nick, "prefix_color"))));
                                }
                                $str .= $prefix;
                            }
                            last;
                        }
                    }
                    weechat::infolist_free($infolist_nick);
                }
            }
        }
        $str .= weechat::color($color) . weechat::color(",".$bg);
        if (weechat::config_boolean( $options{"short_names"} ) eq 1)
        {
            $str .= $buffer->{"short_name"};
        }
        else
        {
            $str .= $buffer->{"name"};
        }
        $str .= "\n";
        $old_number = $buffer->{"number"};
    }

    return $str;
}

sub buffers_signal_buffer
{
    weechat::bar_item_update("buffers");
    return weechat::WEECHAT_RC_OK;
}

sub buffers_signal_hotlist
{
    weechat::bar_item_update("buffers");
    return weechat::WEECHAT_RC_OK;
}


sub buffers_signal_config_whitelist
{
    @whitelist_buffers = split( /,/, weechat::config_string( $options{"color_whitelist_buffers"} ) );
    weechat::bar_item_update("buffers");
    return weechat::WEECHAT_RC_OK;
}

sub buffers_signal_config
{
    weechat::bar_item_update("buffers");
    return weechat::WEECHAT_RC_OK;
}

# called when mouse click occured in buffers item: this callback returns buffer
# hash according to line of item where click ccured
sub buffers_focus_buffers
{
    my %info = %{$_[1]};
    my $item_line = int($info{"_bar_item_line"});
    undef my $hash;
    if (($info{"_bar_item_name"} eq "buffers") && ($item_line >= 0) && ($item_line <= $#buffers_focus))
    {
        $hash = $buffers_focus[$item_line];
    }
    else
    {
        $hash = {};
        my $hash_focus = $buffers_focus[0];
        foreach my $key (keys %$hash_focus)
        {
            $hash->{$key} = "?";
        }
    }
    return $hash;
}

# called when a mouse action is done on buffers item, to execute action
# action can be: jump to a buffer, or move buffer in list (drag & drop of buffer)
sub buffers_hsignal_mouse
{
    my ($data, $signal, %hash) = ($_[0], $_[1], %{$_[2]});
    if ($hash{"number"} eq $hash{"number2"})
    {
        weechat::command("", "/buffer ".$hash{"full_name"});
    }
    else
    {
        my $number2 = $hash{"number2"};
        if ($number2 eq "?")
        {
            # if number 2 is not known (end of gesture outside buffers list), then set it
            # according to mouse gesture
            $number2 = "999999";
            $number2 = "1" if (($hash{"_key"} =~ /gesture-left/) || ($hash{"_key"} =~ /gesture-up/));
        }
        my $ptrbuf = weechat::current_buffer();
        weechat::command("", "/buffer ".$hash{"number"});
        weechat::command("", "/buffer move ".$number2);
        weechat::buffer_set($ptrbuf, "display", "1");
    }
}

