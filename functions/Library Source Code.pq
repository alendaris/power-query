(libraryName as any) =>
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
    code
