/*
 * BinaryImageToDataURI
 *
 * Converts a binary image to a Data URI representation.
 *
 * @param image    The binary image to convert.
 * @return         The Data URI representation of the binary image.
 */
 
(image as binary) as text =>
let
    mimeType = "image/png",
    base64 = Binary.ToText(image, BinaryEncoding.Base64),
    dataURI = "data:" & mimeType & ";base64," & base64
in
    dataURI
