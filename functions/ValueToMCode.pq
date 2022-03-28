(value as any,optional indentStart as number) =>
let
//    Source = {"3"},

    indent = if indentStart is null then 0 else indentStart,

    NullToMCode = (value as any,optional indent as number) as text =>
        """""",

    TextToMCode = (value as text,optional indent as number) as text =>
        """" & Text.Replace(value,"""","""""") & """",
    
    NumberToMCode = (value as number,optional indent as number) as text =>
        Number.ToText(value),

    ListToMCode = (value as list,optional indent as number) as text =>
        let
            Source = value,
            #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Added Custom" = Table.AddColumn(#"Converted to Table", "MCode", each ValueToMCode([Column1]))
        in
            "{" & Text.Combine(#"Added Custom"[MCode],", ") & "}",

    RecordToMCode = (value as record,optional indent as number) as text =>
    let
        fields = Record.FieldNames(value),
        withValues = List.Transform(fields,each _ & " = " & ValueToMCode(Record.Field(value,_))),
        Return = "[" & Text.Combine(withValues,",#(lf)") & "]"
    in
        Return,

    TableToMCode = (value as table,optional indent as number) =>
        let
            headers = ValueToMCode(Table.ColumnNames(value)),
            rows = ValueToMCode(Table.ToRows(value)),
            Return = "#table(#(lf)" & headers & ",#(lf)" & rows & "#(lf))"
        in 
            Return,

    Return =
        let 
            Return = 
                if Value.Is(value,Table.Type) then TableToMCode(value,indent) 
                else if Value.Is(value,Record.Type) then RecordToMCode(value,indent)
                else if Value.Is(value,List.Type) then ListToMCode(value,indent)
                else if Value.Is(value,Text.Type) then TextToMCode(value,indent)
                else if Value.Is(value,Number.Type) then NumberToMCode(value,indent)
                else if Value.Is(value,Null.Type) then NullToMCode(value,indent)
                else try Text.From(value)
        in
            Return
in
    Return
