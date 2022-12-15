let
    // Create a list of times
    timeList = List.Generate(
        () => #time(0, 0, 0),
        each minute([Value]) < 1440,
        each #time([Value] + #duration(0, 0, 1, 0)),
        each [Value]
    ),
    // Create a table with a time column
    source = Table.FromList(timeList, type table [Time = time]),
    // Add a column for the hour in 12-hour format
    add12HourColumn = Table.AddColumn(source, "Hour (12h)", each hour([Time]), type number),
    // Add a column for the hour in 24-hour format
    add24HourColumn = Table.AddColumn(add12HourColumn, "Hour (24h)", each hour24([Time]), type number),
    // Add a column for the minute
    addMinuteColumn = Table.AddColumn(add24HourColumn, "Minute", each minute([Time]), type number),
    // Add a column for AM/PM
    addAMPMColumn = Table.AddColumn(addMinuteColumn, "AM/PM", each "AM/PM"[Time], type text)
in
    addAMPMColumn
