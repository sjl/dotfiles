# bicycle repair man idle extension
import bike
from bike.transformer.undo import UndoStackEmptyException
import bike.parsing.load
import os
from Tkinter import *
import tkFileDialog
import tkMessageBox
import tkSimpleDialog
import sys
import string
try:
    from idlelib.PathBrowser import *
    from idlelib.WindowList import ListedToplevel
    from idlelib.TreeWidget import TreeNode, TreeItem, ScrolledCanvas
    from idlelib import EditorWindow
    from idlelib.PyShell import PyShell
    from idlelib.OutputWindow import OutputWindow
    try:
        from idlelib.configHandler import idleConf
    except ImportError:
        pass



except ImportError:
    from PathBrowser import*
    from WindowList import ListedToplevel
    from TreeWidget import TreeNode, TreeItem, ScrolledCanvas
    import EditorWindow
    from PyShell import PyShell
    from OutputWindow import OutputWindow
    try:
        from configHandler import idleConf
    except ImportError:
        pass

brmctx = None
shellwin = None
loadingFiles = 0
matchwin = None

class NotHighlightedException(Exception):
    pass

class BicycleRepairMan_Idle:
    menudefs = [
    ('bicycleRepairMan', [
        ('----- Queries -----',''),
        ('_Find References','<<brm-find-references>>'),
        ('_Find Definition','<<brm-find-definition>>'),
        None,
        ('--- Refactoring ---',''),
        ('_Rename', '<<brm-rename>>'), 
        ('_Extract Method', '<<brm-extract-method>>'), 
        None,
        ('_Undo', '<<brm-undo>>'), 
        ])
    ]

    keydefs = {
    '<<brm-find-references>>':[],
    '<<brm-find-definition>>':[],
    '<<brm-rename>>':[], 
    '<<brm-extract-method>>':[], 
    '<<brm-undo>>':[], 
     }


    try:
        TRACE = idleConf.GetOption('extensions','BicycleRepairMan_Idle',
                                        'trace',default=1)        
    except NameError:   # hasnt imported idleconf - probably python 22
        TRACE = 1


    def __init__(self, editwin):
        self.editwin = editwin
        
        if self.TRACE == 1:
            self.progressLogger = ProgressLogger(self.editwin.flist)
            
        if not isinstance(editwin, PyShell):
            # sly'ly add the refactor menu to the window
            name, label = ("bicycleRepairMan", "_BicycleRepairMan")
            underline, label = EditorWindow.prepstr(label)
            mbar = editwin.menubar
            editwin.menudict[name] = menu = Menu(mbar, name = name)
            mbar.add_cascade(label = label, menu = menu, underline = underline)

            # Initialize Bicyclerepairman and import the code
            path = self.editwin.io.filename
            if path is not None:
                global brmctx
                if brmctx is None:
                    self.initbrm()
        else:
            global shellwin
            shellwin = editwin


    def initbrm(self):
        global brmctx
        brmctx = bike.init()
        if self.TRACE == 1:
            brmctx.setProgressLogger(self.progressLogger)
        

    def brm_find_references_event(self,event):
        try:
            if not self.confirm_all_buffers_saved():
                return

            if self.editwin.text.index("sel.first") == "":
                self.errorbox("Not highlighted", "Highlight the name of a Function, Class or Method and try again")
                return

            filename = os.path.normpath(self.editwin.io.filename)
            line, column = string.split(self.editwin.text.index("sel.first"),'.')

            numMatches = 0
            global matchwin
            if matchwin is None:
                matchwin = BRMMatchesWindow(self.editwin.flist, self)

            matchwin.clear()

            for ref in brmctx.findReferencesByCoordinates(filename,int(line),int(column)):
                print >>matchwin, "File \""+ref.filename+"\", line "+str(ref.lineno)+", "+str(ref.confidence)+"% confidence"
                numMatches +=1

            print >>matchwin, numMatches," matches"
            print >>matchwin, "(Hint: right-click to open locations.)"
        except:
            self._handleUnexpectedException()


    def brm_find_definition_event(self,event):
        try:
            if not self.confirm_all_buffers_saved():
                return
            filename = os.path.normpath(self.editwin.io.filename)

            if self.editwin.text.index("sel.first") != "":
                line, column = string.split(self.editwin.text.index("sel.first"),'.')
            else:
                line, column = string.split(self.editwin.text.index("insert"), '.')


            defns = brmctx.findDefinitionByCoordinates(filename,int(line),
                                                       int(column))

            try:
                
                firstref = defns.next()
                
                editwin = self.editwin.flist.open(firstref.filename)
                editwin.gotoline(firstref.lineno)
            except StopIteration:
                self.errorbox("Couldn't Find definition","Couldn't Find definition")
                pass
            else:
                numRefs = 1
                global matchwin
                if matchwin is None:
                    matchwin = BRMMatchesWindow(self.editwin.flist, self)
                    
                for ref in defns:
                    if numRefs == 1:
                        print >>matchwin, firstref.filename+":"+str(firstref.lineno)+":    "+str(firstref.confidence)+"% confidence"

                    numRefs += 1
                    print >>matchwin,ref.filename+":"+str(ref.lineno)+":    "+str(ref.confidence)+"% confidence"
                if matchwin is not None:
                    print >>matchwin, "(Hint: right-click to open locations.)"
                    
        except:
            self._handleUnexpectedException()


    def brm_rename_event(self, event):
        try:
            self.renameItemByCoordinates()
        except:
            self._handleUnexpectedException()

    def brm_extract_method_event(self, event):
        try:
            if not self.confirm_all_buffers_saved():
                return
            try:
                filename, newname, beginline, begincolumn, endline, endcolumn = self._getExtractionInformation("Method")
            except NotHighlightedException:
                return
            brmctx.extractMethod(filename, int(beginline), int(begincolumn), 
                                 int(endline), int(endcolumn), newname)
            savedfiles = brmctx.save()
            self.refreshWindows(savedfiles, beginline)
        except:
            self._handleUnexpectedException()


    def brm_undo_event(self, event):
        try:
            line, column = string.split(self.editwin.text.index("insert"), '.')
            brmctx.undo()
            savedfiles = brmctx.save()
            self.refreshWindows(savedfiles, line)
        except UndoStackEmptyException:
            self.errorbox("Undo Stack Empty", "Undo Stack is empty")
        except:
            self._handleUnexpectedException()

    def _handleUnexpectedException(self):
        import traceback
        traceback.print_exc()
        self.errorbox("Caught Exception", "Caught Exception "+str(sys.exc_info()[0]))

    def _getExtractionInformation(self, extracttype):
        if self.editwin.text.index("sel.first") == "":
            self.errorbox("Code not highlighted", "Highlight the region of code you want to extract and try again")
            raise NotHighlightedException()
        filename = os.path.normpath(self.editwin.io.filename)
        newname = tkSimpleDialog.askstring("Extract Method ", 
                                           "New "+extracttype+" Name:", 
                                           parent = self.editwin.text)
        beginline, begincolumn = string.split(self.editwin.text.index("sel.first"), '.')
        endline, endcolumn = string.split(self.editwin.text.index("sel.last"), '.')
        return filename, newname, beginline, begincolumn, endline, endcolumn


    def renameMethodPromptCallback(self, filename, line, colbegin, colend):

        editwin = self.editwin.flist.open(filename)
        originaltop = self.editwin.getwindowlines()[0]

        # select the method call and position the window
        editwin.text.tag_remove("sel", "1.0", "end")
        editwin.text.tag_add("sel", str(line)+"."+str(colbegin), 
                                  str(line)+"."+str(colend))

        line, column = string.split(editwin.text.index("sel.first"), '.')
        editwin.text.yview(str(int(line)-2)+".0")


        d = NoFocusDialog("Rename?", 
                     "Cannot deduce the type of highlighted object reference.\nRename this declaration?", 
                     parent = editwin.text)

        # put the window back where it was
        self.editwin.text.yview(float(originaltop))
        return d.answer

    def renameItemByCoordinates(self):
        if not self.confirm_all_buffers_saved():
            return
        if self.editwin.text.index("sel.first") == "":
            self.errorbox("Name not highlighted", "Double click the name of the declaration you want to rename (to highlight it) and try again")
            return

        brmctx.setRenameMethodPromptCallback(self.renameMethodPromptCallback)
        line, column = string.split(self.editwin.text.index("sel.first"), '.')
        filename = os.path.normpath(self.editwin.io.filename)
        newname = tkSimpleDialog.askstring("Rename", 
                                           "Rename to:", 
                                           parent = self.editwin.text)
        if newname is None: # cancel clicked
            return
        brmctx.renameByCoordinates(filename, int(line), int(column), newname)
        savedfiles = brmctx.save()
        self.refreshWindows(savedfiles, line)



    def refreshWindows(self, savedfiles, line):
        # refresh editor windows
        oldtop = self.editwin.getwindowlines()[0]

        global loadingFiles
        loadingFiles = 1
        for sf in savedfiles:
            normsf = os.path.normcase(sf)
            if normsf in self.editwin.flist.dict:
                editwin = self.editwin.flist.dict[normsf]
                editwin.io.loadfile(sf)
        loadingFiles = 0

        self.editwin.text.mark_set("insert", float(line))
        self.editwin.text.yview(float(oldtop))



    def confirm_all_buffers_saved(self):
        filelist = self.editwin.flist.dict.keys()
        for f in filelist:
            #editwin = self.editwin.flist.open(f)
            editwin = self.editwin.flist.dict[f]
            if self.confirm_buffer_is_saved(editwin) == 0:
                return 0
        return 1


    def confirm_buffer_is_saved(self, editwin):
        if not editwin.get_saved():
            name = (editwin.short_title()or
            editwin.long_title()or
            "Untitled")
            reply = tkMessageBox.askokcancel("Bicycle Repair Man",
                "The buffer for %s is not saved.\n\n"%name+
                "Save it and continue?",
                master = self.editwin.text)
          &nbs p; self.editwin.text.focus_set()
            if reply:
                editwin.io.save(None)
            else:
                return 0
        return 1

    def errorbox(self, title, message):
        tkMessageBox.showerror(title, message, master = self.editwin.text)
        self.editwin.text.focus_set()


