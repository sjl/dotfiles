#
# UrlGrab, version 2.0 for weechat version 0.3
#
#   Listens to all channels for URLs, collects them in a list, and launches
#   them in your favourite web server on the local host or a remote server.
#   Copies url to X11 clipboard via xsel
#      (http://www.vergenet.net/~conrad/software/xsel)
#
# Usage:
#
#   The /url command provides access to all UrlGrab functions.  Run
#   '/help url' for complete command usage.
#
#   In general, use '/url list' to list the entire url list for the current
#   channel, and '/url <n>' to launch the nth url in the list.  For
#   example, to launch the first (and most-recently added) url in the list,
#   you would run '/url 1'
#
#   From the server window, you must specify a specific channel for the
#   list and launch commands, for example:
#     /url list weechat 
#     /url 3 weechat
#
# Configuration:
#
#   The '/url set' command lets you get and set the following options:
#
#   historysize
#     The maximum number of URLs saved per channel.  Default is 10
#
#   method
#     Must be one of 'local' or 'remote' - Defines how URLs are launched by
#     the script.  If 'local', the script will run 'localcmd' on the host.
#     If 'remote', the script will run 'remotessh remotehost remotecmd' on
#     the local host which should normally use ssh to connect to another
#     host and run the browser command there.
#
#   localcmd
#     The command to run on the local host to launch URLs in 'local' mode.
#     The string '%s' will be replaced with the URL.  The default is
#     'firefox %s'.
#
#   remotessh
#     The command (and arguments) used to connect to the remote host for
#     'remote' mode.  The default is 'ssh -x' which will connect as the
#     current username via ssh and disable X11 forwarding.
#
#   remotehost
#     The remote host to which we will connect in 'remote' mode.  For ssh,
#     this can just be a hostname or 'user@host' to specify a username
#     other than your current login name.  The default is 'localhost'.
#
#   remotecmd
#     The command to execute on the remote host for 'remote' mode.  The
#     default is 'bash -c "DISPLAY=:0.0 firefox %s"'  Which runs bash, sets
#     up the environment to display on the remote host's main X display,
#     and runs firefox.  As with 'localcmd', the string '%s' will be
#     replaced with the URL.
#
#   cmdoutput
#     The file where the command output (if any) is saved.  Overwritten
#     each time you launch a new URL.  Default is ~/.weechat/urllaunch.log
#
#   default
#     The command that will be run if no arguemnts to /url are given.
#     Default is show
#
# Requirements:
#
#  - Designed to run with weechat version 0.3 or better.
#      http://www.weechat.org/
#
# Acknowlegements:
#
#  - Based on an earlier version called 'urlcollector.py' by 'kolter' of
#    irc.freenode.net/#weechat Honestly, I just cleaned up the code a bit and
#    made the settings a little more useful (to me).
#
#  - With changes by Leonid Evdokimov (weechat at darkk dot net another dot ru):
#    http://darkk.net.ru/weechat/urlgrab.py
#    v1.1:  added better handling of dead zombie-childs
#           added parsing of private messages
#           added default command setting
#           added parsing of scrollback buffers on load
#    v1.2:  `historysize` was ignored
#
#  - With changes by ExclusivE (exclusive_tm at mail dot ru):
#    v1.3: X11 clipboard support
#
#  - V1.4 Just ported it over to weechat 0.2.7  drubin AT smartcube dot co dot za
#  - V1.5  1) I created a logging feature for urls, Time, Date, buffer, and url.
#           2) Added selectable urls support, similar to the iset plugin (Thanks FlashCode)
#           3) Colors/formats are configuarable.
#           4) browser now uses hook_process (Please test with remote clients)
#           5) Added /url open http://url.com functionality
#           6) Changed urls detection to use regexpressions so should be much better
#                Thanks to xt of #weechat bassed on on urlbar.py
#  - V1.6 FlashCode <flashcode@flashtux.org>: Increase timeout for hook_process
#         (from 1 second to 1 minute)
#  - V1.7 FlashCode <flashcode@flashtux.org>: Update WeeChat site
#  - V1.8 drubin <drubin [at] smartcube . co.za>: 
#           - Changed remote cmd to be single option
#           - Added scrolling on up and down arrow keys for /url show
#           - Changed remotecmd to include options with public/private keys password auth doesn't work
#  - V1.9 Specimen <spinifer [at] gmail . com>: 
#           - Changed the default command when /url is run with no arguments to 'show'
#           - Removed '/url help' command, because /help <command> is the standard way
#  - V2.0 Xilov: replace "/url help" by "/help url"
#
# Copyright (C) 2005 David Rubin <drubin AT smartcube dot co dot za>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
# USA.
#

