#
# Copyright (c) 2010-2012 by Nils Görs <weechatter@arcor.de>
#
# colors the channel text with nick color and also highlight the whole line
# colorize_nicks.py script will be supported
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
# for settings see help page
#
# history:
# 1.3: fix: now using weechat::buffer_get_string() instead of regex to prevent problems with dots inside server-/channelnames (reported by surfhai)
# 1.2: add: hook_modifier("colorize_lines") to use colorize_lines with another script.
#    : fix: regex was too greedy and also hit tag "prefix_nick_ccc"
# 1.1: fix:  problems with temporary server (reported by nand`)
#    : improved: using weechat_string_has_highlight()
# 1.0: fix: irc.look.nick_prefix wasn't supported
# 0.9: added: option "own_nick" (idea by travkin)
#    : new value (always) for option highlight
#    : clean up code
# 0.8.1: fix: regex()
# 0.8: added: option "avail_buffer" and "nicks" (please read help-page) (suggested by ldvx)
#    : fix: blacklist_channels wasn't load at start
#    : fix: nick_modes wasn't displayed since v0.7
#    : rewrote init() routine
#    : thanks to stfn for hint with unescaped variables in regex.
# 0.7: fix: bug when irc.look.nick_suffix was set (reported and beta-testing by: hw2) (>= weechat 0.3.4)
#      blacklist_channels option supports servername
#      clean up code
# 0.6: code optimazations.
#      rename of script (rainbow_text.pl -> colorize_lines.pl) (suggested by xt and flashcode)
# 0.5: support of hotlist_max_level_nicks_add and weechat.color.chat_nick_colors (>= weechat 0.3.4)
# 0.4: support of weechat.look.highlight_regex option (>= weechat 0.3.4)
#    : support of weechat.look.highlight option
#    : highlighted line did not work with "." inside servername
#    ; internal "autoset" function fixed
# 0.3: support of colorize_nicks.py implemented.
#    : /me text displayed wrong nick colour (colour from suffix was used)
#    : highlight messages will be checked case insensitiv
# 0.2: supports highlight_words_add from buffer_autoset.py script (suggested: Emralegna)
#    : correct look_nickmode colour will be used (bug reported by: Emralegna)
#    : /me text will be coloured, too
# 0.1: initial release
#
# Development is currently hosted at
# https://github.com/weechatter/weechat-scripts
#
# requirements: sunglasses ;-)

use strict;
my $prgname	= "colorize_lines";
my $version	= "1.3";
my $description	= "colors text in chat area with according nick color. Highlight messages will be fully highlighted in chat area";

# default values
my %default_options = ( "var_highlight"                         => "on",        # script options in weechat
                        "var_avail_buffer"                      => "all",       # all, channel, query
                        "var_chat"                              => "on",
                        "var_shuffle"                           => "off",
                        "var_buffer_autoset"                    => "off",
                        "var_look_highlight"                    => "off",
                        "var_look_highlight_regex"              => "off",
                        "var_hotlist_max_level_nicks_add"	=> "off",
                        "var_blacklist_channels"                => "",
                        "var_nicks"                             => "",
                        "var_own_lines"                         => "off",
);

my %help_desc = ( "avail_buffer"         => "messages will be colored in buffer (all = all buffers, channel = channel buffers, query = query buffers (default: all ",
                  "blacklist_channels"   => "comma separated list with channelname. Channels in this list will be ignored. (e.g.: freenode.#weechat,freenode.#weechat-fr)",
                  "shuffle"              => "toggle shuffle color mode for chats area (default: off)",
                  "chat"                 => "colors text in chat area with according nick color (default: on)",
                  "highlight"            => "highlight messages will be fully highlighted in chat area (on = whole line will be highlighted, off = only nick will be highlighted, always = a highlight will always color the whole message) (default: on)",
                  "hotlist_max_level_nicks_add"         => "toggle highlight for hotlist (default: off)",
                  "buffer_autoset"       => "toggle highlight color in chat area for buffer_autoset (default: off)",
                  "look_highlight"       => "toggle highlight color in chat area for option weechat.look.highlight (default: off)",
                  "look_highlight_regex" => "toggle highlight color in chat area for option weechat.look.highlight_regex (default: off)",
                  "nicks"                => "comma separated list with nicknames. Only messages from nicks in this list will be colorized. (e.g.: freenode.nils_2,freenode.flashcode,freenode.weebot). You can also give a filename with nicks. The filename has to start with \"/\" (e.g.: /buddylist.txt). The format has to be: one nick each line with <servername>.<nickname>",
                  "own_lines"            => "colors own written messages (default: off)",
);

