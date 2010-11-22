#!/usr/bin/env python
from __future__ import generators
import setpath
import unittest
import visitor
from bike.testutils import *

class TestVisitor(BRMTestCase):
    def test_callsVistorFunctions(self):
        tree = createTree()

        class TreeVisitor:
            def __init__(self):
                self.txt = []

            def visitAClass(self,node):
                self.txt.append("visitAClass")
                self.txt.append(node.txt)
                return self.visitChildren(node)
                
            def visitCClass(self,node):
                self.txt.append("visitCClass")
                self.txt.append(node.txt)

            def getTxt(self):
                return ",".join(self.txt)
        
        self.assertEqual(visitor.walk(tree,TreeVisitor()).getTxt(),
                         "visitAClass,aclass,visitCClass,cclass0,visitCClass,cclass1,visitCClass,cclass2")


    def test_callsVisitorFunctionsWithYield(self):
        tree = createTree()
        
        class TreeVisitor:
            def __init__(self):
                self.txt = []

            def visitAClass(self,node):
                self.txt.append("visitAClass")
                self.txt.append(node.txt)
                yield node
                for i in self.visitChildren(node):
                    yield i
                
            def visitCClass(self,node):
                self.txt.append("visitCClass")
                self.txt.append(node.txt)
                if 0: yield 1

            def getTxt(self):
                return ",".join(self.txt)

        for node in visitor.walkAndGenerate(tree,TreeVisitor()):
            assert node.txt == "aclass"
        

def createTree():
    n = AClass("aclass")
    for i in xrange(3):
        b = n.addChildNode(BClass("bclass%d" % i))
        for j in xrange(20):
            b = b.addChildNode(BClass("bclass%d" % i))
        b.addChildNode(CClass("cclass%d" % i))
    return n

class node(object):
    def __init__(self,txt):
        self._childNodes=[]
        self.txt = txt
    
    def addChildNode(self,node):
        self._childNodes.append(node)
        return node
    
    def getChildNodes(self):
        return [x for x in self._childNodes]


class AClass(node):
    pass

class BClass(node):
    pass

class CClass(node):
    pass

if __name__ == "__main__":

    # add perf test at end of tests
    class Z_SoakTestFastparser(BRMTestCase):
        def test_parsesPythonLibraryCorrectly(self):

            class TreeVisitor:
                pass
            
            import time

            tree = createTree()

            t1 = time.time()
            for i in xrange(1000):
                visitor.walk(tree,TreeVisitor())
            print "tree without yield",time.time()-t1

            t1 = time.time()
            for i in xrange(1000):
                for node in visitor.walkAndGenerate(tree,TreeVisitor()):
                    pass
            print "tree with yield",time.time()-t1


    unittest.main()
