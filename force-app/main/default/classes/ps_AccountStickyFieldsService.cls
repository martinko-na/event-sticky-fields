public with sharing class ps_AccountStickyFieldsService extends sf_StickyFieldsService implements sf_StickyFields {

    @InvocableMethod
    public static void stickThemFields(List<Account> records) {

        // we need new memory reference, since input records from flow are in 'read-only' mode
        List<Account> newRecords = setRecordsWithStickyFields(records, Account.Sticky_JSON__c);
        update newRecords;
    }
}
