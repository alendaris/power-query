(Source as any,optional indentStart as number) =>
let
//    Source = {"3"},

    indent = if indentStart is null then 0 else indentStart,

    NullToMCode = (value as any,optional indent as number) as text =>
        """""",

    TextToMCode = (value as text,optional indent as number) as text =>
        """" & Text.Replace(value,"""","""""") & """",
    
    NumberToMCode = (value as number,optional indent as number) as text =>
        Number.ToText(value),

    ListToMCode = (value as list,optional indent as number) as text =>
        let
            Source = value,
            #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Added Custom" = Table.AddColumn(#"Converted to Table", "MCode", each ValueToMCode([Column1]))
        in
            "{" & Text.Combine(#"Added Custom"[MCode],", ") & "}",

    TableToMCode = (value as table,optional indent as number) =>
        let
            headers = ValueToMCode(Table.ColumnNames(value)),
            rows = ValueToMCode(Table.ToRows(value)),
            Return = "#table(#(lf)" & headers & ",#(lf)" & rows & "#(lf))"
        in 
            Return,

//none
//null
//anynonnull
//duration
//datetimezone
//datetime
//time
//date
//number
//logical
//binary
//record
//table

    /*AnyToMCode = (value as any) as text =>
        let 
            Return = Binary.From(value)
        in 
            Return,*/

    Fail = (value as any) as text => "Type Unrecognized",

    Switch = (Expression as any, Values as list, Results as list, optional Else as any) =>
        try Results{List.PositionOf(Values, Expression)} 
        otherwise
            if Else = null then Fail
            else Else,

    ToMCode = (value as any,optional indent as number) as any =>
        let 
            ParseFunc = Switch(Value.Type(Source),
            {type null,type text,type number},
            {NullToMCode,TextToMCode,NumberToMCode}),
            Return = 
                if Value.Is(value,Table.Type) then TableToMCode(value,indent) 
                else if Value.Is(value,List.Type) then ListToMCode(value,indent)
                else ParseFunc(Source,indent)
        in
            Return,

    Return = ToMCode(Source)

in
    Return
