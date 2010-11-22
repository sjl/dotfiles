# Bicycle Repair Man integration with (X)Emacs
# By Phil Dawes (2002)
# Uses the fabulous Pymacs package by François Pinard

from Pymacs import lisp, Let
import bike
reload(bike)
from bike import bikefacade
import StringIO, traceback
import sys

class EmacsLogger:
    def __init__(self):
        self.msg = ""
    
    def write(self,output):
        self.msg +=output
        if output.endswith("\n"):
            lisp.message(self.msg)
            self.msg = ""

class NullLogger:
    def write(self,output):
        pass
        
logger = EmacsLogger()


class ExceptionCatcherWrapper:

    def __init__(self,myobj):
        self.myobj = myobj
    
    def __getattr__(self,name):
        return ExceptionInterceptor(self.myobj,name)
        

class ExceptionInterceptor:
    def __init__(self,targetobj,name):
        self.targetobj = targetobj
        self.name = name
    
    def __call__(self,  *params, **kwparams ):
        try:
            return self.makeCall(params)
        except:
            traceback.print_exc()
            lisp.error(str(sys.exc_info()[1]))

    def makeCall(self,params):
        argsstr="(self.targetobj"
        for i in range(len(params)):
            argsstr += ",params["+`i`+"]"
        argsstr+=")"
        return eval("self.targetobj.__class__."+self.name+argsstr)


class BRMEmacs(object):
    
    def __init__(self,brmctx):
        self.ctx = brmctx

        lisp.require(lisp["python-mode"])
        lisp("""
        (defvar brm-menu nil "Menu for Bicycle Repair Man")
         (easy-menu-define
          brm-menu py-mode-map "Bicycle Repair Man"
          '("BicycleRepairMan"
                   "Queries"
                   ["Find-References" brm-find-references]
                   ["Find-Definition" brm-find-definition]
                   "---"
                   "Refactoring"
                   ["Rename" brm-rename t]
                   ["Extract-Method" brm-extract-method t]
                   ["Extract-Local-Variable" brm-extract-local-variable t]
                   ["Inline-Local-Variable" brm-inline-local-variable t]
                   ["Undo Last Refactoring" brm-undo t]

        ))
        (add-hook 'python-mode-hook (lambda () (easy-menu-add brm-menu)))
        """)
        #           ["Move-Class-To-New-Module" brm-move-class t]
        #           ["Move-Function-To-New-Module" brm-move-class t]

        self.ctx.setProgressLogger(logger)


    def rename(self,newname):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()
        line,col = _getCoords()
        brmctx.setRenameMethodPromptCallback(promptCallback)
        try:
            self.ctx.renameByCoordinates(filename,line,col,newname)
            savedFiles = brmctx.save()
            _revertSavedFiles(savedFiles)
            lisp.set_marker(lisp.mark_marker(),None)
        except bikefacade.CouldntLocateASTNodeFromCoordinatesException:
            print >>logger,"Couldn't find AST Node. Are you renaming the declaration?"

    def kill(self):        
        self.ctx = None
        self.ctx = bike.init()
        self.ctx.setProgressLogger(logger)

    def undo(self):
        brmctx.undo()
        savedFiles = brmctx.save()
        _revertSavedFiles(savedFiles)

    def find_references(self):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()
        line,col = _getCoords()
        refs = brmctx.findReferencesByCoordinates(filename,line,col)
        _switchToConsole()
        numRefs = 0
        for ref in refs:
            _insertRefLineIntoConsole(ref)
            numRefs +=1
        lisp.insert("Done - %d refs found\n"%numRefs)


    def find_definition(self):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()
        line,col = _getCoords()
        defns = brmctx.findDefinitionByCoordinates(filename,line,col)

        try:
            firstdefn = defns.next()
            lisp.find_file_other_window(firstdefn.filename)
            lisp.goto_line(firstdefn.lineno)
            lisp.forward_char(firstdefn.colno)
        except StopIteration:
            pass
        else:
            numRefs = 1
            for defn in defns:
                if numRefs == 1:
                    _switchToConsole()
                    _insertRefLineIntoConsole(firstdefn)
                _insertRefLineIntoConsole(defn)
                numRefs += 1


    def inline_local_variable(self):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()
        line,col = _getCoords()
        brmctx.inlineLocalVariable(filename,line,col)
        lisp.set_marker(lisp.mark_marker(),None)
        _revertSavedFiles(brmctx.save())

    def extract_local_variable(self,name):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()

        bline,bcol = _getPointCoords()
        lisp.exchange_point_and_mark()
        eline,ecol = _getPointCoords()
        lisp.exchange_point_and_mark()

        brmctx.extractLocalVariable(filename,bline,bcol,eline,ecol,name)
        lisp.set_marker(lisp.mark_marker(),None)
        _revertSavedFiles(brmctx.save())
        
    def extract_method(self,name):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()

        bline,bcol = _getPointCoords()
        lisp.exchange_point_and_mark()
        eline,ecol = _getPointCoords()
        lisp.exchange_point_and_mark()

        brmctx.extract(filename,bline,bcol,eline,ecol,name)
        lisp.set_marker(lisp.mark_marker(),None)
        _revertSavedFiles(brmctx.save())

        
    def move_class(self,newfilename):
        lisp.save_some_buffers()
        filename = lisp.buffer_file_name()
        line,col = _getCoords()
        brmctx.moveClassToNewModule(filename,line,newfilename)
        _revertSavedFiles(brmctx.save())
        


