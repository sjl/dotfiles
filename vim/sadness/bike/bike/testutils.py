from bike.globals import *
import unittest
import os
import os.path
from mock import Mock
from bike.parsing.fastparserast import getRoot, Root, resetRoot
from parsing.utils import fqn_rcar, fqn_rcdr
import re
from bike import log
filesToDelete = None
dirsToDelete = None

class BRMTestCase(unittest.TestCase):
    def setUp(self):
        log.warning = log.SilentLogger()
        try: os.makedirs(tmproot)
        except: pass
        os.chdir(tmproot)
        
        resetRoot(Root([tmproot]))
        getRoot().unittestmode = True
        global filesToDelete
        global dirsToDelete
        filesToDelete = []
        dirsToDelete = []
        from bike.parsing.load import Cache
        Cache.instance.reset()



    def tearDown(self):
        global filesToDelete
        global dirsToDelete

        for path in filesToDelete:
            try: os.remove(path)
            except: pass
        filesToDelete = []
            
        for path in dirsToDelete:
            try: os.removedirs(path)
            except: pass
        dirsToDelete = []

        os.chdir("..")
        try: os.removedirs(tmproot)
        except: pass



tmproot = os.path.abspath("tmproot")
tmpfile = os.path.join(tmproot, "bicyclerepairman_tmp_testfile.py")
tmpmodule = "bicyclerepairman_tmp_testfile"


def writeFile(filename, src):
    f = open(filename, "w+")
    f.write(src)
    f.close()
    filesToDelete.append(filename)

def readFile(filename):
    f = open(filename)
    src = f.read()
    f.close()
    return src

def writeTmpTestFile(src):
    try:
        os.makedirs(tmproot)
    except OSError:
        pass
    writeFile(tmpfile, src)

def readTmpTestFile():
    return readFile(tmpfile)

def deleteTmpTestFile():
    os.remove(tmpfile)
    os.removedirs(tmproot)


pkgstructureRootDir = tmproot
pkgstructureBasedir = os.path.join(pkgstructureRootDir, "a")
pkgstructureChilddir = os.path.join(pkgstructureBasedir, "b")
pkgstructureFile0 = os.path.join(pkgstructureRootDir, "top.py")
pkgstructureFile1 = os.path.join(pkgstructureBasedir, "foo.py")
pkgstructureFile2 = os.path.join(pkgstructureChilddir, "bah.py")


def createPackageStructure(src1, src2, src0="pass"):
    try: os.makedirs(pkgstructureChilddir)
    except: pass
    writeFile(os.path.join(pkgstructureBasedir, "__init__.py"), "#")
    writeFile(os.path.join(pkgstructureChilddir, "__init__.py"), "#")
    writeFile(pkgstructureFile0, src0)
    writeFile(pkgstructureFile1, src1)
    writeFile(pkgstructureFile2, src2)

def removePackageStructure():
    os.remove(os.path.join(pkgstructureBasedir, "__init__.py"))
    os.remove(os.path.join(pkgstructureChilddir, "__init__.py"))
    os.remove(pkgstructureFile0)
    os.remove(pkgstructureFile1)
    os.remove(pkgstructureFile2)
    os.removedirs(pkgstructureChilddir)


pkgstructureBasedir2 = os.path.join(pkgstructureRootDir, "c")
pkgstructureFile3 = os.path.join(pkgstructureBasedir2, "bing.py")

def createSecondPackageStructure(src3):
    try: os.makedirs(pkgstructureBasedir2)
    except: pass
    writeFile(os.path.join(pkgstructureBasedir2, "__init__.py"), "#")
    writeFile(pkgstructureFile3, src3)

def removeSecondPackageStructure():
    os.remove(os.path.join(pkgstructureBasedir2, "__init__.py"))
    os.remove(pkgstructureFile3)
    os.removedirs(pkgstructureBasedir2)



def createAST(src):
    from bike.parsing.load import getSourceNode
    writeFile(tmpfile,src)
    return getSourceNode(tmpfile)


def createSourceNodeAt(src, fqn):
    modname = fqn_rcar(fqn)
    packagefqn = fqn_rcdr(fqn)
    dirpath = os.path.join(*packagefqn.split("."))
    filepath = os.path.join(dirpath,modname+".py")
    try: os.makedirs(dirpath)
    except: pass
    dirsToDelete.append(dirpath)

    # add the __init__.py files
    path = "."
    for pathelem in packagefqn.split("."):
        path = os.path.join(path,pathelem)
        initfile = os.path.join(path,"__init__.py")
        writeFile(initfile,"#")
        filesToDelete.append(initfile)
    writeFile(filepath,src)
    filesToDelete.append(filepath)
    return getRoot()


# takes the leading whitespace out of a multi line comment.
# means you can imbed """
#                     text like
#                     this
#                     """
# in your code, and it will come out
#"""text like
#this"""
def trimLines(src):
    lines = src.splitlines(1)[1:]
    tabwidth = re.match("\s*",lines[0]).end(0)
    newlines = []
    for line in lines:
        if line == "\n" or line == "\r\n":
            newlines.append(line)
        else:
            newlines.append(line[tabwidth:])
    return "".join(newlines)