class BRMTraceWindow(OutputWindow):
    def short_title(self):
        return "BicycleRepairMan Trace"

class ProgressLogger:
    def __init__(self,flist):
        self.flist = flist

    def write(self,txt):
        if not hasattr(self,"io"):
            self.io = BRMTraceWindow(self.flist)
        try:
            self.io.write(txt)
            self.io.flush()
        except IOError:
            pass

        
class NoFocusDialog(tkSimpleDialog._QueryDialog):
    def __init__(self, title, prompt, 
                 initialvalue = None, 
                 minvalue = None, maxvalue = None, 
                 parent = None):
        self.answer = 0

        if not parent:
            import Tkinter
            parent = Tkinter._default_root

        self.prompt = prompt
        self.minvalue = minvalue
        self.maxvalue = maxvalue

        self.initialvalue = initialvalue

        Toplevel.__init__(self, parent)

        if title:
            self.title(title)

        self.parent = parent

        self.result = None

        body = Frame(self)
        self.initial_focus = self.body(body)
        body.pack(padx = 5, pady = 5)

        self.buttonbox()

        self.grab_set()

        self.protocol("WM_DELETE_WINDOW", self.cancel)

        if self.parent is not None:
            self.geometry("+%d+%d"%(parent.winfo_rootx()+50, 
                                      parent.winfo_rooty()+50))
        self.wait_window(self)


    def getresult(self):
        self.answer = 1

    def body(self, master):
        w = Label(master, text = self.prompt, justify = LEFT)
        w.grid(row = 0, padx = 5, sticky = W)

    def buttonbox(self):
        box = Frame(self)

        w = Button(box, text = "Yes", width = 10, command = self.ok, default = ACTIVE)
        w.pack(side = LEFT, padx = 5, pady = 5)
        w = Button(box, text = "No", width = 10, command = self.cancel)
        w.pack(side = LEFT, padx = 5, pady = 5)

        self.bind("<Return>", self.ok)
        self.bind("<Escape>", self.cancel)
        box.pack()





class BRMMatchesWindow(OutputWindow):
    def __init__(self,flist,masterwin):
        OutputWindow.__init__(self,flist)
        self.masterwin = masterwin

    def close(self):
        global matchwin
        matchwin = None
        OutputWindow.close(self)

    def short_title(self):
        return "BicycleRepairMan Matches"
    
    def clear(self):
        self.text.delete("1.0","end-1c")
        
