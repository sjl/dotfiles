#!/usr/bin/env python
import setpath
import unittest

from bike.refactor.extractMethod import ExtractMethod, \
     extractMethod, coords
from bike import testdata
from bike.testutils import *
from bike.parsing.load import Cache

def assertTokensAreSame(t1begin, t1end, tokens):
    it = t1begin.clone()
    pos = 0
    while it != t1end:
        assert it.deref() == tokens[pos]
        it.incr()
        pos+=1
    assert pos == len(tokens)


def helper(src,startcoords, endcoords, newname):
    sourcenode = createAST(src)
    extractMethod(tmpfile, startcoords, endcoords, newname)
    return sourcenode.getSource()

class TestExtractMethod(BRMTestCase):

    def test_extractsPass(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                self.newMethod()

            def newMethod(self):
                pass
        """)
        src = helper(srcBefore, coords(3, 8), coords(3, 12), "newMethod")
        self.assertEqual(src,srcAfter)

    def test_extractsPassWhenFunctionAllOnOneLine(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): pass # comment
        """)

        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): self.newMethod() # comment

            def newMethod(self):
                pass
        """)
        src = helper(srcBefore, coords(2, 24), coords(2, 28),"newMethod")
        self.assertEqual(src,srcAfter)

    def test_extractsPassFromForLoop(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    pass
        """)                
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    self.newMethod()

            def newMethod(self):
                pass
        """)
        src = helper(srcBefore, coords(4, 12), coords(4, 16), "newMethod")
        self.assertEqual(srcAfter, src)

    def test_newMethodHasArgumentsForUsedTemporarys(self):

        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self, c): 
                a = something()
                b = somethingelse()
                print a + b + c + d
                print \"hello\"
                dosomethingelse(a, b)
        """)                
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self, c): 
                a = something()
                b = somethingelse()
                self.newMethod(a, b, c)
                dosomethingelse(a, b)

            def newMethod(self, a, b, c):
                print a + b + c + d
                print \"hello\"
        """)

        src = helper(srcBefore, coords(5, 8), coords(6, 21), "newMethod")
        self.assertEqual(srcAfter, src)

    def test_newMethodHasSingleArgument(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): 
                a = something()
                print a
                print \"hello\"
                dosomethingelse(a, b)
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): 
                a = something()
                self.newMethod(a)
                dosomethingelse(a, b)

            def newMethod(self, a):
                print a
                print \"hello\"
        """)
        src = helper(srcBefore, coords(4, 8), coords(5, 21), "newMethod")
        self.assertEqual(srcAfter, src)


    def test_doesntHaveDuplicateArguments(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                a = 3
                print a
                print a
        """)

        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                a = 3
                self.newMethod(a)

            def newMethod(self, a):
                print a
                print a
        """)
        src = helper(srcBefore, coords(4, 0), coords(6, 0), "newMethod")
        self.assertEqual(srcAfter, src)

    def test_extractsQueryWhenFunctionAllOnOneLine(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self, a): print a # comment
        """)

        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self, a): self.newMethod(a) # comment

            def newMethod(self, a):
                print a
        """)
        src = helper(srcBefore, coords(2, 27), coords(2, 34), "newMethod")
        self.assertEqual(srcAfter, src)


    def test_worksWhenAssignmentsToTuples(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): 
                a, b, c = 35, 36, 37
                print a + b
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): 
                a, b, c = 35, 36, 37
                self.newMethod(a, b)

            def newMethod(self, a, b):
                print a + b
        """)

        src = helper(srcBefore, coords(4, 8), coords(4, 19), "newMethod")
        self.assertEqual(srcAfter, src)

    def test_worksWhenUserSelectsABlockButDoesntSelectTheHangingDedent(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    pass
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    self.newMethod()

            def newMethod(self):
                pass
        """)

        src = helper(srcBefore, coords(4, 8), coords(4, 16), "newMethod")
        self.assertEqual(srcAfter, src)

    def test_newMethodHasSingleReturnValue(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                a = 35    # <-- extract me
                print a
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                a = self.newMethod()
                print a

            def newMethod(self):
                a = 35    # <-- extract me
                return a
        """)

        src = helper(srcBefore, coords(3, 4),
                         coords(3, 34), "newMethod")
        self.assertEqual(srcAfter, src)



    def test_newMethodHasMultipleReturnValues(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                a = 35
                b = 352
                print a + b
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                a, b = self.newMethod()
                print a + b

            def newMethod(self):
                a = 35
                b = 352
                return a, b
        """)
        src = helper(srcBefore, coords(3, 8),
                         coords(4, 15), "newMethod")
        self.assertEqual(srcAfter, src)



    def test_worksWhenMovingCodeJustAfterDedent(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    pass
                print \"hello\"
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                for i in foo:
                    pass
                self.newMethod()

            def newMethod(self):
                print \"hello\"
        """)

        src = helper(srcBefore, coords(5, 8),
                         coords(5, 21), "newMethod")
        self.assertEqual(srcAfter, src)

    
    def test_extractsPassWhenSelectionCoordsAreReversed(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                self.newMethod()

            def newMethod(self):
                pass
        """)
        src = helper(srcBefore, coords(3, 12), coords(3, 8), "newMethod")
        self.assertEqual(srcAfter, src)


    def test_extractsExpression(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                a = 32
                b = 2 + a * 1 + 2
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                a = 32
                b = 2 + self.newMethod(a) + 2

            def newMethod(self, a):
                return a * 1
        """)
        src = helper(srcBefore, coords(4, 16), coords(4, 21), "newMethod")
        self.assertEqual(srcAfter, src)


    def test_extractsExpression2(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                g = 32
                assert output.thingy(g) == \"bah\"
        """)
        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self): # comment
                g = 32
                assert self.newMethod(g) == \"bah\"

            def newMethod(self, g):
                return output.thingy(g)
        """)
        src = helper(srcBefore, coords(4, 15), coords(4, 31), "newMethod")
        self.assertEqual(srcAfter, src)



class TestExtractFunction(BRMTestCase):
    def runTarget(self, src, begincoords, endcoords, newname):
        ast = createAST(src)
        extractFunction(ast, begincoords, endcoords, newname)
        return ast

    def test_extractsFunction(self):        
        srcBefore=trimLines("""
        def myFunction(): # comment
            a = 3
            c = a + 99
            b = c * 1
            print b
        """)
        srcAfter=trimLines("""
        def myFunction(): # comment
            a = 3
            b = newFunction(a)
            print b

        def newFunction(a):
            c = a + 99
            b = c * 1
            return b
        """)

        src = helper(srcBefore, coords(3, 4),
                         coords(4, 13), "newFunction")
        self.assertEqual(srcAfter, src)

    def test_extractsAssignToAttribute(self):
        srcBefore=trimLines("""
        def simulateLoad(path):
            item = foo()
            item.decl = line
        """)
        srcAfter=trimLines("""
        def simulateLoad(path):
            item = foo()
            newFunction(item)

        def newFunction(item):
            item.decl = line
        """)

        src = helper(srcBefore, coords(3, 0),
                         coords(4, 0), "newFunction")
        self.assertEqual(srcAfter, src)


    def test_extractsFromFirstBlockOfIfElseStatement(self):
        srcBefore=trimLines("""
        def foo():
            if bah:
                print \"hello1\"
                print \"hello2\"
                
            elif foo:
                pass
        """)
        srcAfter=trimLines("""
        def foo():
            if bah:
                newFunction()
                print \"hello2\"
                
            elif foo:
                pass

        def newFunction():
            print \"hello1\"
        """)
        src = helper(srcBefore, coords(3, 0),
                         coords(4, 0), "newFunction")
        self.assertEqual(srcAfter, src)
        

    def test_extractsAugAssign(self):
        srcBefore=trimLines("""
        def foo():
            a = 3
            a += 1
            print a
        """)
        srcAfter=trimLines("""
        def foo():
            a = 3
            a = newFunction(a)
            print a

        def newFunction(a):
            a += 1
            return a
        """)
        src = helper(srcBefore, coords(3, 0),
                         coords(4, 0), "newFunction")
        self.assertEqual(srcAfter, src)
        
    def test_extractsForLoopUsingLoopVariable(self):
        srcBefore=trimLines("""
        def foo():
            for i in range(1, 3):
                print i
        """)
        srcAfter=trimLines("""
        def foo():
            for i in range(1, 3):
                newFunction(i)

        def newFunction(i):
            print i
        """)

        src = helper(srcBefore, coords(3, 0),
                         coords(4, 0), "newFunction")
        self.assertEqual(srcAfter, src)

    def test_extractWhileLoopVariableIncrement(self):
        srcBefore=trimLines("""
        def foo():
            a = 0
            while a != 3:
                a = a+1
        """)
        srcAfter=trimLines("""
        def foo():
            a = 0
            while a != 3:
                a = newFunction(a)

        def newFunction(a):
            a = a+1
            return a
        """)
        src = helper(srcBefore, coords(4, 0),
                         coords(5, 0), "newFunction")
        self.assertEqual(srcAfter, src)

    def test_extractAssignedVariableUsedInOuterForLoop(self):
        srcBefore=trimLines("""
        def foo():
            b = 0
            for a in range(1, 3):
                b = b+1
                while b != 2:
                    print a
                    b += 1
        """)
        srcAfter=trimLines("""
        def foo():
            b = 0
            for a in range(1, 3):
                b = b+1
                while b != 2:
                    b = newFunction(a, b)

        def newFunction(a, b):
            print a
            b += 1
            return b
        """)

        src = helper(srcBefore, coords(6, 0),
                         coords(8, 0), "newFunction")
        self.assertEqual(srcAfter, src)
        

    def test_extractsConditionalFromExpression(self):
        srcBefore=trimLines("""
        def foo():
            if 123+3:
                print aoue
        """)
        srcAfter=trimLines("""
        def foo():
            if newFunction():
                print aoue

        def newFunction():
            return 123+3
        """)
        src = helper(srcBefore, coords(2, 7),
                         coords(2, 12), "newFunction")
        self.assertEqual(srcAfter, src)
        
    def test_extractCodeAfterCommentInMiddleOfFnDoesntRaiseParseException(self):
        srcBefore=trimLines("""
        def theFunction():
            print 1
            # comment
            print 2
        """)
        srcAfter=trimLines("""
        def theFunction():
            print 1
            # comment
            newFunction()

        def newFunction():
            print 2
        """)
        src = helper(srcBefore, coords(4, 0),
                         coords(5, 0), "newFunction")
        self.assertEqual(srcAfter, src)
        

    def test_canExtractQueryFromNestedIfStatement(self):
        srcBefore=trimLines("""
        def theFunction():
            if foo: # comment
                if bah:
                    pass
        """)
        srcAfter=trimLines("""
        def theFunction():
            if foo: # comment
                if newFunction():
                    pass

        def newFunction():
            return bah
        """)
        src = helper(srcBefore, coords(3, 11),
                         coords(3, 14), "newFunction")
        self.assertEqual(srcAfter, src)



    def test_doesntMessUpTheNextFunctionOrClass(self):
        srcBefore=trimLines("""
        def myFunction():
            a = 3
            print \"hello\"+a  # extract me
            
        class MyClass:
            def myMethod(self):
                b = 12      # extract me
                c = 3       # and me
                d = 2       # and me
                print b, c
        """)
        srcAfter=trimLines("""
        def myFunction():
            a = 3
            newFunction(a)

        def newFunction(a):
            print \"hello\"+a  # extract me
            
        class MyClass:
            def myMethod(self):
                b = 12      # extract me
                c = 3       # and me
                d = 2       # and me
                print b, c
        """)

        # extract code on one line
        src = helper(srcBefore, coords(3, 4),
                         coords(3, 34), "newFunction")
        self.assertEqual(srcAfter, src)

        # extract code on 2 lines (most common user method)
        resetRoot()
        Cache.instance.reset()
        Root()
        src = helper(srcBefore, coords(3, 0),
                         coords(4, 0), "newFunction")
        self.assertEqual(srcAfter, src)


    def test_doesntBallsUpIndentWhenTheresALineWithNoSpacesInIt(self):
        srcBefore=trimLines("""
        def theFunction():
            if 1:
                pass

            pass
        """)
        srcAfter=trimLines("""
        def theFunction():
            newFunction()

        def newFunction():
            if 1:
                pass
            
            pass
        """)
        src = helper(srcBefore, coords(2, 4),
                     coords(5, 8), "newFunction")
        self.assertEqual(srcAfter, src)


    def test_doesntHaveToBeInsideAFunction(self):
        srcBefore=trimLines(r"""
        a = 1
        print a + 2
        f(b)	
        """)
        srcAfter=trimLines(r"""
        a = 1
        newFunction(a)

        def newFunction(a):
            print a + 2
            f(b)	
        """)
        src = helper(srcBefore, coords(2, 0),
                         coords(3, 4), "newFunction")
        self.assertEqual(srcAfter, src)


    def test_doesntBarfWhenEncountersMethodCalledOnCreatedObj(self):
        srcBefore=trimLines(r"""
        results = QueryEngine(q).foo()
        """)
        srcAfter=trimLines(r"""
        newFunction()

        def newFunction():
            results = QueryEngine(q).foo()
        """)
        src = helper(srcBefore, coords(1, 0),
                         coords(2, 0), "newFunction")
        self.assertEqual(srcAfter, src)


    def test_worksIfNoLinesBeforeExtractedCode(self):
        srcBefore=trimLines(r"""
        print a + 2
        f(b)	
        """)
        srcAfter=trimLines(r"""
        newFunction()

        def newFunction():
            print a + 2
            f(b)	
        """)
        src = helper(srcBefore, coords(1, 0),
                         coords(2, 4), "newFunction")
        self.assertEqual(srcAfter, src)


class TestGetRegionAsString(BRMTestCase):
    def test_getsHighlightedSingleLinePassStatement(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 8),
                             coords(3, 12), "foobah")
        em.getRegionToBuffer()
        self.assertEqual(len(em.extractedLines), 1)
        self.assertEqual(em.extractedLines[0], "pass\n")
        
    def test_getsSingleLinePassStatementWhenWholeLineIsHighlighted(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 0),
                             coords(3, 12), "foobah")
        em.getRegionToBuffer()
        self.assertEqual(len(em.extractedLines), 1)
        self.assertEqual(em.extractedLines[0], "pass\n")


    def test_getsMultiLineRegionWhenJustRegionIsHighlighted(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                print 'hello'
                pass
        """)
        region=trimLines("""
        print 'hello'
        pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 8),
                             coords(4, 12), "foobah")
        em.getRegionToBuffer()
        self.assertEqual(em.extractedLines, region.splitlines(1))

    def test_getsMultiLineRegionWhenRegionLinesAreHighlighted(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                print 'hello'
                pass

        """)
        region=trimLines("""
        print 'hello'
        pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 0),
                             coords(5, 0), "foobah")
        em.getRegionToBuffer()
        self.assertEqual(em.extractedLines, region.splitlines(1))

    def test_getsHighlightedSubstringOfLine(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                if a == 3:
                    pass
        """)
        region=trimLines("""
        a == 3
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 11),
                             coords(3, 17), "foobah")
        em.getRegionToBuffer()
        self.assertEqual(em.extractedLines, region.splitlines(1))


class TestGetTabwidthOfParentFunction(BRMTestCase):
    def test_getsTabwidthForSimpleMethod(self):
        src=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(3, 11),
                             coords(3, 17), "foobah")
        self.assertEqual(em.getTabwidthOfParentFunction(), 4)

    def test_getsTabwidthForFunctionAtRootScope(self):
        src=trimLines("""
        def myFn(self):
            pass
        """)
        sourcenode = createAST(src)
        em = ExtractMethod(sourcenode, coords(2, 0),
                             coords(2, 9), "foobah")
        self.assertEqual(em.getTabwidthOfParentFunction(), 0)


if __name__ == "__main__":
    unittest.main()
