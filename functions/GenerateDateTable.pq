let
func = (FromYear as number, ToYear as number, optional StartofFiscalYear as number) =>
    let
        Today = Date.From(DateTime.LocalNow()),
        firstDayofWeek = Day.Monday,
        
        FromDate = #date(FromYear, 1, 1),
        ToDate = #date(ToYear, 12, 31),
        Source = List.Dates(
            FromDate,
            Duration.Days(ToDate-FromDate)+1,
            #duration(1, 0, 0, 0)
        ),
        #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Date"}}),
        #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Date", type date}}),
        #"Inserted Key" = Table.AddIndexColumn(#"Changed Type", "DateKey", 1, 1, Int64.Type),
        #"Inserted Year" = Table.AddColumn(#"Inserted Key", "Year", each Date.Year([Date]), Int64.Type),
        #"Inserted Start of Year" = Table.AddColumn(#"Inserted Year", "Start of Year", each Date.StartOfYear([Date]), type date),
        #"Inserted End of Year" = Table.AddColumn(#"Inserted Start of Year", "End of Year", each Date.EndOfYear([Date]), type date),
        #"Inserted Month" = Table.AddColumn(#"Inserted End of Year", "Month", each Date.Month([Date]), Int64.Type),
        #"Inserted Start of Month" = Table.AddColumn(#"Inserted Month", "Start of Month", each Date.StartOfMonth([Date]), type date),
        #"Inserted End of Month" = Table.AddColumn(#"Inserted Start of Month", "End of Month", each Date.EndOfMonth([Date]), type date),
        #"Inserted Days in Month" = Table.AddColumn(#"Inserted End of Month", "Days in Month", each Date.DaysInMonth([Date]), Int64.Type),
        #"Inserted Day" = Table.AddColumn(#"Inserted Days in Month", "Day", each Date.Day([Date]), Int64.Type),
        #"Inserted Day Name" = Table.AddColumn(#"Inserted Day", "Day Name", each Date.DayOfWeekName([Date]), type text),
        #"Inserted Day of Week" = Table.AddColumn(#"Inserted Day Name", "Day of Week", each Date.DayOfWeek([Date],firstDayofWeek), Int64.Type),
        #"Inserted Day of Year" = Table.AddColumn(#"Inserted Day of Week", "Day of Year", each Date.DayOfYear([Date]), Int64.Type),
        #"Inserted Month Name" = Table.AddColumn(#"Inserted Day of Year", "Month Name", each Date.MonthName([Date]), type text),
        #"Inserted Quarter" = Table.AddColumn(#"Inserted Month Name", "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
        #"Inserted Start of Quarter" = Table.AddColumn(#"Inserted Quarter", "Start of Quarter", each Date.StartOfQuarter([Date]), type date),
        #"Inserted End of Quarter" = Table.AddColumn(#"Inserted Start of Quarter", "End of Quarter", each Date.EndOfQuarter([Date]), type date),
        #"Inserted Week of Year" = Table.AddColumn(#"Inserted End of Quarter", "Week of Year", each Date.WeekOfYear([Date],firstDayofWeek), Int64.Type),
        #"Inserted Week of Month" = Table.AddColumn(#"Inserted Week of Year", "Week of Month", each Date.WeekOfMonth([Date],firstDayofWeek), Int64.Type),
        #"Inserted Start of Week" = Table.AddColumn(#"Inserted Week of Month", "Start of Week", each Date.StartOfWeek([Date],firstDayofWeek), type date),
        #"Inserted End of Week" = Table.AddColumn(#"Inserted Start of Week", "End of Week", each Date.EndOfWeek([Date],firstDayofWeek), type date),
        FiscalMonthBaseIndex=13-StartofFiscalYear, adjustedFiscalMonthBaseIndex=if(FiscalMonthBaseIndex>=12 or FiscalMonthBaseIndex<0) then 0 else FiscalMonthBaseIndex,
        #"Added Custom" = Table.AddColumn(#"Inserted End of Week", "FiscalBaseDate", each Date.AddMonths([Date],adjustedFiscalMonthBaseIndex)),
        #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom",{{"FiscalBaseDate", type date}}),
        #"Inserted Year1" = Table.AddColumn(#"Changed Type1", "Year.1", each Date.Year([FiscalBaseDate]), Int64.Type),
        #"Renamed Columns1" = Table.RenameColumns(#"Inserted Year1",{{"Year.1", "Fiscal Year"}}),
        #"Inserted Quarter1" = Table.AddColumn(#"Renamed Columns1", "Quarter.1", each Date.QuarterOfYear([FiscalBaseDate]), Int64.Type),
        #"Renamed Columns2" = Table.RenameColumns(#"Inserted Quarter1",{{"Quarter.1", "Fiscal Quarter"}}),
        #"Inserted Month1" = Table.AddColumn(#"Renamed Columns2", "Month.1", each Date.Month([FiscalBaseDate]), Int64.Type),
        #"Renamed Columns3" = Table.RenameColumns(#"Inserted Month1",{{"Month.1", "Fiscal Month"}}),
        #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns3",{"FiscalBaseDate"}),
        
        #"Inserted Age" = Table.AddColumn(if StartofFiscalYear <> null then #"Removed Columns" else #"Inserted End of Week", "Age", each [Date]-Today, type duration),
        #"Extracted Days" = Table.TransformColumns(#"Inserted Age",{{"Age", Duration.Days, Int64.Type}}),
        #"Renamed Columns4" = Table.RenameColumns(#"Extracted Days",{{"Age", "Day Offset"}}),
        #"Added Custom1" = Table.AddColumn(#"Renamed Columns4", "Month Offset", each (([Year]-Date.Year(Today))*12)+([Month]-Date.Month(Today))),
        #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1",{{"Month Offset", Int64.Type}}),
        #"Added Custom2" = Table.AddColumn(#"Changed Type2", "Year Offset", each [Year]-Date.Year(Today)),
        #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom2",{{"Year Offset", Int64.Type}}),
        #"Added Custom3" = Table.AddColumn(#"Changed Type3", "Quarter Offset", each (([Year]-Date.Year(Today))*4)+([Quarter]-Date.QuarterOfYear(Today))),
        #"Changed Type4" = Table.TransformColumnTypes(#"Added Custom3",{{"Quarter Offset", Int64.Type}}),
        #"Added Custom4" = Table.AddColumn(#"Changed Type4", "Year-Month", each Date.ToText([Date],"MMM yyyy"))
    in
        #"Changed Type4",

    TableToMCode = 
        (value as table) as text =>
        let
            ListOfColumns = Table.ToRows(value),
            ConvertToTable = Table.FromList(
                ListOfColumns, 
                Splitter.SplitByNothing(), 
                null, 
                null, 
                ExtraValues.Error
            ),
            CoreString = Table.AddColumn(
                ConvertToTable, 
                "Custom", 
                each Text.Combine(List.Transform([Column1], each if _ = null then "null" else """" & Text.Replace(Text.From(_),"""","""""") & """"), ", ")
            ),
            FullString = "= #table( {"""
                & Text.Combine(Table.ColumnNames(value), """, """)
                & """}, #(lf) { {"
                & Text.Combine(CoreString[Custom], "}, #(lf) {")
                & "} } ) "
        in
            FullString,

    ExampleTable = Table.Combine({Table.FirstN(func(2020, Date.Year(DateTime.LocalNow())), 1), Table.LastN(func(2020, Date.Year(DateTime.LocalNow())), 1)}),

fntype = type function
    (
        FromYear as (type number meta [
            Documentation.FieldCaption = "From Year",
            Documentation.FieldDescription = "Earliest calendar year in the date table, which will start on January 1",
            Documentation.SampleValues = {1981}
        ]),
        ToYear as (type number meta [
            Documentation.FieldCaption = "To Year",
            Documentation.FieldDescription = "Latest calendar year in the date table, which will end on December 31",
            Documentation.SampleValues = {Text.From(Date.Year(DateTime.LocalNow()))}
        ]),
        optional StartofFiscalYear as (type number meta [
            Documentation.FieldCaption = "Start of Fiscal Year",
            Documentation.FieldDescription = "Month number of the first month in the fiscal year.",
            Documentation.SampleValues = {"10"}
        ])
    ) as table meta
        [
            Documentation.Name = "GenerateDateTable",
            Documentation.LongDescription = "This function generates a date table from FromYear to ToYear with the following fields:#(cr)#(lf)" & Text.Combine(Record.FieldNames(Table.First(ExampleTable)), ", ") & ". For fiscal year calculations, StartofFiscalYear establishes the first month of the fiscal year.",
            Documentation.Examples =
            {
                [
                    Description = "Create a list of dates from 2020 to the current year. Do not provide Fiscal Year columns.",
                    Code = "GenerateDateTable(2020, Date.Year(DateTime.LocalNow()))",
                    Result = TableToMCode(ExampleTable)
                ]
            }
        ]

in
    Value.ReplaceType(func,fntype)
