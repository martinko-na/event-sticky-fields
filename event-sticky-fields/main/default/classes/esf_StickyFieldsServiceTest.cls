@isTest
public class esf_StickyFieldsServiceTest {

    static final String STICKY_FIELD = 'Type';
    static final String STICKY_VALUE = 'Other';
    static final Integer NUM_OF_ACC = 200;

    @isTest
    public static void testGetThemStickyFieldsMdt() {

        // when
        Test.startTest();
            List<Event_Sticky_Field__mdt> stickyFieldsMdt = esf_StickyFieldsService.getThemStickyFieldsMdt(Account.SobjectType);
        Test.stopTest();
        // then
        System.assertEquals(1, stickyFieldsMdt.size());
        System.assertEquals(STICKY_FIELD, stickyFieldsMdt[0].Field__c);
    }

    @isTest
    public static void testSetRecordsWithStickyFields() {

        // given
        List<Account> records = 
            (List<Account>) esf_TestFactory.createSObjectList(
                new Account(Type = STICKY_VALUE), NUM_OF_ACC, true);   

        // when
        Test.startTest();            
           records = esf_StickyFieldsService.setRecordsWithStickyFields(records, Account.esf_Sticky_JSON__c);
        Test.stopTest();
        // then        
        System.assertEquals(NUM_OF_ACC, records.size());

        for (Account acc : records) {
            Map<String, String> stickyFields = 
                (Map<String, String> )JSON.deserialize(acc.esf_Sticky_JSON__c, Map<String, String> .class);
            System.assert(String.isNotBlank(stickyFields.get(STICKY_FIELD)), 'Sticky field must have value');
            System.assertEquals(STICKY_VALUE, stickyFields.get(STICKY_FIELD));
            System.assert(String.isNotBlank(stickyFields.get(esf_StickyFieldsService.TIMESTAMP)));
        }
    }
}
