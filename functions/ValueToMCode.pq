(value as any,optional indentStart as number) =>
let

    indent = if indentStart is null then 0 else indentStart,

    NullToMCode = (value as any) as text =>
        "null",

    LogicalToMCode = (value as logical) as text =>
        if value then "TRUE" else "FALSE",

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

    DatetimezoneToMCode = (value as datetimezone) as text =>
        "#datetime(" & Text.From(DateTimeZone.ToRecord(value)[Year]) & "," & Text.From(DateTimeZone.ToRecord(value)[Month]) & "," & Text.From(DateTimeZone.ToRecord(value)[Day]) & "," & Text.From(DateTimeZone.ToRecord(value)[Hour]) & "," & Text.From(DateTimeZone.ToRecord(value)[Minute]) & "," & Text.From(DateTimeZone.ToRecord(value)[Second]) & Text.From(DateTimeZone.ToRecord(value)[ZoneHours]) & Text.From(DateTimeZone.ToRecord(value)[ZoneMinutes]) & ")",

    DurationToMCode = (value as duration) as text =>
        "#duration(" & Text.From(Duration.Days(value)) & "," & Text.From(Duration.Hours(value)) & "," & Text.From(Duration.Minutes(value)) & "," & Text.From(Duration.Seconds(value)) & ")",

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

    BinaryToMCode = (value as binary) as text =>
        "Binary.Decompress(Binary.FromText(" & TextToMCode(Text.From(Binary.Compress(value,Compression.Deflate))) & "),Compression.Deflate)",

    FunctionToMCode = (value as function) as text =>
        if Record.HasFields(Value.Metadata(Value.Type(value)),"Source Code") then
            let  
                Source = Value.Metadata(Value.Type(value))[Source Code],
                Deflated = Text.From(Binary.Compress(Text.ToBinary(Source),Compression.Deflate)),
                Reinflate = "Text.FromBinary(Binary.Decompress(Binary.FromText(" & TextToMCode(Deflated) & "),Compression.Deflate))"
            in  
                Reinflate
        else
            TextToMCode("/* Function without Source Code Metadata */null"),

    Return =
        let 
            Return = 
                if Value.Is(value,Function.Type) then FunctionToMCode(value)
                else if Value.Is(value,Table.Type) then TableToMCode(value,indent) 
                else if Value.Is(value,Record.Type) then RecordToMCode(value,indent)
                else if Value.Is(value,List.Type) then ListToMCode(value,indent)
                else if Value.Is(value,Duration.Type) then DurationToMCode(value)
                else if Value.Is(value,Time.Type) then TimeToMCode(value)
                else if Value.Is(value,Date.Type) then DateToMCode(value)
                else if Value.Is(value,DateTime.Type) then DatetimeToMCode(value)
                else if Value.Is(value,Text.Type) then TextToMCode(value)
                else if Value.Is(value,Number.Type) then NumberToMCode(value)
                else if Value.Is(value,Logical.Type) then LogicalToMCode(value)
                else if Value.Is(value,Null.Type) then NullToMCode(value)
                else if Value.Is(value,Binary.Type) then BinaryToMCode(value)
                else
                    let
                        Attempt = try Text.From(value),
                        Return = if Attempt[HasError] then Attempt[Error] else Attempt[Value]
                    in  
                        Return
        in
            Return
in
    Return
