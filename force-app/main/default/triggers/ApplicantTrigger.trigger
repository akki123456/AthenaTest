trigger ApplicantTrigger on Applicant__c (after insert, after update, after delete) {
    new ApplicantTriggerHandler().run();
}