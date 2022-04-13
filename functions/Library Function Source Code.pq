(LibraryName as any, functionName as text) =>
let
    library = 
        if Value.Type(LibraryName) = Text.Type then
            Expression.Evaluate(Expression.Identifier(LibraryName), #shared)
        else
            LibraryName,
    func = Record.Field(library,functionName),
    code = "// " & functionName & "#(cr)#(lf)#(cr)#(lf)" & Value.Metadata(Value.Type(func))[Source Code]
in
    code
