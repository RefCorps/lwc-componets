public with sharing class ContactHistoryController {
   
@AuraEnabled
public static List<ContactHistoryRecord> getContactHistoryRecords(
    String pContactId,
    String pFieldName
){
    List<ContactHistoryRecord> rtr = new List<ContactHistoryRecord>();
    try {
        String queryselect = 'SELECT Contact.Name, createdby.Name, CreatedDate, Field, NewValue, OldValue FROM ContactHistory ';
        queryselect = queryselect;
        if(String.isNotBlank(pContactId) && String.isNotBlank(pFieldName) )
            queryselect = queryselect + ' WHERE ContactId = \'' + pContactId + '\' AND Field = \'' + pFieldName + '\'';  
        else if(String.isNotBlank(pContactId)) 
            queryselect = queryselect + ' WHERE ContactId = \'' + pContactId + '\'';
        else if(String.isNotBlank(pFieldName))
            queryselect = queryselect + ' WHERE FieldName = \'' + pFieldName + '\'';    
        System.debug(LoggingLevel.DEBUG, 'getContactHistoryRecords - select: ' + queryselect);
        List<sObject> recs = Database.query(queryselect);
        integer sz = recs.size();
        for(integer i=0; i < sz; i++) {
            ContactHistoryRecord rec = new ContactHistoryRecord();
            rec.ContactName = (String) recs[i].getSObject('Contact').get('Name');
            rec.CreatedByName = (String) recs[i].getSObject('createdby').get('Name');
            rec.CreatedDate = (DateTime) recs[i].get('CreatedDate');
            rec.Field = (String) recs[i].get('Field');
            rec.NewValue = (String) recs[i].get('NewValue');
            rec.OldValue = (String) recs[i].get('OldValue');
            rtr.add(rec);
        }

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    return rtr;
}

public class ContactHistoryRecord {
        @AuraEnabled public String ContactName { get; set; }
        @AuraEnabled public String CreatedByName { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        @AuraEnabled public String Field { get; set; }
        @AuraEnabled public String NewValue { get; set; }
        @AuraEnabled public String OldValue { get; set; }

        /*
        public ContactHistoryRecord(
            String ContactName,
            String CreatedByName,
            DateTime CreatedDate,
            String Field,
            String NewValue,
            String OldValue
        ) {
            this.CreatedByName = CreatedByName;
            this.CreatedDate = CreatedDate;
            this.Field = Field;
            this.NewValue = NewValue;
            this.OldValue = OldValue;
        }
		*/
}

}