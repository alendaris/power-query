let
    func = 
        (color as text, optional gamma as number) =>
        let
            gamma_use = if gamma = null then 2.2 else gamma,
            luminosity = 
                0.2126 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 1, 2))/255,gamma_use) + // Red
                0.7152 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 3, 2))/255,gamma_use) + // Green
                0.0722 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 5, 2))/255,gamma_use),  // Blue
        in
            luminosity

    ExampleResult = func("#FFCC72", 2.2)

    fntype = type function
        (
            color as (type text meta [
                Documentation.FieldCaption = "Color",
                Documentation.FieldDescription = "Color in RGB hexadecimal format (#RRGGBB)",
                Documentation.SampleValues = {"#FFCC72"}
            ]),
            optional gamma as (type number meta [
                Documentation.FieldCaption = "Gamma",
                Documentation.FieldDescription = "Gamma value for the luminosity calculation (default: 2.2)",
                Documentation.SampleValues = {2.2}
            ])
        ) as table meta
            [
                Documentation.Name = "Luminosity",
                Documentation.LongDescription = "This function calculates a luminosity value for a given hexadecimal color.",
                Documentation.Examples =
                {
                    [
                        Description = "Determine the luminosity of pure blue (#0000FF).",
                        Code = "Luminosity(""#0000FF"")",
                        Result = ExampleResult
                    ]
                }
            ]

in
    Value.ReplaceType(func,fntype)
