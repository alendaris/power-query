let
    func = (libraryName as any) =>
        let
            SourceCodeNamePrefix = "",
            library = 
                if Value.Type(libraryName) = Text.Type then
                    Expression.Evaluate(Expression.Identifier(libraryName), #shared)
                else
                    libraryName,
            functionSourceCode = library[Library Function Source Code],
            funcs = Table.RemoveColumns(Record.ToTable(library), "Value"),
            codeTable = Table.AddColumn(funcs, "Value", each functionSourceCode(libraryName, [Name])),
            #"Replaced Value" = Table.ReplaceValue(codeTable, each [Name], each SourceCodeNamePrefix & [Name], Replacer.ReplaceText, {"Name"}),
            code = Record.FromTable(#"Replaced Value")
        in
            code,

    fntype = type function
        (
            LibraryName as (type any meta [
                Documentation.FieldCaption = "Library",
                Documentation.FieldDescription = "The name of the function library record to extract source code from. Text values will be interpreted as the name of another query in this file.",
                Documentation.SampleValues = {"Library"}
            ])
        ) as table meta
            [
                Documentation.Name = "Library Source Code",
                Documentation.LongDescription = "This function extracts Source Code metadata, if present, from the elements of a function library record. This function requires a function ""Library Function Source Code"" to be present within the library.",
            ]

in
    Value.ReplaceType(func,fntype)
