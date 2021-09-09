public with sharing class RefereeResumeController {

    /*
         RefResumeController was created to support RefereeResume.vfp, a Visual Force Page
         that outputs a PDF Document in a format

         The RefereeResume.vfp entry point is getResumeVF [action="{!getResumeVF}"]

         An example Full URL 
         https://usrowing--uat--c.visualforce.com/apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM
		 https://usrowing--uat--c.visualforce.com/apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM&pDataCallYear=2020
		 https://usrowing--uat--c.visualforce.com/apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM&pDataCallYear=2021
		 https://usrowing--uat--c.visualforce.com/apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM&pDataCallYear=2022

         An example URL called from within a Flow
         ../apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM

     */

    // THE FOLLOWING GLOBAL VALUES ARE USED WITHIN RefResume.vfp

    public static final integer STARTDATE = 0;
    public static final integer ENDDATE = 1;

     public static boolean renderDemo {get; set;} 
     public static boolean renderDetail {get; set;} 
     public static boolean renderSummary {get; set;} 
    
    //public static Date todaysDate {get; set;} 
    
    // Demographic data
    public static Contact contactData {
        get;
        set;
    }

    // Rank history object
    public static List < Designation__c > ranks {
        get;
        set;
    }

    // Endorsement (Role) history object
    public static List < Designation__c > endorsements {
        get;
        set;
    }

    // Current year data objects
    public static Date currDataCallStartDate {get; set;}
    public static Date currDataCallEndDate {get; set;}
     
    public static integer currYear {
        get;
        set;
    }
    public static List < Regatta_Participation__c > currRegattas {
        get;
        set;
    }
    public static integer currRegattaCnt {
        get;
        set;
    }
    public static List < Clinic_Participation__c > currClinics {
        get;
        set;
    }
    public static integer currClinicCnt {
        get;
        set;
    }

    // Last year data objects
    //public static Date lastDataCallStartDate {get; set;}
    //public static Date lastDataCallEndDate {get; set;} 
     
    public static integer lastYear {
        get;
        set;
    }
    public static List < Regatta_Participation__c > lastyrRegattas {
        get;
        set;
    }
    public static integer lastyrRegattaCnt {
        get;
        set;
    }
    public static List < Clinic_Participation__c > lastyrClinics {
        get;
        set;
    }
    public static integer lastyrClinicCnt {
        get;
        set;
    }

    // Prior year data objects
    //public static Date priorDataCallStartDate {get; set;}
    //public static Date priorDataCallEndDate {get; set;}
    
    public static integer priorYear {
        get;
        set;
    }
    public static List < Regatta_Participation__c > prioryrRegattas {
        get;
        set;
    }
    public static integer prioryrRegattaCnt {
        get;
        set;
    }
    public static List < Clinic_Participation__c > prioryrClinics {
        get;
        set;
    }
    public static integer prioryrClinicCnt {
        get;
        set;
    }


    // =====================================================================================
    // Custom objects used to report summary data

    public static List < DataCallSummaryYear > rptDataCallSummaryYear {
        get;
        set;
    }

    //public static boolean renderDataCallSummary {get; set;}
    
    public class DataCallSummaryYear {
        public integer yrsumDataCallYear {
            get;
            set;
        }
        public string yrsumRank {
            get;
            set;
        }
        public integer yrsumNumberOfRegattas {
            get;
            set;
        }
        public integer yrsumNumberOfRegattaDays {
            get;
            set;
        }
        public integer yrsumNumberOfCourses {
            get;
            set;
        }
        public boolean yrsumAttendedClinic {
            get;
            set;
        }
        public boolean yrsumWorkedNRR {
            get;
            set;
        }
        public boolean yrsumWorkedOutOfRegion {
            get;
            set;
        }
    }

    // =====================================================================================

    // test test test
    //static final string TESTCONTACTID = '0036A00000dxHjWQAU';  // Howard Meisner
    //static final string TESTCONTACTID = '0036A00000P1zVCQAZ';  // Doug Jones
    static final string TESTCONTACTID = '0036A00000peZM1QAM'; // Mike Miller
	

    // ====================================================================================
    //  MAIN METHOD

    @AuraEnabled
    @future
    public static void generateRefResumeVF() {

        System.debug('>> IN generateRefResumeVF()');

        PageReference pg = ApexPages.currentPage();
        boolean testing = false;
        string pRequestedContactId = '';
        if (pg != null) {
            pRequestedContactId = pg.getParameters().get('pRequestedContactId');
            System.debug('>> pRequestedContactId ' + pRequestedContactId);
        } else if (pg == null) {
            testing = true;
            System.debug('>> NO pRequestedContactId testing = true');
        }
        string pDataCallYear = pg.getParameters().get('pDataCallYear');
        if(!String.isBlank(pDataCallYear) && pDataCallYear.isNumeric()) {
        	currYear = Integer.valueOf(pDataCallYear);
        } else {
            currYear = CurrentDataCallYear(Date.today())[ENDDATE].Year();    
        }
        renderDemo = true;
        renderDetail = true;
        renderSummary = true;
        string pRenderPages = pg.getParameters().get('pRenderPages');
        if(!String.isBlank(pRenderPages)) {
            renderDemo = false;
        	renderDetail = false;
            renderSummary = false;
            renderDemo = pRenderPages.contains('1');
            renderDetail = pRenderPages.contains('2');
            renderSummary = pRenderPages.contains('3');
        } 
        
        currDataCallStartDate = dataCallPeriod(currYear)[STARTDATE];
    	currDataCallEndDate = dataCallPeriod(curryear)[ENDDATE];
        
        // test test test
        if (String.IsBlank(pRequestedContactId))
            pRequestedContactId = TESTCONTACTID;
        // end test - end test - end test

        
        // -----------------------------------------------------------------------------------
        // DEMOGRAPHIC PAGE
        
        if(renderDemo) {
            System.debug(LoggingLevel.DEBUG, 'generateRefResume ContactId: ' + pRequestedContactId);
    
            // SELECT DEMOGRAPHIC DATA FOR TOP OF REPORT 
            contactData = getContactData(pRequestedContactId);
    
            // SELECT RANKS & ENDORSEMENTS FOR TOP PAGE  
            ranks = getRanks(pRequestedContactId);
    
            endorsements = getEndorsements(pRequestedContactId);
        }
        // -----------------------------------------------------------------------------------
        // GET THE CURRENT DATA CALL YEAR PLUS LAST YEAR AND PRIOR YEAR FOR REPORTS BY YEAR 
        if(renderDetail) {
        // CURRENT YEAR REPORT DATA
        currRegattas = GetDataCallYearRegattas(pRequestedContactId, currYear);
        currRegattaCnt = currRegattas.size();
        currClinics = GetDataCallYearClinics(pRequestedContactId, currYear);
        currClinicCnt = currClinics.size();

        // LAST YEAR REPORT DATA
        lastYear = currYear - 1;
        lastyrRegattas = GetDataCallYearRegattas(pRequestedContactId, lastYear);
        lastyrRegattaCnt = lastyrRegattas.size();
        lastyrClinics = GetDataCallYearClinics(pRequestedContactId, lastYear);
        lastyrClinicCnt = lastyrClinics.size();

        // PRIOR YEAR REPORT DATA
        priorYear = currYear - 2;
        prioryrRegattas = GetDataCallYearRegattas(pRequestedContactId, priorYear);
        prioryrRegattaCnt = prioryrRegattas.size();
        prioryrClinics = GetDataCallYearClinics(pRequestedContactId, priorYear);
        prioryrClinicCnt = prioryrClinics.size();
    }
        // -----------------------------------------------------------------------------------
        // GET DATA CALL SUMMARIES
    	if(renderSummary) {
        	rptDataCallSummaryYear = DataCallSummary(currYear, pRequestedContactId, contactData.Region__c, contactData.Referee_License_Year__c);
    	}
    }

    // Demographic object
    public static Contact getContactData(string contactId) {
 
        Contact contact = [SELECT Name, FirstName, LastName, Birthdate, Id,
            MailingStreet, MailingCity, MailingState, MailingPostalCode,
            Phone, MobilePhone, npe01__WorkPhone__c,
            Email, npe01__AlternateEmail__c, Membership_Number__c,
            Referee_License_Year__c, Referee_License_Number__c, Referee_Rank__c, Referee_Status__c, Region__c
            FROM CONTACT WHERE Id =: contactId WITH SECURITY_ENFORCED
        ];
        return contact;
    }

    // Rank history object
    public static List < Designation__c > getRanks(string contactId) {
        List < Designation__c > ranks = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c FROM Designation__c WHERE
            designation__c in ('Emeritus', 'Full Referee', 'Assistant Referee', 'Candidate Referee') AND Designee__c =: contactId WITH SECURITY_ENFORCED
        ];
        return ranks;
    }

    // Endorsement (Role) history object
    public static List < Designation__c > getEndorsements(string contactId) {
        // SELECT ENDORSEMENT HISTORY FROM DESIGNATION__C - SAME AS RDF ROLES
        List < Designation__c > endorsements = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c FROM Designation__c WHERE
            designation__c not in ('Full Referee', 'Assistant Referee', 'Candidate Referee') AND Designee__c =: contactId WITH SECURITY_ENFORCED
        ];
        return endorsements;
    }

    // Get Regatta data by data call year
    public static List < Regatta_Participation__c > getDataCallYearRegattas(string contactId, integer rptDataCallYear) {

        DateTime startRptDate = DataCallPeriod(rptDataCallYear)[STARTDATE];
        DateTime endRptDate = DataCallPeriod(rptDataCallYear)[ENDDATE];

        //System.debug(LoggingLevel.DEBUG, 'Regatta DataCallYear: ' + rptDataCallYear + ' StartDate = ' + startRptDate.format() + ' EndDate' + endRptDate.format() );

        List < Regatta_Participation__c > regattas = [SELECT
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
            and Participation_Regatta__r.Start_Date_Time__c >=: startRptDate
            and Participation_Regatta__r.Start_Date_Time__c <: endRptDate.addDays(1)
            WITH SECURITY_ENFORCED
            order by Participation_Regatta__r.Start_Date_Time__c desc
        ];

        //System.debug(LoggingLevel.DEBUG, 'regattas count = ' + regattas.size());

        return regattas;
    }

    // Get clinic data by data call year
    public static List < Clinic_Participation__c > getDataCallYearClinics(string contactId, integer rptDataCallYear) {

        DateTime startRptYear = DataCallPeriod(rptDataCallYear)[STARTDATE];
        DateTime endRptYear = DataCallPeriod(rptDataCallYear)[ENDDATE];

        //System.debug(LoggingLevel.DEBUG, 'Clinic DataCallYear = ' + rptDataCallYear + ' ' + startRptYear.format('MM/dd/yyyy') + ' ' + endRptYear.format('MM/dd/yyyy') );

        List < Clinic_Participation__c > clinics = [Select
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
            and Participation_Clinic__r.Start_Date__c >=: startRptYear
            and Participation_Clinic__r.Start_Date__c <: endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
            order by Participation_Clinic__r.Start_Date__c desc
        ];

        //System.debug(LoggingLevel.DEBUG, 'clinincs count = ' + clinics.size());
                
        return clinics;

    }

    // This Method will summarize data call data across mulitple roles - the max is 10 years due to system limitations
    public static List < DataCallSummaryYear > dataCallSummary(integer rptYear, string contactId, string refereeRegion, string refereeLicenseYear) {

        System.debug(LoggingLevel.DEBUG, '=====================================================================================================================' );
        System.debug(LoggingLevel.DEBUG, 'dataCallSummary: ' + contactId + ', ' + refereeRegion + ', ' + refereeLicenseYear);
        
        integer yr = rptYear;
        //integer yr = CurrentDataCallYear(Date.today())[ENDDATE].Year();

        List < DataCallSummaryYear > dataCallSummaryData = new List < DataCallSummaryYear > ();

        integer licYear = Integer.valueOf(refereeLicenseYear);
        if (licYear < (yr - 10)) {
            licYear = yr - 10;
        }

        System.debug(LoggingLevel.DEBUG, 'Starting data call year ' + yr);
        for (integer n = yr; n >= licYear; n--) {

            System.debug(LoggingLevel.DEBUG, 'Year = ' + n);
            integer reportYear = n;

            DataCallSummaryYear dataCallYear = getDataCallSummaryData(contactId, refereeRegion, reportYear);
            dataCallSummaryData.add(dataCallYear);

        }
        System.debug(LoggingLevel.DEBUG, '=====================================================================================================================' );
        return dataCallSummaryData;

    }

    // Look up stats for a single year
    public static DataCallSummaryYear getDataCallSummaryData(string contactId, string region, integer reportYear) {

         System.debug(LoggingLevel.DEBUG, '---------------------------------------------------------------------------------------------------------------------' );
        
        DataCallSummaryYear dataCallYear = new DataCallSummaryYear();

        DateTime startRptYear = DataCallPeriod(reportYear)[STARTDATE];
        DateTime endRptYear = DataCallPeriod(reportYear)[ENDDATE];

        // Year
        dataCallYear.yrsumDataCallYear = endRptYear.Year();
        System.debug(LoggingLevel.DEBUG, 'DataCallYear = ' + dataCallYear.yrsumDataCallYear);

        // Rank - Note that you may have mulitple ranks during a Data Call Year
        List < Designation__c > ranks = [SELECT Designation__c, Designation_Start_Date__c FROM Designation__c
            WHERE Designee__c =: contactId
            AND designation__c in ('Emeritus', 'Full Referee', 'Assistant Referee', 'Candidate Referee')
            AND Designation_Start_Date__c <: endRptYear.date()
            WITH SECURITY_ENFORCED
        ];
        
        dataCallYear.yrsumRank = getHighestRankDuringDataCallYear(ranks);
             
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
            dataCallYear.yrsumNumberOfRegattas = (integer) regattaresult[0].get('expr0');
            System.debug(LoggingLevel.DEBUG, 'NumberOfRegattas ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.yrsumNumberOfRegattas);
            if (dataCallYear.yrsumNumberOfRegattas > 0) {
                double sumofdays = (double) regattaresult[0].get('expr1');
                dataCallYear.yrsumNumberOfRegattaDays = sumofdays.intValue();
            } else {
                dataCallYear.yrsumNumberOfRegattaDays = 0;
            }
            System.debug(LoggingLevel.DEBUG, 'NumberOfRegattaDayss ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.yrsumNumberOfRegattaDays);
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

        dataCallYear.yrsumNumberOfCourses = courses.size();
        System.debug(LoggingLevel.DEBUG, 'NumberOfCourses ' + startRptYear.format('MM/dd/yyyy') + ' ' + dataCallYear.yrsumNumberOfCourses);

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
            dataCallYear.yrsumWorkedNRR = true;
        }

        // Worked Out of Region
        integer outofregioncount = [SELECT
            count()
            FROM Regatta_Participation__c
            where Participant__c =: contactId
            and Participation_Regatta__r.REGATTA_REGION__C <> : region
            and Participation_Regatta__r.Start_Date_Time__c >= : startRptYear
            and Participation_Regatta__r.Start_Date_Time__c < : endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if (outofregioncount > 0) {
            dataCallYear.yrsumWorkedOutOfRegion = true;
        }

        // Attended Clinic
        List < AggregateResult > cliniccount = [Select count(Participant__c) FROM Clinic_Participation__c
            WHERE Participant__c =: contactId
            and Participation_Clinic__r.Start_Date__c >=: startRptYear
            and Participation_Clinic__r.Start_Date__c <: endRptYear.addDays(1)
            WITH SECURITY_ENFORCED
        ];

        if ((integer) cliniccount[0].get('expr0') > 0) {
            dataCallYear.yrsumAttendedClinic = true;
        }

        return dataCallYear;

    }
    
    public static string getHighestRankDuringDataCallYear( List < Designation__c > ranks) {
        
        integer r = 0; // Candidate Referee
        for (Designation__c d: ranks) {
            //System.debug(LoggingLevel.DEBUG, 'DataCallYear current rank ' + d.Designation__c + ' ' + d.Designation_Start_Date__c + ' ' + startRptYear.date() + ' ' + endRptYear.addDays(1).date());
            if (d.Designation__c == 'Assistant Referee' && r < 1) {
                System.debug(LoggingLevel.DEBUG, '! DataCallYear Rank = 1 ' + d.Designation__c );
                r = 1;
            } else if (d.Designation__c == 'Full Referee' && r < 2) {
                System.debug(LoggingLevel.DEBUG, '! DataCallYear Rank = 2 ' + d.Designation__c );
                r = 2;
            } else if (d.Designation__c == 'Emeritus' && r < 3) {
                System.debug(LoggingLevel.DEBUG, '! DataCallYear Rank = 3 ' + d.Designation__c );
                r = 3;
            }
        }
        string yrsumRank = '';
        System.debug(LoggingLevel.DEBUG, 'DataCallYear rank =  ' + r);
        switch on r {
            when 3 {
                yrsumRank = 'Emeritus';
            }
            when 2 {
                yrsumRank = 'Full Referee';
            }
            when 1 {
                yrsumRank = 'Assistant Referee';
            }
            when 0 {
                yrsumRank = 'Candidate Referee';
            }
        }
		return yrsumRank;
        
    }
    

    // =============================================================================================
    // Utilities

    // Calculate current data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // HINT: use STARTDATE = 0 and ENDDATE = 1 to make code readable
    public static Date[] currentDataCallYear(Date currdate) {
        //Date currdate = date.today();
        integer year = currdate.year();
        if (currdate.month() < 1) {
            year = year - 1;
        }
        return dataCallPeriod(year);
    }

    // Calcuate prior data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // NOTE:  THE FULL RANGE AVAILABLE IS 1960 TO 2200
    public static Date[] dataCallPeriod(integer dataCallYear) {
        Date[] dataCallDate = new Date[2];
        if (dataCallYear > 1960 && dataCallYear < 2200) {
            dataCallDate[STARTDATE] = Date.newInstance(dataCallYear - 1, 9, 1);
            dataCallDate[ENDDATE] = Date.newInstance(dataCallYear, 8, 31);
            // System.debug(LoggingLevel.DEBUG, 'DateCallPeriod ' + dataCallDate[STARTDATE] + ' ' + dataCallDate[ENDDATE] );
        }
        return dataCallDate;
    }



}