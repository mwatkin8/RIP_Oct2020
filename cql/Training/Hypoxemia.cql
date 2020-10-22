library Hypoxemia

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers

codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'
codesystem "ConditionVerificationStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-ver-status'
codesystem "LOINC": 'http://loinc.org'

valueset "Hypoxemia valueset" : 'http://fake-valueset-url.org/fhir/ValueSet/hypoxemia'

code "O2 Saturation Code": '2708-6' from "LOINC"
code "Arterial PO2 Code": '2703-7' from "LOINC"
code "active": 'active' from "ConditionClinicalStatusCodes"
code "confirmed": 'confirmed' from "ConditionVerificationStatusCodes"

context Patient

define "New-onset hypoxemia that persists despite observation care treatment":
  "Active Hypoxemia in Past 24 hours"
    or (
      ("New O2 Saturation" < 90)
        and ("New O2 Saturation" > 20)
        and not IsNull("Baseline O2 Saturation")
        and not ("Baseline O2 Saturation" < 90)
    )
    or (
      ("New Arterial PO2" < 60)
        and ("New Arterial PO2" > 20)
        and not IsNull("Baseline Arterial PO2")
        and not ("Baseline Arterial PO2" < 60)
    )

//Save the current time
define "Current DateTime":
    Now()

//Pull all hypoxemia conditions for the patient using a valueset filter
define "Hypoxemia Conditions":
  ["Condition": "Hypoxemia valueset"]

//Filter for hypoxemia conditions with an onset DateTime in the past 24 hours
define "Hypoxemia in Past 24 hours":
    "Hypoxemia Conditions" C //Use the alias 'C' for the List of all hypoxemia Conditions
        where C.onset as dateTime in //Cast the 'onset' field as a DateTime
            Interval["Current DateTime" - 24 hours, "Current DateTime"] //Check to see if it falls within an Interval of the past 24 hours

//Check to see if any conditions have an 'active' clinical status (DRC) and 'confirmed' verificationStatus (DRC)
define "Active Hypoxemia in Past 24 hours":
    exists(
        "Hypoxemia in Past 24 hours" C //Use the alias 'C' for the List of all hypoxemia Conditions in the past 24 hours
            where (
                FHIRHelpers.ToConcept(C.clinicalStatus) ~ "active" //Filter for Conditions whose 'clinicalStatus' field are equivalent to the "active" DRC
            )
            and (
                FHIRHelpers.ToConcept(C.verificationStatus) ~ "confirmed" //They must also have a 'verificationStatus' field which are equivalent to the "confirmed" DRC
            )
    )

//Pull all O2 Saturation Observation resources for patient
define "All O2 Saturation Observations":
    [Observation: "O2 Saturation Code"]

//Smallest O2 saturation from the past 24 hours
define "New O2 Saturation":
    First( //Use the first item in the resulting List
        "All O2 Saturation Observations" Obs //Use the alias 'Obs' for the List of all O2 saturation observations
        where Obs.effective as dateTime in //Cast the 'effective' field as a DateTime
            Interval["Current DateTime" - 24 hours, "Current DateTime" - 0 hours] //Check to see if it falls within an Interval of the past 24 hours
        sort by ((value as Quantity).value) //Cast the 'value' field as a Quantity and sort by the value of that Quantity
    ).value.value as decimal //Use the value of the 'value' field (cast as a Decimal)

//Latest O2 saturation from the past year (excluding the past 7 days)
define "Baseline O2 Saturation":
    Last( //Use the last item in the resulting List
        "All O2 Saturation Observations" Obs //Use the alias 'Obs' for the List of all O2 saturation observations
         where Obs.effective as dateTime in //Cast the 'effective' field as a DateTime
             Interval["Current DateTime" - 1 year, "Current DateTime" - 7 days] //Check to see if it falls within an Interval of the past year (excluding the past 7 days)
         sort by (ToDate(effective as dateTime)) //Cast the 'effective' field as a DateTime and sort by the value of that DateTime
    ).value.value as decimal //Use the value of the 'value' field (cast as a Decimal)

//Pull all Arterial PO2 Observations for patient
define "All Arterial PO2 Observations":
  [Observation: "Arterial PO2 Code"]

define "New Arterial PO2":
    First(
        "All Arterial PO2 Observations" Obs
        where Obs.effective as dateTime in
          Interval["Current DateTime" - 24 hours, "Current DateTime" - 0 hours]
        sort by ((value as Quantity).value)
    ).value.value as decimal

define "Baseline Arterial PO2":
    Last(
      "All Arterial PO2 Observations" Obs
      where Obs.effective as dateTime in
          Interval["Current DateTime" - 1 year, "Current DateTime" - 7 days]
      sort by (ToDate(effective as dateTime))
    ).value.value as decimal
