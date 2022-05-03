let
    func = (compressedText as text) as text =>
        let
            Source = Text.FromBinary(Binary.Decompress(Binary.FromText(compressedText), Compression.Deflate))
        in
            Source,

    ExampleParameter = Text.From(Binary.Compress(Text.ToBinary("https://github.com/alendaris/power-query"),Compression.Deflate)),
    ExampleResult = func(ExampleParameter),

    fntype = type function
        (
            compressedText as (type Text meta [
                Documentation.FieldCaption = "Compressed Text",
                Documentation.FieldDescription = "Compressed Text to be expanded",
                Documentation.SampleValues = {ExampleParameter}
            ])
        ) as text meta
            [
                Documentation.Name = "Decompress",
                Documentation.LongDescription = "This function performs the decompression steps used in queries created by Enter Data.",
                Documentation.Examples =
                {
                    [
                        Description = "Decompress a compressed string.",
                        Code = "func(""" & ExampleParameter & """)",
                        Result = ExampleResult
                    ]
                }
            ]

in
    Value.ReplaceType(func,fntype)