my $zahl = 0;
my $weechat_version = 0;
my $nick_mode = "";
my $get_prefix_action = "";
my @var_blacklist_channels = "";
my @nick_list = "";

# standard colours.
my %colours = ( 0 => "darkgray", 1 => "red", 2 => "lightred", 3 => "green",
                4 => "lightgreen", 5 => "brown", 6 => "yellow", 7 => "blue",
                8 => "lightblue", 9 => "magenta", 10 => "lightmagenta", 11 => "cyan",
                12 => "lightcyan", 13 => "white");

# program starts here
sub colorize_cb {
my ( $data, $modifier, $modifier_data, $string ) = @_;

if (index($modifier_data,"irc_privmsg") == -1){                                                 # its neither a channel nor a query buffer
  return $string;
}

if ($default_options{var_highlight} eq "off" and $default_options{var_chat} eq "off"){          # all options OFF
  return $string;
}

# get servername and channelname. Do not use regex to extract server- and channelname out of $modifier_data. You will FAIL!
# some possible names: freenode.#weechat, freenode.#weechat.de, freenode.query, chat.freenode.net.#weechat, chat.freenode.net.#weechat.de
$modifier_data =~ (m/(.*);(.*);/);
my $plugin = $1;
my $name = $2;
my $buf_pointer = weechat::buffer_search($plugin,$name);
return $string if ($buf_pointer eq "");
my $servername = weechat::buffer_get_string($buf_pointer, "localvar_server");
my $channel_name = weechat::buffer_get_string($buf_pointer, "localvar_channel");

my $my_nick = weechat::info_get( 'irc_nick', $servername );                                     # get nick with servername (;freenode.)

if ( grep /^$servername.$channel_name$/, @var_blacklist_channels ) {                            # check for blacklist_channels
  return $string;
}

$string =~ m/^(.*)\t(.*)/;                                                                      # get the nick name: nick[tab]string
my $nick = $1;                                                                                  # nick with nick_mode and color codes
my $line = $2;                                                                                  # get written text

$line = weechat::string_remove_color($line,"");                                                 # remove color-codes from line, first
# get the nick name from modifier_data (without nick_mode and color codes! Take care of tag "prefix_nick_ccc")
$modifier_data =~ m/(^|,)nick_(.*),/;
my $nick_wo_suffix = $2;                                                                        # nickname without nick_suffix

if ( lc($nick_wo_suffix) eq lc($my_nick) ){                                                     # this one checks for own messages
  if ( $default_options{var_avail_buffer} ne "all" ){                                           # check for option avail_buffer
    if ( substr($channel_name, 0, 1) eq "#" ){                                                  # get first chat of buffer.
      return $string if ( $default_options{var_avail_buffer} ne "channel" );                    # channel? yes
    }else{                                                                                      # query buffer?
      return $string if ( $default_options{var_avail_buffer} ne "query" );                      # yes
    }
  }
}

# recreate irc.look.nick_suffix and irc.color.nick_suffix
my $nick_suffix_with_color = "";
my $nick_suffix = weechat::config_string( weechat::config_get("irc.look.nick_suffix"));
if ( $nick_suffix ne "" ){
  my $nick_suffix_color = weechat::color( weechat::config_color( weechat::config_get( "irc.color.nick_suffix" )));
  $nick_suffix_with_color = $nick_suffix_color . $nick_suffix;
}
# recreate irc.look.nick_prefix and irc.color.nick_prefix
my $nick_prefix_with_color = "";
my $nick_prefix = weechat::config_string( weechat::config_get("irc.look.nick_prefix"));
if ( $nick_prefix ne "" ){
  my $nick_prefix_color = weechat::color( weechat::config_color( weechat::config_get( "irc.color.nick_prefix" )));
  $nick_prefix_with_color = $nick_prefix_color . $nick_prefix;
}

# check for action (/me)
my $prefix_action_with_color = "";
if (index($modifier_data,"irc_action") >= 0){
  my $prefix_action_color = weechat::color( weechat::config_color( weechat::config_get( "weechat.color.chat_prefix_action" )));
  my $prefix_action = weechat::config_string( weechat::config_get("weechat.look.prefix_action"));
  $prefix_action_with_color = $prefix_action_color . $prefix_action;
}

# check if look.nickmode is ON and no prefix and no query buffer
$nick_mode = "";
if ( weechat::config_boolean(weechat::config_get("weechat.look.nickmode")) ==  1 and ($nick ne $get_prefix_action) and (index($modifier_data,"notify_private")) == -1){
#   if ($nick  =~ m/^\@|^\%|^\+|^\~|^\*|^\&|^\!|^\-/) {                                                  # check for nick modes (@%+~*&!-) without colour
      my $nick_pointer = weechat::nicklist_search_nick($buf_pointer,"",$nick_wo_suffix);
      $nick_mode = weechat::nicklist_nick_get_string($buf_pointer,$nick_pointer,"prefix");
      my $color_mode = weechat::color( weechat::nicklist_nick_get_string($buf_pointer, $nick_pointer, "prefix_color") );
      if ( $nick_mode eq "" or $color_mode eq ""){                                             # no nick_mode!
        $nick_mode = "";
      }else{                                                                                    # nick_mode exists
        $nick_mode = $color_mode . $nick_mode;
      }
}

# i wrote the message
#weechat::print("","nick_wo: $nick_wo_suffix");
#weechat::print("","my_nick: $my_nick");
    if ($nick_wo_suffix eq $my_nick ){                                                                  # i wrote the message
      return $string if check_whitelist_nicks($servername, $my_nick, $nick_wo_suffix);                  # check for whitelist
      if ($default_options{var_chat} eq "on"){
	  my $nick_color = weechat::config_color(weechat::config_get("weechat.color.chat_nick_self"));  # get my nick color
	  $nick_color = weechat::color($nick_color);
	  $line = colorize_nicks($nick_color,$modifier_data,$line);

          if (index($modifier_data,"irc_action") >= 0){                                                 # /me message?
            $nick = $prefix_action_with_color;
            $nick_mode = "";                                                                            # clear nick_mode for /me
          }else{
            $nick = $nick_prefix_with_color . $nick_color . $nick_wo_suffix . $nick_suffix_with_color;
          }
	  $line = $nick_mode . $nick_color . $nick . "\t" . $nick_color . $line . weechat::color('reset');
	  return $line;
      }else{
	  return $string;
      }
    }


# get nick color
$nick = $nick_wo_suffix;
#$nick = weechat::string_remove_color($nick_wo_suffix,"");                                      # remove colour-codes from nick
my $nick_color = weechat::info_get('irc_nick_color', $nick_wo_suffix);                          # get nick-colour

    my $var_hl_max_level_nicks_add = 0;
# highlight message received?
    if ( $default_options{var_highlight} eq "on" or $default_options{var_highlight} eq "always" ){# highlight_mode on?
# this one check for other nick!!

      unless ( $default_options{var_highlight} eq "always" ){                                   # option is not "always"
        return $string if check_whitelist_nicks($servername, $my_nick, $nick_wo_suffix);        # check for whitelist
      }

      if ( $default_options{var_buffer_autoset} eq "on" || $default_options{var_look_highlight} eq "on" ){# buffer_autoset or look_highlight "on"?
	  my $highlight_words = "";

	  # get strings from buffer_autoset and/or weechat.look.highlight and weechat.look.highlight_regex
	  if ($default_options{var_buffer_autoset} eq "on"){
	    my $highlight_words_add = weechat::config_string(weechat::config_get("buffer_autoset.buffer.irc.".$servername.".".$channel_name.".highlight_words_add"));
	    $highlight_words .= $highlight_words_add . ",";
	  }

	  if ($default_options{var_look_highlight} eq "on"){
	    my $look_highlight = weechat::config_string( weechat::config_get("weechat.look.highlight") );
	    $highlight_words .= $look_highlight;
	  }
	  if ( $default_options{var_hotlist_max_level_nicks_add} eq "on" and weechat::config_string(weechat::config_get("buffer_autoset.buffer.irc.".$servername.".".$channel_name.".hotlist_max_level_nicks_add")) =~ /$nick\:[0-2]/ ){
	    $var_hl_max_level_nicks_add = 1;
	  }

            $/ = ",";                                                                           # kill "," at end of string

	    chomp($highlight_words);

#            weechat::print("",$highlight_words);
	      foreach ( split( /,+/, $highlight_words ) ) {                                     # check for highlight_words
		  if ($_ eq ""){next;}                                                          # ignore empty string
		    my $search_string = shell2regex($_);

		  if ($string =~ m/\b$search_string\b/gi){                                      # i (ignorecase)
		    my $color_highlight = weechat::config_color(weechat::config_get("weechat.color.chat_highlight"));
		    my $color_highlight_bg = weechat::config_color(weechat::config_get("weechat.color.chat_highlight_bg"));
		    my $high_color = weechat::color("$color_highlight,$color_highlight_bg");
                          if (index($modifier_data,"irc_action") >= 0){
			    $line = colorize_nicks($high_color,$modifier_data,$line);
                            $nick = $prefix_action_with_color;
			    $line = $high_color . $nick . "\t" . $high_color . $line . weechat::color('reset');
			    return $line;
			  }
		    $line = colorize_nicks($high_color,$modifier_data,$line);
		    $line = $nick_mode . $high_color . $nick_prefix_with_color . $nick . $nick_suffix_with_color . "\t" . $high_color . $line . weechat::color('reset');
		    return $line;
		  }
	      }
      }
	# buffer_autoset is off.
        if ( weechat::string_has_highlight($line, $my_nick) >= 1){
#        if (lc($string) =~ m/(\w.*$my_nick.*)/){                                                # my name called in string (case insensitiv)?
	    my $color_highlight = weechat::config_color(weechat::config_get("weechat.color.chat_highlight"));
	    my $color_highlight_bg = weechat::config_color(weechat::config_get("weechat.color.chat_highlight_bg"));

	    my $high_color = weechat::color("$color_highlight,$color_highlight_bg");

              if (index($modifier_data,"irc_action") >= 0){                                    # action used (/me)?
                $line = colorize_nicks($high_color,$modifier_data,$line);
                $nick = $prefix_action_with_color;
                $line = $high_color . $nick . "\t" . $high_color . $line . weechat::color('reset');
                return $line;
	      }

# highlight whole line
	if ( $var_hl_max_level_nicks_add eq 0 ){
	      $line = colorize_nicks($high_color,$modifier_data,$line);
	      $line = $nick_prefix_with_color . $nick_mode . $high_color . $nick . $nick_suffix_with_color . "\t" . $high_color . $line . weechat::color('reset');
	      return $line;
	}
	}
    } # highlight area finished

return $string if check_whitelist_nicks($servername, $my_nick, $nick_wo_suffix);                # check for whitelist
# this one check for other nick!!
if ( $default_options{var_avail_buffer} ne "all" ){                                             # check for option avail_buffer
  if ( index($modifier_data,"notify_message") > -1){                                            # message is public
    return $string if ( $default_options{var_avail_buffer} ne "channel" );
  }elsif ( index($modifier_data,"notify_private") > -1){                                        # message is privat
    return $string if ( $default_options{var_avail_buffer} ne "query" );
  }
}

# simple channel message
    if ($default_options{var_chat} eq "on"){                                                    # chat_mode on?
	if ($default_options{var_shuffle} eq "on"){                                             # color_shuffle on?
	  my $zahl2 = 0;
	  my $my_color = weechat::config_color(weechat::config_get("weechat.color.chat_nick_self"));# get my own nick colour
	    for (1){                                                                            # get a random colour but don't use
	      redo if ( $zahl ==  ($zahl2 = int(rand(14))) or ($colours{$zahl2} eq $my_color) );# latest color nor own nick color
	      $zahl = $zahl2;
	    }
	  $nick_color = weechat::color($colours{$zahl});                                        # get new random color
	}

# check for weechat version and use weechat.look.highlight_regex option
       if ( $weechat_version eq 1 ){                                                            # weechat is >= 0.3.4?
	  if ( $default_options{var_look_highlight_regex} eq "on" ){
	    if ( weechat::string_has_highlight_regex($line,weechat::config_string(weechat::config_get("weechat.look.highlight_regex"))) eq 1 ){
		my $color_highlight = weechat::config_color(weechat::config_get("weechat.color.chat_highlight"));
		my $color_highlight_bg = weechat::config_color(weechat::config_get("weechat.color.chat_highlight_bg"));

		my $high_color = weechat::color("$color_highlight,$color_highlight_bg");
		$line = colorize_nicks($high_color,$modifier_data,$line);
		$line = $nick_prefix_with_color . $nick_mode . $high_color . $nick . $nick_suffix_with_color . "\t" . $high_color . $line . weechat::color('reset');
		return $line;
	    }
	  }
	}
          if (index($modifier_data,"irc_action") >= 0){
#	  if ($default_options{prefix_action} eq $nick){
                my $nick_color = weechat::info_get('irc_nick_color', $nick_wo_suffix);          # get nick-color
		$line = colorize_nicks($nick_color,$modifier_data,$line);
                $nick = $prefix_action_with_color;
		$line = $nick . "\t" . $nick_color . $line . weechat::color('reset');
		return $line;
	  }

      $line = colorize_nicks($nick_color,$modifier_data,$line);
      $line = $nick_prefix_with_color . $nick_mode . $nick_color . $nick . $nick_suffix_with_color .  "\t" . $nick_color . $line . weechat::color('reset');  # create new line nick_color+nick+separator+text
      return $line;
    }else{
      return $string;										# return original string
    }
} # end of sub colorize_cb{}

