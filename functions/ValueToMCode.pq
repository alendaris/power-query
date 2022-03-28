(value as any,optional indentStart as number) =>
let

    indent = if indentStart is null then 0 else indentStart,

    NullToMCode = (value as any) as text =>
        """""",

    TextToMCode = (value as text) as text =>
        """" & Text.Replace(value,"""","""""") & """",
    
    NumberToMCode = (value as number) as text =>
        Number.ToText(value),

    DateToMCode = (value as date) as text =>
        "#date(" & Text.From(Date.Year(value)) & "," & Text.From(Date.Month(value)) & "," & Text.From(Date.Day(value)) & ")",

    TimeToMCode = (value as time) as text =>
        "#time(" & Text.From(Time.Hour(value)) & "," & Text.From(Time.Minute(value)) & "," & Text.From(Time.Second(value)) & ")",

    DatetimeToMCode = (value as datetime) as text =>
        "#datetime(" & Text.From(DateTime.ToRecord(value)[Year]) & "," & Text.From(DateTime.ToRecord(value)[Month]) & "," & Text.From(DateTime.ToRecord(value)[Day]) & "," & Text.From(DateTime.ToRecord(value)[Hour]) & "," & Text.From(DateTime.ToRecord(value)[Minute]) & "," & Text.From(DateTime.ToRecord(value)[Second]) & ")",

//    DurationToMCode = (value as date) as text =>
//        "#date(" & Text.From(Date.Year(date)) & "," & Text.From(Date.Month(date)) & "," & Text.From(Date.Day(date)) & ")",



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
//                else if Value.Is(value,Duration.Type) then DurationToMCode(value)
                else if Value.Is(value,Time.Type) then TimeToMCode(value)
                else if Value.Is(value,Date.Type) then DateToMCode(value)
                else if Value.Is(value,DateTime.Type) then DatetimeToMCode(value)
                else if Value.Is(value,Text.Type) then TextToMCode(value)
                else if Value.Is(value,Number.Type) then NumberToMCode(value)
                else if Value.Is(value,Null.Type) then NullToMCode(value)
                else try Text.From(value)
        in
            Return
in
    Return
