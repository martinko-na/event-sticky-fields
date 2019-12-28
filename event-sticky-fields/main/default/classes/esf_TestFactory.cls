@isTest
public class esf_TestFactory {

  public static SObject createSObject(SObject sObj) {
    // Check what type of object we are creating and add any defaults that are needed.
    String objectName = String.valueOf(sObj.getSObjectType());
    // Construct the default values class. Salesforce doesn't allow '__' in class names
    String defaultClassName = objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
    // If there is a class that exists for the default values, then use them
    if(Type.forName('ps_TestFactoryDefaults.' + defaultClassName) != null) {
      sObj = createSObject(sObj, 'ps_TestFactoryDefaults.' + defaultClassName);
    }
    return sObj;
  }

  public static SObject createSObject(SObject sObj, Boolean doInsert) {
    SObject retObject = createSObject(sObj);
    if(doInsert) {
      insert retObject;
    }
    return retObject;
  }

  public static SObject createSObject(SObject sObj, String defaultClassName) {
    // Create an instance of the defaults class so we can get the Map of field defaults
    Type t = Type.forName(defaultClassName);
    if(t == null) {
      Throw new TestFactoryException('Invalid defaults class.');
    }
    FieldDefaults defaults = (FieldDefaults)t.newInstance();
    addFieldDefaults(sObj, defaults.getFieldDefaults());
    return sObj;
  }

  public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
    SObject retObject = createSObject(sObj, defaultClassName);
    if(doInsert) {
      insert retObject;
    }
    return retObject;
  }

  public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
    return createSObjectList(sObj, numberOfObjects, (String)null);
  }

  public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
    SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
    if(doInsert) {
      insert retList;
    }
    return retList;
  }

  public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
    SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
    if(doInsert) {
      insert retList;
    }
    return retList;
  }

  public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
    SObject[] sObjs = new SObject[] {};
    SObject newObj;

    // Get one copy of the object
    if(defaultClassName == null) {
      newObj = createSObject(sObj);
    } else {
      newObj = createSObject(sObj, defaultClassName);
    }

    // Get the name field for the object
    String nameField = String.valueOf(nameFieldMap.get(sObj.getSObjectType()));
    if(nameField == null) {
      nameField = 'Name';
    }
    Boolean nameIsAutoNumber = sObj.getSobjectType().getDescribe().fields.getMap().get(nameField).getDescribe().isAutoNumber();
    Boolean hasRecordTypeField = false;
    if(!(sObj.getSObjectType().getDescribe().getName() == 'OrderItem')){//16.12.2019: excluded Order Item object since it does not have RecordTypeId
      hasRecordTypeField = sObj.isSet(ps_GlobalConstants.RECORD_TYPE_FIELD);
    }
    
    Boolean isPersonAccount = ps_GlobalConstants.PERSON_ACCOUNT_ID == (hasRecordTypeField ? sObj.get(ps_GlobalConstants.RECORD_TYPE_FIELD) : NULL);

    // Clone the object the number of times requested. Increment the name field so each record is unique
    for(Integer i = 0; i < numberOfObjects; i++) {
      SObject clonedSObj = newObj.clone(false, true);
      if(!nameIsAutoNumber && !isPersonAccount) {
        clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
      }
      sObjs.add(clonedSObj);
    }
    return sObjs;
  }

  private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
    // Loop through the map of fields and if they weren't specifically assigned, fill them.
    Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
    for(Schema.SObjectField field : defaults.keySet()) {
      if(!populatedFields.containsKey(String.valueOf(field))) {
        sObj.put(field, defaults.get(field));
      }
    }
  }

  // When we create a list of SObjects, we need to have a unique field for the insert if there isn't an autonumber field.
  // Usually we use the Name field, but some objects don't have a name field.
  private static Map<Schema.SObjectType, Schema.SObjectField> nameFieldMap = new Map<Schema.SObjectType, Schema.SObjectField> {
    Contact.sObjectType => Contact.LastName,
    Case.sObjectType => Case.CaseNumber, //this is the autonumber field
    Lead.sObjectType => Lead.Fax,
    OrderItem.sObjectType => OrderItem.OrderItemNumber
  };

  public class TestFactoryException extends Exception {}

  // Use the FieldDefaults interface to set up values you want to default in for all objects.
  public interface FieldDefaults {
    Map<Schema.SObjectField, Object> getFieldDefaults();
  }
}