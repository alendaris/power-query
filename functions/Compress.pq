let
    func = (uncompressedText as text) as text =>
        let
            Source = Text.From(Binary.Compress(Text.ToBinary(uncompressedText),Compression.Deflate))
        in
            Source,

    ExampleParameter = "https://github.com/alendaris/power-query",
    ExampleResult = func(ExampleParameter),

    fntype = type function
        (
            FromYear as (type number meta [
                Documentation.FieldCaption = "Uncompressed Text",
                Documentation.FieldDescription = "Text to be compressed.",
                Documentation.SampleValues = {"https://github.com/alendaris/power-query"}
            ])
        ) as text meta
            [
                Documentation.Name = "Compress",
                Documentation.LongDescription = "This function performs the compression steps that PQ uses when generating the Source string for queries created from the Enter Data functionality.",
                Documentation.Examples =
                {
                    [
                        Description = "Compress an uncompressed string.",
                        Code = "func(""" & ExampleParameter & """)",
                        Result = ExampleResult
                    ]
                }
            ]

in
    Value.ReplaceType(func,fntype)
