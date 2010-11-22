def myFunction():
    a = 3
    print "hello"+a  # extract me

class MyClass:
    def myMethod(self):
        b = 12      # extract me
        c = 3       # and me
        d = 2       # and me
        print b, c


def inlineVariableTest():
    a = b + 3 - 5
    # --^^^^^  - Extract this into variable

