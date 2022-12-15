(dirtyTable as table meta [Documentation.FieldCaption = "Table", Documentation.FieldDescription = "A table with column names in camelCase or snake_case."]) as table =>
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
meta [
    Documentation.Name = "TableCleanColumnNames",
    Documentation.LongDescription = "The TableCleanColumnNames function takes a table as input and returns a new table with clean column names. Column names are cleaned by splitting them into words based on the transition from lower case to to upper case, transforming each word into upper or proper case depending on its length. Columns ending with ' NO' are adjusted to end in ' Number'."
]
