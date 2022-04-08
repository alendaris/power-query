(compressedText as text) as text =>
let
    Source = Text.FromBinary(Binary.Decompress(Binary.FromText(compressedText), Compression.Deflate))
in
    Source