# whitelist nicks
sub check_whitelist_nicks{
my ( $servername, $my_nick, $nick_wo_suffix ) = @_;
  if ( $default_options{var_nicks} ne "" and $default_options{var_own_lines} eq "off" ){          # nicks in option and own_lines = off
        return 1 unless (grep /^\Q$servername.$nick_wo_suffix\E$/i, @nick_list)                   # check other nicks
  }elsif ( $default_options{var_nicks} ne "" and $default_options{var_own_lines} eq "on" ){       # nicks in option and own_lines = on
      if ( $nick_wo_suffix ne $my_nick){                                                          # not my nick!
        return 1 unless (grep /^\Q$servername.$nick_wo_suffix\E$/i, @nick_list)                   # check other nicks
      }
  }elsif( $default_options{var_nicks} eq "" and $default_options{var_own_lines} eq "off" ){       # no nicks and do not color my line?
      if ( $nick_wo_suffix eq $my_nick){                                                          # my nick?
        return 1;                                                                                 # yes
      }
  }
return 0;
}

# converts shell wildcard characters to regex
sub shell2regex {
    my $globstr = shift;
    my %patmap = (
        '*' => '.*',
        '?' => '.',
        '[' => '[',
        ']' => ']',
    );
    $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
    return $globstr;
}

