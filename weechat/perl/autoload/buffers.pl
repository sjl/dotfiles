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
#   display short names (remove text before first "." in buffer name):
#      /set plugins.var.perl.buffers.short_names on
#   use indenting for some buffers like IRC channels:
#      /set plugins.var.perl.buffers.indenting on
#   use indenting for numbers:
#      /set plugins.var.perl.buffers.indenting_number on
#   hide merged buffers:
#      /set plugins.var.perl.buffers.hide_merged_buffers on
#   show prefix:
#      /set plugins.var.perl.buffers.show_prefix on
#      /set plugins.var.perl.buffers.show_prefix_empty on
#   change colors:
#      /set plugins.var.perl.buffers.color_number color
#      /set plugins.var.perl.buffers.color_default color
#      /set plugins.var.perl.buffers.color_hotlist_low color
#      /set plugins.var.perl.buffers.color_hotlist_message color
#      /set plugins.var.perl.buffers.color_hotlist_private color
#      /set plugins.var.perl.buffers.color_hotlist_highlight color
#      /set plugins.var.perl.buffers.color_current color
#   (replace "color" by your color, which may be "fg" or "fg,bg")
#

use strict;

my $version = "2.4";

# -------------------------------[ config ]-------------------------------------

my %default_options = ("short_names"               => "on",
                       "indenting"                 => "on",
                       "indenting_number"          => "on",
                       "hide_merged_buffers"       => "off",
                       "show_number"               => "on",
                       "show_prefix"               => "off",
                       "show_prefix_empty"         => "on",
                       "sort"                      => "number",  # "number" or "name"
                       "color_hotlist_low"         => "white",
                       "color_hotlist_message"     => "yellow",
                       "color_hotlist_private"     => "lightgreen",
                       "color_hotlist_highlight"   => "magenta",
                       "color_current"             => "lightcyan,red",
                       "color_default"             => "default",
                       "color_number"              => "lightgreen",
                       "color_whitelist_buffers"   => "",
                       "color_whitelist_default"   => "",
                       "color_whitelist_low"       => "",
                       "color_whitelist_message"   => "",
                       "color_whitelist_private"   => "",
                       "color_whitelist_highlight" => "",

    );
my %mouse_keys = ("\@item(buffers):button1*" => "hsignal:buffers_mouse");
my %options;
my %hotlist_level = (0 => "low", 1 => "message", 2 => "private", 3 => "highlight");
my @whitelist_buffers = "";
my @buffers_focus = ();

# --------------------------------[ init ]--------------------------------------

weechat::register("buffers", "SÃ©bastien Helleu <flashcode\@flashtux.org>", $version,
                  "GPL3", "Sidebar with list of buffers", "", "");

foreach my $option (keys %default_options)
{
    if (!weechat::config_is_set_plugin($option))
    {
        weechat::config_set_plugin($option, $default_options{$option});
    }
}
buffers_read_options();

weechat::bar_item_new("buffers", "build_buffers", "");
weechat::bar_new("buffers", "0", "0", "root", "", "left", "horizontal",
                 "vertical", "0", "0", "default", "default", "default", "1",
                 "buffers");
weechat::hook_signal("buffer_*", "buffers_signal_buffer", "");
weechat::hook_signal("hotlist_*", "buffers_signal_hotlist", "");
weechat::hook_config("plugins.var.perl.buffers.*", "buffers_signal_config", "");
weechat::bar_item_update("buffers");
my $weechat_version = weechat::info_get("version_number", "") || 0;
if ($weechat_version >= 0x00030600)
{
    weechat::hook_focus("buffers", "buffers_focus_buffers", "");
    weechat::hook_hsignal("buffers_mouse", "buffers_hsignal_mouse", "");
    weechat::key_bind("mouse", \%mouse_keys);
}

# ------------------------------------------------------------------------------

sub buffers_read_options
{
    foreach my $option (keys %default_options)
    {
        $options{$option} = weechat::config_get_plugin($option);
    }
    @whitelist_buffers = split(/,/, $options{color_whitelist_buffers});
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
            if ($options{"sort"} eq "name")
            {
                my $name = $buffer->{"name"};
                $name = $buffer->{"short_name"} if ($options{"short_names"} eq "on");
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
        if (($options{"hide_merged_buffers"} eq "on") && (! $buffer->{"active"}))
        {
            next;
        }
        
        push(@buffers_focus, $buffer);
        my $color = "";
        # whitelist buffer?
        if (grep /^$buffer->{"name"}$/, @whitelist_buffers)
        {
            # options empty?
            if ($options{"color_whitelist_default"} eq "")
            {
                $color = $options{"color_default"};
            }
            else
            {
                # use color
                $color = $options{"color_whitelist_default"};
            }
        }
        else
        {
            # no whitelist buffer
            $color = $options{"color_default"};
        }

        $color = "default" if ($color eq "");
        my $bg = "";

        if (exists $hotlist{$buffer->{"pointer"}})
        {
            if (grep /^$buffer->{"name"}$/, @whitelist_buffers)
            {
                if ($options{"color_whitelist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}} eq "")    # no color in settings
                {
                    $color = $options{"color_hotlist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}};     # use standard colors
                }
                else
                {
                    $color = $options{"color_whitelist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}};
                }
            }
            else
            {
                $color = $options{"color_hotlist_".$hotlist_level{$hotlist{$buffer->{"pointer"}}}};
            }
        }
        if ($buffer->{"current_buffer"})
        {
            $color = $options{"color_current"};
            $bg = $1 if ($color =~ /.*,(.*)/);
        }
        my $color_bg = "";
        $color_bg = weechat::color(",".$bg) if ($bg ne "");
        if ($options{"show_number"} eq "on")
        {
            if (($options{"indenting_number"} eq "on")
                && (($position eq "left") || ($position eq "right")))
            {
                $str .= weechat::color("default").$color_bg
                    .(" " x ($max_number_digits - length(int($buffer->{"number"}))));
            }
            if ($old_number ne $buffer->{"number"})
            {
                $str .= weechat::color($options{"color_number"})
                    .$color_bg
                    .$buffer->{"number"}
                    .weechat::color("default")
                    .$color_bg
                    .".";
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
        if (($options{"indenting"} eq "on")
            && (($position eq "left") || ($position eq "right")))
        {
            my $type = weechat::buffer_get_string($buffer->{"pointer"}, "localvar_type");
            if (($type eq "channel") || ($type eq "private"))
            {
                $str .= "  ";
            }
        }
        if ($options{"show_prefix"} eq "on")
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
                            if (($prefix ne " ") or ($options{"show_prefix_empty"} eq "on"))
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
        $str .= weechat::color($color);
        if ($options{"short_names"} eq "on")
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

sub buffers_signal_config
{
    buffers_read_options();
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