import sys
import os
try:
    import weechat
    import_ok = True
except:
    print "This script must be run under WeeChat."
    print "Get WeeChat now at: http://www.weechat.org/"
    import_ok = False
import subprocess
import time
import re
from UserDict import UserDict


octet = r'(?:2(?:[0-4]\d|5[0-5])|1\d\d|\d{1,2})'
ipAddr = r'%s(?:\.%s){3}' % (octet, octet)
# Base domain regex off RFC 1034 and 1738
label = r'[0-9a-z][-0-9a-z]*[0-9a-z]?'
domain = r'%s(?:\.%s)*\.[a-z][-0-9a-z]*[a-z]?' % (label, label)
urlRe = re.compile(r'(\w+://(?:%s|%s)(?::\d+)?(?:/[^\])>\s]*)?)' % (domain, ipAddr), re.I)


SCRIPT_NAME    = "urlgrab"
SCRIPT_AUTHOR  = "David Rubin <drubin [At] smartcube [dot] co [dot] za>"
SCRIPT_VERSION = "2.0"
SCRIPT_LICENSE = "GPL"
SCRIPT_DESC    = "Url functionality Loggin, opening of browser, selectable links"
CONFIG_FILE_NAME= "urlgrab" 
SCRIPT_COMMAND = "url"


def urlGrabPrint(message):
    bufferd=weechat.current_buffer()
    if urlGrabSettings['output_main_buffer'] == 1 :
        weechat.prnt("","[%s] %s" % ( SCRIPT_NAME, message ) )
    else :
        weechat.prnt(bufferd,"[%s] %s" % ( SCRIPT_NAME, message ) )
        
def hashBufferName(bufferp):
    if not weechat.buffer_get_string(bufferp, "short_name"):
        bufferd = weechat.buffer_get_string(bufferp, "name")
    else:
        bufferd = weechat.buffer_get_string(bufferp, "short_name")
    return bufferd
    
def ug_config_reload_cb(data, config_file):
    """ Reload configuration file. """
    return weechat.config_read(config_file)