# check for colorize_nicks script an set colour before and after nick name 
sub colorize_nicks{
my ( $nick_color, $mf_data, $line ) = @_;

my $pyth_ptn = weechat::infolist_get("python_script","","colorize_nicks");
weechat::infolist_next($pyth_ptn);

if ( "colorize_nicks" eq weechat::infolist_string($pyth_ptn,"name") ){				# does colorize_nicks is installed?
	$line = weechat::hook_modifier_exec( "colorize_nicks",$mf_data,$line);			# call colorize_nicks function and color the nick(s)
	my @array = "";
	my $color_code_reset = weechat::color('reset');
	@array=split(/$color_code_reset/,$line);
	my $new_line = "";
	foreach (@array){
	  $new_line .=  $nick_color . $_ . weechat::color('reset');
	}
	$new_line =~ s/\s+$//g;									# remove space at end
	$line = $new_line;
}
weechat::infolist_free($pyth_ptn);

return $line;
}

# -----------------------------[ config ]-----------------------------------
sub init_config{
    foreach my $option ( keys %default_options ){
        $option = substr($option,4,length($option)-4);
        if (!weechat::config_is_set_plugin($option)){
            weechat::config_set_plugin($option, $default_options{"var_" . $option});
        }else{
            $default_options{"var_" . $option} = lc( weechat::config_get_plugin($option) );
        }
    }

    if ( ($weechat_version ne "") && (weechat::info_get("version_number", "") >= 0x00030500) ) {    # v0.3.5
        description_options();
    }

    if ( $default_options{"var_blacklist_channels"} ne "" ){
        @var_blacklist_channels = "";
        @var_blacklist_channels = split( /,/, $default_options{"var_blacklist_channels"} );
    }
    if ( $default_options{var_nicks} ne "" ){
      undef (@nick_list);
      if ( substr($default_options{var_nicks}, 0, 1) eq "/" ){                                # get first chat of nicks "/" ?
          nicklist_read();                                                                      # read nicks from file
      }else{
          @nick_list = split( /,/, $default_options{var_nicks} );                             # use nicks from option
      }
    }

}

