let
    TableDetectType_Type = type function (
        candidateTable as (type table meta [
            Documentation.FieldCaption = "Table",
            Documentation.FieldDescription = "Table whose data types are to be identifed"
        ]))
        as table meta [
            Documentation.Name = "TableDetectType",
            Documentation.LongDescription = "Identifies the data types of the columns in a table by iterating through each column and using a series of checks to determine the data type.",
            Documentation.Examples = {[
                Description = "Returns a table with the data types of the columns in the input table",
                Code = "TableDetectType(someTable)",
                Result = "<someTable, with all column types updated to the best fit types for each column>"
            ]}
        ],
        
    TableDetectTypeImpl = 
        (candidateTable as table) as table =>
        let
            
            IdentifyColumnType = 
                (column as list) as type =>
                let
                    Source = List.FirstN(column, 1000),
                    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                    #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each [Column1] <> null and [Column1]<> ""),
                    #"Added Custom" = Table.AddColumn(#"Filtered Rows", "Type Check", each #table({"Type Name", "Type", "Check"},{
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
                    #"Filtered Rows1" = Table.SelectRows(#"Added Custom1", each ([Check Result] = true)),
                    #"Grouped Rows" = Table.Group(#"Filtered Rows1", {"Type Check.Type Name", "Type Check.Type"}, {{"Count", each Table.RowCount(_), Int64.Type}, {"Data", each [Column1]}}),
                    #"Added Custom2" = Table.AddColumn(#"Grouped Rows", "Custom", each if [Type Check.Type Name] <> "datetime" then null else (
                        let
                            times = List.Distinct(
                                        List.Sort(
                                            List.Transform(List.RemoveNulls([Data]), each Time.From(_))
                                        )
                                    ),
                            first = times{0}
                        in
                            List.Count(times) = 1 and first = #time(0,0,0)
                    )),
                    #"Replaced Value" = Table.ReplaceValue(#"Added Custom2", each [Type Check.Type], each if [Type Check.Type Name] = "datetime" and (if [Type Check.Type Name] <> "datetime" then null else (
                        let
                            times = List.Distinct(List.Sort(List.Transform(List.RemoveNulls([Data]), each Time.From(_)))),
                            first = times{0}
                        in
                            List.Count(times) = 1 and first = #time(0,0,0) ))
                        then
                            Date.Type
                        else
                            [Type.Check.Type], Replacer.ReplaceValue, {"Type Check.Type"}),
                    #"Filtered Rows2" = Table.SelectRows(#"Replaced Value", each ([Count] = List.Max(#"Replaced Value"[Count]))),
                    Custom1 = try #"Filtered Rows2"{0}[Type Check.Type] otherwise Any.Type
                in
                    Custom1,

            Source = candidateTable,
            Custom1 = Table.ColumnNames(Source),
            #"Converted to Table" = Table.FromList(Custom1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Added Custom" = Table.AddColumn(#"Converted to Table", "Type", each IdentifyColumnType(Table.Column(Source,[Column1]))),
            #"Added Custom1" = Table.AddColumn(#"Added Custom", "ChangeTypes", each {[Column1], [Type]}),
            Custom2 = Table.TransformColumnTypes(Source, #"Added Custom1"[ChangeTypes]),
        in
            Custom2
in
    Value.ReplaceType(TableDetectTypeImpl, TableDetectType_Type)