class UrlGrabSettings(UserDict):
    def __init__(self):
        UserDict.__init__(self)
        self.data = {}
        self.config_file = weechat.config_new(CONFIG_FILE_NAME,
                                        "ug_config_reload_cb", "")
        if not self.config_file:
            return
            
        section_color = weechat.config_new_section(
            self.config_file, "color", 0, 0, "", "", "", "", "", "",
                     "", "", "", "")
        section_default = weechat.config_new_section(
            self.config_file, "default", 0, 0, "", "", "", "", "", "",
                     "", "", "", "")
                     
        self.data['color_buffer']=weechat.config_new_option(
            self.config_file, section_color,
            "color_buffer", "color", "Color to display buffer name", "", 0, 0,
            "red", "red", 0, "", "", "", "", "", "")
        
        self.data['color_url']=weechat.config_new_option(
            self.config_file, section_color,
            "color_url", "color", "Color to display urls", "", 0, 0,
            "blue", "blue", 0, "", "", "", "", "", "")
         
        self.data['color_time']=weechat.config_new_option(
            self.config_file, section_color,
            "color_time", "color", "Color to display time", "", 0, 0,
            "cyan", "cyan", 0, "", "", "", "", "", "")
       
        self.data['color_buffer_selected']=weechat.config_new_option(
            self.config_file, section_color,
            "color_buffer_selected", "color", 
            "Color to display buffer selected name", "", 0, 0, "red", "red", 
            0, "", "", "", "", "", "")
        
        self.data['color_url_selected']=weechat.config_new_option(
            self.config_file, section_color,
            "color_url_selected", "color", "Color to display url selected",
             "", 0, 0, "blue", "blue", 0, "", "", "", "", "", "")
            
        self.data['color_time_selected']=weechat.config_new_option(
            self.config_file, section_color,
            "color_time_selected", "color", "Color to display tim selected", 
            "", 0, 0, "cyan", "cyan", 0, "", "", "", "", "", "")    
        
        self.data['color_bg_selected']=weechat.config_new_option(
            self.config_file, section_color,
            "color_bg_selected", "color", "Background for selected row", "", 0, 0,
            "green", "green", 0, "", "", "", "", "", "") 
            
        self.data['historysize']=weechat.config_new_option(
            self.config_file, section_default,
            "historysize", "integer", "Max number of urls to store per buffer", 
            "", 0, 999, "10", "10", 0, "", "", "", "", "", "") 
        
        self.data['method']=weechat.config_new_option(
            self.config_file, section_default,
            "method", "string", """Where to launch URLs
            If 'local', runs %localcmd%.
            If 'remote' runs the following command:
            '%remodecmd%'""", "", 0, 0,
            "local", "local", 0, "", "", "", "", "", "") 
            
            
        self.data['localcmd']=weechat.config_new_option(
            self.config_file, section_default,
            "localcmd", "string", """Local command to execute""", "", 0, 0,
            "firefox %s", "firefox %s", 0, "", "", "", "", "", "") 
        
        remotecmd="ssh -x localhost -i ~/.ssh/id_rsa -C \"export DISPLAY=\":0.0\" &&  firefox %s\""
        self.data['remotecmd']=weechat.config_new_option(
            self.config_file, section_default,
            "remotecmd", "string", remotecmd, "", 0, 0,
            remotecmd, remotecmd, 0, "", "", "", "", "", "")
            
        self.data['url_log']=weechat.config_new_option(
            self.config_file, section_default,
            "url_log", "string", """log location""", "", 0, 0,
            "~/.weechat/urls.log", "~/.weechat/urls.log", 0, "", "", "", "", "", "")
            
        self.data['time_format']=weechat.config_new_option(
            self.config_file, section_default,
            "time_format", "string", """TIme format""", "", 0, 0,
            "%H:%M:%S", "%H:%M:%S", 0, "", "", "", "", "", "")
            
        self.data['output_main_buffer']=weechat.config_new_option(
            self.config_file, section_default,
            "output_main_buffer", "boolean", 
            """Print text to main buffer or current one""", "", 0, 0, "1", "1",
             0, "", "", "", "", "", "")
        weechat.config_read(self.config_file)

    def __getitem__(self, key):
        if key == "historysize":
            return weechat.config_integer(self.data[key])
        elif key == 'output_main_buffer':
            return weechat.config_boolean(self.data[key])
        #elif key.startswith('color'):
        #    return weechat.config_color(self.data[key])
        else:
            return weechat.config_string(self.data[key])

    def prnt(self, name, verbose = True):
        weechat.prnt( ""," %s = %s" % (name.ljust(11), self.data[name]) )

    def prntall(self):
        for key in self.names():
            self.prnt(key, verbose = False)

    def createCmd(self, url):
        str =""
        if self['method'] == 'remote':
            str = self['remotecmd']  % url
        else:
            str =  self['localcmd']  % url
        return str

