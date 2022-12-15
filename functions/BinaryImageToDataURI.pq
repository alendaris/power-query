/*
 * BinaryImageToDataURI
 *
 * Converts a binary image to a Data URI representation.
 *
 * @param image    The binary image to convert.
 * @return         The Data URI representation of the binary image.
 */
 
(image as binary
    meta [
            Documentation.FieldCaption = "Image",
            Documentation.FieldDescription = "Binary value of an image"
    ]
) as text =>
let
    mimeType = "image/png",
    base64 = Binary.ToText(image, BinaryEncoding.Base64),
    dataURI = "data:" & mimeType & ";base64," & base64
in
    dataURI
meta [
    Documentation.Name = "BinaryImageToDataURI",
    Documentation.Description = "Converts a binary image to a Data URI representation.",
    Documentation.Examples = [
        {
            Description = "Convert a binary image to a Data URI",
            Code = "BinaryImageToDataURI(binaryImage)",
            Result = "data:image/png;base64,..."
        }
    ]
]
