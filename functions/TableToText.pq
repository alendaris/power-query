(value as any) =>
let
    Source = value,
    ValueDetails = Table.SingleRow(Table.Schema(#table(type table [Col1 = Value.Type(Source)], {})))
in
    ValueDetails[TypeName] meta [Kind = RowDetails[Kind]]
