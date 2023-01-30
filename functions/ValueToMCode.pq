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
            Documentation.SampleValues = {0, 1, 2, 3, 4}
        ]),
        optional options as (type record meta [
            Documentation.FieldCaption = "Options",
            Documentation.FieldDescription = "Options for the conversion"/*,
            Documentation.SampleValues = {[supressIndent=true], [supressIndent=false]}*/
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
                firstindent & (if value then "true" else "false"),

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

            TypeToMCode = (value as type) as text =>
                Table.SingleRow(Table.Schema(#table(type table [Col1 = value], {})))[TypeName],

            // Determines if a value is Complex:
            // Tables, Functions, and Binary are always treated as complex
            // Records are complex if they have complex field values or more than 2 field values
            // Lists are complex if they have any complex values or if all values are either complex or lists or records
            // All others should be simple primitive values
            // Complex values should generally be broken up with additional lines and indentation, while non-complex values should be okay if inline
            isComplex = 
                (value as any) as logical =>
                let
                    ValueToKind = 
                        (value as any) =>
                        let 
                            Kind = Table.SingleRow(Table.Schema(#table(type table [Col1 = Value.Type(value)], {})))[Kind]
                        in
                            Kind,
                    kind = ValueToKind(value),
                    hasComplexChildren = 
                        (children as list) as logical => 
                        let
                            result = List.AnyTrue(List.Transform(children, each @isComplex(_)))
                        in
                            result,
                    hasAllComplexImmediateChildren = 
                        (children as list) as logical => 
                        let
                            result = List.AllTrue(List.Transform(children, each List.Contains({"list","record","table","binary","function"},ValueToKind(_))))
                        in
                            result,
                    isValueComplex = 
                        if not List.Contains({"list","record","table","binary","function"},kind) then 
                            false
                        else if kind = "list" then
                            let
                                children = value
                            in
                                hasComplexChildren(children) or hasAllComplexImmediateChildren(children)
                        else if kind = "record" then
                            let
                                children = Record.FieldValues(value)
                            in
                                hasComplexChildren(children) or Record.FieldCount(value)>2
                        else
                            true
                in
                    isValueComplex,

            newline = "#(cr)#(lf)",

            ListToMCode = (value as list) as text =>
                let 
                    Result = 
                        if isComplex(value) then 
                            firstindent & "{" & newline &
                            Text.Combine(
                                List.Transform(
                                    value,
                                    each @ValueToMCode(_,indentTabs+1)
                                ),
                                "," & newline
                            ) &
                            newline & indent & "}"
                        else
                            firstindent & "{" &
                            Text.Combine(
                                List.Transform(
                                    value,
                                    each @ValueToMCode(_,indentTabs+1,[supressIndent = true])
                                ),
                                ", "
                            ) &
                            "}"
                in 
                    Result,

            RecordToMCode = (value as record) as text =>
                let 
                    fields = Record.FieldNames(value),
                    Result = 
                        if isComplex(value) then
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
                        else
                            firstindent & "[" &
                            Text.Combine(
                                List.Transform(
                                    fields,
                                    each 
                                        Expression.Identifier(_) & " = " & 
                                        @ValueToMCode(Record.Field(value,_), indentTabs+1, [supressIndent = true])
                                ),
                                ", "
                            ) &
                            "]"
                in 
                    Result,

            TableToMCode = (value as table) as text =>
                let 

                    IdentifyColumnType = 
                        (column as list) as type =>
                        let 
                            Source = column,
                            #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                            #"Filtered Rows2" = Table.SelectRows(#"Converted to Table", each [Column1]<> null and [Column1] <> ""),
                            NonEmptyValues = List.Count(#"Filtered Rows2"[Column1]),
                            #"Added Custom" = Table.AddColumn(#"Filtered Rows2", "Type Check", each #table({"Type Name","Type","Check"},{
                                {"list", type list, each try (_ is list) otherwise false},
                                {"record", type record, each try (_ is record) otherwise false},
                                {"table", type table, each try (_ is table) otherwise false},
                                {"binary", type binary, each try (_ is binary) otherwise false},
                                {"function", type function, each try (_ is function) otherwise false},
                                {"date", Date.Type, each try Text.From(_)=Text.From(Date.From(_)) otherwise false},
                                {"datetime", DateTime.Type, each try Text.From(_)=Text.From(DateTime.From(_)) otherwise false},
                                {"datetimezone", DateTimeZone.Type, each try Text.From(_)=Text.From(DateTimeZone.From(_)) otherwise false},
                                {"duration", Duration.Type, each try Text.From(_)=Text.From(Duration.From(_)) otherwise false},
                                {"logical", Logical.Type, each try Text.From(_)=Text.From(Logical.From(_)) otherwise false},
                                {"integer", Int64.Type, each try Text.From(_)=Text.From(Int64.From(_)) otherwise false},
                                {"number", Number.Type, each try Text.From(_)=Text.From(Number.From(_)) otherwise false},
                                {"time", Time.Type, each try Text.From(_)=Text.From(Time.From(_)) otherwise false},
                                {"text", Text.Type, each try Text.From(_)=Text.From(Text.From(_)) otherwise false}
                            })),
                            #"Expanded Type Check" = Table.ExpandTableColumn(#"Added Custom", "Type Check", {"Type Name", "Type", "Check"}, {"Type Check.Type Name", "Type Check.Type", "Type Check.Check"}),
                            #"Added Custom1" = Table.AddColumn(#"Expanded Type Check", "Check Result", each [Type Check.Check]([Column1])),
                            #"Filtered Rows" = Table.SelectRows(#"Added Custom1", each ([Check Result] = true)),
                            #"Grouped Rows" = Table.Group(#"Filtered Rows", {"Type Check.Type Name", "Type Check.Type"}, {{"Count", each Table.RowCount(_), Int64.Type},{"Data", each [Column1]}}),
                            #"Replaced Value" = Table.ReplaceValue(#"Grouped Rows", each [Type Check.Type], each if [Type Check.Type Name] = "datetime" and (if [Type Check.Type Name]<>"datetime" then null else (let times = List.Distinct(List.Sort(List.Transform(List.RemoveNulls([Data]), each Time.From(_)))), first = times{0} in List.Count(times)=1 and first = #time(0,0,0) )) then Date.Type else [Type Check.Type],Replacer.ReplaceValue,{"Type Check.Type"}),
                            #"Filtered Rows1" = Table.SelectRows(#"Replaced Value", each ([Count] = NonEmptyValues)),
                            Custom1 = try #"Filtered Rows1"{0}[Type Check.Type] otherwise Any.Type 
                        in 
                            Custom1,
                    
                    headers = 
                        indent & "    type table " & 
                        @ValueToMCode(
                            Record.FromList(
                                List.Transform(Table.ColumnNames(value), each IdentifyColumnType(Table.Column(value,_))),
                                Table.ColumnNames(value)
                            ),
                            indentTabs+1,
                            [supressIndent = true]
                        ),
                    rows = @ValueToMCode(Table.ToRows(value),indentTabs+1,[supressIndent = false]),
                    Result = 
                        firstindent & "#table(" & newline &
                        headers & "," & newline &
                        rows & newline &
                        indent & ")"
                in 
                    Result,
            
            BinaryToMCode = (value as binary) as text =>
                firstindent & "Binary.Decompress(Binary.FromText(" & @ValueToMCode(Text.From(Binary.Compress(value,Compression.Deflate))) & "),Compression.Deflate)",

            FunctionToMCode = (value as function) as text =>
                if Record.HasFields(Value.Metadata(Value.Type(value)),"Source Code") or Record.HasFields(Value.Metadata(value),"Source Code") then
                    let  
                        Source = Record.FieldOrDefault(Value.Metadata(Value.Type(value)),"Source Code",Value.Metadata(value)[Source Code]),
                        Deflated = Text.From(Binary.Compress(Text.ToBinary(Source),Compression.Deflate)),
                        Reinflate = firstindent & "Expression.Evaluate(Text.FromBinary(Binary.Decompress(Binary.FromText(" & TextToMCode(Deflated) & "),Compression.Deflate)),#shared)"
                    in  
                        Reinflate
                else
                    error "Can only convert functions to M Code if the source code is included as metadata on the function as Source Code",//firstindent & "/* Function without Source Code Metadata */null",

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
                        else if value is type then TypeToMCode(value)
                        else 
                            let 
                                Attempt = try Text.From(value),
                                Return = if Attempt[HasError] then Attempt[Error] else Attempt[Value]
                            in 
                                if Expression.Evaluate(Return)=value then Return else error "Unable to convert to M Code"
                in 
                    if Record.FieldCount(Value.Metadata(value)) > 0 and 
                        not Text.Contains(Value.Metadata(value)[Documentation.Description]?,"The type that represents ") then
                        Return & " meta " & 
                        (let  
                            metadata = Value.Metadata(value),
                            Source = @ValueToMCode(metadata),
                            Deflated = Text.From(Binary.Compress(Text.ToBinary(Source),Compression.Deflate)),
                            Reinflate = firstindent & "Expression.Evaluate(Text.FromBinary(Binary.Decompress(Binary.FromText(" & TextToMCode(Deflated) & "),Compression.Deflate)))"
                        in  
                            Source)
                    else
                        Return
        in 
            Return
in
    Value.ReplaceType(ValueToMCode,ValueToMCodeType)
