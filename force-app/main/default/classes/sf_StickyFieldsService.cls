/**
* @author Martin Kona
* @date 2019-11-28
* @description Virtual class, which entity specific class needs to extend
**/
public virtual class sf_StickyFieldsService {

    private static final String TIMESTAMP = 'TIMESTAMP';

    /**
    * @author Martin Kona
    * @date 2019-11-28
    * @description Query configured entity fields, which we will stick to entity into JSON text-area(1000) field
    * @param objType
    * @return List<Sticky_Field__mdt>
    **/
    private static List<Sticky_Field__mdt> getThemStickyFieldsMdt(Schema.SObjectType objType) {
        return [SELECT Field__r.QualifiedApiName FROM Sticky_Field__mdt WHERE Entity__c = :String.valueOf(objType)];
    }

    /**
    * @author Martin Kona
    * @date 2019-11-28
    * @description Set entity fields into JSON text-area(1000) field
    * @param records
    * @param stickyJsonField  - we stick fields into this field   
    * @return List<Sticky_Field__mdt>
    **/
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
