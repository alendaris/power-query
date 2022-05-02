(lighter_color as text, darker_color as text) =>
let
    luminosity = (color as text, optional gamma as number) =>
        let
            gamma_use = if gamma = null then 2.2 else gamma,
            luminosity = 
                0.2126 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 1, 2))/255,gamma_use) + // Red
                0.7152 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 3, 2))/255,gamma_use) + // Green
                0.0722 * Number.Power(Expression.Evaluate("0x" & Text.Middle(color, 5, 2))/255,gamma_use),  // Blue
        in
            luminosity,
    color_contrast = 
//        if luminosity(lighter_color)>=luminosity(darker_color) then
            (luminosity(lighter_color)+0.05)/(luminosity(darker_color)+0.05)
//        else
//            (luminosity(darker_color)+0.05)/(luminosity(lighter_color)+0.05)
in
    color_contrast
