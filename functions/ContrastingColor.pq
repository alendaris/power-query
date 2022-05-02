(background_color as text, optional dark_text as text, optional light_text as text, optional gamma as number) =>
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
    font_color
