let
    func = (lighter_color as text, darker_color as text) =>
        let
            luminosity = (color as text, optional gamma as number) =>
                let
                    gamma_use = if gamma = null then 2.2 else gamma,
                    luminosity = 
                        0.2126 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 1, 2))/255,gamma_use) + // Red
                        0.7152 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 3, 2))/255,gamma_use) + // Green
                        0.0722 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 5, 2))/255,gamma_use)  // Blue
                in
                    luminosity,
            color_contrast = 
                if luminosity(lighter_color)>=luminosity(darker_color) then
                    (luminosity(lighter_color)+0.05)/(luminosity(darker_color)+0.05)
                else
                    (luminosity(darker_color)+0.05)/(luminosity(lighter_color)+0.05)
        in
            color_contrast,

    ExampleParameter1 = "#FFCC72",
    ExampleParameter2 = "#000000",
    ExampleResult = func(ExampleParameter1,ExampleParameter2),

    fntype = type function
        (
            lighter_color as (type text meta [
                Documentation.FieldCaption = "Color 1",
                Documentation.FieldDescription = "One of two colors to compare in the contrast ratio calculation.",
                Documentation.SampleValues = {ExampleParameter1}
            ]),
            darker_color as (type text meta [
                Documentation.FieldCaption = "Color 2",
                Documentation.FieldDescription = "One of two colors to compare in the contrast ratio calculation.",
                Documentation.SampleValues = {ExampleParameter2}
            ])
        ) as text meta
            [
                Documentation.Name = "ColorContrastRatio",
                Documentation.LongDescription = "This function calculates the Color Contrast Ratio between the lighter color and the darker color.",
                Documentation.Examples =
                {
                    [
                        Description = "Determine the color contrast ratio between #FFCC72 and #000000.",
                        Code = "ColorContrastRatio(""#FFCC72"", ""#000000"")",
                        Result = ExampleResult
                    ]
                }
            ]

in
    Value.ReplaceType(func,fntype)
