let
    TableCleanFieldNamesType = type function (
        dirtyTable as (type table meta [
            Documentation.FieldCaption = "Table",
            Documentation.FieldDescription = "A table with column names in camelCase or snake_case."
        ]))
        as table meta [
            Documentation.Name = "Table Clean Field Names",
            Documentation.Description = "Cleans up the field names for a table by removing spaces, replacing spaces with underscores, converting to lower case, or converting to upper case",
            Documentation.Examples = {[
                Description = "Clean up field names in a table",
                Code = "TableCleanFieldNames(Table.FromRecords({[field_1=1,field_2=2],[field_1=3,field_2=4]}))",
                Result = "#table({""Field 1"",""Field 2""},{{1,2},{3,4}})"
            ]}
        ],

    TableCleanFieldNames = 
    (dirtyTable as table) as table =>
    let 
        RenameColumn = (ColumnName as text) as text =>
            let 
                SplitColumnName = 
                    Text.Combine(
                        List.Transform(
                            Text.Split(
                                Text.Replace(
                                    Text.Combine(
                                        Splitter.SplitTextByCharacterTransition({"a".."z"},{"A".."Z"})(ColumnName),
                                        " "
                                    ),
                                    "_",
                                    " "
                                ),
                                " "
                            ),
                            each 
                                if Text.Length(_)<3 then
                                    Text.Upper(_)
                                else 
                                    Text.Proper(_)
                        ),
                        " "
                    ),
                FixTrailingNo = 
                    if Text.End(SplitColumnName,3) = " NO" then 
                        Text.Replace(SplitColumnName," NO"," Number")
                    else 
                        SplitColumnName
            in 
                FixTrailingNo
    in 
        Table.TransformColumnNames(dirtyTable,RenameColumn)
in
    Value.ReplaceType(TableCleanFieldNames,TableCleanFieldNamesType)
