library Basics

define "First part":
    'Hello'

define "Second part":
    ', World!'

define "Combining definitions":
    "First part" + "Second part"

//https://cql.hl7.org/02-authorsguide.html#arithmetic-operators
define "Some arithmetic operators":
    (5+5)^2

//https://cql.hl7.org/02-authorsguide.html#constructing-datetime-values
define "Current date":
    Today()

define "Current time":
    TimeOfDay()

define "Current datetime":
    Now()

//https://cql.hl7.org/02-authorsguide.html#extracting-date-and-time-components
define "Extracting date/time components":
    timezoneoffset from "Current datetime"

//https://cql.hl7.org/02-authorsguide.html#datetime-operators
define "Some date/time operators":
    ("Current datetime" + 3 weeks) - 1 month

define "Additional date/time operators":
    duration in minutes between @2020-01-01T00:00:00.000 and Now()

//https://cql.hl7.org/02-authorsguide.html#list-values
define "A list":
    {1, 2, 3, 4, 5}

define "List indexing":
    "A list"[0]

define "An interval":
    Interval[@2019-01-01, @2020-01-01]

define "The 'in' operator":
    Today() - 1 year in "An interval"

//https://cql.hl7.org/02-authorsguide.html#structured-values-tuples
define "Structured value":
    Tuple {
        Name : 'Jeff',
        ProblemList : List {
            Tuple {
                Name: 'COPD',
                Onset: @2010-01-01
            },
            Tuple {
                Name: 'Bronchitis',
                Onset: @2016-03-21
            },
            Tuple {
                Name: 'Emphysema',
                Onset: @2019-11-23
            }
        }
    }

define "Sorting":
    "Structured value".ProblemList P
    return { The_Problem : P.Name, When_It_Started: P.Onset }
    sort by When_It_Started desc
