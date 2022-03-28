(value as record) as text =>
let
    fields = Record.FieldNames(value),
    withValues = List.Transform(fields,each _ & " = " & ValueToMCode(Record.Field(value,_))),
    Return = "[" & Text.Combine(withValues,",#(lf)") & "]"
in
    Return
