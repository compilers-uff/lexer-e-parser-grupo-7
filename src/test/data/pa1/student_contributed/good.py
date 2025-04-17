class Stack(object):
    objs:list = None

    def __init__(self: "Stack"):
        self.objs = []

    def push(self: "Stack", o: int):
        self.objs.append(o)

    def pop(self: "Stack") -> int:
        return self.objs.pop(len(self.objs) - 1)

    def top(self: "Stack") -> int:
        return self.objs[-1]

    def __repr__(self: "Stack") -> str:
        return str(self.objs)

def readIndent(inputString: str):
    stack = Stack()
    stack.push(0)
    curr_indent = 0
    analyzed_str = ""
    has_tab = False
    index = 0
    while index < len(inputString):
        c = inputString[index]
        if c  == " " or c == "\t":
            if c == "\t":
                has_tab = True
            analyzed_str = analyzed_str + c
            curr_indent = curr_indent + 1 
        elif c == "\n":
            analyzed_str = ""
            curr_indent = 0
        else:
            if has_tab:
                if curr_indent % 8 != 0:
                    curr_indent = curr_indent + 8 - (curr_indent % 8)

            if stack.top() < curr_indent:
                print("INDENT")
                stack.push(curr_indent)
                print(stack)
            else:
                while stack.top() > curr_indent:
                    stack.pop()
                    print("DEDENT")
                    print(stack)
                
                if stack.top() < curr_indent:
                    print("BAD INDENTATION")
                    exit(1)

            curr_indent = 0
            analyzed_str = ""
            has_tab = False
            while index < len(inputString) and inputString[index] != "\n":
                index = index + 1

        index = index + 1
