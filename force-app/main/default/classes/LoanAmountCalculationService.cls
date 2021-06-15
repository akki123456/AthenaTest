public class LoanAmountCalculationService {
    
    public static void calculateTotalAmountForAccountIds(List<String> accountIdList) {
        List<Applicant__c> applicantList = [
            SELECT Id, Name, Account__c, Application__r.LoanAmount__c, ApplicationOwnership__c 
            FROM Applicant__c WHERE Account__c IN :accountIdList
        ];

        calculateTotalAmountForApplicant(applicantList, accountIdList);  
    }

    public static void calculateTotalAmountForApplicationIds(List<String> applicationIdList) {
        List<Applicant__c> applicantList = [ 
            SELECT Id, Name, Account__c FROM Applicant__c WHERE Application__c IN :applicationIdList 
        ];
        List<String> accountIdList = new List<String>();

        System.debug('applicantList : ' + applicantList);
        
        for (Applicant__c applicant : applicantList) {
            accountIdList.add(applicant.Account__c);
        }

        calculateTotalAmountForAccountIds(accountIdList);  
    }

    public static void calculateTotalAmountForDeletedApplications(List<String> applicationIdList) {
        List<Applicant__c> applicantListForDeletedApps = [ 
            SELECT Id, Name, Account__c FROM Applicant__c WHERE Application__c IN :applicationIdList 
        ];
        List<String> accountIdList = new List<String>();

        for (Applicant__c applicant : applicantListForDeletedApps) {
            accountIdList.add(applicant.Account__c);
        }

        List<Applicant__c> applicantList = [
            SELECT Id, Name, Account__c, Application__r.LoanAmount__c, ApplicationOwnership__c 
            FROM Applicant__c 
            WHERE Account__c IN :accountIdList
            AND Application__c NOT IN :applicationIdList
        ];

        calculateTotalAmountForApplicant(applicantList, accountIdList);  
    }

    private static void calculateTotalAmountForApplicant(List<Applicant__c> applicantList, List<String> accountIdList) {
        Map<String, Decimal> accountIdToTotalLoanMap = new Map<String, Decimal>();

        for (Applicant__c applicant : applicantList) {
            if (accountIdToTotalLoanMap.containsKey(applicant.Account__c) == false) {
                accountIdToTotalLoanMap.put(applicant.Account__c, 0.0);
            }
            accountIdToTotalLoanMap.put(applicant.Account__c, 
                    accountIdToTotalLoanMap.get(applicant.Account__c) + 
                    applicant.ApplicationOwnership__c/100 * applicant.Application__r.LoanAmount__c);
        }

        for (String accountId : accountIdList) {
            if (accountIdToTotalLoanMap.containsKey(accountId) == false) {      // to handle cases where all applicant
                accountIdToTotalLoanMap.put(accountId, 0.0);                    //records are deleted for the account
            }
        }
        List<Account> updatedAccountList = new List<Account>();

        for (String accountId : accountIdToTotalLoanMap.keySet()) {
            updatedAccountList.add(new Account(Id = accountId, TotalLoanAmount__c = accountIdToTotalLoanMap.get(accountId)));
        }

        if(updatedAccountList.size() > 0) { update updatedAccountList; }
    }
}