class UrlGrabber:
    def __init__(self, historysize):
        # init
        self.urls = {}
        self.globalUrls = []
        self.historysize = 5
        # control
        self.setHistorysize(historysize)

    def setHistorysize(self, count):
        if count > 1:
            self.historysize = count

    def getHistorysize(self):
        return self.historysize

    def addUrl(self, bufferp,url ):
        global urlGrabSettings
        self.globalUrls.insert(0,{"buffer":bufferp, 
            "url":url, "time":time.strftime(urlGrabSettings["time_format"])})
        #Log urls only if we have set a log path.
        if urlGrabSettings['url_log']:
            try :
                index = self.globalUrls[0] 
                logfile = os.path.expanduser(urlGrabSettings['url_log'])
                dout = open(logfile, "a")
                dout.write("%s %s %s\n" % (index['time'], 
                                           index['buffer'], index['url']))
                dout.close()
            except :
                print "failed to log url check that %s is valid path" % urlGrabSettings['url_log']
                pass
        
        # check for buffer
        if not bufferp in self.urls:
            self.urls[bufferp] = []
        # add url
        if url in self.urls[bufferp]:
            self.urls[bufferp].remove(url)
        self.urls[bufferp].insert(0, url)
        # removing old urls
        while len(self.urls[bufferp]) > self.historysize:
            self.urls[bufferp].pop()

    def hasIndex( self, bufferp, index ):
        return bufferp in self.urls and \
                len(self.url[bufferp]) >= index

    def hasBuffer( self, bufferp ):
        return bufferp in self.urls
    

    def getUrl(self, bufferp, index):
        url = ""
        if  bufferp in self.urls:
            if len(self.urls[bufferp]) >= index:
                    url = self.urls[bufferp][index-1]
        return url
        

    def prnt(self, buff):
        found = True
        if self.urls.has_key(buff):
            if len(self.urls[buff]) > 0:
                i = 1
                for url in self.urls[buff]:
                    urlGrabPrint("--> " + str(i) + " : " + url)
                    i += 1
            else:
                found = False
        elif buff == "*":
            for b in self.urls.keys():
              self.prnt(b)
        else:
            found = False

        if not found:
            urlGrabPrint(buff + ": no entries")

def urlGrabCheckMsgline(bufferp, message):
	global urlGrab, max_buffer_length
	if not message:
		return
	# Ignore output from 'tinyurl.py' and our selfs
	if ( message.startswith( "[AKA] http://tinyurl.com" ) or 
        message.startswith("[urlgrab]") ):
		return
	# Check for URLs
	for url in urlRe.findall(message):
	    urlGrab.addUrl(bufferp,url)
        if max_buffer_length < len(bufferp):
            max_buffer_length = len(bufferp)
        if urlgrab_buffer:
            refresh()
            

def urlGrabCheck(data, bufferp, uber_empty, tagsn, isdisplayed, ishilight, prefix, message):
	urlGrabCheckMsgline(hashBufferName(bufferp), message)
	return weechat.WEECHAT_RC_OK

def urlGrabCopy(bufferd, index):
    global urlGrab
    if bufferd == "":
        urlGrabPrint( "No current channel, you must activate one" )
    elif not urlGrab.hasBuffer(bufferd):
        urlGrabPrint("No URL found - Invalid channel")
    else:
        if index <= 0:
            urlGrabPrint("No URL found - Invalid index")
            return
        url = urlGrab.getUrl(bufferd,index)
    if url == "":
        urlGrabPrint("No URL found - Invalid index")
    else:
        try:
            pipe = os.popen("xsel -i","w")
            pipe.write(url)
            pipe.close()
            urlGrabPrint("Url: %s gone to clipboard." % url)
        except:
            urlGrabPrint("Url: %s faile to copy to clipboard." % url)

def urlGrabOpenUrl(url):
    global urlGrab, urlGrabSettings
    argl = urlGrabSettings.createCmd( url )
    weechat.hook_process(argl,60000, "ug_open_cb", "")

def ug_open_cb(data, command, code, out, err):
    #print out
    #print err
    return weechat.WEECHAT_RC_OK
    

def urlGrabOpen(bufferd, index):
    global urlGrab, urlGrabSettings 
    if bufferd == "":
        urlGrabPrint( "No current channel, you must specify one" )
    elif not urlGrab.hasBuffer(bufferd) :
        urlGrabPrint("No URL found - Invalid channel")
    else:
        if index <= 0:
            urlGrabPrint("No URL found - Invalid index")
            return
        url =  urlGrab.getUrl(bufferd,index)
        if url == "":
            urlGrabPrint("No URL found - Invalid index")
        else:
            urlGrabPrint("loading %s %sly" % (url, urlGrabSettings["method"]))
            urlGrabOpenUrl (url)

