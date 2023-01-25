public with sharing class RefereeResumeController {

    // THE FOLLOWING GLOBAL VALUES ARE USED WITHIN RefResume.vfp

    // #region objects

    public static final integer STARTDATE = 0;
    public static final integer ENDDATE = 1;

    public static boolean renderDemo {
        get;
        set;
    }
    public static boolean renderDetail {
        get;
        set;
    }
    public static boolean renderSummary {
        get;
        set;
    }

    public static final integer MAXREPORTINGYEARS = 10;

    public static integer maxYear {get;set;}
    public static integer reportingYears {get; set;}

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



    public static List < Regatta_Participation__c > allRegattas {
        get;
        set;
    }

    // development - debuggin
    //public static integer allRegattaCnt {
    //    get;
    //    set;
    //}

    public static List < Clinic_Participation__c > allClinics {
        get;
        set;
    }

    // development - debugging
    //public static integer allClinicCnt {get; set;}

    // Current year data objects
    public static Date currDataCallStartDate {
        get;
        set;
    }
    public static Date currDataCallEndDate {
        get;
        set;
    }

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


    public static Map < string, Regatta_Participation__c > mapRegattaParticipation = new Map < string, Regatta_Participation__c > ();

    public static Map < string, Clinic_Participation__c > mapClinicParticipation = new Map < string, Clinic_Participation__c > ();

    // =====================================================================================
    // Custom objects used to report summary data

    public static List < DataCallSummaryYear > rptDataCallSummaryYear {
        get;
        set;
    }

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
    
    // #endregion

    // =====================================================================================

    // test test test
    //static final string TESTCONTACTID = '0036A00000dxHjWQAU';  // Howard Meisner
    //static final string TESTCONTACTID = '0036A00000P1zVCQAZ';  // Doug Jones
    static final string TESTCONTACTID = '0036A00000peZM1QAM'; // Mike Miller
/*
    RefereeResumeController.generateRefResumeVF()
*/

    // ====================================================================================
    //  MAIN METHOD

    @AuraEnabled
    @future
    public static void generateRefResumeVF() {

        System.debug(LoggingLevel.DEBUG, '>> IN generateRefResumeVF()');

        PageReference pg = ApexPages.currentPage();
        boolean testing = false;
        string pRequestedContactId = '';
        renderDemo = true;
        renderDetail = true;
        renderSummary = true;
         if (pg != null) {
            pRequestedContactId = pg.getParameters().get('pRequestedContactId');
            System.debug(LoggingLevel.DEBUG, '>> pRequestedContactId ' + pRequestedContactId);

            string pDataCallYear = pg.getParameters().get('pDataCallYear');
            if (!String.isBlank(pDataCallYear) && pDataCallYear.isNumeric()) {
                currYear = Integer.valueOf(pDataCallYear);
            } else {
                currYear = CurrentDataCallYear()[ENDDATE].Year();
            }


            string pRenderPages = pg.getParameters().get('pRenderPages');
            if (!String.isBlank(pRenderPages)) {
                renderDemo = false;
                renderDetail = false;
                renderSummary = false;
                renderDemo = pRenderPages.contains('1');
                renderDetail = pRenderPages.contains('2');
                renderSummary = pRenderPages.contains('3');

            }

        } else if (pg == null) {
            testing = true;
            currYear = CurrentDataCallYear()[ENDDATE].Year();
            System.debug(LoggingLevel.DEBUG, '>> NO pRequestedContactId testing = true');
        }

        currDataCallStartDate = dataCallPeriod(currYear)[STARTDATE];
        currDataCallEndDate = dataCallPeriod(curryear)[ENDDATE];
        System.debug(LoggingLevel.DEBUG, '>> Current Data Call Year: ' + currYear + ' Dates: ' + currDataCallStartDate.format() + ' to ' + currDataCallEndDate.format());


        // test test test
        if (String.IsBlank(pRequestedContactId)) {
            pRequestedContactId = TESTCONTACTID;
            System.debug(LoggingLevel.DEBUG, '!!! Testing with pRequestedContactId ' + pRequestedContactId);
        }
        // end test - end test - end test


        // -----------------------------------------------------------------------------------
        // DEMOGRAPHIC PAGE

        //if (renderDemo) {
            System.debug(LoggingLevel.DEBUG, 'generateRefResume ContactId: ' + pRequestedContactId);

            // SELECT DEMOGRAPHIC DATA FOR TOP OF REPORT 
            contactData = getContactData(pRequestedContactId);

            // SELECT RANKS & ENDORSEMENTS FOR TOP PAGE  
            ranks = getRanks(pRequestedContactId);

            endorsements = getEndorsements(pRequestedContactId);

            integer licYear = Integer.valueOf(contactData.Referee_License_Year__c);
            if (licYear < (currYear - MAXREPORTINGYEARS)) {
                licYear = currYear - MAXREPORTINGYEARS;
            }
            maxYear = licYear;
			reportingYears = currYear - licYear;

        //}
        //

        // -----------------------------------------------------------------------------------
        // GET THE CURRENT DATA CALL FOR REPORTS BY YEAR 

        //if (renderDetail) {

            System.debug(LoggingLevel.DEBUG, 'renderDetail from ' + maxYear + ' to ' + currYear + ' included years ' + reportingYears);
            
            allRegattas = GetDataCallYearRegattas(pRequestedContactId, currYear, reportingYears);
            allClinics = GetDataCallYearClinics(pRequestedContactId, currYear, reportingYears);

            currRegattas = new List < Regatta_Participation__c > ();
            lastyrRegattas = new List < Regatta_Participation__c > ();
            prioryrRegattas = new List < Regatta_Participation__c > ();
            
            currClinics = new List < Clinic_Participation__c > ();
            lastyrClinics = new List < Clinic_Participation__c > ();
            prioryrClinics = new List < Clinic_Participation__c > ();
            

            DateTime startRptDate = DataCallPeriod(currYear)[STARTDATE];
            DateTime endRptDate = DataCallPeriod(currYear)[ENDDATE];

            integer regattacount = 1;
            integer testyear = 0;

            for (Regatta_Participation__c r: allRegattas) {

                DateTime regattastart = r.Participation_Regatta__r.Start_Date_Time__c;

                integer regattayear = getDataCallYear(regattastart);

                // Build map key
                if (testyear == regattayear) {
                    regattacount++;
                } else if (testyear != regattayear) {
                    testyear = regattayear;
                    regattacount = 1;
                }

                string regattakey = String.valueOf(regattayear) + '.' + String.valueOf(regattacount);
                if (!mapRegattaParticipation.containskey(regattakey)) {
                    regattakey = String.valueOf(regattayear) + '.' + String.valueOf(regattacount);
                    //System.debug('new key = ' + regattakey);
                    mapRegattaParticipation.put(regattakey, r);
                } else {
                    regattacount++;
                    //System.debug('existing key = ' + regattakey);
                    regattakey = String.valueOf(regattayear) + '.' + String.valueOf(regattacount);
                    //System.debug('created key = ' + regattakey);
                    mapRegattaParticipation.put(regattakey, r);
                }

                if(regattayear == currYear) {
                    currRegattas.add(r);
                } else if(regattayear == currYear-1) {
                    lastyrRegattas.add(r);
                }  else if(regattayear == currYear-2) {
                   prioryrRegattas.add(r);
                }   

            }

            lastyear = currYear-1;
            priorYear = currYear-2;

            currRegattaCnt = currRegattas.size();
            lastyrRegattaCnt = lastyrRegattas.size();
            prioryrRegattaCnt = prioryrRegattas.size();

            //System.debug(LoggingLevel.DEBUG, ' current regatta count = ' + currRegattas.size());

            integer cliniccount = 0;

            for (Clinic_Participation__c c: allClinics) {

                DateTime clinicstart = c.Participation_Clinic__r.Start_Date__c;

                integer clinicyear = getDataCallYear(Clinicstart);

                // Build map key
                if (testyear == clinicyear) {
                    cliniccount++;
                } else if (testyear != clinicyear) {
                    testyear = clinicyear;
                    cliniccount = 1;
                }

                string clinickey = String.valueOf(clinicyear) + '.' + String.valueOf(cliniccount);
                if (!mapClinicParticipation.containskey(clinickey)) {
                    clinickey = String.valueOf(clinicyear) + '.' + String.valueOf(cliniccount);
                    //System.debug('new key = ' + clinickey);
                    mapClinicParticipation.put(clinickey, c);
                } else {
                    cliniccount++;
                    //System.debug('existing key = ' + clinickey);
                    clinickey = String.valueOf(clinicyear) + '.' + String.valueOf(cliniccount);
                    //System.debug('created key = ' + clinickey);
                    mapClinicParticipation.put(clinickey, c);
                }

                if(clinicyear == currYear) {
                    currClinics.add(c);
                } else if(clinicyear == currYear-1) {
                    lastyrClinics.add(c);
                } else if(clinicyear == currYear-2) {
                    prioryrClinics.add(c);
                }

            }
            currClinicCnt = currClinics.size();
            lastyrClinicCnt = lastyrClinics.size();
            prioryrClinicCnt = prioryrClinics.size();
            

        //}
        // end if

        // -----------------------------------------------------------------------------------
        // GET DATA CALL SUMMARIES

        if (renderSummary) {
            rptDataCallSummaryYear = DataCallSummary(reportingYears);
        }
       
    }

    // ===================================================================================================================================

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
    public static List < Regatta_Participation__c > getDataCallYearRegattas(string contactId, integer rptDataCallYear, integer incldYears) {

        DateTime startRptDate = DataCallPeriod(rptDataCallYear - incldYears)[STARTDATE];
        DateTime endRptDate = DataCallPeriod(rptDataCallYear)[ENDDATE];

        System.debug(LoggingLevel.DEBUG, 'Regatta DataCallYear: ' + rptDataCallYear + ' StartDate = ' + startRptDate.format() + '  EndDate = ' + endRptDate.format());

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
            and Participation_Regatta__r.Start_Date_Time__c <: endRptDate
            WITH SECURITY_ENFORCED
            order by Participation_Regatta__r.Start_Date_Time__c desc
        ];

        System.debug(LoggingLevel.DEBUG, 'regattas count = ' + regattas.size());

        return regattas;
    }

    // Get clinic data by data call year
    public static List < Clinic_Participation__c > getDataCallYearClinics(string contactId, integer rptDataCallYear, integer incldYears) {

        //DateTime startRptYear = DataCallPeriod(rptDataCallYear)[STARTDATE];
        //DateTime endRptYear = DataCallPeriod(rptDataCallYear)[ENDDATE];
        DateTime startRptDate = DataCallPeriod(rptDataCallYear - incldYears)[STARTDATE];
        DateTime endRptDate = DataCallPeriod(rptDataCallYear)[ENDDATE];

        System.debug(LoggingLevel.DEBUG, 'Clinic DataCallYear: ' + rptDataCallYear + ' StartDate = ' + startRptDate.format() + '  EndDate = ' + endRptDate.format('MM/dd/yyyy') );

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
            and Participation_Clinic__r.Start_Date__c >=: startRptDate
            and Participation_Clinic__r.Start_Date__c <: endRptDate
            WITH SECURITY_ENFORCED
            order by Participation_Clinic__r.Start_Date__c desc
        ];

        System.debug(LoggingLevel.DEBUG, 'clinincs count = ' + clinics.size());

        return clinics;

    }

    // This Method will summarize data call data across mulitple roles - the max is 10 years due to system limitations
    //public static List < DataCallSummaryYear > dataCallSummary(integer rptYear, string contactId, string refereeRegion, string refereeLicenseYear) {
    //         System.debug(LoggingLevel.DEBUG, 'dataCallSummary: ' + contactId + ', ' + refereeRegion + ', ' + refereeLicenseYear);
    
    public static List < DataCallSummaryYear > dataCallSummary(integer incldYears) {

        //System.debug(LoggingLevel.DEBUG, '=====================================================================================================================');
        //System.debug(LoggingLevel.DEBUG, '>> dataCallSummary incldYears = ' + incldYears);


        List < DataCallSummaryYear > lstDataCallSummaryData = new List < DataCallSummaryYear > ();

        Map < string, DataCallSummaryYear > mapDataCallSummaryYear = new Map < string, DataCallSummaryYear > ();

        Map < string, integer > mapNumberOfRegattas = new Map < string, integer > ();
        Map < string, integer > mapRegattaDays = new Map < string, integer > ();

        Map < string, string > mapCourseByYear = new Map < string, string > ();
        Map < string, integer > mapCourses = new Map < string, integer > ();

        List < string > lstWorkedNRR = new List < string > ();
        List < string > lstWorkedOutOfRegion = new List < string > ();

        List <string> lstAttendedClinic = new List <string> ();


        // WHEN TESTING YOU MAY NOT HAVE ACCESS TO currYear - this will resolve testing issues
        if(currYear == null) {
            currYear = CurrentDataCallYear()[ENDDATE].Year();
        }

        for (integer n = 0; n <= incldYears; n++) {

            DataCallSummaryYear sum = new DataCallSummaryYear();
            integer rptYear = currYear + (n * -1);
            string key = String.valueOf(rptYear);
            sum.yrsumDataCallYear = rptYear;
            sum.yrsumRank = '';
            sum.yrsumNumberOfRegattas = 0;
            sum.yrsumNumberOfRegattaDays = 0;
            sum.yrsumNumberOfCourses = 0;
            sum.yrsumAttendedClinic = false;
            sum.yrsumWorkedNRR = false;
            sum.yrsumWorkedOutOfRegion = false;
            if (key != null) {
                mapDataCallSummaryYear.put(key, sum);
                //System.debug('init mapDataCallSummaryYear ' + n + ' key=' + key);
            }
        }

        //System.debug('Init mapDataCallSummaryYear completed');

        // ACCUMULATE BY YEAR
        for (string regattakey: mapRegattaParticipation.keySet()) {

            // System.debug('regattakey ' + regattakey);

            string[] keyparts = regattakey.split('\\.');
            string key = keyparts[0];
            string seq = keyparts[1];

            Regatta_Participation__c r = mapRegattaParticipation.get(regattakey);

            //System.debug('regetta: ' + regattakey + ' ' + r.Participation_Regatta__r.Name + ' ' + r.Participation_Regatta__r.Regatta_Course__r.Name);
            DataCallSummaryYear sumyr = new DataCallSummaryYear();

            // Number of Regattas
            if (mapNumberOfRegattas.containsKey(key)) {
                integer cntin = mapNumberOfRegattas.get(key);
                integer cntout = cntin + 1;
                //System.debug('     updt number: ' + key + ' ' + seq + ' ' + cntin + ' to ' + cntout);
                mapNumberOfRegattas.put(key, cntout);
            } else {
                integer cntin = 0;
                integer cntout = 1;
                //System.debug('     new number: ' + key + ' ' + seq + ' ' + cntin + ' to ' + cntout);
                mapNumberOfRegattas.put(key, cntout);
            }

            // Number of Regatta Days
            if (mapRegattaDays.containsKey(key)) {
                integer sumdays = mapRegattaDays.get(key);
                integer days = Integer.valueOf(r.Days_Worked__c);
                sumdays = sumdays + days;
                mapRegattaDays.put(key, sumdays);
                //System.debug('   add days: ' + key + ' ' + sumdays);
            } else {
                integer sumdays = Integer.valueOf(r.Days_Worked__c);
                mapRegattaDays.put(keyparts[0], sumdays);
                //System.debug('   new days: ' + key + ' ' + sumdays);
            }

            // Number of Courses
            string course = r.Participation_Regatta__r.Regatta_Course__r.Name + '.' + keyparts[0];
            string courseByYearKey = keyparts[0] + '.' + course;
            if (!mapCourseByYear.containsKey(courseByYearKey)) {
                mapCourseByYear.put(courseByYearKey, course);
                if (!mapCourses.ContainsKey(keyparts[0])) {
                    mapCourses.put(keyparts[0], 1);
                } else {
                    integer yrcnt = mapCourses.get(keyparts[0]);
                    yrcnt++;
                    mapCourses.put(keyparts[0], yrcnt);
                }
            }

            // Worked NRR
            if (r.Participation_Regatta__r.Nationally_Recognized_Regatta__c) {
                lstWorkedNRR.add(keyparts[0]);
            }

            // Worked Out of Region
            if (!r.Participation_Regatta__r.REGATTA_REGION__C.contains(contactData.Region__c)) {
                lstWorkedOutOfRegion.add(keyparts[0]);
            }

        }

        for (string clinickey : mapClinicParticipation.keySet()) {

            string[] keyparts = clinickey.split('\\.');
            lstAttendedClinic.add(keyparts[0]);

        }

        System.debug('  ranks size ' + ranks.size());
        System.debug('Referee Rank ' + contactData.Referee_Rank__c);
        System.debug('    currYear ' + currYear);
        System.debug('  incldYears ' + incldYears);

        Map<string, string> dbranks = getHighestRankDuringDataCallYear( ranks, contactData.Referee_Rank__c,  currYear,  incldYears);

        // SET INTO FINAL OBJECT
        for (string key: mapNumberOfRegattas.keySet()) {
            DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
            //System.debug('mapDataCallSummaryYear key=' + key + ' s=' + s.yrsumNumberOfRegattas);
            integer num = mapNumberOfRegattas.get(key);
            //System.debug('numberOfRegattas key=' + key + ' num=' + num);
            s.yrsumNumberOfRegattas = num;
            mapDataCallSummaryYear.put(key, s);
        }
        for (string key: mapRegattaDays.keySet()) {
            DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
            integer days = mapRegattaDays.get(key);
            s.yrsumNumberOfRegattaDays = days;
            mapDataCallSummaryYear.put(key, s);
        }
        for (string key: mapCourses.keySet()) {
            DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
            integer courses = mapCourses.get(key);
            s.yrsumNumberOfCourses = courses;
            mapDataCallSummaryYear.put(key, s);
        }

        for (string key: mapDataCallSummaryYear.keySet()) {
            DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
            if (lstWorkedNRR.contains(key)) {
                //DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
                s.yrsumWorkedNRR = true;
                //mapDataCallSummaryYear.put(key, s);
            }
            if (lstWorkedOutOfRegion.contains(key)) {
                //DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
                s.yrsumWorkedOutOfRegion = true;
                //mapDataCallSummaryYear.put(key, s);
            }
            if(lstAttendedClinic.contains(key)) {
                //DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
                s.yrsumAttendedClinic = true;
                //mapDataCallSummaryYear.put(key, s);
            }
            s.yrsumRank = dbranks.get(key);

            mapDataCallSummaryYear.put(key, s);
        }


        for (string key: mapDataCallSummaryYear.keySet()) {
            DataCallSummaryYear s = mapDataCallSummaryYear.get(key);
            // System.debug('mapDataCallSummaryYear=' + s.yrsumDataCallYear + ' #reg=' + s.yrsumNumberOfRegattas + ' days=' + s.yrsumNumberOfRegattaDays + ' #cour=' + s.yrsumNumberOfCourses + ' nrr=' + s.yrsumWorkedNRR + ' wor=' + s.yrsumWorkedOutOfRegion);
            lstDataCallSummaryData.add(s);
        }

        return lstDataCallSummaryData;

    }
 

    // --------------------------------------------------------------------------------------------------------------

    private static  Map<string, string> getHighestRankDuringDataCallYear(List < Designation__c > ranks, string currentrank, integer currYear, integer incldYears) {

        string lastrank = getFormalRank(currentrank);
        
        Map<string, string> dbranks = new Map<string, string>();
        string key = '';
        string mrank = '';
        string drank = '';

		// Map the database ranks        
        for (Designation__c d: ranks) {
            drank = d.Designation__c;
           	key = String.valueOf(d.Designation_Start_Date__c.Year());
            if(dbranks.containsKey(key)) {
                mrank = dbranks.get(key);
                if( ranking(drank) > ranking(mrank) )
                {
                     dbranks.put(key,drank);
                }
            } else {
               dbranks.put(key, drank);
            }
        }
        
        // Map ranks across years
        Map<string, string> hrank = new Map<string, string>();        
        string myrank = '';
        for(integer yr = (currYear-incldYears); yr <= currYear ; yr++) {
            key = String.valueOf(yr);
			//
            if(dbranks.containsKey(key)) {
                myrank = dbranks.get(key);
                hrank.put(key,myrank);
                //System.debug('key + myrank =' + key + ' ' + myrank);
                lastrank = myrank;
            } else {
                hrank.put(key,lastrank);
                //System.debug('key + lastrank =' + key + ' ' + lastrank);
            }
        	
        }
        
        //for (string dkey: hrank.keySet()) {
        //    System.debug('hrank: ' + dkey + ' ' + hrank.get(dkey));
        //}

        return hrank;
        
    }

    private static integer ranking(string rankdesignation) {
        integer r = 0;
        if (rankdesignation == 'Assistant Referee' && r < 1) {
           r = 1;
        } else if (rankdesignation == 'Full Referee' && r < 2) {
           r = 2;
        } else if (rankdesignation == 'Emeritus' && r < 3) {
           r = 3;
        }
        return r;
    }
    
    private static string getFormalRank(string rank) {
        string fullrank = '';
        if(rank == 'Candidate') {
            fullrank = 'Candidate Referee';
        } else if( rank == 'Assistant') {
            fullrank = 'Assistant Referee';
        } else if( rank == 'Referee') {
            fullrank = 'Full Referee';
        } else if( rank == 'Emeritus') {
            fullrank = 'Emeritus';
        } else {
            fullrank = rank;
        }
        return fullrank;
    }
    

    // =============================================================================================
    // Utilities

    // Calculate current data call year
    // returns Date array with 2 elements start date is in element 0 and end date is in element 1
    // HINT: use STARTDATE = 0 and ENDDATE = 1 to make code readable
    public static Date[] currentDataCallYear() {
        Date currdate = date.today();
        integer year = currdate.year();
        if (currdate.month() < 1) {
            year = year - 1;
        }
        return dataCallPeriod(year);
    }

    public static integer getDataCallYear(DateTime currdate) {
        integer year = currdate.year();
        if (currdate.month() >= 9 && currdate.month() <= 12) {
            year = year + 1;
        }
        //System.debug('currdate=' + currdate + ' month-' + currdate.month() + ' regattayear=' + year);
        return year;
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