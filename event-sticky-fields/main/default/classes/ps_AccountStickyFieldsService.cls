/**
* @author Martin Kona
* @date 2019-11-28
* @description Entity specific service class. We are not able to use generic service class due to @InvocableMethod restrictions
**/
public without sharing class ps_AccountStickyFieldsService extends esf_StickyFieldsService implements esf_StickyFields {

    /**
    * @author Martin Kona
    * @date 2019-11-28
    * @description This method will be executed from flow
    * @param records
    **/  
    @InvocableMethod
    public static void stickThemFields(List<Account> records) {

        // we need new memory reference, since input records from flow are in 'read-only' mode
        List<Account> newRecords = setRecordsWithStickyFields(records, Account.esf_Sticky_JSON__c);
        
        update newRecords;
    }
}
