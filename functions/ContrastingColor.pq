let
    func = (background_color as text, optional dark_text as text, optional light_text as text, optional gamma as number) =>
        let
            dark_text_use = if dark_text = null then "#000000" else dark_text,
            light_text_use = if light_text = null then "#FFFFFF" else light_text,
            gamma_use = if gamma = null then 2.2 else gamma,
            luminosity = (color as text, optional gamma as number) =>
                let
                    gamma_use = if gamma = null then 2.2 else gamma,
                    luminosity = 
                        0.2126 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 1, 2))/255,gamma_use) + // Red
                        0.7152 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 3, 2))/255,gamma_use) + // Green
                        0.0722 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 5, 2))/255,gamma_use)  // Blue
                in
                    luminosity,
            font_color = if luminosity(background_color, gamma_use)>0.5 then dark_text_use else light_text_use
        in
            font_color,

    ExampleParameter = "#FFCC72",
    ExampleResult = func(ExampleParameter),

    fntype = type function
        (
            background_color as (type text meta [
                Documentation.FieldCaption = "Background Color",
                Documentation.FieldDescription = "The background color as a hexadecimal text string (#RRGGBB).",
                Documentation.SampleValues = {ExampleParameter}
            ]),
            optional dark_text as (type text meta [
                Documentation.FieldCaption = "Dark Text Color",
                Documentation.FieldDescription = "The color to be used when dark text is appropriate.",
                Documentation.SampleValues = {"#000000"}
            ]),
            optional light_text as (type text meta [
                Documentation.FieldCaption = "Light Text Color",
                Documentation.FieldDescription = "The color to be used when light text is appropriate.",
                Documentation.SampleValues = {"#FFFFFF"}
            ]),
            optional gamma as (type number meta [
                Documentation.FieldCaption = "Gamma",
                Documentation.FieldDescription = "Gamma value to use for luminosity calculations.",
                Documentation.SampleValues = {2.2}
            ])            
        ) as table meta
            [
                Documentation.Name = "Contrasting Color",
                Documentation.LongDescription = "This function provides for a given background color a light or dark text value as appropriate contrast.",
                Documentation.Examples =
                {
                    [
                        Description = "Determine the better font color for a background color of " & ExampleParameter & ".",
                        Code = "ContrastingColor(""" & ExampleParameter & """)",
                        Result = ExampleResult
                    ]
                }
            ]

in
    Value.ReplaceType(func,fntype)
