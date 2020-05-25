public class mmillerCurrentDesignation {

    public string NameIn {get; set;}
    
    public string ContactIdIn {get; set;}
    public string RankIn {get; set;}
    public string RegionIn {get; set;}
    public string StateIn {get; set;}
    
    public string usercontactid {get; set;}
    public String username {get; set;}
    public string userrank {get; set;}
    public string userregion {get; set;}
    public string userstate {get; set;}
    
    public static String listsize {get; set;}
    
    public static List<Contact> contactdata {get; set;}
   
    
    public void selectContactsForDesignation() {
        //
        // THE FOLLOWING ARE ALTERNATE EXAMPLES USED TO SET PARAMS
        //string state1 = Apexpages.currentPage().getParameters().get('StateIn');
        //string state2 = system.CurrentPageReference().getParameters().get('StateIn');
        //
        System.debug('ContactIdIn ' + ContactIdIn);
        System.debug('RankIn ' + RankIn);
        System.debug('RegionIn ' + RegionIn);
        System.debug('StateIn ' + StateIn);
        if(!String.isEmpty(ContactIdIn)) {
	        mmillerCurrentDesignation.contactdata = [SELECT Id, Name, Referee_Rank__c, Region__c, MailingState FROM Contact WHERE Id =: contactIdIn];
            mmillerCurrentDesignation.listsize = String.valueOf(mmillerCurrentDesignation.contactdata.size());
            System.debug('contactlistsize(1) ' + listsize);
        } else {
            if(String.isEmpty(RankIn))
                RankIn = 'Candidate';
            if(String.isEmpty(RegionIn))
                RegionIn = '%';
            if(String.isEmpty(StateIn))
                StateIn = '%';
            mmillerCurrentDesignation.contactdata = [SELECT Id, Name, Referee_Rank__c, Region__c, MailingState FROM Contact 
                                              WHERE Referee_Rank__c =: RankIn AND Region__c LIKE :RegionIn AND MailingState LIKE :StateIn];
            mmillerCurrentDesignation.listsize = String.valueOf(mmillerCurrentDesignation.contactdata.size());
            System.debug('contactlistsize(2) ' + listsize);
        }
    }

    public void getUserName() {
        
        username = UserInfo.getName();
        string UserId = UserInfo.getUserId();
                
        //TEST 
        //UserId = '0056A000002Hx5HQAS';
        //System.debug('UserId ' + UserId);
        
        List<Contact> cont = [select name, Referee_Rank__c, Region__c, MailingState from contact where id in
			(select contactid from user where id =: UserId )];

        if(!cont.isEmpty()) {
            username = cont[0].Name;
        	userrank = cont[0].Referee_Rank__c;
        	userregion = cont[0].Region__c;
        	userstate = cont[0].MailingState;
        } else {
            userrank = 'Rank_NA';
        	userregion = 'Region_NA';
        	userstate = 'State_NA';
        }
    }

    public void initVariables() {
        System.debug('initVariables');
        ContactIdIn = '';
        RankIn = '';
        RegionIn = '';
        StateIn = '';
    }

    
    public PageReference PageReset() {
        
        System.debug('you are in doneReloadPage');
        //pageReference pg = new pageReference(ApexPages.currentPage().getURL());
        pageReference pg = new PageReference(System.currentPageReference().getURL());
        pg.setRedirect(TRUE);
        return pg;
        
    } 

    public void setState(String n) {
	        state = n;
    }
    public String getState() {
	        return state;
    }
     private String state = 'no';
}