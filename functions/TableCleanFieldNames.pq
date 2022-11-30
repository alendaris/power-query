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