sub toggle_config_by_set{
my ( $pointer, $name, $value ) = @_;
    $name = substr($name,length("plugins.var.perl.$prgname."),length($name));
    $default_options{"var_" . $name} = lc($value);

    if ( $name eq "blacklist_channels" ){
      @var_blacklist_channels = "";
      @var_blacklist_channels = split( /,/, $default_options{"var_" . $name} );
    }
    if ( $name eq "nicks" ){
      undef (@nick_list);
      if ( $default_options{"var_".$name} eq "" ){                                              # no nicks given
          undef (@nick_list);
#          count_nicks();
      }elsif ( substr($default_options{var_nicks}, 0, 1) eq "/" ){                             # get first chat of nicks "/" ?
          nicklist_read();                                                                      # read nicks from file
#          count_nicks();
      }else{
          @nick_list = split( /,/, $default_options{"var_" . $name} );
#          count_nicks();
      }
    }

$default_options{var_avail_buffer} = "all" if ( $default_options{var_avail_buffer} eq "" );

return weechat::WEECHAT_RC_OK ;
}

# create description options for script...
sub description_options{
    foreach my $option ( keys %help_desc ){
        weechat::config_set_desc_plugin( $option,$help_desc{$option} );
    }
}

# toggle functions on/off with command line
sub change_settings{
my $getarg = lc($_[2]); # switch to lower-case

    foreach my $option ( keys %default_options ){
      $option = substr($option,4,length($option)-4);            # remove "var_" from option
      if ( $getarg eq $option ){
        if ( $default_options{"var_" . $option} eq "on" ){
          weechat::config_set_plugin( $option, "off" );
        }else{
          weechat::config_set_plugin( $option, "on" );
        }
      }
    }
return weechat::WEECHAT_RC_OK;
}

