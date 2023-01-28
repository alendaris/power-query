// Functions to manipulate a metadata record called bandaid
//
// Bandaids are for tracking assumptions and steps that you will want to go back and revisit before moving to production
// To create a bandaid, add the following to a query step:
//   meta bandaid[new](comment,query,step)
//  where all three arguments are text (query and step are optional)
//
// PQ removes metadata when functions/operators are applied, so either the 'in' portion of the let statement needs to have bandaid metadata added, or the very last step of the let (if the 'in' expression is simple)
//
// If you have multiple bandaids in a query, you can use:
//   meta bandaid[combine]({list of values})
//  where list of values are values that /may/ have bandaid metadata
// Consider using the combine function to evaluate any value external to a let statement
//
// To generate a table of all bandaids, you can use:
//   bandaid[report](environment)
//  By default, this will poll #sections[Section1]
//

[
    new = (comment as text, optional query as text, optional step as text) =>
        [
            bandaid = {
                [comment = comment, query = query, step = step]
            }
        ],

    combine = (values as list) =>
        let
            bandaids = List.Combine(List.RemoveNulls(List.Transform(values, each Value.Metadata(_)[bandaid]?)))
        in
            [
                bandaid = bandaids
            ],
    
    report = reportBandaids,

    reportBandaidSingle = (value as any) =>
        try Table.FromRecords(Value.Metadata(value)[bandaid]) otherwise null,

    reportBandaids = (optional environment as record) as any =>
        let
            env = environment ?? #sections[Section1],
            Source = env,
            #"Converted to Table" = Record.ToTable(Source),
            #"Added Custom" = try bandaid[combine](#"Converted to Table"[Value])[bandaid] otherwise null,
            bandaidTable = Table.FromRecords(#"Added Custom")
        in
            bandaidTable
]
