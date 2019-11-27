public virtual class sf_StickyFieldsService {

    private static final String COMMA = ',';
    private static final String DOT = '.';
    private static final String TIMESTAMP = 'TIMESTAMP';

    private static List<Sticky_Field__mdt> getThemStickyFieldsMdt(Schema.SObjectType objType) {
        return [SELECT Field__r.QualifiedApiName FROM Sticky_Field__mdt WHERE Entity__c = :String.valueOf(objType)];
    }

    public static List<sObject> setRecordsWithStickyFields(List<sObject> records, Schema.sObjectField stickyJsonField) {
        
        List<Sticky_Field__mdt> stickyFieldsMdt = getThemStickyFieldsMdt(records[0].Id.getSObjectType());
        List<sObject> newRecords = new List<sObject>();

        for (sObject rec : records) {
            SObject newRecord = rec.Id.getSObjectType().newSObject() ;
            Map<String, Object> stickyFields = new Map<String, Object>();
            stickyFields.put(TIMESTAMP, Datetime.now());
            
            for (Sticky_Field__mdt sf : stickyFieldsMdt) {
                String fieldApi = sf.Field__r.QualifiedApiName;
                stickyFields.put(fieldApi, rec.get(fieldApi));
            }

            newRecord.Id = rec.Id;
            newRecord.put(stickyJsonField, JSON.serialize(stickyFields));
            newRecords.add(newRecord);
        }

        return newRecords;
    }    
}
