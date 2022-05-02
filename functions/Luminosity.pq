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

    TableToMCode = 
        let
            compressedCode = "zVTRatswFH33V1xUCDYYbXkdTaF1Eyg0HaShLyEU1b5OzGQpk+QlIeRf8i35sklynMbOBnucDbZ879HRuefK4mggr0QKAwAIIJyyD47ANBg3iGBwF3A0wfFwPPjU8TA4jWIffC60+Z4nklel0J9JOpUTudY1XVRDEyl+oTJT2SGiIyVLxxN6WHO3mOPjoZV8XfHCGFTUDx62L9IsC7EIoy5QVJz/S2y4MYq9MV6hpkOlpDpnz+oVvhplF7lQfp9ltcC29Hal3aVIUmkjS9KNI0uXlhg3hiay/CgEhs4DOlVM6FyqMpzVi/XncYMucni3rXMVgVmiAOKGBJBrBGIv6IFnnOCKsxRD/+EMD9+j2AH8g5DIAv3bUpMYSNStf2R5L+onA7jxWySEnZ12Rvc6FdQ+1bpfWInnLWEpiFuIXCzV88F9DDchzyPYWeq/En/2Y1b76Uy5mNuh3cMeIiBBITrVxEEm06pEYZgppLBmzoLHywh1st3vQaDZ2uNEZtbeuAN8RJ2qYnWisfCmcRoYwG1qJ915itsvfgxgpM1orwNkDmNwcdtIZmBd2JamCpk5BbzbUAjXZ/hZodoCZoWRil4reZZi8f+oSeyshbSIQePhNeZVVipFj7hOvqHSTRl9+pX2ryH3lVlK5RFP5Q+EEfKsZEJ8g/V6TadLfHhKU1lZuDA0lSX8Qedww8oVR21ZdrO2fSdZvu+NxgnqipvT53w/D9wBah2xT/AnSfPTTbcrDN0hG7fjYzQsY4aFdfQMi2Jo7ckoCn4D",
            func = Expression.Evaluate(Text.FromBinary(Binary.Decompress(Binary.FromText(compressedCode), Compression.Deflate)), #shared)
        in
            func,

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
