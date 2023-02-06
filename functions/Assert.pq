[
    // Default Error Reason
    Error.Reason = "Assertion Error",
    
   /** Basic assertion function. Check if expression is true **/
    True =
        let
            TrueType = type function (
                expression as (type logical meta [
                    Documentation.FieldCaption = "Expression",
                    Documentation.FieldDescription = "The value to be evaluated as true or false",
                    Documentation.SampleValues = {true, false}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the expression is false",
                    Documentation.SampleValues = {"Value is not true", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the expression is false",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "True",
                    Documentation.LongDescription = "Basic assertion function. Check if expression is true",
                    Documentation.Examples = {[
                        Description = "Check if a value is true",
                        Code = "True(1=1)",
                        Result = true
                    ],[
                        Description = "Check if a value is true",
                        Code = "True(1=2)",
                        Result = "value is not true"
                    ]}
                ],

            TrueImpl = (expression, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value is not true" else message,
                    Detail = if detail = null then expression else detail,
                    Return =
                        if expression = true
                        then expression
                        else error Error.Record(Error.Reason, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(TrueImpl, TrueType),
   
   /** Check if expression is false **/
    False = 
        let
            FalseType = type function (
                expression as (type logical meta [
                    Documentation.FieldCaption = "Expression",
                    Documentation.FieldDescription = "The value to be evaluated as true or false",
                    Documentation.SampleValues = {true, false}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the expression is true",
                    Documentation.SampleValues = {"Value is not false", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the expression is true",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "False",
                    Documentation.LongDescription = "Check if expression is false",
                    Documentation.Examples = {[
                        Description = "Check if a value is false",
                        Code = "False(1=2)",
                        Result = true
                    ],[
                        Description = "Check if a value is true",
                        Code = "False(1=1)",
                        Result = "value is not false"
                    ]}
                ],

            FalseImpl = (expression, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value is not false" else message,
                    Detail = if detail = null then expression else detail,
                    Return = True(expression = false, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(FalseImpl, FalseType),

    /** Check if a and b are equal **/
    Equal = 
        let
            EqualType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The first value to compare",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                b as (type any meta [
                    Documentation.FieldCaption = "B",
                    Documentation.FieldDescription = "The second value to compare",
                    Documentation.SampleValues = {false, 2, "b"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the values are not equal",
                    Documentation.SampleValues = {"Values are not equal", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the values are not equal",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "Equal",
                    Documentation.LongDescription = "Check if a and b are equal",
                    Documentation.Examples = {[
                        Description = "Check if two values are equal",
                        Code = "Equal(1, 1)",
                        Result = true
                    ],[
                        Description = "Check if two values are not equal",
                        Code = "Equal(1, 2)",
                        Result = Error.Record
                    ]}
                ],

            EqualImpl = (a, b, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "values are not equal" else message,
                    Detail = if detail = null then {a,b} else detail,
                    Return = True(a = b, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(EqualImpl, EqualType),


    /** Check if a and b are not equal **/
    NotEqual = 
        let
            NotEqualType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The first value to compare",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                b as (type any meta [
                    Documentation.FieldCaption = "B",
                    Documentation.FieldDescription = "The second value to compare",
                    Documentation.SampleValues = {false, 2, "b"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the values are equal",
                    Documentation.SampleValues = {"Values are equal", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the values are equal",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "NotEqual",
                    Documentation.LongDescription = "Check if a and b are not equal",
                    Documentation.Examples = {[
                        Description = "Check if two values are not equal",
                        Code = "NotEqual(1, 2)",
                        Result = true
                    ],[
                        Description = "Check if two values are equal",
                        Code = "NotEqual(1, 1)",
                        Result = Error.Record
                    ]}
                ],

            NotEqualImpl = (a, b, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "values are equal" else message,
                    Detail = if detail = null then {a,b} else detail,
                    Return = False(a = b, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(NotEqualImpl, NotEqualType),
        
    /** Check if a is greater than b **/
    GreaterThan = 
        let
            GreaterThanType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The first value to compare",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                b as (type any meta [
                    Documentation.FieldCaption = "B",
                    Documentation.FieldDescription = "The second value to compare",
                    Documentation.SampleValues = {false, 2, "b"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value of a is less than or equal to b",
                    Documentation.SampleValues = {"Value of a is less than or equal to b", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value of a is less than or equal to b",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "GreaterThan",
                    Documentation.LongDescription = "Check if a is greater than b",
                    Documentation.Examples = {[
                        Description = "Check if a value is greater than another",
                        Code = "GreaterThan(2, 1)",
                        Result = true
                    ],[
                        Description = "Check if a value is less than or equal to another",
                        Code = "GreaterThan(1, 2)",
                        Result = Error.Record
                    ]}
                ],

            GreaterThanImpl = (a, b, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value a is less than b" else message,
                    Detail = if detail = null then {a,b} else detail,
                    Return = True(a > b, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(GreaterThanImpl, GreaterThanType),

    /** Check if a is less than b **/
    LessThan = 
        let
            LessThanType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The first value to compare",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                b as (type any meta [
                    Documentation.FieldCaption = "B",
                    Documentation.FieldDescription = "The second value to compare",
                    Documentation.SampleValues = {false, 2, "b"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value of a is greater than or equal to b",
                    Documentation.SampleValues = {"Value of a is greater than or equal to b", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value of a is greater than or equal to b",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "LessThan",
                    Documentation.LongDescription = "Check if a is less than b",
                    Documentation.Examples = {[
                        Description = "Check if a value is less than another",
                        Code = "LessThan(1, 2)",
                        Result = true
                    ],[
                        Description = "Check if a value is greater than or equal to another",
                        Code = "LessThan(2, 1)",
                        Result = Error.Record
                    ]}
                ],

            LessThanImpl = (a, b, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value a is greater than b" else message,
                    Detail = if detail = null then {a,b} else detail,
                    Return = True(a < b, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(LessThanImpl, LessThanType),


    /** Check if a is positive **/
    Positive = 
        let
            PositiveType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The value to evaluate as positive or non-positive",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value is non-positive",
                    Documentation.SampleValues = {"Value is non-positive", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value is non-positive",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "Positive",
                    Documentation.LongDescription = "Check if a is positive",
                    Documentation.Examples = {[
                        Description = "Check if a value is positive",
                        Code = "Positive(1)",
                        Result = true
                    ],[
                        Description = "Check if a value is non-positive",
                        Code = "Positive(-1)",
                        Result = Error.Record
                        ]}
                    ],
            PositiveImpl = (a, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value is non-positive" else message,
                    Detail = if detail = null then a else detail,
                    Return = True(a > 0, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(PositiveImpl, PositiveType),

    /** Check if a is negative **/ 
    Negative = 
        let
            NegativeType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The value to evaluate as negative or non-negative",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value is non-negative",
                    Documentation.SampleValues = {"Value is non-negative", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value is non-negative",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "Negative",
                    Documentation.LongDescription = "Check if a is negative",
                    Documentation.Examples = {[
                        Description = "Check if a value is negative",
                        Code = "Negative(-1)",
                        Result = true
                    ],[
                        Description = "Check if a value is non-negative",
                        Code = "Negative(1)",
                        Result = Error.Record
                    ]}
                ],

            NegativeImpl = (a, optional message as nullable text, optional detail) as logical =>
                let
                    Message = if message = null then "value is non-negative" else message,
                    Detail = if detail = null then a else detail,
                    Return = True(a < 0, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(NegativeImpl, NegativeType),

    /** Check if a is non-negative **/
    NonNegative = 
        let
            NonNegativeType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The value to evaluate as non-negative or negative",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value is negative",
                    Documentation.SampleValues = {"Value is negative", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value is negative",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "NonNegative",
                    Documentation.LongDescription = "Check if a is non-negative",
                    Documentation.Examples = {[
                        Description = "Check if a value is non-negative",
                        Code = "NonNegative(0)",
                        Result = true
                    ],[
                        Description = "Check if a value is negative",
                        Code = "NonNegative(-1)",
                        Result = Error.Record
                    ]}
                ],
            NonNegativeImpl = (a, optional message as nullable text, optional detail) =>
                let
                    Message = if message = null then "value is negative" else message,
                    Detail = if detail = null then a else detail,
                    Return = True(a >= 0, Message, Detail)
                in
                    Return
        in 
            Value.ReplaceType(NonNegativeImpl,NonNegativeType),
            
            
            
    /** Check if a is negative **/
    NonPositive = 
        let
            NonPositiveType = type function (
                a as (type any meta [
                    Documentation.FieldCaption = "A",
                    Documentation.FieldDescription = "The value to evaluate as non-positive or positive",
                    Documentation.SampleValues = {true, 1, "a"}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the value is positive",
                    Documentation.SampleValues = {"Value is positive", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the value is positive",
                    Documentation.SampleValues = {null, true, 1, "a"}
                ]))
                as logical meta [
                    Documentation.Name = "NonPositive",
                    Documentation.LongDescription = "Check if a is non-positive",
                    Documentation.Examples = {[
                        Description = "Check if a value is non-positive",
                        Code = "NonPositive(0)",
                        Result = true
                    ],[
                        Description = "Check if a value is positive",
                        Code = "NonPositive(1)",
                        Result = Error.Record
                    ]}
                ],

            NonPositiveImpl = (a, optional message as nullable text, optional detail) =>
                let
                    Message = if message = null then "value is positive" else message,
                    Detail = if detail = null then a else detail,
                    Return = True(a <= 0, Message, Detail)
                in
                    Return
        in 
            Value.ReplaceType(NonPositiveImpl,NonPositiveType),
            
            
    /** Check if zero-argument function raises error **/
    Raises = (func, reason as text, optional message as nullable text, optional detail) =>
        let
            Message = if message = null then "does not raise " & reason else message,
            Detail = if detail = null then func else detail,
            Reason = try (try func())[Error][Reason] otherwise null,
            Return = True(Reason = reason, Message, Detail)
        in
            Return,

    /** Same as Raises but with argument list **/
    InvokeRaises = (func, args as nullable list, reason as text, optional message as nullable text, optional detail) =>
        Raises(() => Function.Invoke(func, args), reason, message, detail),

    // Runs an Assertion Check on an entire table and returns only the rows where there is an issue
    AssertTable = (inputTable as table, functionToApply as function, optional columnsToInclude as list) =>
        let
            indexedTable = Table.AddIndexColumn(inputTable, "Index", 2, 1, Int64.Type),
            
            transformedTable = Table.AddColumn(indexedTable, "_Assert", functionToApply),
            
            selectedColumns = if (columnsToInclude = null) then Table.ReorderColumns(transformedTable, {"Index"} & Table.ColumnNames(inputTable) & {"_Assert"}) else Table.SelectColumns(transformedTable, {"Index"} & columnsToInclude & {"_Assert"}),
            
            filteredTable = Table.SelectRowsWithErrors(selectedColumns)
        in 
            filteredTable,
            
            
    // Check if Table has a certain number of rows
    TableRowCountEqual = 
        let
            TableRowCountEqualType = type function (
                a as (type table meta [
                    Documentation.FieldCaption = "Table",
                    Documentation.FieldDescription = "The table to check the row count of",
                    Documentation.SampleValues = {Table.FromRecords({[Value = "abc"], [Value = 123], [Value = true]})}
                ]),
                b as (type number meta [
                    Documentation.FieldCaption = "Number",
                    Documentation.FieldDescription = "The number to compare the row count of the table to",
                    Documentation.SampleValues = {3, 5}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the table does not have the specified number of rows",
                    Documentation.SampleValues = {"Table does not have 3 rows", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the table does not have the specified number of rows",
                    Documentation.SampleValues = {null, Table.FromRecords({[Value = "abc"], [Value = 123], [Value = true]})}
                ]))
                as any meta [
                    Documentation.Name = "TableRowCountEqual",
                    Documentation.LongDescription = "Check if Table has a certain number of rows",
                    Documentation.Examples = {[
                        Description = "Check if a table has 3 rows",
                        Code = "TableRowCountEqual(Table.FromRecords({[Value = ""abc""], [Value = 123], [Value = true]}), 3)",
                        Result = true
                    ],[
                        Description = "Check if a table has 5 rows",
                        Code = "TableRowCountEqual(Table.FromRecords({[Value = ""abc""], [Value = 123], [Value = true]}), 5)",
                        Result = false
                    ]}
                ],

            TableRowCountEqualImpl = (a, b, optional message, optional detail) as any =>
                let
                    Message = if message = null then "table does not have " & Text.From(b) & " rows" else message,
                    Detail = if detail = null then a else detail,
                    Return = Equal(Table.RowCount(a), b, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(TableRowCountEqualImpl, TableRowCountEqualType),
            
            
    // Check if Table is Empty
    TableEmpty = 
        let
            TableEmptyType = type function (
                a as (type table meta [
                    Documentation.FieldCaption = "Table",
                    Documentation.FieldDescription = "The table to check if it is empty",
                    Documentation.SampleValues = {Table.FromRecords({[Value = "abc"], [Value = 123], [Value = true]})}
                ]),
                optional message as (type nullable text meta [
                    Documentation.FieldCaption = "Message",
                    Documentation.FieldDescription = "Optional message to display when the table is not empty",
                    Documentation.SampleValues = {"Table is not empty", null}
                ]),
                optional detail as (type any meta [
                    Documentation.FieldCaption = "Detail",
                    Documentation.FieldDescription = "Optional detail to include when the table is not empty",
                    Documentation.SampleValues = {null, Table.FromRecords({[Value = "abc"], [Value = 123], [Value = true]})}
                ]))
                as any meta [
                    Documentation.Name = "TableEmpty",
                    Documentation.LongDescription = "Check if Table is empty",
                    Documentation.Examples = {[
                        Description = "Check if a table is empty",
                        Code = "TableEmpty(Table.FromRecords({}))",
                        Result = true
                    ]}
                ],

            TableEmptyImpl = (a, optional message, optional detail) as any =>
                let
                    Message = if message = null then "table is not empty" else message,
                    Detail = if detail = null then a else detail,
                    Return = TableRowCountEqual(a, 0, Message, Detail)
                in
                    Return
        in
            Value.ReplaceType(TableEmptyImpl, TableEmptyType)
]
