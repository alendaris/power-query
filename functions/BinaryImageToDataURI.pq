/*
 * BinaryImageToDataURI
 *
 * Converts a binary image to a Data URI representation.
 *
 * @param image    The binary image to convert.
 * @return         The Data URI representation of the binary image.
 */
 
let
    BinaryImageToDataURIType = type function (
        image as (type binary meta [
            Documentation.FieldCaption = "Image",
            Documentation.FieldDescription = "Binary representation of the image to be converted to a data URI",
            Documentation.SampleValues = { #binary("iVBORw0KGg==") }
        ])
    ) as text meta [
        Documentation.Name = "Binary Image To Data URI",
        Documentation.LongDescription = "Converts a binary image to a data URI",
        Documentation.Examples = {[
            Description = "Convert a binary image to a data URI",
            Code = "BinaryImageToDataURI(#binary(""iVBORw0KGg==""))",
            Result = "data:image/png;base64,iVBORw0KGg=="
        ]}
    ],
    
    BinaryImageToDataURI = 
    (image as binary) as text =>
    let
        mimeType = "image/png",
        base64 = Binary.ToText(image, BinaryEncoding.Base64),
        dataURI = "data:" & mimeType & ";base64," & base64
    in
        dataURI
in
    Value.ReplaceType(BinaryImageToDataURI, BinaryImageToDataURIType)
