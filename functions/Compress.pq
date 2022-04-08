(uncompressedText as text) as text =>
let
    Source = Text.From(Binary.Compress(Text.ToBinary(uncompressedText),Compression.Deflate))
in
    Source
