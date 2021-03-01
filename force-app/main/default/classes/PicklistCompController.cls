public with sharing class PicklistCompController {

    @AuraEnabled
    public static List < String > getPickListValues(String pObjAPIName, String pFieldAPIName) {

        System.debug(LoggingLevel.DEBUG,'Obj: ' + pObjAPIName + ' Field: ' + pFieldAPIName);
        List < String > designationpicklist = new List < String > ();

        SObjectType objToken = Schema.getGlobalDescribe().get(pObjAPIName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map < String, SObjectField > fields = objDef.fields.getMap();
        SObjectField fieldToken = fields.get(pFieldAPIName);
        Schema.DescribeFieldResult selectedPLField = fieldToken.getDescribe();
        Schema.DisplayType fieldType = selectedPLField.getType();
        System.debug(LoggingLevel.DEBUG, selectedPLField.getName() + ' Type=' + fieldType);
        List < Schema.PicklistEntry > picklist = selectedPLField.getPicklistValues();
        for (Schema.PicklistEntry entry: picklist) {
            System.debug(LoggingLevel.DEBUG, 'In getValue() = ' + entry.getValue());
            designationpicklist.add(entry.getValue());
        }
        return designationpicklist;
    }

    @AuraEnabled
    public static List < String > getObjectAPINames(String pMatchObj) {
		List<String> options = new List<String>();
        //if(pMatchObj.length() < 3)
        //    return options;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        //System.debug(gd);
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
        {
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            if(objResult.getName().containsIgnoreCase(pMatchObj) && objResult.isSearchable() ) {
            	System.debug(LoggingLevel.DEBUG,'Sobject API Name: ' + objResult.getName() );
                options.add(objResult.getName());
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static List < String > getObjectPicklistFields(String pObjAPIName) {
		List<String> fieldNames = new List<String>();
        SObjectType matchType = Schema.getGlobalDescribe().get(pObjAPIName);
        Map<String,Schema.SObjectField> mfields = matchType.getDescribe().fields.getMap();
        for(String fieldName : mfields.keyset()){
            if( mfields.get(fieldName).getDescribe().getType() == Schema.DisplayType.PICKLIST) {
    			//System.debug( fieldName + ' --> ' + mfields.get(fieldName).getDescribe().getType() );
            	//System.debug('---------------------------------------------');
                fieldNames.add(mfields.get(fieldName).getDescribe().getName());
            }    
		}
        System.debug(fieldNames);
        return fieldNames;
    }
    
    
}