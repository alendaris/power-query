/*
 * BinaryImageToDataURI
 *
 * Converts a binary image to a Data URI representation.
 *
 * @param image    The binary image to convert.
 * @return         The Data URI representation of the binary image.
 */
 
let
    BinaryImageToURIType = 
    type function (
        image as (type binary meta [
            Documentation.FieldCaption = "Image",
            Documentation.FieldDescription = "The binary image to convert",
            Documentation.SampleValues = {
                /* Add some sample binary image values here */
            ]
        ]),
        as (type text meta [
            Documentation.Name = "BinaryImageToURI",
            Documentation.LongDescription = "Converts a binary image to a Data URI representation",
            Documentation.Examples = {
                [
                    Description = "Convert a binary image to a Data URI",
                    Code = "BinaryImageToURI(binaryImage)",
                    Result = "data:image/png;base64,<base64-encoded-image>"
                ]
            ]
        ])
    ),
    BinaryImageToURI = 
    (image as binary) as text =>
    let
        mimeType = "image/png",
        base64 = Binary.ToText(image, BinaryEncoding.Base64),
        dataURI = "data:" & mimeType & ";base64," & base64
    in
        dataURI
in
    Value.ReplaceType(BinaryImageToURI, BinaryImageToURIType)


