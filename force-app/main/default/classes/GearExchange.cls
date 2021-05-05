public with sharing class GearExchange {

    @AuraEnabled
    public static List<User> fetchBidder(){
       string UserId = UserInfo.getUserId();
       // USE USER ID SINCE SOME USERS MAY NOT HAVE A CONTACT - IT WON'T FAIL - THE CONTANTID WILL BE BLANK
       List<User> bidder = [select name, contactid from user where id =: UserId ];
       //System.debug(LoggingLevel.DEBUG,evaluator); 
       return bidder;
    }


    @AuraEnabled
    public List<Gear_Exchange__c> getUnclaimedGearList() {
        return  GetGearList(1);
    }

    @AuraEnabled
    public List<Gear_Exchange__c> getFullGearList() {
        return  GetGearList(0);
    }

    @AuraEnabled
    public static List<Gear_Exchange__c> GetGearList(Integer listType) {
        
        String searchquery = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, ';
        searchquery = searchquery + 'LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate,  ';
        searchquery = searchquery + 'UserRecordAccessId, Category__c, Item_Clothing__c, Item_Stopwatchs__c, '; 
        searchquery = searchquery + 'Item_Megaphones__c, Item_NonTech_tools__c, Item_Tech_Based_Tools__c, '; 
        searchquery = searchquery + 'Item_Other__c, Size__c, Color__c, Offered_By__c, Value__c, '; 
        searchquery = searchquery + 'Coordinated_By__c, Received_By__c, Date_Recd__c, Location_Recd__c, '; 
        searchquery = searchquery + 'Located_At__c, Distribution_Date__c, Distributed_By__c, '; 
        searchquery = searchquery + 'Distributed_To__c, Thanks_Sent__c, Description__c, US_Rowing_Logo__c, Gender__c '; 
        searchquery = searchquery + 'from Gear_Exchange__c  ';
        
        if(listType == 1)
            searchquery = searchquery + 'WHERE Distributed_To__c = null';
        List<Gear_Exchange__c> eg = Database.query(searchquery);
        return eg;
    }
    
    @AuraEnabled
    public static List<GearData> getGearBoxTableData(Integer listType) { 

        List<GearData> rtr = new List<GearData>();
            
        String searchquery = 'SELECT Id, Category__c, Item__c, USRowing_Logo__c, '; 
        searchquery = searchquery + ' Description__c, Item_Status__c, Offered_By__r.Name,  Offered_Date__c '; 
        searchquery = searchquery + ' from Gear_Exchange__c  ';
        
        if(listType == 1)
            searchquery = searchquery + 'WHERE Distributed_To__c = null';
        searchquery = searchquery + ' ORDER BY Offered_Date__c, Offered_By__c';    
        List<sObject> gear = Database.query(searchquery);
        integer sz = gear.size();
        for(integer i=0; i < sz; i++) {
            GearData gd = new GearData();
            gd.id = (String) gear[i].get('Id');
            gd.category = (String) gear[i].get('Category__c');
            gd.item = (String) gear[i].get('Item__c');
        	gd.description = (String) gear[i].get('Description__c');
        	gd.usrowinglogo = (Boolean) gear[i].get('USRowing_Logo__c');
       		gd.offered_by = (String) gear[i].getSObject('Offered_By__r').get('Name');
        	gd.offered_date = (Date) gear[i].get('Offered_Date__c');
        	gd.item_status = (String) gear[i].get('Item_Status__c');
            rtr.add(gd);
        }
        System.debug('getGearBoxGearList: ' + rtr);
        return rtr;
    }
    
    public class GearData {
        @AuraEnabled public String id {get; set;} 
        @AuraEnabled public String category {get; set;}
        @AuraEnabled public String item {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public Boolean usrowinglogo {get; set;}
        @AuraEnabled public String offered_by {get; set;}
        @AuraEnabled public Date offered_date {get; set;}
        @AuraEnabled public String item_status {get; set;}
    }

}