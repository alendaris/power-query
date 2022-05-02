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
    let
        compressedCode = "zVTRatswFH33V1xUCDYYbXkdTaF1Eyg0HaShLyEU1b5OzGQpk+QlIeRf8i35sklynMbOBnucDbZ879HRuefK4mggr0QKAwAIIJyyD47ANBg3iGBwF3A0wfFwPPjU8TA4jWIffC60+Z4nklel0J9JOpUTudY1XVRDEyl+oTJT2SGiIyVLxxN6WHO3mOPjoZV8XfHCGFTUDx62L9IsC7EIoy5QVJz/S2y4MYq9MV6hpkOlpDpnz+oVvhplF7lQfp9ltcC29Hal3aVIUmkjS9KNI0uXlhg3hiay/CgEhs4DOlVM6FyqMpzVi/XncYMucni3rXMVgVmiAOKGBJBrBGIv6IFnnOCKsxRD/+EMD9+j2AH8g5DIAv3bUpMYSNStf2R5L+onA7jxWySEnZ12Rvc6FdQ+1bpfWInnLWEpiFuIXCzV88F9DDchzyPYWeq/En/2Y1b76Uy5mNuh3cMeIiBBITrVxEEm06pEYZgppLBmzoLHywh1st3vQaDZ2uNEZtbeuAN8RJ2qYnWisfCmcRoYwG1qJ915itsvfgxgpM1orwNkDmNwcdtIZmBd2JamCpk5BbzbUAjXZ/hZodoCZoWRil4reZZi8f+oSeyshbSIQePhNeZVVipFj7hOvqHSTRl9+pX2ryH3lVlK5RFP5Q+EEfKsZEJ8g/V6TadLfHhKU1lZuDA0lSX8Qedww8oVR21ZdrO2fSdZvu+NxgnqipvT53w/D9wBah2xT/AnSfPTTbcrDN0hG7fjYzQsY4aFdfQMi2Jo7ckoCn4D",
        func = Expression.Evaluate(Text.FromBinary(Binary.Decompress(Binary.FromText(compressedCode), Compression.Deflate)), #shared)
    in
        func,

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
            Documentation.Name = "generateDateTable",
            Documentation.LongDescription = "This function generates a date table from FromYear to ToYear with the following fields:#(cr)#(lf)" & Text.Combine(Record.FieldNames(Table.First(ExampleTable)), ", ") & ". For fiscal year calculations, StartofFiscalYear establishes the first month of the fiscal year.",
            Documentation.Examples =
            {
                [
                    Description = "Create a list of dates from 2020 to the current year. Do not provide Fiscal Year columns.",
                    Code = "generateDateTable(2020, Date.Year(DateTime.LocalNow()))",
                    Result = TableToMCode(ExampleTable)
                ]
            }
        ]

in
    Value.ReplaceType(func,fntype)
