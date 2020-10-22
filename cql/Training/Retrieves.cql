//Library declaration
library Retrieves

//Data model declaration
using FHIR version '4.0.0'

//External library declaration(s)
include FHIRHelpers version '4.0.0' called FHIRHelpers

//Codesystem declaration(s)
codesystem "SNOMED": 'http://snomed.info/sct'

//ValueSet declaration(s)
valueset "COPD valueset" : 'http://fake-valueset-url.org/fhir/ValueSet/copd'

//DRC (Direct Reference Code) declaration(s), the 'display' field is optional
code "COPD code": '13645005' from "SNOMED"
code "Dyspnea code" : '267036007' from "SNOMED" display 'Dyspnea (finding)'

//Parameter declaration(s)
parameter MeasurementPeriod default Interval[@2020-01-01, @2021-01-01]

//Context declaration
context Patient

//-------------------------Define statements-------------------------
define "Patient demographics":
    Tuple{
        Name : Patient.name.given[0].value, //Parse the data out of the patient resource, .value extracts the actual value from the data model reference variable
        Gender : Patient.gender.value,
        Age : AgeInYears() //(Patient-specific concept) https://cql.hl7.org/02-authorsguide.html#patient-operators
    }

//This retrieve has no filter and will return all Condition resources
define "All conditions":
    [Condition]

//Filtering with operators
define "Sorting with 'where'":
    "All conditions" C //List of all Conditions is given the alias 'C'
        where C.code.text.value = 'Chronic obstructive lung disease' //For each Condition, pull out its code.text field (String) and compare it
        return C.id.value //Return just the ID of the matching resources

//Terminology-based filtering
define "Filtering with a DRC":
    [Condition: "COPD code"] C //Retrieve using the "COPD code" DRC
        return C.id.value

//Terminology-based filtering
define "Filtering with a valueset":
    [Condition: "COPD valueset"] C //Retrieve using the "COPD valueset" ValueSet
        return C.id.value

//Filtering with parameters
define "Filtering with a parameter":
    "All conditions" C
        where C.onset.value in MeasurementPeriod //For each Condition, pull out its onset field (DateTime) and check to see if its in the Parameter (Interval of Dates)
        return C.id.value

//More complex filtering
define "Filtering by relationships":
    [Encounter] E //List of all Encounters is given the alias 'E'
        with [Condition: "COPD code"] C //List of all COPD Conditions is given alias 'C'
            such that C.onset.value during E.period //Filter for Conditions whose onset field (DateTime) falls during the Encounter period field (DateTime, start and end)
            return E.id.value

//More complex filtering
define "Sorting with first/last":
    First( //Select the first value in the sorted and filtered retrieve result List
        [Observation: "Dyspnea code"] O //List of all Dyspnea Observations is given alias 'O'
        where O.effective as dateTime in //Cast the effective field as a DateTime object, only keep the Observation in the result List if that DateTime falls within the Interval
            Interval[Now() - 24 hours, Now() - 0 hours] //An interval representing the past 24 hours
        sort by(ToDate(effective as dateTime)) //Cast the effective field of the resulting Observation back to a Date object and sort result List order by those Dates
    ).id.value

//Practice Activity
