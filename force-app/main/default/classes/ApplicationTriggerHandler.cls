public class ApplicationTriggerHandler extends TriggerHandler {
    private Map<Id, Application__c> newApplicationMap;
    private Map<Id, Application__c> oldApplicationMap;

    private List<Application__c> newApplicationList;
    private List<Application__c> oldApplicationList;

    public ApplicationTriggerHandler() {
        this.newApplicationList = (List<Application__c>) Trigger.new;
        this.oldApplicationList = (List<Application__c>) Trigger.old; 
        this.newApplicationMap  = (Map<Id, Application__c>) Trigger.newMap;
        this.oldApplicationMap  = (Map<Id, Application__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> applicationIdList = new List<String>();

            for(Application__c application : newApplicationList) {
                applicationIdList.add(application.Id);
            }
            LoanAmountCalculationService.calculateTotalAmountForApplicationIds(applicationIdList);
        }
    }

    public override void afterUpdate() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> applicationIdList = new List<String>();

            for(Application__c application : newApplicationList) {
                Application__c oldRecord = oldApplicationMap.get(application.Id);
                if (application.LoanAmount__c != oldRecord.LoanAmount__c) {
                    applicationIdList.add(application.Id);
                }
            }
            LoanAmountCalculationService.calculateTotalAmountForApplicationIds(applicationIdList);
        }
    }

    public override void beforeDelete() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> applicationIdList = new List<String>();

            for(Application__c application : oldApplicationList) {
                applicationIdList.add(application.Id);
            }
            LoanAmountCalculationService.calculateTotalAmountForDeletedApplications(applicationIdList);
        }
    }

}