def urlGrabList( args ):
    global urlGrab
    if len(args) == 0:
        buf = hashBufferName(weechat.current_buffer())
    else:
        buf = args[0]
    if buf == "" or buf == "all":
        buf = "*"
    urlGrab.prnt(buf)


def urlGrabMain(data, bufferp, args):
    if args[0:2] == "**":
        keyEvent(data, bufferp, args[2:])
        return weechat.WEECHAT_RC_OK

    bufferd = hashBufferName(bufferp)
    largs = args.split(" ")
    #strip spaces
    while '' in largs:
        largs.remove('')
    while ' ' in largs:
        largs.remove(' ')
    if len(largs) == 0 or largs[0] == "show":
        if not urlgrab_buffer:
            init()
        refresh()
        weechat.buffer_set(urlgrab_buffer, "display", "1")
    elif largs[0] == 'open' and len(largs) == 2:
        urlGrabOpenUrl(largs[1])
    elif largs[0] == 'list':
        urlGrabList( largs[1:] )
    elif largs[0] == 'copy':
        if len(largs) > 1:
            no = int(largs[1])
            urlGrabCopy(bufferd, no)
	else:
		urlGrabCopy(bufferd,1)
    else:
        try:
            no = int(largs[0])
            if len(largs) > 1:
                urlGrabOpen(largs[1], no)
            else:
                urlGrabOpen(bufferd, no)
        except ValueError:
            #not a valid number so try opening it as a url.. 
            for url in urlRe.findall(largs[0]):
                urlGrabOpenUrl(url)
            urlGrabPrint( "Unknown command '%s'.  Try '/help url' for usage" % largs[0])
    return weechat.WEECHAT_RC_OK

def buffer_input(*kwargs):
    return weechat.WEECHAT_RC_OK

def buffer_close(*kwargs):
    global urlgrab_buffer
    urlgrab_buffer =  None
    return weechat.WEECHAT_RC_OK

def keyEvent (data, bufferp, args):
    global urlGrab , urlGrabSettings, urlgrab_buffer, current_line
    if args == "refresh":
        refresh()
    elif args == "up":
        if current_line > 0:
            current_line = current_line -1
            refresh_line (current_line + 1)
            refresh_line (current_line)
            ugCheckLineOutsideWindow()
    elif args == "down":
         if current_line < len(urlGrab.globalUrls) - 1:
            current_line = current_line +1
            refresh_line (current_line - 1)
            refresh_line (current_line)
            ugCheckLineOutsideWindow()
    elif args == "scroll_top":
        temp_current = current_line
        current_line =  0
        refresh_line (temp_current)
        refresh_line (current_line)
        weechat.command(urlgrab_buffer, "/window scroll_top")
        pass 
    elif args == "scroll_bottom":
        temp_current = current_line
        current_line =  len(urlGrab.globalUrls)
        refresh_line (temp_current)
        refresh_line (current_line)
        weechat.command(urlgrab_buffer, "/window scroll_bottom")
    elif args == "enter":
        if urlGrab.globalUrls[current_line]:
            urlGrabOpenUrl (urlGrab.globalUrls[current_line]['url'])

def refresh_line (y):
    global urlGrab , urlGrabSettings, urlgrab_buffer, current_line, max_buffer_length
    #Print format  Time(space)buffer(max4 spaces, but lined up)url
    format = "%%s%%s %%s%%-%ds%%s%%s" % (max_buffer_length+4)
    
    #non selected colors
    color_buffer = urlGrabSettings["color_buffer"]
    color_url = urlGrabSettings["color_url"]
    color_time =urlGrabSettings["color_time"]
    #selected colors
    color_buffer_selected = urlGrabSettings["color_buffer_selected"]
    color_url_selected = urlGrabSettings["color_url_selected"]
    color_time_selected = urlGrabSettings["color_time_selected"]
    
    color_bg_selected = urlGrabSettings["color_bg_selected"]
    
    color1 = color_time
    color2 = color_buffer
    color3 = color_url
    
    #If this line is selected we change the colors.
    if y == current_line:
          color1 = "%s,%s" % (color_time_selected, color_bg_selected)
          color2 = "%s,%s" % (color_buffer_selected, color_bg_selected)
          color3 = "%s,%s" % (color_url_selected, color_bg_selected)
          
    color1 = weechat.color(color1)
    color2 = weechat.color(color2)
    color3 = weechat.color(color3)
    text = format % (color1,
                    urlGrab.globalUrls[y]['time'],
                    color2, 
                    urlGrab.globalUrls[y]['buffer'],
                    color3, 
                    urlGrab.globalUrls[y]['url'] )
    weechat.prnt_y(urlgrab_buffer,y,text)
    
