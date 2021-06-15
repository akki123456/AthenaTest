@IsTest
public class LoanAmountCalculationServiceTest {
    @TestSetup
    static void setup(){
        AccountSettings__c accountSettings = new AccountSettings__c();
        accountSettings.TRG_CalculateTotalAmountForTheCustomer__c = true;

        insert accountSettings;

        List<Account> accountList = new List<Account>();

        Account account1 = new Account(Name='Account1');
        accountList.add(account1);

        Account account2 = new Account(Name='Account2');
        accountList.add(account2);

        insert accountList;

        Application__c application  = new Application__c(LoanAmount__c = 10000);

        insert application;
    }

    @IsTest
    static void testLoanAmountCalculationOnApplicantInsert(){
        Account account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        
        System.assertNotEquals(5000, account.TotalLoanAmount__c);
        Application__c application  = [SELECT Id, Name FROM Application__c LIMIT 1 ];

        Applicant__c applicant = new Applicant__c( Account__c               = account.Id, 
                                                   Application__c           = application.Id,
                                                   ApplicationOwnership__c  = 50);

        Test.startTest();
        insert applicant;
        Test.stopTest();

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        
        System.assertEquals(5000, account.TotalLoanAmount__c);
    }

    @IsTest
    static void testLoanAmountCalculationOnApplicantUpdate(){
        Account account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        
        System.assertNotEquals(5000, account.TotalLoanAmount__c);
        Application__c application  = [SELECT Id, Name FROM Application__c LIMIT 1 ];

        Applicant__c applicant = new Applicant__c( Account__c               = account.Id, 
                                                   Application__c           = application.Id,
                                                   ApplicationOwnership__c  = 50);

        
        insert applicant;

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        
        System.assertEquals(5000, account.TotalLoanAmount__c);

        Test.startTest();

        applicant.ApplicationOwnership__c = 75;
        update applicant;
        Test.stopTest();

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(7500, account.TotalLoanAmount__c);

        applicant.Account__c = null;
        update applicant;

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(0, account.TotalLoanAmount__c);
    
        delete applicant;

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(0, account.TotalLoanAmount__c);
    }

    @IsTest
    static void testLoanAmountCalculationOnApplication(){
        Account account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        
        System.assertNotEquals(5000, account.TotalLoanAmount__c);
        Application__c application  = [SELECT Id, Name FROM Application__c LIMIT 1 ];

        Applicant__c applicant = new Applicant__c( Account__c               = account.Id, 
                                                   Application__c           = application.Id,
                                                   ApplicationOwnership__c  = 50);
        insert applicant;
        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(5000, account.TotalLoanAmount__c);

        Application__c application2  = new Application__c(LoanAmount__c = 10000);
        insert application2;

        Applicant__c applicant2 = new Applicant__c( Account__c              = account.Id, 
                                                   Application__c           = application2.Id,
                                                   ApplicationOwnership__c  = 20);
        insert applicant2;

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(7000, account.TotalLoanAmount__c);

        application2.LoanAmount__c = 20000;
        update application2;

        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(9000, account.TotalLoanAmount__c);

        delete application2;
        account = [ SELECT Id, Name, TotalLoanAmount__c FROM Account LIMIT 1 ];
        System.assertEquals(5000, account.TotalLoanAmount__c);
    }
}
