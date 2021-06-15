trigger ApplicationTrigger on Application__c (after insert, after update, before delete) {
    new ApplicationTriggerHandler().run();
}