def ugCheckLineOutsideWindow():
    global urlGrab , urlGrabSettings, urlgrab_buffer, current_line, max_buffer_length   
    if (urlgrab_buffer):
        infolist = weechat.infolist_get("window", "", "current")
        if (weechat.infolist_next(infolist)):
            start_line_y = weechat.infolist_integer(infolist, "start_line_y")
            chat_height = weechat.infolist_integer(infolist, "chat_height")
            if(start_line_y > current_line):
                weechat.command(urlgrab_buffer, "/window scroll -%i" %(start_line_y - current_line))
            elif(start_line_y <= current_line - chat_height):
                weechat.command(urlgrab_buffer, "/window scroll +%i"%(current_line - start_line_y - chat_height + 1))
        weechat.infolist_free(infolist)
    

def refresh():
    global urlGrab
    y=0
    for x in urlGrab.globalUrls:
        refresh_line (y)
        y += 1
    
    
def init():
    global urlGrab , urlGrabSettings, urlgrab_buffer
    if not urlgrab_buffer:
        urlgrab_buffer = weechat.buffer_new("urlgrab", "buffer_input", "", "buffer_close", "")
    if urlgrab_buffer:
        weechat.buffer_set(urlgrab_buffer, "type", "free")
        weechat.buffer_set(urlgrab_buffer, "key_bind_ctrl-R",        "/url **refresh")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta2-A",       "/url **up")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta2-B",       "/url **down")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta-ctrl-J",   "/url **enter")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta-ctrl-M",   "/url **enter")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta-meta2-1./~", "/url **scroll_top")
        weechat.buffer_set(urlgrab_buffer, "key_bind_meta-meta2-4~", "/url **scroll_bottom")
        weechat.buffer_set(urlgrab_buffer, "title","Lists the urls in the applications")
        weechat.buffer_set(urlgrab_buffer, "display", "1")

def completion_urls_cb(data, completion_item, bufferp, completion):
    """ Complete with URLS, for command '/url'. """
    global urlGrab
    bufferd = hashBufferName( bufferp)
    for url in urlGrab.globalUrls :
        if url['buffer'] == bufferd:
            weechat.hook_completion_list_add(completion, url['url'], 0, weechat.WEECHAT_LIST_POS_SORT)
    return weechat.WEECHAT_RC_OK

def ug_unload_script():
    """ Function called when script is unloaded. """
    global urlGrabSettings
    weechat.config_write(urlGrabSettings.config_file)
    return weechat.WEECHAT_RC_OK

#Main stuff
if ( import_ok and 
    weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION,
        SCRIPT_LICENSE,SCRIPT_DESC, "ug_unload_script", "") ):
    urlgrab_buffer = None
    current_line = 0
    max_buffer_length = 0
    urlGrabSettings = UrlGrabSettings()
    urlGrab = UrlGrabber( urlGrabSettings['historysize'])
    weechat.hook_print("", "", "", 1, "urlGrabCheck", "")
    weechat.hook_command(SCRIPT_COMMAND,
                             "Url Grabber",
                             "[open <url> | <url> | show | copy [n] | [n] | list]",
                             "open or <url>: opens the url\n"
                             "show: Opens the select buffer to allow for url selection\n"
                             "copy: Copies the nth url to the system clipboard\n"
                             "list: Lists the urls in the current buffer\n",
                             "open %(urlgrab_urls) || %(urlgrab_urls) || "
                             "copy || show || list",
                             "urlGrabMain", "")
    weechat.hook_completion("urlgrab_urls", "list of URLs",
                                "completion_urls_cb", "")
else:
    print "failed to load weechat"
