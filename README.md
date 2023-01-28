# power-query

A library of Power Query functions & other reference material.

|Function|Description|
|:---|:---|
|Bandaid|Adds metadata to values to track assumptions made|
|BinaryImageToDataURI|Converts a binary image to a Data URI representation.|
|Compress|Performs the compression steps that PQ uses when generating the Source string for queries created from the Enter Data functionality.|
|ContrastingColor|Given a background color, determine if light or dark text should be used as a foreground text color.|
|Decompress|Performs the decompression steps used in queries created by Enter Data.|
|GenerateDateTable|Generates a Date dimension table given a starting and ending year.|
|GithubRepository|Loads queries stored as .pq files from a Github repository.|
|Library Function Source Code|Returns the Source Code metadata from functions generated by external loading functions in this repository.|
|Library Source Code|Calls Library Function Source Code over the entire contents of a function library record.|
|Load Function Library - Local Filesystem|Loads queires stored as .pq files from a given folder path.|
|Luminosity|Calculated the Luminosity of a color value.|
|TableCleanFieldNames|Cleans Field Names of a table to be Proper Case instead of cammelCase or snake_case.|
|TableDataQualityProfile|Reviews data in a table and determines a basic description of the data.|
|TableToMCode|Converts a simple table to equivalent M code. Credit: ImkeF|
|Unzip|Unzip the binary of a .zip file.|
|ValueToMCode|Converts nearly any type of value into equivalent M code.|
