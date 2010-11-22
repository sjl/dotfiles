#
# (c) Dave Kirby 2001
# dkirby@bigfoot.com
#
# Call interceptor code by Phil Dawes (pdawes@users.sourceforge.net)

'''
The Mock class emulates any other class for testing purposes.
All method calls are stored for later examination.
The class constructor takes a dictionary of method names and the values
they return.  Methods that are not in the dictionary will return None.
'''
import inspect


class Mock:
    def __init__(self, returnValues=None ):
        self.mockCalledMethods = {}
        self.mockAllCalledMethods = []
        self.mockReturnValues = returnValues or {}
        self.setupMethodInterceptors()
        
    def setupMethodInterceptors(self):
        if self.__class__ != Mock: # check we've been subclassed
            methods =  inspect.getmembers(self.__class__,inspect.ismethod)
            for m in methods:
                name = m[0]
                self.__dict__[name] = MethodCallInterceptor(name,self)        
            
    def __getattr__( self, name ):
        return MockCaller( name, self )
    
    def getAllCalls(self):
        '''return a list of MockCall objects,
        representing all the methods in the order they were called'''
        return self.mockAllCalledMethods

    def getNamedCalls(self, methodName ):
        '''return a list of MockCall objects,
        representing all the calls to the named method in the order they were called'''
        return self.mockCalledMethods.get(methodName, [] )
    
    def assertNamedCall(self,methodName,*args):
        # assert call was made once
        assert(len(self.getNamedCalls(methodName)) == 1)
        # assert args are correct
        argsdict = inspect.getargvalues(inspect.currentframe())[3]
        i=0
        for arg in argsdict['args']:
            assert(self.getNamedCalls(methodName)[0].getParam(i) == arg)
            i += 1

    def assertCallInOrder(self,methodName,*args):
        ''' Convenience method to allow client to check that calls were
        made in the right order. Call once for each methodcall'''

        # initialise callIndex. (n.b. __getattr__ method complicates
        # this since attrs are MockCaller instances by default)
        if type(self.callIndex) != type(1):
            self.callIndex=0
        
        call = self.getAllCalls()[self.callIndex]
        # assert method name is correct
        assert(call.getName() == methodName)
        # assert args are correct
        argsdict = inspect.getargvalues(inspect.currentframe())[3]
        i=0
        for arg in argsdict['args']:
            assert(call.getParam(i) == arg)
            i += 1
        # assert num args are correct
        assert(call.getNumParams() == i)
        self.callIndex += 1
        
    def assertNoMoreCalls(self):
        assert(len(self.getAllCalls()) == self.callIndex)
        
class MockCall:
    def __init__(self, name, params, kwparams ):
        self.name = name
        self.params = params
        self.kwparams = kwparams
    def getParam( self, n ):
        if type(n) == type(1):
            return self.params[n]
        elif type(n) == type(''):
            return self.kwparams[n]
        else:
            raise IndexError, 'illegal index type for getParam'

    def getNumParams(self):
        return len(self.params)


    def getName(self):
        return self.name
    
    #pretty-print the method call
    def __str__(self):
        s = self.name + "("
        sep = ''
        for p in self.params:
            s = s + sep + repr(p)
            sep = ', '
        for k,v in self.kwparams.items():
            s = s + sep + k+ '='+repr(v)
            sep = ', '
        s = s + ')'
        return s
    def __repr__(self):
        return self.__str__()

class MockCaller:
    def __init__( self, name, mock):
        self.name = name
        self.mock = mock
    def __call__(self,  *params, **kwparams ):
        self.recordCall(params,kwparams)
        return self.mock.mockReturnValues.get(self.name)

    def recordCall(self,params,kwparams):
        thisCall = MockCall( self.name, params, kwparams )
        calls = self.mock.mockCalledMethods.get(self.name, [] )
        if calls == []:
            self.mock.mockCalledMethods[self.name] = calls 
        calls.append(thisCall)
        self.mock.mockAllCalledMethods.append(thisCall)


# intercepts the call and records it, then delegates to the real call
class MethodCallInterceptor(MockCaller):
    
    def __call__(self,  *params, **kwparams ):
        self.recordCall(params,kwparams)
        return self.makeCall(params)
        
    def makeCall(self,params):
        argsstr="(self.mock"
        for i in range(len(params)):
            argsstr += ",params["+`i`+"]"
        argsstr+=")"
        return eval("self.mock.__class__."+self.name+argsstr)

