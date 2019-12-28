/**
* @author Martin Kona
* @date 2019-11-28
* @description Interface for entity specific service class
**/
public interface esf_StickyFields {
    /**
    * @author Martin Kona
    * @date 2019-11-28
    * @description This method will be executed from flow
    * @param records
    **/    
    void stickThemFields(List<sObject> records);
}