brmctx = bike.init()

brmemacs = None

is_xemacs = (lisp.emacs_version().find("GNU") == -1)
currently_saving=0

# fix pop_excursion to work with xemacs
class Let(Let):
    def pop_excursion(self):
        method, (buffer, point_marker, mark_marker) = self.stack[-1]
        assert method == 'excursion', self.stack[-1]
        del self.stack[-1]
        lisp.set_buffer(buffer)
        lisp.goto_char(point_marker)
        lisp.set_mark(mark_marker)
        lisp.set_marker(point_marker, None)
        if mark_marker is not None:   # needed for xemacs
            lisp.set_marker(mark_marker, None)



def init():
    global brmemacs
    brmemacs = ExceptionCatcherWrapper(BRMEmacs(brmctx))

    
def kill():
    """
    Removes the bicyclerepairman context (freeing the state),
    and reinitialises it.
    """
    brmemacs.kill()
kill.interaction=""


def promptCallback(filename,line,colbegin,colend):
    let = Let().push_excursion()   # gets popped when let goes out of scope
    buffer = lisp.current_buffer()
    if let:
        ans = 0
        lisp.find_file(filename)
        lisp.goto_line(line)
        lisp.move_to_column(colbegin)
        lisp.set_mark(lisp.point() + (colend - colbegin))
        if is_xemacs:
            lisp.activate_region()
        ans = lisp.y_or_n_p("Couldn't deduce object type - rename this method reference? ")
    del let
    lisp.switch_to_buffer(buffer)
    return ans

def rename(newname):
    return brmemacs.rename(newname)
rename.interaction="sNew name: "


def undo():
    return brmemacs.undo()
undo.interaction=""


def _revertSavedFiles(savedFiles):
    global currently_saving
    currently_saving = 1
    for file in savedFiles:
        buf = lisp.find_buffer_visiting(file)
        if buf:
            lisp.set_buffer(buf)
            lisp.revert_buffer(None,1)
    currently_saving = 0

def find_references():
    brmemacs.find_references()    
find_references.interaction=""

def _getCoords():
    line = lisp.count_lines(1,lisp.point())
    col = lisp.current_column()
    if col == 0:            
        line += 1  # get round 'if col == 0, then line is 1 out' problem

    if mark_exists() and lisp.point() > lisp.mark():
        lisp.exchange_point_and_mark()
        col = lisp.current_column()
        lisp.exchange_point_and_mark()
    return line,col

def mark_exists():
    if is_xemacs:
        return lisp.mark()
    else:
        return lisp("mark-active") and lisp.mark()



def _switchToConsole():
    consolebuf = lisp.get_buffer_create("BicycleRepairManConsole")
    lisp.switch_to_buffer_other_window(consolebuf)
    lisp.compilation_mode("BicycleRepairMan")
    lisp.erase_buffer()
    lisp.insert("Bicycle Repair Man\n")
    lisp.insert("(Hint: Press Return a Link)\n")
    
def find_definition():
    brmemacs.find_definition()
find_definition.interaction=""

def _insertRefLineIntoConsole(ref):
    lisp.insert(ref.filename+":"+str(ref.lineno)+":    "+str(ref.confidence)+"% confidence\n")
    _redisplayFrame()

def _redisplayFrame():
    lisp.sit_for(0)

def inline_local_variable():
    brmemacs.inline_local_variable()
inline_local_variable.interaction=""

def extract_local_variable(name):
    brmemacs.extract_local_variable(name)
extract_local_variable.interaction="sVariable name: "


def extract_method(name):
    brmemacs.extract_method(name)
extract_method.interaction="sName of function: "


def move_class(newfilename):
    return brmemacs.move_class(newfilename)
move_class.interaction="fTarget file: "



def _getPointCoords():
    bline = lisp.count_lines(1,lisp.point())
    bcol = lisp.current_column()
    if bcol == 0:  # get round line is one less if col is 0 problem
        bline += 1
    return bline,bcol

