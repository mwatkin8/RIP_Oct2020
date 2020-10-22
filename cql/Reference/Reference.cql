library Reference

//Strings - https://cql.hl7.org/03-developersguide.html#string-operators
define "Hello part":
	'Hello'

define "World part":
	'World!'

define "My First String":
	Lower("Hello part") + ', ' + Upper("World part")

define "Alternate world":
    Combine({ "Hello part", "World part" }, ', ' )

define "Break it up":
    Split( "Alternate world", ', ' )

define "Where is the comma?":
    PositionOf(',', "My First String")

define "World substring":
    Substring("My First String", "Where is the comma?" + 1, Length("My First String"))

//Decimals and Integers - https://cql.hl7.org/02-authorsguide.html#arithmetic-operators
define "My First Decimal":
    Exp(1)

define "My First Integer":
	Round("My First Decimal")

define "My First Between Operator":
    "My First Decimal" between 0 and "My First Integer"

//Dates and Times - https://cql.hl7.org/02-authorsguide.html#datetime-operators
define "My First Date":
    @2020-01-01

define "Same year":
    "My First Date" same year as Date(2020, 01, 01)

define "Later month":
    Date(2020, 04, 01) same month or after "My First Date"

define "Some months between":
    months between "My First Date" and Today() + 1 months

define "My First Time":
    @T12:00

define "My First DateTime":
    @2020-01-25T12:00

define "Some hours between":
    duration in hours between "My First DateTime" and Date(2020,01,26)

//Intervals - https://cql.hl7.org/02-authorsguide.html#operating-on-intervals
define "My First Interval":
    Interval[1,5)

define "My First Width Operator":
    width of "My First Interval"

define "My First Start Of Operator":
    start of "My First Interval"

define "My First End Of Operator":
    end of "My First Interval"

define "Time interval":
    Interval[@2020-01-25T00:00, @2020-01-26T00:00)

define "My First In Operator":
    "My First DateTime" in "Time interval"

define "My First Contains Operator":
    "Time interval" contains "My First DateTime"

define "Timing phrases": //https://cql.hl7.org/02-authorsguide.html#timing-relationships
    /*
    Additional phrases: less than, more than, or less, or more, on or, or on, before, after, within
    */
    Interval[@2020-01-27, @2020-01-30) starts less than 3 days on or after end "Time interval"

//Quantities - https://cql.hl7.org/02-authorsguide.html#quantity-operators
define "My First Quantity":
	100.42 '[degF]'

define "Quantity Value":
    "My First Quantity".value

define "Quantity Unit":
    "My First Quantity".unit

define "My First Quantity Operation":
    "My First Quantity" > 100 '[degF]'

//Lists
define "My First List":
    {1, 2, 3}

define "Find list index":
    IndexOf("My First List", 3)

define "Use list index":
    "My First List"["Find list index"]

define "Singleton list":
    singleton from { 1 }

define "Aggregate operators for lists": //https://cql.hl7.org/02-authorsguide.html#aggregate-operators
    /*
    Additional aggregate operators: Count, Sum, Min, Max, Avg, Median, Mode, PopStdDev, Variance,
                                    PopVariance, AllTrue, AnyTrue, GeometricMean, Product
    */
    StdDev("My First List")
