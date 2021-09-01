public class RefereeResumeController {

   /*
        RefResumeController was created to support RefereeResume.vfp, a Visual Force Page
        that outputs a PDF Document in a format

        The RefereeResume.vfp entry point is getResumeVF [action="{!getResumeVF}"]

        An example Full URL 
        https://usrowing--uat--c.visualforce.com/apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM

        An example URL called from within a Flow
        ../apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM

    */

    // THE FOLLOWING GLOBAL VALUES ARE USED WITHIN RefResume.vfp
    
    public static final integer STARTDATE = 0;
    public static final integer ENDDATE = 1;

    // Demographic data
    public static string name {get; set;}
    public static string mailingStreet {get; set;}
    public static string mailingCity {get; set;}
    public static string mailingState {get; set;}
    public static string mailingPostalcode {get; set;}
    public static string phone {get; set;}
    public static string mobilephone {get; set;}
    public static string npe01Workphone {get; set;}
    public static string email {get; set;}
    public static string npe01AlternateEmail {get; set;}
    public static string refereeLicenseYear {get; set;}
    public static string refereeLicenseNumber {get; set;}
    public static DateTime birthdate {get; set;}
    public static string fmtDOB {get; set;}
    public static string refereeRank {get; set;}
    public static string refereeStatus {get; set;}
    public static string refereeRegion {get; set;}

    // Rank history object
    public static List <Designation__c> ranks {get; set;}
    
    // Endorsement (Role) history object
    public static List <Designation__c> endorsements {get; set;}

    // Current year data objects
    public static integer currYear {get; set;}
    public static List <Regatta_Participation__c> currRegattas {get; set;}
    public static integer currRegattaCnt {get; set;}
    public static List <Clinic_Participation__c> currClinics {get; set;}
    public static integer currClinicCnt {get; set;}
    
    // Last year data objects
    public static integer lastYear {get; set;}
    public static List <Regatta_Participation__c> lastyrRegattas {get; set;}
    public static integer lastyrRegattaCnt {get; set;}
    public static List <Clinic_Participation__c> lastyrClinics {get; set;}
    public static integer lastyrClinicCnt {get; set;}
    
    // Prior year data objects
    public static integer priorYear {get; set;}
    public static List <Regatta_Participation__c> prioryrRegattas {get; set;}
    public static integer prioryrRegattaCnt {get; set;}
    public static List <Clinic_Participation__c> prioryrClinics {get; set;}
    public static integer prioryrClinicCnt {get; set;}


    // =====================================================================================
    // Custom objects used to report summary data

    public static List<DataCallSummaryYear> rptDataCallSummaryYear {get; set;}

    public class DataCallSummaryYear {
        public integer dcDataCallYear {get; set;}
        public string dcRank {get; set;}
        public integer dcNumberOfRegattas {get; set;} 
        public integer dcNumberOfRegattaDays {get; set;}
        public integer dcNumberOfCourses {get; set;}
        public boolean dcAttendedClinic {get; set;}
        public boolean dcWorkedNRR {get; set;}
        public boolean dcWorkedOutOfRegion {get; set;}
    }
    
    // =====================================================================================

    // test test test
    //static final string TESTCONTACTID = '0036A00000dxHjWQAU';  // Howard Meisner
    //static final string TESTCONTACTID = '0036A00000P1zVCQAZ';  // Doug Jones
	static final string TESTCONTACTID = '0036A00000peZM1QAM';  // Mike Miller


    // ====================================================================================
    //  MAIN METHOD

    @AuraEnabled
    @future
    public static void generateRefResumeVF() {
        
        System.debug('>> IN generateRefResumeVF()');
        
        PageReference pg = ApexPages.currentPage();
        string pRequestedContactId = '';
        if(pg != null) {
        	pRequestedContactId = pg.getParameters().get('pRequestedContactId');
    	}
        // test test test
        if(String.IsBlank(pRequestedContactId))
        	pRequestedContactId = TESTCONTACTID;
		// end test - end test - end test

		System.debug(LoggingLevel.DEBUG, 'generateRefResume ContactId: ' + pRequestedContactId);

        // SELECT DEMOGRAPHIC DATA FOR TOP OF REPORT        
        Contact contact =[SELECT Name, FirstName, LastName, Birthdate, Id, 
            MailingStreet, MailingCity, MailingState, MailingPostalCode, 
            Phone, MobilePhone,  npe01__WorkPhone__c, 
            Email, npe01__AlternateEmail__c, 
            Referee_License_Year__c, Referee_License_Number__c, Referee_Rank__c, Referee_Status__c, Region__c 
            FROM CONTACT WHERE Id =: pRequestedContactId WITH SECURITY_ENFORCED];
                
        name = contact.Name;
        mailingstreet  = contact.MailingStreet;
        mailingcity = contact.MailingCity;
        mailingstate  = contact.MailingState;
        mailingpostalcode  = contact.MailingPostalCode;
        phone  = contact.Phone;
        mobilephone  = contact.MobilePhone;
        npe01Workphone  = contact.npe01__WorkPhone__c;
        email  = contact.Email;
        npe01AlternateEmail  = contact.npe01__AlternateEmail__c;
        refereeLicenseYear = contact.Referee_License_Year__c;
        refereeLicenseNumber = contact.Referee_License_Number__c;
        birthdate = contact.Birthdate;
        fmtDOB = birthdate.format('MM/dd/yyyy');
        refereeRank = contact.Referee_Rank__c;
        refereeStatus = contact.Referee_Status__c;
        refereeRegion = contact.Region__c;

        // SELECT RANK HISTORY FROM DESIGNATION__C
        ranks = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c FROM Designation__c WHERE 
        designation__c in ('Emeritus', 'Full Referee','Assistant Referee','Candidate Referee') AND Designee__c =: pRequestedContactId WITH SECURITY_ENFORCED];
        
        for(Designation__c d: ranks) {
            System.debug(LoggingLevel.DEBUG, 'generateRefResumeVF - rank = ' + d.designation__c );
        }

        // SELECT ENDORSEMENT HISTORY FROM DESIGNATION__C - SAME AS RDF ROLES
        endorsements = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c FROM Designation__c WHERE 
        designation__c not in ('Full Referee','Assistant Referee','Candidate Referee') AND Designee__c =: pRequestedContactId WITH SECURITY_ENFORCED];

        // -----------------------------------------------------------------------------------
        // GET THE CURRENT DATA CALL YEAR PLUS LAST YEAR AND PRIOR YEAR FOR REPORTS BY YEAR   
        currYear = CurrentDataCallYear()[ENDDATE].Year();

        // CURRENT YEAR REPORT DATA
		currRegattas = GetDataCallYearRegattas(pRequestedContactId, currYear );
        currRegattaCnt = currRegattas.size();
        currClinics =  GetDataCallYearClinics(pRequestedContactId, currYear );
        currClinicCnt = currClinics.size();
        
        // LAST YEAR REPORT DATA
        lastYear =  currYear-1;
		lastyrRegattas = GetDataCallYearRegattas(pRequestedContactId, lastYear );
        lastyrRegattaCnt = lastyrRegattas.size();
        lastyrClinics =  GetDataCallYearClinics(pRequestedContactId, lastYear );
        lastyrClinicCnt = lastyrClinics.size();
                
        // PRIOR YEAR REPORT DATA
        priorYear = currYear-2;
        prioryrRegattas = GetDataCallYearRegattas(pRequestedContactId, priorYear );
        prioryrRegattaCnt = prioryrRegattas.size();
        prioryrClinics =  GetDataCallYearClinics(pRequestedContactId, priorYear );
        prioryrClinicCnt = prioryrClinics.size();

        // -----------------------------------------------------------------------------------
        // GET DATA CALL SUMMARIES

        rptDataCallSummaryYear =  DataCallSummary( pRequestedContactId, refereeRegion, refereeLicenseYear );
        /*
		System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear rows=' + rptDataCallSummaryYear.size());
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcDataCallYear);
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcRank);
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcNumberOfRegattas);
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcNumberOfRegattaDays);
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcNumberOfCourses);
        System.debug(LoggingLevel.DEBUG, 'rptDataCallSummaryYear row 1 =' + rptDataCallSummaryYear[0].dcAttendedClinic);
	    */

    }
    
    public static List <Regatta_Participation__c> getDataCallYearRegattas(string contactId, integer rptDataCallYear ) {

        DateTime startRptDate = DataCallPeriod(rptDataCallYear)[STARTDATE];     
        DateTime endRptDate = DataCallPeriod(rptDataCallYear)[ENDDATE];     
        
        //System.debug(LoggingLevel.DEBUG, 'Regatta DataCallYear: ' + rptDataCallYear + ' StartDate = ' + startRptDate.format() + ' EndDate' + endRptDate.format() );
        
       List <Regatta_Participation__c> regattas =[SELECT 
            Participation_Regatta__r.name, 
            Participation_Regatta__r.Regatta_Location__c,
            Participation_Regatta__r.Regatta_Course__r.Name,
            Participation_Regatta__r.Regatta_City__c,
            Participation_Regatta__r.Start_Date_Time__c,
            Participation_Regatta__r.End_Date_Time__c,
            Participation_Regatta__r.REGATTA_REGION__C,
            Participation_Regatta__r.Regatta_Type__c,
            Participation_Regatta__r.Nationally_Recognized_Regatta__c,
            Days_Worked__c
            FROM Regatta_Participation__c 
            where Participant__c =: contactId
            and Participation_Regatta__r.Start_Date_Time__c >= : startRptDate 
            and Participation_Regatta__r.Start_Date_Time__c < : endRptDate.addDays(1) 
            WITH SECURITY_ENFORCED
            order by Participation_Regatta__r.Start_Date_Time__c desc ];
        
        //System.debug(LoggingLevel.DEBUG, 'regattas count = ' + regattas.size());

        /*
        for(Regatta_Participation__c r: regattas) {
            System.debug(LoggingLevel.DEBUG, 'regatta name = ' + r.Participation_Regatta__r.name );
            System.debug(LoggingLevel.DEBUG, 'regatta course = ' + r.Participation_Regatta__r.Regatta_Course__r.Name);
        }
        */
        return regattas;
    }
    
    
     public static List <Clinic_Participation__c> getDataCallYearClinics(string contactId, integer rptDataCallYear) {
        
        DateTime startRptYear = DataCallPeriod(rptDataCallYear)[STARTDATE];     
        DateTime endRptYear = DataCallPeriod(rptDataCallYear)[ENDDATE];     
    
        //System.debug(LoggingLevel.DEBUG, 'Clinic DataCallYear = ' + rptDataCallYear + ' ' + startRptYear.format('MM/dd/yyyy') + ' ' + endRptYear.format('MM/dd/yyyy') );
        
        List <Clinic_Participation__c> clinics =[Select 
            Participation_Clinic__r.name,
            Participation_Clinic__r.Start_Date__c,
            Participation_Clinic__r.End_Date__c,
            Participation_Clinic__r.Clinic_City__c,
            Participation_Clinic__r.Clinic_State__c,
            Participation_Clinic__r.Clinic_Type__c,      
            Participant__r.Name,
            Clinic_Participant_Role__c, 
            Clinic_Participation_Dupe__c, 
            Clinic_Participation_Status__c, 
            Participant_Region__c, 
            Participant__c, 
            Participation_Clinic__c
            FROM Clinic_Participation__c
            WHERE Participant__c =: contactId
            and Participation_Clinic__r.Start_Date__c >= : startRptYear 
            and Participation_Clinic__r.Start_Date__c < : endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
            order by Participation_Clinic__r.Start_Date__c desc      
        ];
        
        //System.debug(LoggingLevel.DEBUG, 'clinincs count = ' + clinics.size());
        /*
        for(Clinic_Participation__c c: clinics) {
            System.debug(LoggingLevel.DEBUG, 'clinic name = ' + c.Participation_Clinic__r.name );
            System.debug(LoggingLevel.DEBUG, 'regatta course = ' + c.Clinic_Participant_Role__c);
        }
        */
        return clinics;
        
    }
    
    public static List<DataCallSummaryYear> dataCallSummary(string contactId, string refereeRegion, string refereeLicenseYear) {
        
        integer yr = CurrentDataCallYear()[ENDDATE].Year();
      
        List<DataCallSummaryYear> dataCallSummaryData = new List<DataCallSummaryYear>();
       
        integer licYear = Integer.valueOf(refereeLicenseYear);
        if(licYear < (yr-10)) {
        	licYear = yr - 10;
        }
        
        System.debug(LoggingLevel.DEBUG, 'Starting data call year ' + yr );
        for(integer n = yr; n >= licYear; n-- ) {
        
             System.debug(LoggingLevel.DEBUG, 'Year = ' + n);
             integer reportYear = n;
            
			DataCallSummaryYear dataCallYear = getDataCallSummaryData(contactId, refereeRegion, reportYear);
            dataCallSummaryData.add(dataCallYear);
            
    	}
        return dataCallSummaryData;
        
    }
    
    public static DataCallSummaryYear getDataCallSummaryData(string contactId, string region, integer reportYear) {

        DataCallSummaryYear dataCallYear = new DataCallSummaryYear();

        DateTime startRptYear = DataCallPeriod(reportYear)[STARTDATE];
        DateTime endRptYear = DataCallPeriod(reportYear)[ENDDATE];

        // Year
        dataCallYear.dcDataCallYear = endRptYear.Year();
        System.debug(LoggingLevel.DEBUG, 'DataCallYear = ' + dataCallYear.dcDataCallYear);

         // Rank
         List<Designation__c> ranks = [SELECT Designation__c, Designation_Start_Date__c FROM Designation__c 
            WHERE Designee__c =: contactId
            AND designation__c in ('Emeritus', 'Full Referee','Assistant Referee','Candidate Referee')
            AND Designation_Start_Date__c < : endRptYear.date()
            WITH SECURITY_ENFORCED ];
        integer r = 0;
        for(Designation__c d : ranks) {
            System.debug(LoggingLevel.DEBUG, 'DataCallYear current rank ' + d.Designation__c + ' ' + d.Designation_Start_Date__c + ' ' + startRptYear.date() + ' ' +  endRptYear.addDays(1).date());
            if(d.Designation__c == 'Assistant Referee' && r < 1) {  
                System.debug(LoggingLevel.DEBUG, 'DataCallYear Rank = 1 ' + d.Designation__c + ' ' + d.Designation_Start_Date__c);
                r = 1;
            }
            else if(d.Designation__c == 'Full Referee' && r < 2) {   
                System.debug(LoggingLevel.DEBUG, 'DataCallYear Rank = 2 ' + d.Designation__c + ' ' + d.Designation_Start_Date__c);
                r = 2;
            }
            else if(d.Designation__c == 'Emeritus' && r < 3) {   
                System.debug(LoggingLevel.DEBUG, 'DataCallYear Rank = 3 ' + d.Designation__c + ' ' + d.Designation_Start_Date__c);
                r = 3;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'DataCallYear rank =  ' + r);
        switch on r {
            when 3 {dataCallYear.dcRank = 'Emeritus'; }
            when 2 {dataCallYear.dcRank = 'Full Referee'; }
            when 1 { dataCallYear.dcRank = 'Assistant Referee'; }
            when else { dataCallYear.dcRank = 'Candidate Referee'; }
        }
 
        // Number of Regattas & Days Worked
        List < AggregateResult > regattaresult = [SELECT
            count(Name),
            sum(Days_Worked__c)
            FROM Regatta_Participation__c
            where Participant__c =: contactId
            and Participation_Regatta__r.Start_Date_Time__c >=: startRptYear
            and Participation_Regatta__r.Start_Date_Time__c <: endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if (!regattaresult.isEmpty()) {
            dataCallYear.dcNumberOfRegattas = (integer) regattaresult[0].get('expr0');
            System.debug(LoggingLevel.DEBUG, 'NumberOfRegattas ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.dcNumberOfRegattas);
            if (dataCallYear.dcNumberOfRegattas > 0) {
                double sumofdays = (double) regattaresult[0].get('expr1');
                dataCallYear.dcNumberOfRegattaDays = sumofdays.intValue();
            } else {
                dataCallYear.dcNumberOfRegattaDays = 0;
            }
            System.debug(LoggingLevel.DEBUG, 'NumberOfRegattaDayss ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.dcNumberOfRegattaDays);
        }

        // Number of Distinct Courses            
        List < AggregateResult > courses = [SELECT Participation_Regatta__r.Regatta_Course__r.Name
            FROM Regatta_Participation__c
            where Participant__c =: contactId
            and Participation_Regatta__r.Start_Date_Time__c >=: startRptYear
            and Participation_Regatta__r.Start_Date_Time__c <: endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
            group by Participation_Regatta__r.Regatta_Course__r.Name
        ];

        dataCallYear.dcNumberOfCourses = courses.size();
        System.debug(LoggingLevel.DEBUG, 'NumberOfCourses ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.dcNumberOfCourses);

        // WorkedNRR
        integer nrr = [SELECT count()
            FROM Regatta_Participation__c
            where Participant__c =: contactId
            and Participation_Regatta__r.Nationally_Recognized_Regatta__c = true
            and Participation_Regatta__r.Start_Date_Time__c >=: StartRptYear
            and Participation_Regatta__r.Start_Date_Time__c <: EndRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if (nrr > 0) {
            dataCallYear.dcWorkedNRR = true;
        }

        // Worked Out of Region
        integer outofregioncount = [SELECT
            count()
            FROM Regatta_Participation__c
            where Participant__c =: contactId
            and Participation_Regatta__r.REGATTA_REGION__C <> : region
            and Participation_Regatta__r.Start_Date_Time__c >= : startRptYear
            and Participation_Regatta__r.Start_Date_Time__c <  : endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if (outofregioncount > 0) {
            dataCallYear.dcWorkedOutOfRegion = true;
        }

        // Attended Clinic
        List < AggregateResult > cliniccount = [Select count(Participant__c) FROM Clinic_Participation__c
            WHERE Participant__c =: contactId
            and Participation_Clinic__r.Start_Date__c >=: startRptYear
            and Participation_Clinic__r.Start_Date__c <: endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if ((integer) cliniccount[0].get('expr0') > 0) {
            dataCallYear.dcAttendedClinic = true;
        }

        return dataCallYear;

    }
     
    // =============================================================================================
    // Utilities

    // Calculate current data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // HINT: use STARTDATE = 0 and ENDDATE = 1 to make code readable
    public static Date[] currentDataCallYear() {
        Date currdate = date.today();
        integer year = currdate.year();
        if(currdate.month() < 1) {
        	year = year-1;
        }
        return dataCallPeriod(year);
    }

    // Calcuate prior data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // NOTE:  THE FULL RANGE AVAILABLE IS 1960 TO 2200
    public static Date[] dataCallPeriod(integer dataCallYear) {
        Date[] dataCallDate = new Date[2];
        if(dataCallYear > 1960 && dataCallYear < 2200) {
            dataCallDate[STARTDATE] = Date.newInstance(dataCallYear-1, 9, 1);
            dataCallDate[ENDDATE] = Date.newInstance(dataCallYear, 8, 31);
            // System.debug(LoggingLevel.DEBUG, 'DateCallPeriod ' + dataCallDate[STARTDATE] + ' ' + dataCallDate[ENDDATE] );
        }
        return dataCallDate;
    } 

    

}