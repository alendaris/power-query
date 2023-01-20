let
    func = (FolderPath as text) =>
        let
            Source = Folder.Files(FolderPath),
            #"Removed Other Columns" = Table.SelectColumns(Source, {"Content", "Name"}),
            #"Remove .pq" = Table.ReplaceValue(#"Removed Other Columns", ".pq", "", Replacer.ReplaceText, {"Name"}),
            #"Pull Source Code" = Table.AddColumn(#"Remove .pq", "Source Code", each Text.Combine(Lines.FromBinary([Content]), "#(lf)")),
            #"Generate Function" = Table.AddColumn(#"Pull Source Code", "Function from File", each Expression.Evaluate([Source Code], #shared)),
            #"Original Function Type" = Table.AddColumn(#"Generate Function", "Original Function Type", each Value.Type([Function from File])),
            #"Add Source Code" = Table.AddColumn(#"Original Function Type", "Function Type Metadata with Source Code Added", each Record.AddField(Value.Metadata([Original Function Type]), "Source Code", [Source Code])),
            #"Regenerate Function" = Table.AddColumn(#"Add Source Code", "Value", each Value.ReplaceType([Function from File], Value.ReplaceMetadata([Original Function Type], [Function Type Metadata with Source Code Added])) meta [#"Source Code" = [Source Code]]),
            #"Removed Other Columns1" = Table.SelectColumns(#"Regenerate Function", {"Name", "Value"}),
            newrecord = Record.FromTable(#"Removed Other Columns1"),
            Library = if Record.HasFields(newrecord, {"Library Source Code"}) then
                [
                    Library = newrecord,
                    Source Code = newrecord[Library Source Code](newrecord)
                ]
                else
                [
                    Library = newrecord
                ]
        in
            Library,

    fntype = type function
        (
            FolderPath as (type text meta [
                Documentation.FieldCaption = "Folder Path",
                Documentation.FieldDescription = "Folder path to the directory containing .pq files"/*,
                Documentation.SampleValues = {null}*/
            ])
        ) as any meta
            [
                Documentation.Name = "Load Function Library - Local Filesystem",
                Documentation.LongDescription = "This function loads .pq files from a local directory and generates a function library record. If one of the files is called ""Library Source Code.pq"", the contents of each file will be stored as metadata."
            ]

in
    Value.ReplaceType(func,fntype)
