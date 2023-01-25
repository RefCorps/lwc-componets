public class GearImportExport {

    /*
     * GearImportExport
     * This is an APEX controller created to support the Lightning Component Bundle GearImportExport
     *   Custom Code -> Lightning Components
     * The component GearImportExport is used in
     *   Apps -> App Manager -> RefCorps - Manage - Builder - Page - Gear Exchange - Page Variation - Gear Exchange Coordinator
     *   This page is only visible to the Referee Gear Coordinators audience.
     * NOTE:  @AuraEnabled allows the method to be accessed through a Lightning/Aura application
     * 
     *
     * Much of the code comes a post to 
     *   http://salesforcecodes.com/author/salesforce123/
     *   Import & Export data from CSV file using Lightning Component
     *   By SalesforceCodes | December 9, 2019 
     * The code in the post had to be modified to:   
     * 1.  Support our custom object GearExchangeWorkSheet   GearExchangeWorkSheet__c 
     * 2.  The code did not handle Strings surrounded with double quotes
     * 3.  The code did not handle embedded double quotes
     * 4.  The code did not handled embedded commas
     * 5.  The code did not attempt to validate data as CSV with required columns
     * 6.  The code did not perform an upsert
     * 7.  The code did not include a lightning spinner, alerts, or a modal 
     */

    /* For importing reading data into GearExchangeWorkSheet__c */
    @AuraEnabled
    public static string insertGearExchangeData(String strGearWS) {

        String returnresponse = '';
        boolean recordExists = false;

        try {

            if (strGearWS == null || strGearWS.length() < 4) {
                returnresponse = 'ERROR insertGearExchangeData : No input data found.';
                System.debug(LoggingLevel.ERROR, returnresponse);
                return returnresponse;
            }

            List < GearExchangeWorkSheet__c > GearExchangeWorkSheet = new List < GearExchangeWorkSheet__c > ();

            //system.debug(LoggingLevel.DEBUG,'strGearWS = ' + strGearWS);
            List < fieldWrapper > datalist = (List < fieldWrapper > ) JSON.deserialize(strGearWS, List < fieldWrapper > .class);

            //system.debug(LoggingLevel.DEBUG,'datalist = ' + datalist);
            for (fieldWrapper wrapper: datalist) {

                GearExchangeWorkSheet__c gear = new GearExchangeWorkSheet__c();

                if (wrapper.Item_Num == null || wrapper.Item_Num.isWhitespace()) {
                    returnresponse = 'ERROR insertGearExchangeData : Item Num missing from data.';
                    System.debug(LoggingLevel.ERROR, returnresponse);
                    return returnresponse;
                } else {
                    // Check to see if Item_Num exists - if present we'll do an upsert otherwise we'll insert
                    String searchquery = 'SELECT Item_Num__c, Name FROM GearExchangeWorksheet__c WHERE Item_Num__c = \'' + wrapper.Item_Num + '\'';
                    List < GearExchangeWorkSheet__c > itemlist = Database.query(searchquery);
                    if (itemlist.size() > 0) {
                        //String itemName = (String)itemlist[0].getSObject('GearExchangeWorkSheet__c').get('NAME');
                        system.debug(LoggingLevel.DEBUG, 'GearExchangeWorkSheet returned a row - setting recordExists true');
                        gear = itemlist[0]; //.getSObject('GearExchangeWorkSheet__c');
                        recordExists = true;
                    }
                }

                // The following validates/reformats value prior to load
                Integer intItem_Num = Integer.valueOf(wrapper.Item_Num);
                gear.Item_Num__c = wrapper.Item_Num;

                if (wrapper.Date_Recd != null && wrapper.Date_Recd.length() > 6) {
                    Date dtDate_Recd = Date.parse(wrapper.Date_Recd);
                    gear.Date_Recd__c = dtDate_Recd;
                } else {
                    gear.Date_Recd__c = NULL;
                }

                gear.Category__c = wrapper.Category;
                gear.Item__c = wrapper.Item;

                String Price = '';
                if (wrapper.Price == null)
                    Price = '0.00';
                else if (!wrapper.Price.isNumeric())
                    Price = '0.00';
                else if (!Price.contains('.'))
                    Price = Price + '.00';
                else
                    Price = wrapper.Price;
                Decimal currencyPrice = Decimal.valueOf(Price);
                gear.Price__c = currencyPrice;

                gear.Size__c = wrapper.Size;
                gear.Gender__c = wrapper.Gender;
                gear.Color__c = wrapper.Color;
                gear.Notes__c = wrapper.Notes;
                gear.Donated_by__c = wrapper.Donated_by;
                gear.Received_by__c = wrapper.Received_by;
                gear.Located_at__c = wrapper.Located_at;

                String Value = '';
                if (wrapper.Value == null)
                    Value = '0.00';
                else if (!wrapper.Value.isNumeric())
                    Value = '0.00';
                else if (!wrapper.Value.contains('.'))
                    Value = wrapper.Value + '.00';
                else
                    Value = wrapper.Value;
                Decimal currencyValue = Decimal.valueOf(Value);
                gear.Value__c = currencyValue;

                gear.Distributed_To__c = wrapper.Distributed_To;

                if (wrapper.Distribution_Date != null & wrapper.Distribution_Date.length() > 6) {
                    Date dtDistribution_Date = Date.parse(wrapper.Distribution_Date);
                    gear.Distribution_Date__c = dtDistribution_Date;
                } else {
                    gear.Distribution_Date__c = NULL;
                }

                gear.Distributed_By__c = wrapper.Distributed_By;
                gear.Distribution_Location__c = wrapper.Distribution_Location;

                if (wrapper.Thanks_Sent_Date != null && wrapper.Thanks_Sent_Date.length() > 6) {
                    Date dtThanks_Sent_Date = Date.parse(wrapper.Thanks_Sent_Date);
                    gear.Thanks_Sent_Date__c = dtThanks_Sent_Date;
                } else {
                    gear.Thanks_Sent_Date__c = NULL;
                }

                //gear.DisplayOnList__c = true; // wrapper.DisplayOnList;
                if( wrapper.DisplayOnList != null && (wrapper.DisplayOnList.containsIgnoreCase('FALSE') || wrapper.DisplayOnList.containsIgnoreCase('NO')))
                { 
                    gear.DisplayOnList__c = false; 
                }
                else {
                    gear.DisplayOnList__c = true;
                }

                GearExchangeWorkSheet.add(gear);

            }

            if (GearExchangeWorkSheet.size() > 0) {
   
                if (!recordExists)
                    insert GearExchangeWorkSheet;
                else
                    upsert GearExchangeWorkSheet;
                returnresponse = 'SUCCESS';
            }
 
        } catch (Exception ex) {
            returnresponse = 'ERROR insertGearExchangeData :' + ex.getMessage();
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }

        return returnresponse;
    }

    // These are the expect column headers - they should be the data keys in the JSON Object
    public class fieldWrapper {
        public String Item_Num; // Item_Num__c Text(25)  (External ID) (Unique Case Insensitive)
        public String Date_Recd; // Date_Recd__c Date
        public String Category; // Category__c Picklist
        public String Item; // Item__c Text(255)
        public String Price; // Price__c Currency(16, 2)
        public String Size; // Size__c Text(255)
        public String Gender; // Gender__c Text(255)
        public String Color; // Color__c Text(255)
        public String Notes; // Notes__c Long Text Area(1000)
        public String Donated_by; // Donated_by__c Text(255)
        public String Received_by; // Received_by__c Text(255)
        public String Located_at; // Located_at__c Text(255)
        public String Value; // Value__c Currency(16, 2)
        public String Distributed_To; // Distributed_To__c Text(255)
        public String Distribution_Date; // Distribution_Date__c Date
        public String Distributed_By; // Distributed_By__c Text(255)
        public String Distribution_Location; // Distribution_Location__c Text(255)
        public String Thanks_Sent_Date; // Thanks_Sent_Date__c Date
        public String DisplayOnList; // DisplayOnList__c Checkbox 
    }

    /* Select data for export into a CSV file  */
    @AuraEnabled
    public static list < GearExchangeWorkSheet__c > fetchGearExchangeData() {
        //system.debug(LoggingLevel.DEBUG,'GearImportExport fetchGearExchangeData >> start');
        List < GearExchangeWorkSheet__c > returnConList = new List < GearExchangeWorkSheet__c > ();
        for (GearExchangeWorkSheet__c con: [SELECT Item_Num__c, Date_Recd__c, Category__c, Item__c, Price__c, Size__c,
                Gender__c, Color__c, Notes__c, Donated_by__c, Received_by__c, Located_at__c,
                Value__c, Distributed_To__c, Distribution_Date__c, Distributed_By__c,
                Distribution_Location__c, Thanks_Sent_Date__c, DisplayOnList__c FROM GearExchangeWorksheet__c
            ]) {
            // TEST - WHERE Item_Num__c in ('35','38')]) {
            returnConList.add(con);
        }
        //system.debug(LoggingLevel.DEBUG,'GearImportExport fetchGearExchangeData data rows ' + returnConList.size());
        return returnConList;
    }

    @AuraEnabled
    public static String GearExchangeEmailTo() {
        String emailTo1 = '';
        // OPTION 1 STATIC RESOURCE
        try {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'GearExchangeEmailTo' LIMIT 1];
		    emailTo1 = sr.Body.toString();
        } catch (Exception err) {
            emailTo1 = 'doug.jones@usrowing.org';
        }
		System.debug(LoggingLevel.DEBUG, '1 Returning: ' + emailTo1);
        //
        // OPTION 3 - PUBLIC GROUP 
        /*
        String emailTo = '';
        Group grp = [SELECT Id FROM Group where name = 'Referee Gear Coordinators' LIMIT 1];
        GroupMember[] gmlist = [Select UserOrGroupId FROM GroupMember where GroupId =: grp.Id]; 
        List<String> IdList= new List<String>();
        for(GroupMember gm : gmlist) {
            IdList.add('\'' + gm.UserOrGroupId + '\'');
        }
        String searchquery = 'Select email, name, id, Address from User WHERE Id in ' + IdList;
        System.debug(LoggingLevel.DEBUG, searchquery);
        User[] usr = Database.query(searchquery);
        for(User u : usr) {
            System.debug(LoggingLevel.DEBUG, 'user: ' + u.name + ' email: ' + u.email + ' Address: ' + u.Address );
            emailTo = String.isBlank(emailTo) ? u.email : emailTo + ';' + u.email;
         }
		System.debug(LoggingLevel.DEBUG, '2 Returning: ' + emailTo1);
        */
        return emailTo1;
        
    }
    
}