/*
    THIS IS AN APEX CLASS THAT YOU CAN RUN AS ANONYMOUS APEX
    TO RUN YOU'LL PASTE THE CODE THAT APPEARS HERE INTO DEVELOPER CONSOLE -> DEBUG -> OPEN EXECUTE ANONYMOUS WINDOW
*/

public with sharing class CrossCheckUserContactController {

    public static List<String> Results = new List<String>();

    public static List<String> TextResults {
        get{return Results;}  
        set;
    }
    
    public static String TextLines { 
        get; 
        set;
    }

    @AuraEnabled
    @future
    public static void generateCrossCheckUserContactResults() {

    // ----------------------------------------------------------------------------
    // REGEXP PATTERNS
    // #region regexp_patterns
    String A2States = '^(AK|AL|AR|AZ|CA|CO|CT|DC|DE|FL|GA|HI|IA|ID|IL|IN|KS|KY|LA|MA|MD|ME|MI|MN|MO|MS|MT|NC|ND|NE|NH|NJ|NM|NV|NY|OH|OK|OR|PA|PR|RI|SC|SD|TN|TX |UT|VA|VI|VT|WA|WI|WV|WY)$';
    String States = '^(Alabama|Alaska|Arizona|Arkansas|California|Colorado|Connecticut|Delaware|Florida|Georgia|Hawaii|Idaho|Illinois|Indiana|Iowa|Kansas|Kentucky|Louisiana|Maine|Maryland|Massachusetts|Michigan|Minnesota|Mississippi|Missouri|Montana|Nebraska|Nevada|New Hampshire|New Jersey|NewMexico|New York|North Carolina|North Dakota|Ohio|Oklahoma|Oregon|Pennsylvania|Rhode Island|South Carolina|South Dakota|Tennessee|Texas|Utah|Vermont|Virginia|Washington|West Virginia|Wisconsin|Wyoming)$';

    // 12345 | 12345-1234 | 123456789 
    Pattern zipPattern = Pattern.compile('(^\\d{5}$)|(^\\d{9}$)|(^\\d{5}-\\d{4}$)');

    // 1234567890 | 1123456789 | +1123456789 | 1.123.456.789 | 123.456.7890 | 123-456-789 | (123) 456-7890
    Pattern phPattern = Pattern.compile('\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*');

    // name@domain.topleveldomain 
    Pattern emPattern = Pattern.compile('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$');

    // Used to remove non numeric chars from phone number
    String replNonNum = '[^0-9]';
    String replCRNLTAB = '[\\r\\n\\t]';

    Boolean Cleanup = true;

    String Debug = 'DEBUG';
    String Info = 'INFO';
    String Error = 'ERROR';


    // #endregion
    // ----------------------------------------------------------------------------

    // HOLD CURRENT USER RECORD - USE IN EXCEPTION
    User userInProg = new User();

    // COUNTERS
    // #region counters
    Integer UserAddressNull = 0;
    Integer ContactAddressNull = 0;
    Integer UserContactAddressNull = 0;

    Integer NameMismatch = 0;
    Integer StreetMismatch = 0;
    Integer CityMismatch = 0;
    Integer StateMismatch = 0;

    Integer UserStreetNull = 0;
    Integer ContactStreetNull = 0;

    Integer UserStateInvalid = 0;
    Integer UserStateNull = 0;

    Integer ContactStateInvalid = 0;
    Integer ContactStateNull = 0;

    Integer ZipMismatch = 0;
    Integer UserZipMalFormed = 0;
    Integer UserZipNull = 0;
    Integer ContactZipMalformed = 0;
    Integer ContactZipNull = 0;

    Integer EmailMismatch = 0;
    Integer InvalidUserEmail = 0;
    Integer InvalidContactEmail = 0;

    Integer PhoneMismatch = 0;
    Integer LicMismatch = 0;

    Integer RankMismatch = 0;

    Integer RegionMismatch = 0;
    Integer UserRegionInvalid = 0;
    Integer ContactRegionInvalid = 0;

    // #endregion
    // ----------------------------------------------------------------------------

    try {

        // ----------------------------------------------------------------------------
        // SELECT DATA FROM USER AND CONTACT
        // #region SOQL
        //String refid = '1336';
        //String refid = '943';
        String refid = '1121';
        String contactId = '0036A00000peZMgQAM';
        
        String userQuery = 'Select ContactId, Name, Address, Email, Gender__c, Phone, Referee_License__c, User_Referee_Rank__c, User_Region__c,  ';
        userQuery = userQuery + 'Contact.Name, Contact.MailingAddress, Contact.Email, Contact.Phone, Contact.HomePhone, Contact.MobilePhone, Contact.Referee_License_Number__c, Contact.Referee_Rank__c, Contact.Region__c ';
        userQuery = userQuery + 'from User  ';
        userQuery = userQuery + 'where IsActive = TRUE and User_Referee_Rank__c != null  ';
        //userQuery = userQuery + 'and USER_REFEREE_RANK__C  in (\'Assistant\', \'Referee\', \'Candidate\' )';
        //userQuery = userQuery + 'and USER_REFEREE_RANK__C  in (\'Assistant\', \'Referee\' )';
        userQuery = userQuery + 'and USER_REFEREE_RANK__C  in (\'Referee\' )';
        //userQuery = userQuery + 'and Referee_License__c =: refid ';
        //userQuery = userQuery + 'and ContactId =: contactId ';
        userQuery = userQuery + 'and Referee_License__c != null  ';
        userQuery = userQuery + 'Order by User_Referee_Rank__c, Name '; 
        //userQuery = userQuery + 'limit 3 ' ;

    System.debug(LoggingLevel.Debug, '\n' + userQuery + '\n');
        List < User > ul = Database.query(userQuery);
        
        // #endregion

        // ----------------------------------------------------------------------------
        // PROCESS QUERY RESULT
        if (ul.size() > 0) {

        //AppLog(Debug, 'User records count ' + ul.size());

            for (User u: ul) {
                
                Integer errs = 0; 

                userInProg = u;

                Boolean validUserState = false;
                Boolean validContactState = false;

            String cID = u.ContactID;
            String uID = u.ID;    

            //AppLog(Debug,'-------------------------------------------------------------------------');
            //AppLog(Debug, 'User Name: ' + u.Name + '\tRank: ' + u.User_Referee_Rank__c + '\tContactId: ' + cId);
            
            cID = u.Name + ' | ' +  u.User_Referee_Rank__c + ' | ' + cId;    

                // ---------------------------------------------------------------------------
                // NAME CHECK
                // #region name_check
                if (!MatchNames(Cleanup, u.Name, u.Contact.Name )) {
                AppLog(Debug, cID + ' | NM | \tUser Name: ' + u.Name + '\tContact Name: ' +  u.Contact.Name);
                    NameMismatch++;
                    errs++;
                }
                // #endregion

                Boolean UserAddressIsNull = true;
                String userStreet = '';
                String userCity = '';
                String userState = '';
                Boolean InvalidUserState = true;
                String userZip = '';
                
                String userRegionByState = '';

                Boolean ContactAddressIsNull = true;
                String contactStreet = '';
                String contactCity = '';
                String contactState = '';
                Boolean InvalidContactState = true;
                String contactZip = '';
            
                String contactRegionByState = '';
            

                // ---------------------------------------------------------------------------
                // ADDERSS CHECKS

                if(u.Address != null) {
                    UserAddressIsNull = false;
                    //System.debug(Debug,' ... u.Address ' + 
                    //    u.Address.getStreet() + '\t' + 
                    //    u.Address.getCity() + '\t' + 
                    //    u.Address.getState() );

                    // NORMALIZE STREET
                    if(String.isNotBlank(u.Address.getStreet()) )
                        userStreet = NormalizeStreet(Cleanup, u.Address.getStreet().normalizeSpace());
                    else {
                        userStreet = 'UserStreetUNK';
                        UserStreetNull++;
                    }

                    // VALIDATE STATE
                    if( u.Address.getState() == null  ) {
                        userState = 'UST';
                        UserStateNull++;
                    }
                    else {   
                        userState =  StateA2( Cleanup, u.Address.getState().normalizespace() );
                    }

                    // VALIDATE ZIP
                    
                    if(u.Address.getPostalCode() == null) {
                        userZip = 'uZip';
                        UserZipNull++;
                    } else    
                        userZip = zipPattern.matcher(userZip).matches() ? u.Address.getPostalCode().Left(5) : 'Invalid ' ;

                    // LOOKUP REGION
                    if(A2States.contains(userState)) {
                        userRegionByState = LookupStateRegion(userState);
                    }
                }    

                if(u.Contact.MailingAddress != null) {
                    ContactAddressIsNull = false;
                    //System.debug(Debug,' ... u.Contact.MailingAddress ' + 
                    //    u.Contact.MailingAddress.getStreet() + '\t' + 
                    //    u.Contact.MailingAddress.getCity() + '\t' + 
                    //    u.Contact.MailingAddress.getState());
                    
                    // NORMALIZE STREET
                    if(String.isNotBlank(u.Contact.MailingAddress.getStreet()) )
                        contactStreet =  NormalizeStreet(Cleanup, u.Contact.MailingAddress.getStreet().normalizeSpace());
                    else {
                        contactStreet = 'ContactStreetUNK';
                        ContactStreetNull++;
                    }
        
                    // VALID STATE
                    if( u.Contact.MailingAddress.getState() == null  ) {
                        contactState = 'CST';
                        ContactStateNull++;
                    }
                    else {   
                        contactState =  StateA2(Cleanup, u.Contact.MailingAddress.getState().normalizespace() );
                    }

                    // VALID ZIP
                    
                    if(u.Contact.MailingAddress.getPostalCode() == null) {
                        ContactZipNull++;
                        contactZip = 'cZip';
                    } else    
                        contactZip = zipPattern.matcher(contactZip).matches() ? u.Contact.MailingAddress.getPostalCode().Left(5) : 'Invalid ' ;

                    // LOOKUP REGION
                    if(A2States.contains(contactState)) {
                        contactRegionByState = LookupStateRegion(contactState);
                    }
                }    

    // ===================================================================================

                if(ContactAddressIsNull) {
                    String uAddressStreet = u.Address.getStreet() != null ? u.Address.getStreet().ReplaceAll(replCRNLTAB,'') : 'NullContactStreet';
                    String uAddressCity = u.Address.getCity() != null ? u.Address.getCity() : 'NullContactCity'; 
                    String uAddressState = u.Address.getState() != null ? u.Address.getState() : 'NullContactState'; 
                	AppLog(Debug, cID + ' | UAN | \t** User Address Is Null - Validating Contact MailingAddress: ' + 
                        uAddressStreet  + ' ' + 
                        uAddressCity + ' ' + 
                        uAddressState + 
                        ' [' + u.User_Region__c + ']');
                    errs++;
                }
                else if(UserAddressIsNull) {
                    
                    String cAddressStreet = u.Contact.MailingAddress.getStreet() != null ? u.Contact.MailingAddress.getStreet().ReplaceAll(replCRNLTAB,'') : 'NullContactStreet';
                    String cAddressCity = u.Contact.MailingAddress.getCity() != null ? u.Contact.MailingAddress.getCity() : 'NullContactCity'; 
                    String cAddressState = u.Contact.MailingAddress.getState() != null ? u.Contact.MailingAddress.getState() : 'NullContactState'; 
                	AppLog(Debug, cID + ' | UAN | \t** User Address Is Null - Validating Contact MailingAddress: ' + 
                        cAddressStreet  + ' ' + 
                        cAddressCity + ' ' + 
                        cAddressState + 
                        ' [' + u.Contact.Region__c + ']');
                    errs++;
                } else {

                    if(!userStreet.Equals(contactStreet)) {
                        String uAddressStreet =  u.Address.getStreet() != null ? u.Address.getStreet().ReplaceAll(replCRNLTAB,'') : 'NullUserStreet';
                        String cAddressStreet = u.Contact.MailingAddress.getStreet() != null ? u.Contact.MailingAddress.getStreet().ReplaceAll(replCRNLTAB,'') : 'NullContactStreet';
                    AppLog(Debug, cID + ' | AM | \tMismatch User Street: [' + uAddressStreet + ']\t Contact Street: [' + cAddressStreet + ']');
                        StreetMismatch++;
                        errs++;
                    }

                    if(!userCity.Equals(contactCity)) {
                    AppLog(Debug, cID + ' | CM | \tMismatch User City: [' + u.Address.getCity() + ']\t Contact City: [' + u.Contact.MailingAddress.getCity() + ']');
                        CityMismatch++;
                        errs++;
                    }

                    if(!userState.Equals(contactState)) {
                    AppLog(Debug, cID + ' | SM | \tMismatch User State: [' + u.Address.getState() + ']\t Contact State: [' + u.Contact.MailingAddress.getState() + ']');
                        StateMismatch++;
                        errs++;
                    }

                    // MATCH ZIP - FOR NOW REMOVE ZIP+4 -- NOTE THE +4 VALUE COULD BE INVALID
                    if (!userZip.Left(5).Equals(contactZip.Left(5))) {
                        AppLog(Debug, cID + ' | ZM | \tUser Zip: [' + userZip + ']\tContact Zip: [' + contactZip + ']');
                            ZipMismatch++;
                        errs++;
                        }
                    }    

            // ===================================================================================

                // ---------------------------------------------------------------------------
                // EMAIL CHECK
                // #region email_check
                String userEmail = String.isNotBlank(u.Email) ? u.Email.Replace('.invalid', '') : 'XXX';
                String contactEmail = String.isNotBlank(u.Contact.Email) ? u.Contact.Email :'ZZZ';
                Boolean okUserEmail = emPattern.matcher(userEmail).matches();
                Boolean okContactEmail = emPattern.matcher(contactEmail).matches();
                if(!okUserEmail) {
                AppLog(Debug, cID + ' | UEI | \tInvalid User Email: [' + userEmail + ']\tContact Email: [' + contactEmail + ']');
                    InvalidUserEmail++;
                    errs++;
                }
                else if(!okContactEmail) {
                AppLog(Debug, cID + ' | CEI | \tUser Email: [' + userEmail + ']\tInvalid Contact Email: [' + contactEmail + ']');
                    InvalidContactEmail++;
                    errs++;
                }
                else if (!userEmail.Equals(contactEmail)) {
                AppLog(Debug, cID + ' | EMM | \tMismatch User Email: [' + userEmail + ']\tContact Email: [' + contactEmail + ']');
                    EmailMismatch++;
                    errs++;
                }
                // #endregion

                // ---------------------------------------------------------------------------
                // PHONE CHECK
                // #region phone_check
                String uPhone = String.isNotBlank(u.Phone) ? u.PHone : 'NOPHONEU';

                // String cPhone =  'NOPHONEC'; // u.Contact.Phone != null && String.isNotBlank(u.Contact.Phone) ? u.Contact.PHone : 'NOPHONEC';
                String cPhone =  String.isNotBlank(u.Contact.Phone) ? u.Contact.PHone : 'NOPHONEC';
                String cHPhone = String.isNotBlank(u.Contact.HomePhone) ? u.Contact.HomePHone : 'NOPHONEH';
                String cMPhone = String.isNotBlank(u.Contact.MobilePhone) ? u.Contact.MobilePHone : 'NOPHONEM';

                if(!cMPhone.Equals('NOPHONEM'))
                    cPhone = cMPhone;    
                else if(!cHPhone.Equals('NOPHONEH'))
                    cPhone = cHPhone;

                String uphCk = phPattern.matcher(uPhone).matches() ? 'Valid ' : 'Invalid ' ;
                String cphCk = phPattern.matcher(cPhone).matches() ? 'Valid ' : 'Invalid ' ;
                String uXPhone = uPhone.replaceAll(replNonNum, '').right(10); // normalize ph number
                String chXPhone = cHPhone.replaceAll(replNonNum, '').right(10); // normalize ph number
                String cmXphone = cMPhone.replaceAll(replNonNum, '').right(10);
                if(  !UserAddressIsNull && !ContactAddressIsNull &&
                    (!uXPhone.Equals(chXPhone) && !uXPhone.Equals(cmXphone)) 
                ) {   
                AppLog(Debug, cID + ' | PM | \tMismatch ' +  uphCk + 'User Phone: [' + u.Phone + ']\t' + cphCk + 'Contact Phone: [' + cMPhone + ']\t[' +  cHPhone + ']');
                    PhoneMismatch++;
                    errs++;
                }
                // #endregion
                
                // ---------------------------------------------------------------------------
                // LICENSE MISMATCH
                // #region license_mismatch

                if (!u.Referee_License__c.Equals(u.Contact.Referee_License_Number__c)) {
                AppLog(Debug, cID + ' | LM | \tMismatch User Lic: [' + u.Referee_License__c + ']\tContact Lic: [' + u.Contact.Referee_License_Number__c + ']');
                    LicMismatch++;
                    errs++;
                }

                // #endregion
                
                // ---------------------------------------------------------------------------
                // RANK MISMATCH
                // #region rank_mismatch
                if (!u.User_Referee_Rank__c.Equals(u.Contact.Referee_Rank__c)) {
                AppLog(Debug, cID + ' | RKM | \tMismatch User Rank: [' + u.User_Referee_Rank__c + ']\tContact Rank: [' + u.Contact.Referee_Rank__c + ']');
                    LicMismatch++;
                    errs++;
                }
                // #endregion
                
                // ------------------------------------    
                // REGION CHECKS
                // #region ref_region_checks

                String uRegion = u.User_Region__c != null ? u.User_Region__c : 'USERREGIONUNK';
                String cRegion = u.Contact.Region__c != null ? u.Contact.Region__c : 'CONTACTREGIONUNK';

                // ------------------------------------ 
                // VALIDATE USER REGION BY USER STATE
                // #region region_user_state
                if (!uRegion.Equals(userRegionByState) ) 
                {
                AppLog(Debug, cID + ' | RM | \tUser region lookup by state [' + userState + ']\tLookup value: [' + userRegionByState + '] <> Contact State: [' + contactState + ']\tContact Region: ' + uRegion + ']');
                    UserRegionInvalid++;
                    errs++;
                }
                // #endregion

                // ------------------------------------ 
                // VALIDATE CONTACT REGION BY CONTACT STATE
                // #region region_contact_state
                if (!cRegion.Equals(contactRegionByState)) {
                AppLog(Debug, cID + ' | CRM | \tContact region lookup by state [' + contactState + ']\tLookup value: [' + contactRegionByState + '] <> User State: [' + userState + ']\tUser Region: [' + uRegion + ']');
                    ContactRegionInvalid++;
                    errs++;
                }
                // #endregion
                
                // ------------------------------------ 
                // COMPARE USER REGION TO CONTACT REGION   
                // #region ref_region
                if (!uRegion.Equals(cRegion)) {
                AppLog(Debug, cID + ' | URM | \tMismatch: User Region: [' + uRegion + ']\tContact Region: [' + cRegion + ']');
                    RegionMismatch++;
                    errs++;
                }
                // #endregion
                // ------------------------------------    

                // #endregion    

                if(errs > 0)
            	AppLog(Debug,'-------------------------------------------------------------------------');
            } // END LOOP

            // #region display_counters
            AppLog(Debug,'\tNA UserContactAddressNull = ' + UserContactAddressNull);
            AppLog(Debug,'\tNCA ContactAddressNull = ' + ContactAddressNull);
            AppLog(Debug,'\tNUA UserAddressNull = ' + UserAddressNull);
            AppLog(Debug,'\tMC CityMismatch = ' + CityMismatch);
            AppLog(Debug,'\tIUE InvalidUserEmail = ' + InvalidUserEmail);
            AppLog(Debug,'\tICE InvalidContactEmail = ' + InvalidContactEmail);
            AppLog(Debug,'\tME EmailMismatch = ' + EmailMismatch);
            AppLog(Debug,'\tML LicMismatch = ' + LicMismatch);
            AppLog(Debug,'\tMN NameMismatch = ' + NameMismatch);
            AppLog(Debug,'\tNP PhoneMismatch = ' + PhoneMismatch);
            AppLog(Debug,'\tNRK RankMismatch = ' + RankMismatch);
            AppLog(Debug,'\tICR ContactRegionInvalid = ' + ContactRegionInvalid);
            AppLog(Debug,'\tIUR UserRegionInvalid = ' + UserRegionInvalid);
            AppLog(Debug,'\tMR RegionMismatch = ' + RegionMismatch);
            AppLog(Debug,'\tICS ContactStateInvalid = ' + ContactStateInvalid);
            AppLog(Debug,'\tIUS UserStateInvalid = ' + UserStateInvalid);
            AppLog(Debug,'\tMS StateMismatch = ' + StateMismatch);
            AppLog(Debug,'\tNUS UserStateNull = ' + UserStateNull);
            AppLog(Debug,'\tNCS ContactStateNull = ' + ContactStateNull);
            AppLog(Debug,'\tMST StreetMismatch = ' + StreetMismatch);
            AppLog(Debug,'\tNCST ContactStreetNull = ' + ContactStreetNull);
            AppLog(Debug,'\tNUS UserStreetNull = ' + UserStreetNull);
            AppLog(Debug,'\tICZ ContactZipMalFormed = ' + ContactZipMalFormed);
            AppLog(Debug,'\tIUZ UserZipMalFormed = ' + UserZipMalFormed);
            AppLog(Debug,'\tMZ ZipMismatch = ' + ZipMismatch);
            AppLog(Debug,'\tNCZ ContactZipNull = ' + ContactZipNull);
            AppLog(Debug,'\tNUZ UserZipNull = ' + UserZipNull);

            // #endregion


        } // IF DATA

    } catch (Exception err) {
    AppLog(Error, 'CrossCheckUserContact error: ' + err.getCause());
    AppLog(ERROR, err.getMessage());
    AppLog(ERROR, err.getStackTraceString());
    // AppLog(Error, userInProg);
        
    }

    System.debug(' !!! TextLines count = ' + Results.size() );
    TextLines = '';
    Integer ctr = 0;
    for(String textrow : TextResults) {
        ctr++;
        TextLines = TextLines + ctr + ' | ' + textrow + '\n';
    }


    }  // END generateCrossCheckUserContactResults

    public static String NormalizeStreet(Boolean DoIt, String street) {

        if(!DoIt)
            return street;

        street = street.normalizeSpace().toUpperCase();

        street = street.ReplaceAll('NORTH','N');
        street = street.ReplaceAll('SOUTH','S');
        street = street.ReplaceAll('EAST','E');
        street = street.ReplaceAll('WEST','W');
        street = street.ReplaceAll('NORTHEAST','NE');
        street = street.ReplaceAll('NORTHWEST','NW');
        street = street.ReplaceAll('SOUTHEAST','SE');
        street = street.ReplaceAll('SOUTHWEST','SW');

        // SOURCE: https://pe.usps.com/text/pub28/28apc_002.htm
        street = street.ReplaceAll('AVENUE','AVE');
        street = street.ReplaceAll('BOULEVARD','BLVD');
        street = street.ReplaceAll('BYPASS','BYP');
        street = street.ReplaceAll('CIRCLE','CIR');
        street = street.ReplaceAll('COURT','CT');
        street = street.ReplaceAll('CROSSING','XING'); 
        street = street.ReplaceAll('DRIVE','DR');
        street = street.ReplaceAll('EXPRESSWAY','EXPY');
        street = street.ReplaceAll('FREEWAY','FWY');
        street = street.ReplaceAll('GLEN','GLN');
        street = street.ReplaceAll('HIGHWAY','HWY');
        street = street.ReplaceAll('LANE','LN');
        street = street.ReplaceAll('MEADOW','MDW');
        street = street.ReplaceAll('MOUNT','MT');
        street = street.ReplaceAll('PARKWAY','PKWY');
        street = street.ReplaceAll('PLACE','PL');
        street = street.ReplaceAll('PLAZA','PLZ');
        street = street.ReplaceAll('ROAD','RD');
        street = street.ReplaceAll('STREET','ST');
        street = street.ReplaceAll('SUITE','STE');
        street = street.ReplaceAll('THROUGHWAY','TRWY');
        street = street.ReplaceAll('TRAIL','TRL');
        street = street.ReplaceAll('TURNPIKE','TPKE');
        street = street.ReplaceAll('VALLEY','VLY');
        street = street.ReplaceAll('VIEW','VW');

        street = street.ReplaceAll('APARTMENT','APT');
        street = street.ReplaceAll('BUILDING','BLDG');
        street = street.ReplaceAll('FLOOR','FL');
        street = street.ReplaceAll('TRAILER','TRLR');
        street = street.ReplaceAll('UNIT','UNIT');

        street = street.ReplaceAll('\\.','');
        street = street.ReplaceAll(',','');
        street = street.ReplaceAll('\\t','');
        street = street.ReplaceAll('\\n','');

        System.debug(LoggingLevel.DEBUG,street);

        return street;
    }

    public static Boolean MatchNames(Boolean DoIt, String name1, String Name2) {
        if(!DoIt)
            return name1.Equals(name2);    
        name1 = name1.toUpperCase().ReplaceAll('[^A-Z]','');
        name2 = name2.toUpperCase().ReplaceAll('[^A-Z]','');
        return name1.Equals(name2);
    }


    public static Boolean MatchCities(Boolean DoIt, String city1, String city2) {
        if(!DoIt)
            return city1.Equals(city2);    
        city1 = city1.toUpperCase().ReplaceAll('[^A-Z]','');
        city2 = city2.toUpperCase().ReplaceAll('[^A-Z]','');
        return city1.Equals(city2);
    }

    public static String StateA2(Boolean DoIt, String state) {

        if(!DoIt)
            return state;

        string rtr = state;
        state = state.toUpperCase().normalizeSpace();

        switch on state {
            // #region 
            when  'ALABAMA' { rtr = 'AL'; }
            when  'ALASKA' { rtr = 'AK'; }
            when  'ARIZONA' { rtr = 'AZ'; }
            when  'ARKANSAS' { rtr = 'AR'; }
            when  'CALIFORNIA' { rtr = 'CA'; }
            when  'COLORADO' { rtr = 'CO'; }
            when  'CONNECTICUT' { rtr = 'CT'; }
            when  'DELAWARE' { rtr = 'DE'; }
            when  'DISTRICT OF COLUMBIA' { rtr = 'DC'; }
            when  'FLORIDA' { rtr = 'FL'; }
            when  'GEORGIA' { rtr = 'GA'; }
            when  'HAWAII' { rtr = 'HI'; }
            when  'IDAHO' { rtr = 'ID'; }
            when  'ILLINOIS' { rtr = 'IL'; }
            when  'INDIANA' { rtr = 'IN'; }
            when  'IOWA' { rtr = 'IA'; }
            when  'KANSAS' { rtr = 'KS'; }
            when  'KENTUCKY' { rtr = 'KY'; }
            when  'LOUISIANA' { rtr = 'LA'; }
            when  'MAINE' { rtr = 'ME'; }
            when  'MARYLAND' { rtr = 'MD'; }
            when  'MASSACHUSETTS' { rtr = 'MA'; }
            when  'MICHIGAN' { rtr = 'MI'; }
            when  'MINNESOTA' { rtr = 'MN'; }
            when  'MISSISSIPPI' { rtr = 'MS'; }
            when  'MISSOURI' { rtr = 'MO'; }
            when  'MONTANA' { rtr = 'MT'; }
            when  'NEBRASKA' { rtr = 'NE'; }
            when  'NEVADA' { rtr = 'NV'; }
            when  'NEW HAMPSHIRE' { rtr = 'NH'; }
            when  'NEW JERSEY' { rtr = 'NJ'; }
            when  'NEW MEXICO' { rtr = 'NM'; }
            when  'NEW YORK' { rtr = 'NY'; }
            when  'NORTH CAROLINA' { rtr = 'NC'; }
            when  'NORTH DAKOTA' { rtr = 'ND'; }
            when  'OHIO' { rtr = 'OH'; }
            when  'OKLAHOMA' { rtr = 'OK'; }
            when  'OREGON' { rtr = 'OR'; }
            when  'PENNSYLVANIA' { rtr = 'PA'; }
            when  'PUERTO RICO' { rtr = 'PR'; }
            when  'RHODE ISLAND' { rtr = 'RI'; }
            when  'SOUTH CAROLINA' { rtr = 'SC'; }
            when  'SOUTH DAKOTA' { rtr = 'SD'; }
            when  'TENNESSEE' { rtr = 'TN'; }
            when  'TEXAS' { rtr = 'TX'; }
            when  'U.S. VIRGIN ISLANDS' { rtr = 'VI'; }
            when  'UTAH' { rtr = 'UT'; }
            when  'VANCOVER' { rtr = 'VC'; }
            when  'VERMONT' { rtr = 'VT'; }
            when  'VIRGINIA' { rtr = 'VA'; }
            when  'WASHINGTON' { rtr = 'WA'; }
            when  'WEST VIRGINIA' { rtr = 'WV'; }
            when  'WISCONSIN' { rtr = 'WI'; }
            when  'WYOMING' { rtr = 'WY'; }
        
            // #endregion
        }

        return rtr;
    }

    public static String LookupStateRegion(String state) {

        state =  state.length() > 2 ? StateA2(true, state) : state.toUpperCase();

        String MA = 'DE|DC|MD|NJ|PA|VA|WV';
        String MW = 'IL|IN||IA|KS|MI|MN|MO|NE|ND|OH|OK|SD|WI';
        String NE = 'CT|ME|MA|NH|NY|RI|VT';
        String NW = 'AK|ID|MT|OR|VC|WA|WY';
        String SE = 'AL|AR|FL|GA|KY|LA|MS|NC|PR|SC|TN|TX||VI';
        String SW = 'AZ|CA|CO|HI|NV|NM|UT';

        if(MA.contains(state)) {
            //AppLog(' ... ' + state + '  MA');
            return 'Mid-Atlantic';
        }
        else if(MW.contains(state)) {
            //System.debug(' ... ' + state + '  MW');
            return 'Midwest';
        }
        else if(NE.contains(state)) {
            //System.debug(' ... ' + state + '  NE');
            return 'Northeast';
        }
        else if(NW.contains(state)) {
            //System.debug(' ... ' + state + '  Nw');
            return 'Northwest';
        }
        else if(SE.contains(state)) {
            //System.debug(' ... ' + state + '  SE');
            return 'Southeast';
        }
        else if(SW.contains(state)) {
            //System.debug(' ... ' + state + '  SW');
            return 'Southwest';      
        }      
        else 
            return 'UNLOOKUPFAILED';
    }


    public static void AppLog(String Message) {
        AppLog('DEBUG', Message);
    }

    public static void AppLog(String Level, String Message) {

        if(Level.equalsIgnoreCase('INFO')) {
            System.debug(LoggingLevel.INFO,Message);    
        } else if(Level.equalsIgnoreCase('ERROR')) {
            System.debug(LoggingLevel.ERROR,Message);        
        } else if(Level.equalsIgnoreCase('DEBUG')) {
            System.debug(LoggingLevel.DEBUG,Message);        
        } else {
            System.debug(LoggingLevel.DEBUG,Message);        
        }
        
        Results.Add(Message);
    }

}