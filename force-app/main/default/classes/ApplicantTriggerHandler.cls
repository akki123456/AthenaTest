public class ApplicantTriggerHandler extends TriggerHandler {
    private Map<Id, Applicant__c> newApplicantMap;
    private Map<Id, Applicant__c> oldApplicantMap;

    private List<Applicant__c> newApplicantList;
    private List<Applicant__c> oldApplicantList;

    public ApplicantTriggerHandler() {
        this.newApplicantList = (List<Applicant__c>) Trigger.new;
        this.oldApplicantList = (List<Applicant__c>) Trigger.old; 
        this.newApplicantMap  = (Map<Id, Applicant__c>) Trigger.newMap;
        this.oldApplicantMap  = (Map<Id, Applicant__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> accountIdList = new List<String>();

            for(Applicant__c applicant : newApplicantList) {
                if (applicant.Account__c != null) { accountIdList.add(applicant.Account__c); }
            }
            LoanAmountCalculationService.calculateTotalAmountForAccountIds(accountIdList);
        }
    }

    public override void afterUpdate() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> accountIdList = new List<String>();

            for(Applicant__c applicant : newApplicantList) {
                Applicant__c oldRecord = oldApplicantMap.get(applicant.Id);
                if (applicant.ApplicationOwnership__c != oldRecord.ApplicationOwnership__c ||
                    applicant.Application__c != oldRecord.Application__c) {
                        accountIdList.add(applicant.Account__c);
                }
                if (applicant.Account__c != oldRecord.Account__c) {
                    if (applicant.Account__c != null) { accountIdList.add(applicant.Account__c); }
                    if (oldRecord.Account__c != null) { accountIdList.add(oldRecord.Account__c); }
                }
            }
            LoanAmountCalculationService.calculateTotalAmountForAccountIds(accountIdList);
        }
    }

    public override void afterDelete() {
        if(AccountSettings__c.getInstance().TRG_CalculateTotalAmountForTheCustomer__c) {
            List<String> accountIdList = new List<String>();

            for(Applicant__c applicant : oldApplicantList) {
                if (applicant.Account__c != null) { accountIdList.add(applicant.Account__c); }
            }
            LoanAmountCalculationService.calculateTotalAmountForAccountIds(accountIdList);
        }
    }
}

