let
    GetTypeNameType = type function (
        value as (type any meta [
            Documentation.FieldCaption = "Value",
            Documentation.FieldDescription = "The value to get the type name of",
            Documentation.SampleValues = {"abc", 123, true, #date(2022,1,1)}
        ]))
        as text meta [
            Documentation.Name = "GetTypeName",
            Documentation.LongDescription = "Returns the type name of a given value. The Kind of the value is returned as metadata in the result of this function.",
            Documentation.Examples = {[
                Description = "Get the type name of a text value",
                Code = "GetTypeName(""abc"")",
                Result = "Text"
            ],[
                Description = "Get the type name of a number",
                Code = "GetTypeName(123)",
                Result = "Number"
            ]}
        ],
    GetTypeNameImpl = (value as any) =>
        let
            Source = value,
            ValueDetails = Table.SingleRow(Table.Schema(#table(type table [Col1 = Value.Type(Source)], {})))
        in
            ValueDetails[TypeName] meta [Kind = ValueDetails[Kind]]
in
    Value.ReplaceType(GetTypeNameImpl, GetTypeNameType)