sub nicklist_read {
        undef (@nick_list);
        my $weechat_dir = weechat::info_get( "weechat_dir", "" );
        my $nicklist = weechat::config_get_plugin("nicks");
        $nicklist = $weechat_dir.$nicklist;
        $default_options{var_nicks} = "" unless -e $nicklist;
        return unless -e $nicklist;
        open (WL, "<", $nicklist) || DEBUG("$nicklist: $!");
        while (<WL>) {
                chomp;                                                          # kill LF
                        my ( $servername, $nickname ) = split /\./;           # servername,nickname (seperator could be "," or ".")
                        if (not defined $nickname){
                                close WL;
                                weechat::print("",weechat::prefix("error")."$prgname: $nicklist is not valid format (<servername>.<nickname>).");
                                return;
                        }
              push @nick_list,($servername.".".$nickname."," );                 # servername.nickname+","
        }
        close WL;
        chop @nick_list;                                                        # remove last ","
}

# debug....
sub count_nicks{
  my $anzahl=@nick_list;
  weechat::print("","anzahl: $anzahl");

  foreach (@nick_list){
      weechat::print ("","$_");
  }
}
# -------------------------------[ init ]-------------------------------------
# first function called by a WeeChat-script.
weechat::register($prgname, "Nils Görs <weechatter\@arcor.de>", $version,
                  "GPL3", $description, "", "");
