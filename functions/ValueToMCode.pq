let
    FunctionName = "ValueToMCode",
    DocumentationLongDescriptionBase = "This function converts a value into M Code. Binary values are converted to a compressed string wrapped inside of function calls to decompress back to a binary value. Functions must have a metadata field named Source Code.",
    DocumentationLongDescriptionComplete = 
        if ThisFunctionName <> FunctionName then
            DocumentationLongDescriptionBase & "#(cr)#(lf)#(cr)#(lf)NOTE: This function performs best when it is named """ & Expression.Identifier(FunctionName) & """. Please consider renaming the function."
        else
            DocumentationLongDescriptionBase,
    findQueryByDocumentationName = 
        let
            Source = Record.ToTable(#shared),
            #"Removed Errors" = Table.RemoveRowsWithErrors(Source, {"Value"}),
            #"Added Custom" = Table.AddColumn(#"Removed Errors", "Type Metadata", each Value.Metadata(Value.Type([Value]))),
            #"Added Custom1" = Table.AddColumn(#"Added Custom", "Documentation.Name", each if Record.HasFields([Type Metadata],"Documentation.Name") then [Type Metadata][Documentation.Name] else null),
            #"Filtered Rows" = Table.SelectRows(#"Added Custom1", each ([Documentation.Name] = FunctionName)),
            #"Removed Duplicates" = Table.Distinct(#"Filtered Rows", {"Documentation.Name"})[Name]{0}
        in
            #"Removed Duplicates",
    ThisFunctionName = findQueryByDocumentationName,
    envLocal = Record.Combine({#shared, [ThisFunctionName = ThisFunctionName]}),
    func = (value as any, optional indentStart as number) as any =>
        let
            // indent tracks the current indentation level
            // for the simple types, we don't worry about the indent level, as they should display inline in most cases
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
        
            ListToMCode = (value as list, optional indent as number) as text =>
                let
                    Source = value,
                    Types = List.Transform(Source,each Value.Type(_)),
                    needsIndent = List.ContainsAny(Types,{List.Type,Record.Type,Table.Type}),
                    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                    #"Added Custom" = Table.AddColumn(#"Converted to Table", "MCode", each Expression.Evaluate(ThisFunctionName, envLocal)([Column1])),
                    Result =
                        if needsIndent then
                            Text.PadStart("", 4*indent, " ") & "{#(cr)#(lf)" &
                            Text.Combine(
                                List.Transform(
                                    Source,
                                    each Text.PadStart("", 4*(indent)+1, " ") & Expression.Evaluate(ThisFunctionName, envLocal)(_, indent + 1)),
                                ",#(cr)#(lf)") &
                            "#(cr)#(lf)" & Text.PadStart("",4*indent, " ") & "}"
                        else  
                            "{" & Text.Combine(#"Added Custom"[MCode],", ") & "}"
                in
                    Result,
        
            RecordToMCode = (value as record, optional indent as number) as text =>
            let
                fields = Record.FieldNames(value),
                Types = List.Transform(Record.FieldValues(value),each Value.Type(_)),
                needsIndent = List.ContainsAny(Types,{List.Type,Record.Type,Table.Type}),
                withValues = List.Transform(fields,each "#" & TextToMCode(_) & " = " & Expression.Evaluate(ThisFunctionName, envLocal)(Record.Field(value,_), indent+1)),
                Return = 
                    if needsIndent then
                        "#(cr)#(lf)" & Text.PadStart("", 4*indent, " ") & "[#(cr)#(lf)" & Text.PadStart("", 4*(indent+1), " ") &
                        Text.Combine(withValues,",#(cr)#(lf)" & Text.PadStart("", 4*(indent+1), " ")) &
                        "#(cr)#(lf)" & Text.PadStart("",4*indent, " ") & "]#(cr)#(lf)"
                    else
                        "[" & Text.Combine(withValues,",#(lf)") & "]"
            in
                Return,
        
            TableToMCode = (value as table, indent as number) =>
                let
                    needsIndent =
                    let
                        Source = Table.ToRows(value),
                        typeCheck = List.ContainsAny(
                            List.Transform(Source,
                                each List.ContainsAny(List.Transform(_, each Value.Type(_)),
                                {List.Type,Record.Type,Table.Type})
                            ),
                            {true}
                        )
                    in
                        typeCheck,
                    headers = ListToMCode(Table.ColumnNames(value),indent),
                    rows = List.Transform(Table.ToRows(value), each ListToMCode(_, 0)),
                    Return = 
                        if needsIndent then  
                            "#table(#(cr)" & Text.PadStart("", 4*(indent+1), " ") &
                            headers & ",#(cr)" & Text.PadStart("", 4*(indent+1), " ") &
                            "{#(cr)#(lf)" & Text.PadStart("",4*(indent+2), " ") & "#(cr)#(lf)" &
                            Text.Combine(rows, ",#(cr)#(lf)" & Text.PadStart("", 4*(indent+2), " ")) &
                            "#(cr)#(lf)" & Text.PadStart("",4*(indent+1), " ") & "}#(cr)#(lf)" &
                            "#(cr)#(lf)" & Text.PadStart("",4*indent, " ") & ")#(cr)#(lf)"
                        else
                            "#table(" & headers & ", {" & Text.Combine(rows,", ") & "})"
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
            Return,

    ExampleArgument = "The book started with the line, ""There was no hope of a walk that day.""",



    funcType = type function
        (
            value as (type any meta [
                Documentation.FieldCaption = "Value",
                Documentation.FieldDescription = "Value to be converted to M Code",
                Documentation.SampleValues = {{1,2,3,4,5}},
                Formatting.IsCode = true
            ]),
            optional indentStart as (type number meta [
                Documentation.FieldCaption = "Indentation",
                Documentation.FieldDescription = "Used internally to indent M Code",
                Documentation.AllowedValues = {0}
            ])
         ) as any meta
            [
                Documentation.Name = FunctionName,
                Documentation.LongDescription = DocumentationLongDescriptionComplete,
                Documentation.Examples =
                {
                    [
                        Description = "Convert a string with quoted text to M Code.",
                        Code = ThisFunctionName & "(" & ExampleArgument &")",
                        Result = func(ExampleArgument)
                    ]
                }
            ]

    in
        Value.ReplaceType(func,funcType)
