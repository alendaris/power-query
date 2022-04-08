(input as any) =>

let
    url = if input = null then "https://api.github.com/repos/alendaris/power-query/contents" else if Type.Is(Value.Type(input),Record.Type) then "https://api.github.com/repos/" & input[owner] & "/" & input[repository] & "/contents" else input,
    Source = Json.Document(Web.Contents(url)),
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"name", "path", "sha", "size", "url", "html_url", "git_url", "download_url", "type", "_links"}, {"name", "path", "sha", "size", "url", "html_url", "git_url", "download_url", "type", "_links"}),
    Files = 
        let
            Source = Table.SelectColumns(Table.SelectRows(#"Expanded Column1", each ([type] = "file")),{"name", "download_url"}),
            #"Filter to PQ / M Source Code Files" = Table.SelectRows(Source, each Text.EndsWith([name], ".pq") or Text.EndsWith([name], ".m")),
            #"Renamed Columns" = Table.RenameColumns(#"Filter to PQ / M Source Code Files",{{"name", "Name"}}),
            #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns",".pq","",Replacer.ReplaceText,{"Name"}),
            #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value",".m","",Replacer.ReplaceText,{"Name"}),
            #"Added Custom" = Table.AddColumn(#"Replaced Value1", "Source Code", each Text.Combine(Lines.FromBinary(Web.Contents([download_url])),"#(lf)")),
            #"Replaced Value2" = Table.ReplaceValue(#"Added Custom",each [Source Code],each if Text.StartsWith([Source Code],"Expresssion.Evaluate(") then Expression.Evaluate([Source Code],#shared) else [Source Code],Replacer.ReplaceText,{"Source Code"}),
            #"Added Custom1" = Table.AddColumn(#"Replaced Value2", "Function from URL", each Expression.Evaluate([Source Code],#shared)),
            #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Original Function Type", each Value.Type([Function from URL])),
            #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Function Type Metadata with Source Code Added", each Record.AddField(Value.Metadata([Original Function Type]), "Source Code", [Source Code])),
            #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Value", each Value.ReplaceType([Function from URL],Value.ReplaceMetadata([Original Function Type], [Function Type Metadata with Source Code Added]))),
            #"Removed Other Columns" = Table.SelectColumns(#"Added Custom4",{"Name", "Value"})
        in
            #"Removed Other Columns",

    Directories = Table.AddColumn(Table.SelectColumns(Table.SelectRows(#"Expanded Column1", each ([type] = "dir")),{"url"}),"recurse", each GithubRepository([url]))[recurse],
    DownloadList = Table.Combine({Files,Table.Combine(Directories)}),
    FunctionCollection = 
        if input = null or Type.Is(Value.Type(input),Record.Type) then
            let
                newrecord = Record.FromTable(DownloadList),
                Library = if Record.HasFields(newrecord, "Library Source Code") then
                    [
                        Library = newrecord,
                        Source Code = newrecord[Library Source Code](newrecord)
                    ]
                    else
                    [
                        Library = newrecord
                    ]
            in  
                Library
        else
            DownloadList
in
    FunctionCollection
