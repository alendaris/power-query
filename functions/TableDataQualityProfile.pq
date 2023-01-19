(Table1 as table) as table =>
let 

    TableDetectType = 
        (candidateTable as table) as table =>
        let 
        
            IdentifyColumnType = 
            (column as list) as type =>
            let 
                Source = column,
                #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                #"Filtered Rows2" = Table.SelectRows(#"Converted to Table", each [Column1]<> null and [Column1] <> ""),
                NonEmptyValues = List.Count(#"Filtered Rows2"[Column1]),
                #"Added Custom" = Table.AddColumn(#"Filtered Rows2", "Type Check", each #table({"Type Name","Type","Check"},{
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

            Source = candidateTable,
            Custom1 = Table.ColumnNames(Source),
            #"Converted to Table" = Table.FromList(Custom1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Added Custom" = Table.AddColumn(#"Converted to Table", "Type", each IdentifyColumnType(Table.Column(Source,[Column1]))),
            #"Added Custom1" = Table.AddColumn(#"Added Custom", "ChangeTypes", each {[Column1],[Type]}),
            Custom2 = Table.TransformColumnTypes(Source,#"Added Custom1"[ChangeTypes])
        in 
            Custom2,
    Source = TableDetectType(Table.ReplaceValue(Table1,"NULL",null,Replacer.ReplaceValue,Table.ColumnNames(Table1))),
    Schema = Table.Schema(Source),
    Profile = Table.Profile(
        Source,
        {
            {"Text Length Varies", each Type.Is(_,type nullable text), each List.Min(List.Transform(_, each Text.Length(_)))<>List.Max(List.Transform(_,each Text.Length(_)))},
            {"1st 10 Unique Values", each true, each Text.Combine(List.Transform(List.FirstN(List.Distinct(_),10), each Text.From(_)), "; ")}
        }
    ),
    Custom1 = Table.NestedJoin(Profile,"Column", "Schema", "Name", "Schema", JoinSide.Left),
    #"Expanded Schema" = Table.ExpandTableColumn(Custom1, "Schema", {"Position", "Kind"}, {"Position", "Kind"}),
    #"Added Custom" = Table.AddColumn(#"Expanded Schema", "All Unique Values", each [DistinctCount] = [Count]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Questions", each ""),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Assumptions", each ""),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Temporary Mitigations", each ""),
    #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Describe Data", each 
        (
            if [NullCount] = 0 then 
                "required "
            else if [NullCount] = [Count] then 
                "empty"
            else if [NullCount]>[Count]/2 then 
                "sparse "
            else if [DistinctCount] = 1 then 
                "same "
            else 
                ""
        ) &
        (
            if [DistinctCount] = [Count] and [NullCount] = 0 then 
                "unique "
            else
                ""
        ) &
        (
            if [Kind] <> "text" then 
                ""
            else 
                (
                    if [Text Length Varies] then 
                        "variable-length "
                    else 
                        "constant-length"
                )
        ) &
        (
            if [NullCount] = [Count] then 
                ""
            else 
                [Kind]
        )
    ),
    #"Reordered Columns" = Table.ReorderColumns(#"Added Custom4",{
        "Column",
        "Describe Data",
        "Questions",
        "Assumptions",
        "Temporary Mitigations",
        "All Unique Values",
        "Text Length Varies",
        "1st 10 Unique Values",
        "Min",
        "Max",
        "Average",
        "StandardDeviation",
        "Count",
        "NullCount",
        "DistinctCount"
    }),
    #"Sorted Rows" = Table.Sort(#"Reordered Columns", {{"Position", Order.Ascending}}),
    #"Removed Columns" = Table.RemoveColumns(#"Sorted Rows",{"Postion", "Kind"})
in 
    #"Removed Columns"
