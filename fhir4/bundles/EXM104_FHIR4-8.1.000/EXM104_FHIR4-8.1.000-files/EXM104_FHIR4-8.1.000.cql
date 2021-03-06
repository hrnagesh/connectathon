library EXM104_FHIR4 version '8.1.000'
// for 2020 Reporting Year
//STK 2
/*
Based on CMS104 - Discharged on Antithrombotic Therapy
Author: TJC
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global
include SupplementalDataElements_FHIR4 version '1.0.0' called SDE
include TJCOverall_FHIR4 version '4.0.000' called TJC

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct/731000124108'
// NOTE: R4 code system URLs changed to be based on terminology.hl7.org...
codesystem "Diagnosis Role": 'http://terminology.hl7.org/CodeSystem/diagnosis-role'
//codesystem "Diagnosis Role": 'http://hl7.org/fhir/diagnosis-role'
codesystem "RequestIntent": 'http://terminology.hl7.org/CodeSystem/request-intent'
//codesystem "RequestIntent": 'http://hl7.org/fhir/request-intent'
codesystem "MedicationRequestCategory": 'http://terminology.hl7.org/CodeSystem/medicationrequest-category'


valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.201'
valueset "Comfort Measures": 'http://cts.nlm.nih.gov/fhir/ValueSet/1.3.6.1.4.1.33895.1.3.0.45'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837'
valueset "Hemorrhagic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.212'
valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.247'
valueset "Left Against Medical Advice": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.308'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473'
valueset "Non-Elective Inpatient Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.424'
valueset "Observation Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.143'
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93'
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591'
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836'
valueset "Ticagrelor Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.39'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Order": 'order' from "RequestIntent" display 'Order'
code "Discharge": 'discharge' from "MedicationRequestCategory" display 'Discharge'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
	SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
	SDE."SDE Sex"

define "Initial Population":
	TJC."Encounter with Principal Diagnosis and Age"

  define "Encounter with Principal Diagnosis and Age":
    "All Stroke Encounter" AllStrokeEncounter
    	with ["Patient"] BirthDate
    		such that Global."CalendarAgeInYearsAt"(FHIRHelpers.ToDate(BirthDate.birthDate), start of AllStrokeEncounter.period) >= 18

        define "All Stroke Encounter":
        	"Non Elective Inpatient Encounter" NonElectiveEncounter
        		where Global.PrincipalDiagnosis(NonElectiveEncounter).code in "Hemorrhagic Stroke"
        		or Global.PrincipalDiagnosis(NonElectiveEncounter).code in "Ischemic Stroke"


              define "Non Elective Inpatient Encounter":
              	["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
              		where Global."LengthInDays"(NonElectiveEncounter.period)<= 120
              			and NonElectiveEncounter.period ends during "Measurement Period"

define "Denominator":
	TJC."Ischemic Stroke Encounter"

  define "Ischemic Stroke Encounter":
    "Encounter with Principal Diagnosis and Age" EncounterWithAge
      where Global.PrincipalDiagnosis(EncounterWithAge).code in "Ischemic Stroke"

define "Denominator Exclusion":
	TJC."Ischemic Stroke Encounters with Discharge Disposition"
		union TJC."Comfort Measures during Hospitalization"


define "Numerator":
	TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
		with "Antithrombotic Therapy at Discharge" DischargeAntithrombotic
			such that DischargeAntithrombotic.authoredOn during Global."Normalize Interval"(IschemicStrokeEncounter.period)

      define "Antithrombotic Therapy at Discharge":
      	["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
      	  where exists (Antithrombotic.category C where FHIRHelpers.ToConcept(C) ~ "Discharge")
          //.value should not be required.  Antithrombotic.intent should work.  Pending fix to CQF Ruler.
      	    and Antithrombotic.intent.value in {'plan', 'order'}

define "Denominator Exceptions":
	"Encounter With No Antithrombotic At Discharge"
		union "Encounter With Ticagrelor at Discharge"

    define "Encounter With No Antithrombotic At Discharge":
    	TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
    		with "Antithrombotic Not Given at Discharge" NoDischargeAntithrombotic
    			such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

          define "Antithrombotic Not Given at Discharge":
          	["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
              where NoAntithromboticDischarge.doNotPerform is true
          			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
          				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
                    and exists (NoAntithromboticDischarge.category C where FHIRHelpers.ToConcept(C) ~ "Discharge")


    define "Encounter With Ticagrelor at Discharge":
      TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
        with "Ticagrelor Therapy at Discharge" DischargeTicagrelor
          such that DischargeTicagrelor.authoredOn during IschemicStrokeEncounter.period

          define "Ticagrelor Therapy at Discharge":
            ["MedicationRequest": medication in TJC."Ticagrelor Therapy"] Ticagrelor
              where exists (Ticagrelor.category C where FHIRHelpers.ToConcept(C) ~ "Discharge")
                and Ticagrelor.intent in {'order', 'plan'}
