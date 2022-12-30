let
    ValueToMCodeType = type function (
        value as (type any meta [
            Documentation.FieldCaption = "Value",
            Documentation.FieldDescription = "The value to convert to M code.",
            Documentation.SampleValues = {null, true, "hello", 3.14, #date(2020,1,1), #time(12,30,0), #datetime(2020,1,1,12,30,0), #datetimezone(2020,1,1,12,30,0, -5, 0), #duration(1,2,3,4), {1,2,3}, [a=1,b=2], (x) => x+1}
        ]),
        optional indentStart as (type number meta [
            Documentation.FieldCaption = "Indentation Start",
            Documentation.FieldDescription = "The number of tabs to use for indentation at the beginning of the string",
            Documentation.AllowedValues = {0, 1, 2, 3, 4}
        ]),
        optional options as (type record meta [
            Documentation.FieldCaption = "Options",
            Documentation.FieldDescription = "Options for the conversion"/*,
            Documentation.AllowedValues = {[supressIndent=true], [supressIndent=false]}*/
        ]))
        as any meta [
            Documentation.Name = "ValueToMCode",
            Documentation.LongDescription = "Converts a value of any type to a string representation of the M code that could be used to create that value  (Functions must have their Source Code stored in a ""Source Code"" metadata value on the function type)",
            Documentation.Examples = {[
                Description = "Convert a null value to M code",
                Code = "ValueToMCode(null)",
                Result = ValueToMCode(null)
            ],[
                Description = "Convert a number to M code",
                Code = "ValueToMCode(42)",
                Result = ValueToMCode(42)
            ],[
                Description = "Convert a text value that contains quoted text to M code",
                Code = "ValueToMCode(""This is a ""quoted"" string"")",
                Result = ValueToMCode("This is a ""quoted"" string")
            ],[
                Description = "Convert a list value to M code",
                Code = "ValueToMCode({1,2,3})",
                Result = ValueToMCode({1,2,3})
            ],[
                Description = "Convert a record value to M code",
                Code = "ValueToMCode([a=1,b=2])",
                Result = ValueToMCode([a=1,b=2])
            ],[
                Description = "Convert a table value to M code",
                Code = "ValueToMCode(Table.FromRecords({[a=1,b=2],[a=3,b=4]}))",
                Result = ValueToMCode(Table.FromRecords({[a=1,b=2],[a=3,b=4]}))
            ],[
                Description = "Convert a function value to M code",
                Code = "ValueToMCode((x) => x+1)",
                Result = "(x) => x + 1"
            ]}
        ],

    ValueToMCode = 
        (value as any, optional indentStart as number, optional options as record) as any =>
        let 
            supressIndent = Record.FieldOrDefault(options,"supressIndent",false),

            // indent tracks the current indentation level
            indentTabs = if indentStart = null then 0 else indentStart,
            firstindent = if supressIndent then "" else Text.Repeat("    ",indentTabs),
            indent = Text.Repeat("    ",indentTabs),

            NullToMCode = (value as any) as text =>
                firstindent & "null",

            LogicalToMCode = (value as logical) as text =>
                firstindent & (if value then "TRUE" else "FALSE"),

            TextToMCode = (value as text) as text =>
                firstindent & """" & Text.Replace(value,"""","""""") & """",

            NumberToMCode = (value as number) as text =>
                firstindent & Number.ToText(value),

            DateToMCode = (value as date) as text =>
                firstindent & "#date(" & Text.From(Date.Year(value)) & "," & Text.From(Date.Month(value)) & "," & Text.From(Date.Day(value)) & ")",
        
            TimeToMCode = (value as time) as text =>
                firstindent & "#time(" & Text.From(Time.Hour(value)) & "," & Text.From(Time.Minute(value)) & "," & Text.From(Time.Second(value)) & ")",
        
            DatetimeToMCode = (value as datetime) as text =>
                firstindent & "#datetime(" & Text.From(DateTime.ToRecord(value)[Year]) & "," & Text.From(DateTime.ToRecord(value)[Month]) & "," & Text.From(DateTime.ToRecord(value)[Day]) & "," & Text.From(DateTime.ToRecord(value)[Hour]) & "," & Text.From(DateTime.ToRecord(value)[Minute]) & "," & Text.From(DateTime.ToRecord(value)[Second]) & ")",
        
            DatetimezoneToMCode = (value as datetimezone) as text =>
                firstindent & "#datetime(" & Text.From(DateTimeZone.ToRecord(value)[Year]) & "," & Text.From(DateTimeZone.ToRecord(value)[Month]) & "," & Text.From(DateTimeZone.ToRecord(value)[Day]) & "," & Text.From(DateTimeZone.ToRecord(value)[Hour]) & "," & Text.From(DateTimeZone.ToRecord(value)[Minute]) & "," & Text.From(DateTimeZone.ToRecord(value)[Second]) & Text.From(DateTimeZone.ToRecord(value)[ZoneHours]) & Text.From(DateTimeZone.ToRecord(value)[ZoneMinutes]) & ")",
        
            DurationToMCode = (value as duration) as text =>
                firstindent & "#duration(" & Text.From(Duration.Days(value)) & "," & Text.From(Duration.Hours(value)) & "," & Text.From(Duration.Minutes(value)) & "," & Text.From(Duration.Seconds(value)) & ")",

            newline = "#(cr)#(lf)",

            ListToMCode = (value as list) as text =>
                let 
                    Source = Table.FromList(value,Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                    AddedEntryMCode = Table.AddColumn(Source, "MCode", each @ValueToMCode([Column1])),
                    Result = 
                        firstindent & "{" & newline &
                        Text.Combine(
                            List.Transform(
                                value,
                                each @ValueToMCode(_,indentTabs+1)
                            ),
                            "," & newline
                        ) &
                        newline & indent & "}"
                in 
                    Result,

            RecordToMCode = (value as record) as text =>
                let 
                    fields = Record.FieldNames(value),
                    Result = 
                        firstindent & "[" & newline &
                        Text.Combine(
                            List.Transform(
                                fields,
                                each 
                                    indent & "    " & Expression.Identifier(_) & " = " & 
                                    @ValueToMCode(Record.Field(value,_), indentTabs+2, [supressIndent = true])
                            ),
                            "," & newline
                        ) &
                        newline & indent & "]"
                in 
                    Result,

            TableToMCode = (value as table) as text =>
                let 
                    headers = @ValueToMCode(Table.ColumnNames(value), indentTabs+1),
                    rows = Text.Combine(
                        List.Transform(
                            Table.ToRows(value),
                            each @ValueToMCode(_,indentTabs+2)
                        ),
                        "," & newline
                    ),
                    Result = 
                        firstindent & "#table(" & newline &
                        headers & "," & newline &
                        indent & "    {" & newline &
                        rows & newline &
                        indent & "    }" & newline &
                        indent & ")"
                in 
                    Result,
            
            BinaryToMCode = (value as binary) as text =>
                firstindent & "Binary.Decompress(Binary.FromText(" & @ValueToMCode(Text.From(Binary.Compress(value,Compression.Deflate))) & "),Compression.Deflate)",

            FunctionToMCode = (value as function) as text =>
                if Record.HasFields(Value.Metadata(Value.Type(value)),"Source Code") then
                    let  
                        Source = Value.Metadata(Value.Type(value))[Source Code],
                        Deflated = Text.From(Binary.Compress(Text.ToBinary(Source),Compression.Deflate)),
                        Reinflate = firstindent & "Text.FromBinary(Binary.Decompress(Binary.FromText(" & TextToMCode(Deflated) & "),Compression.Deflate))"
                    in  
                        Reinflate
                else
                    firstindent & "/* Function without Source Code Metadata */null",

            Return = 
                let 
                    Return = 
                        if Value.Is(value,Function.Type) then FunctionToMCode(value)
                        else if Value.Is(value,Table.Type) then TableToMCode(value)
                        else if Value.Is(value,Record.Type) then RecordToMCode(value)
                        else if Value.Is(value,List.Type) then ListToMCode(value)
                        else if Value.Is(value,Duration.Type) then DurationToMCode(value)
                        else if Value.Is(value,Time.Type) then TimeToMCode(value)
                        else if Value.Is(value,Date.Type) then DateToMCode(value)
                        else if Value.Is(value,DateTime.Type) then DatetimeToMCode(value)
                        else if Value.Is(value,DateTimeZone.Type) then DatetimezoneToMCode(value)
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
                                if Expression.Evaluate(Return)=value then Return else error "Unable to convert to M Code"
                in 
                    Return
        in 
            Return
in
    Value.ReplaceType(ValueToMCode,ValueToMCodeType)