# check weechat version
  $weechat_version = weechat::info_get("version_number", "");
  if (( $weechat_version eq "" ) or ( $weechat_version < 0x00030400 )){
    weechat::print("",weechat::prefix("error")."$prgname: needs WeeChat >= 0.3.4. Please upgrade: http://www.weechat.org/");
    weechat::command("","/wait 1ms /perl unload $prgname");
  }


init_config();


$get_prefix_action = weechat::config_string(weechat::config_get("weechat.look.prefix_action"));
weechat::hook_modifier("weechat_print","colorize_cb", "");
weechat::hook_modifier("colorize_lines","colorize_cb", "");

  if (( $weechat_version ne "" ) && ( $weechat_version >= 0x00030400 )){        # v0.3.4?
    $weechat_version = 1;                                                       # yes!

    # read nick colours if exists (>= weechat 0.3.4) in %colours
    my $colours_buf = weechat::config_string(weechat::config_get("weechat.color.chat_nick_colors"));
    if ( $colours_buf ne "" ) {
        my @array = split(/,/,$colours_buf);
        my $i = 0;
        foreach (@array){
          $colours{$i++} = $_;
        }
      undef $colours_buf;
      undef @array;
    }
  }

weechat::hook_command($prgname, $description,

        "<highlight> || <chat> || <shuffle> || <autoset> || <look_highlight> || <look_highlight_regex> || <hotlist> || <own_lines>",

        "<highlight>            toggle highlight color in chat area (on/off)\n".
        "<chat>                 colors the text in chat area with according nick color (on/off)\n".
        "<shuffle>              toggle shuffle color mode on/off\n".
        "<autoset>              toggle highlight color mode for buffer_autoset on/off\n".
        "<look_highlight>       toggle highlight color mode for weechat.look.highlight on/off\n".
        "<look_highlight_regex> toggle highlight color in chat area for option weechat.look.highlight_regex on/off\n".
        "<hotlist>              toggle hotlist_max_level_nicks_add on/off\n".
        "<own_lines>            toggle coloring of own lines on/off\n".
        "\n".
        "Options (script):\n".
        "   'plugins.var.perl.$prgname.highlight'                   : $help_desc{highlight}\n".
        "   'plugins.var.perl.$prgname.hotlist_max_level_nicks_add' : $help_desc{hotlist_max_level_nicks_add}\n".
        "   'plugins.var.perl.$prgname.buffer_autoset'              : $help_desc{buffer_autoset}\n".
        "   'plugins.var.perl.$prgname.look_highlight'              : $help_desc{look_highlight}\n".
        "   'plugins.var.perl.$prgname.look_highlight_regex'        : $help_desc{look_highlight_regex}\n".
        "   'plugins.var.perl.$prgname.chat'                        : $help_desc{chat}\n".
        "   'plugins.var.perl.$prgname.shuffle'                     : $help_desc{shuffle}\n".
        "   'plugins.var.perl.$prgname.blacklist_channels'          : $help_desc{blacklist_channels}\n".
        "   'plugins.var.perl.$prgname.avail_buffer'                : $help_desc{avail_buffer}\n".
        "   'plugins.var.perl.$prgname.nicks'                       : $help_desc{nicks}\n".
        "   'plugins.var.perl.$prgname.own_lines'                   : $help_desc{own_lines}\n".
        "\n".
        "Options (global):\n".
        "   'weechat.color.chat_highlight'                      : highlight color\n".
        "   'weechat.color.chat_highlight_bg'                   : highlight background color\n".
        "   'weechat.color.chat_nick*'                          : colors for nicks\n\n".
        "To use options \"buffer_autoset\" and/or \"hotlist_max_level_nicks_add\" install buffer_autoset script from: http://www.weechat.org/scripts/\n",
        "highlight|chat|shuffle|autoset|look_highlight|look_highlight_regex|hotlist|own_lines %-", "change_settings", "");

weechat::hook_config( "plugins.var.perl.$prgname.*", "toggle_config_by_set", "" );
