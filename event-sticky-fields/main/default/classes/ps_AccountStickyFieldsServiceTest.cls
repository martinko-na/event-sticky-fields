@isTest
public class ps_AccountStickyFieldsServiceTest {

    static final String POMS_SYSTEM = 'POMS';
    static final String POMS_RECORD_ID= '1';
    static final String CDB_SYSTEM = 'CDB';
    static final String CDB_RECORD_ID= '2';

    static final String STICKY_FIELD = 'Country__pc';
    static final Integer NUM_OF_ACC = 200; 
    static final Integer NUM_OF_IDENT = 2; 

    @isTest
    public static void testStickThemFieldsWithSystemRefs() {

        //given
        Account acc = (Account) ps_TestFactory.createSObject(new Account(), ps_GlobalConstants.TF_PERSON_ACCOUNT_DEFAUTLS, true);
        List<Additional_Identifier__c> ais = 
            (List<Additional_Identifier__c>) ps_TestFactory.createSObjectList(
                new Additional_Identifier__c(Account__c = acc.Id, Created_Date_in_System__c = Datetime.now(), 
                                             Last_Modified_Date_in_System__c = Datetime.now()), NUM_OF_IDENT);
        ais[0].System__c = POMS_SYSTEM;
        ais[0].System_Record_Id__c = POMS_RECORD_ID;
        ais[1].System__c = CDB_SYSTEM;
        ais[1].System_Record_Id__c = CDB_RECORD_ID;
        insert ais;

        // when
        Test.startTest();            
            update acc; 
        Test.stopTest();

        // then
        acc = [SELECT esf_Sticky_JSON__c FROM Account WHERE Id = :acc.Id];
        system.debug(acc);
        StickyFieldsWrapper stickyFields = 
            (StickyFieldsWrapper)JSON.deserialize(acc.esf_Sticky_JSON__c, StickyFieldsWrapper.class);        
        System.assertEquals(NUM_OF_IDENT, stickyFields.sysRefs.size());

        for (ps_AccountService.SystemReference sysRef : stickyFields.sysRefs) {
            System.assert(String.isNotBlank(sysRef.sysName)); 
            System.assert(String.isNotBlank(sysRef.recordId)); 
        }
    } 

    /**
    * @author Martin Kona
    * @date 2019-12-02
    * @description Wrapper class to store record reference in external system
    **/
    public class StickyFieldsWrapper {
        List<ps_AccountService.SystemReference> sysRefs;
        String timestamp;
    }   

    @isTest
    public static void testStickThemFields() {

        // given
        List<Account> records = 
            (List<Account>) ps_TestFactory.createSObjectList(
                new Account(Country__pc = ps_GlobalConstants.SWEDEN_ISO), NUM_OF_ACC, ps_GlobalConstants.TF_PERSON_ACCOUNT_DEFAUTLS, true);  

        // when
        Test.startTest();            
            ps_AccountStickyFieldsService.stickThemFields(records); 
        Test.stopTest();
        // then
        records = [SELECT esf_Sticky_JSON__c FROM Account WHERE Id IN :records];
        System.assertEquals(NUM_OF_ACC, records.size());

        for (Account acc : records) {
            Map<String, String> stickyFields = 
                (Map<String, String> )JSON.deserialize(acc.esf_Sticky_JSON__c, Map<String, String> .class);
            System.assertEquals(ps_GlobalConstants.SWEDEN_ISO, stickyFields.get(STICKY_FIELD));              
        }
    }

    @isTest
    public static void testStickThemFields_flowExecuted() {

        // when
        Test.startTest();
        List<Account> records = 
            (List<Account>) ps_TestFactory.createSObjectList(
                new Account(Country__pc = ps_GlobalConstants.SWEDEN_ISO), NUM_OF_ACC, ps_GlobalConstants.TF_PERSON_ACCOUNT_DEFAUTLS, true);
        Test.stopTest();
        // then
        records = [SELECT esf_Sticky_JSON__c FROM Account WHERE Id IN :records];
        System.assertEquals(NUM_OF_ACC, records.size());

        for (Account acc : records) {
            Map<String, String> stickyFields = 
                (Map<String, String> )JSON.deserialize(acc.esf_Sticky_JSON__c, Map<String, String> .class);
            System.assert(String.isNotBlank(stickyFields.get(STICKY_FIELD)), 'Sticky field must have value');                
            System.assertEquals(ps_GlobalConstants.SWEDEN_ISO, stickyFields.get(STICKY_FIELD));
        }
    }    
}
