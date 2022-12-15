let
    // Define a start time and an end time for the table
    StartTime = #time(0, 0, 0),

    // Generate a list of all the times between the start time and end time
    TimeList = List.Times(StartTime, 24*60*60, #duration(0, 0, 1, 0)),

    // Convert the list of times to a table
    TimeTable = Table.FromList(TimeList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // Add a column for the hour in 24-hour format
    Hour24 = Table.AddColumn(TimeTable, "Hour (24)", each Date.Hour([Column1])),

    // Add a column for the hour in 12-hour format
    Hour12 = Table.AddColumn(Hour24, "Hour (12)", each if #["Hour (24)"] = 0 then 12 else if #["Hour (24)"] > 12 then #["Hour (24)"] - 12 else #["Hour (24)"]),

    // Add a column for the AM/PM notation
    AmPm = Table.AddColumn(Hour12, "AM/PM", each if #["Hour (24)"] < 12 then "AM" else "PM"),

    // Add a column for the hour and AM/PM notation in the format "H AM/PM"
    HourAmPm = Table.AddColumn(AmPm, "Hour AM/PM", each Text.Combine({#["Hour (12)"], " ", [AM/PM]}), type text),

    // Add a column for the minute
    Minute = Table.AddColumn(HourAmPm, "Minute", each Date.Minute([Column1]))
in
    // Return the resulting table
    Minute
