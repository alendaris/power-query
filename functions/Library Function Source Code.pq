let
    func = (LibraryName as any, functionName as text) =>
        let
            library = 
                if Value.Type(LibraryName) = Text.Type then
                    Expression.Evaluate(Expression.Identifier(LibraryName), #shared)
                else
                    LibraryName,
            func = Record.Field(library,functionName),
            code = "// " & functionName & "#(cr)#(lf)#(cr)#(lf)" & Value.Metadata(Value.Type(func))[Source Code]
        in
            code,

    fntype = type function
        (
            LibraryName as (type any meta [
                Documentation.FieldCaption = "Library",
                Documentation.FieldDescription = "The name of the function library record to extract source code from. Text values will be interpreted as the name of another query in this file.",
                Documentation.SampleValues = {"Library"}
            ]),
            functionName as (type text meta [
                Documentation.FieldCaption = "Function",
                Documentation.FieldDescription = "The name of the function to extract Source Code metadata from.",
                Documentation.SampleValues = {"GenerateDateTable"}
            ])
        ) as text meta
            [
                Documentation.Name = "Library Function Source Code",
                Documentation.LongDescription = "This function extracts Source Code metadata, if present, from a specified element of a function library record.",
            ]

in
    Value.ReplaceType(func,fntype)
