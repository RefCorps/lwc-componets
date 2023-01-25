@isTest
public class RefereeResumeControllerTest {

    static Contact resumecontact;
    static User resumeuser;
    static Contact evalueecontact;
    static User evalueeuser;
	static Regatta__c evalregatta;
    static Regatta_Participation__c[] regattaparticipation;
    static User adminuser;

    @IsTest
    public static void LoadTestUserData(){

        /*
            This method creates an admin user that will create a Referee user and an Assistant Referee user
            Note 1:  A real RefCorp user will have an AccountId set to ID 0016A00000K77C4QAJ NAME USRowing
            Through trial and error I found that when I included AccountId the load would fail due to an
            embedded test condition [if(Test.isRunningTest())...] in a Nonprofit Success Pack (NPSP) related trigger.  
            Omitting AccountId works just fine for testing.
            Note 2:  This method may be call many times depending upon scope of variables across methods. Note that 
            global variables are static.
            Note 3:  Consideration was given to loading static resources; however, this proved to be the cleaner
            option and since the basic user data is limited and consistent there's no need to change it as would 
            be possible with a static resource.  If static resource is needed because values are more dynamic than 
            currently implmented consider the following code:
                List<StaticResource> docs;
                docs = [select id, name, body from StaticResource 
                where name = 'RAResumetestData'];
            The data will appear in the body.
        */
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None'
            Limit 1
        ];
        // Select Id, name from UserRole where  
        // portalRole is blank for us rowing ref

        // admin user
        String fnamea = 'Admin';
        String lnamea = 'Resumetest';
        String emaila = 'admin.Resumetest@test.com';
        String aliasa = 'aeval'; // only be 8 chars 

        // contact1 - user1 
        String fname1 = 'Eva';
        String lname1 = 'Resumetest';
        String email1 = 'evareferee@test.com';
        String rank1 = 'Referee';
        String region1 = 'Southeast';
        String gender1 = 'Female';
        String alias1 = 'reval'; // only be 8 chars 

        System.debug('=================================================================================================');
        System.debug('In LoadTestUserData');
        
        System.debug('portalRole is ' + portalRole);
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        System.debug('New System Admin user follows');
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + emaila,
            Alias = aliasa,
            Email= emaila,
            EmailEncodingKey='UTF-8',
            Firstname=fnamea,
            Lastname=lnamea,
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/New_York'
        );
        Database.SaveResult portalAccountOwner = Database.insert(portalAccountOwner1);
         /*
            OwnerId is the ID of the user that created the account, e.g., Jules, Doug, Kendal
            For testing we'll use our systme user 'Admin Resumetest'
        */
        System.debug('OwnerId will be = ' + portalAccountOwner.Id);
        adminuser = portalAccountOwner1;
        System.debug('Admin user: ' + adminuser.name);

        System.debug('runAs portalAccountOwner1');
        System.runAs(portalAccountOwner1) {

            System.debug('Create Contact 1');
            Contact contact1 = new Contact(
                FirstName = fname1,
                Lastname = lname1,
                // AccountId =  portalAccount1.Id, //'0016A00000K77C4QAJ',
                Email = System.now().millisecond() + email1,
                MEMBERSHIP_LEVEL__C = 'Basic',
                OWNERID = portalAccountOwner.Id, // '005e00000060aLjAAI',
                REFEREE_RANK__C = rank1,
                REFEREE_STATUS__C = 'Active',
                REGION__C = region1,
                Contact_Gender__c = gender1,
                Referee_License_Number__c = '2345',
                Referee_License_Year__c = '2014'
            );
            System.debug('Insert Contact1 ' + fname1 + ' ' + lname1);
            Database.insert(contact1);
            System.debug('Contact1 id = ' + contact1.Id);

            resumecontact = [SELECT AccountId, Name, FirstName,
                Lastname, Email, MEMBERSHIP_LEVEL__C, OWNERID, REFEREE_RANK__C,
                REFEREE_STATUS__C, REGION__C, Contact_Gender__c FROM Contact where ID =: contact1.Id
            ];
            // Load to EvaluationQuestionController for processing tests
            //EvaluationQuestionsController.testresumecontact = resumecontact;

            System.debug('evalcontact id = ' + contact1.Id +
                '\nAccountId = ' + resumecontact.AccountId +
                '\nName = ' + resumecontact.Name +
                '\nOwnerId = ' + resumecontact.OwnerId +
                '\nReferee_Status__c = ' + resumecontact.Referee_Status__c
            );
            //
            //Create user
            // SELECT Id, name FROM Profile where name like '%Referee%'
            Profile portalProfile = [SELECT Id FROM Profile where name = 'Referee'
                Limit 1
            ];
            User user1 = new User(
                Username = System.now().millisecond() + email1,
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = alias1,
                Email = email1,
                EmailEncodingKey = 'UTF-8',
                FirstName = resumecontact.FirstName, //'Referee',
                LastName = resumecontact.LastName, //'Resumetest',
                USER_REFEREE_RANK__C = resumecontact.REFEREE_RANK__C, //'Referee',
                CommunityNickname = alias1 + getTimeBasedId(),
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            System.debug('Insert User1 ' + fname1 + ' ' + lname1);
            Database.insert(user1);

            resumeuser = [Select Id, Username, Name,
                ContactId,
                ProfileId,
                Alias,
                Email,
                EmailEncodingKey,
                FirstName,
                LastName,
                USER_REFEREE_RANK__C, //'Referee',
                CommunityNickname
                FROM User where Id =: user1.Id
            ];

            System.debug('User1 created');

            System.debug('=================================================================================================');
            System.debug('Create Contact 2');

            Designation__c d1 = new Designation__c(
                DESIGNATION_START_DATE__C = Date.newInstance(2014,1,1),
                DESIGNATION__C = 'Candidate Referee',
                DESIGNEE_USER__c = resumeuser.Id,
                DESIGNEE__C	= contact1.Id
            );
            insert d1;

            Designation__c d2 = new Designation__c(
                DESIGNATION_START_DATE__C = Date.newInstance(2014,1,1),
                DESIGNATION__C = 'Assistant Referee',
                DESIGNEE_USER__c = resumeuser.Id,
                DESIGNEE__C	= contact1.Id
            );
            insert d2;

            Designation__c d3 = new Designation__c(
                DESIGNATION_START_DATE__C = Date.newInstance(2017,1,1),
                DESIGNATION__C = 'Full Referee',
                DESIGNEE_USER__c = resumeuser.Id,
                DESIGNEE__C	= contact1.Id
            );
            insert d3;

            System.debug('User2 created');


        }
        System.debug('LoadTestUserData completed');
        System.debug('=================================================================================================');
    }

    @IsTest
    public static void LoadTestRegattaParticipantData() {

        System.debug('=================================================================================================');
        System.debug('In LoadTestRegattaParticipantData');

       // if(regattacourse.Id == null) {
       //     SelectRegattaCourse();
       // }

        if (resumeuser == null) {
            System.debug('resumeuser is null');
            LoadTestUserData();
        }
        System.debug('Get user Id next');
        User evaluatorusr = [Select id from User where Id =: resumeuser.id];

        System.debug('Get regatta Id next');
        System.RunAs(evaluatorusr) {

            System.debug('Create your regatta course -------------------------------------------------');
            // regatta 
            Course__c rc = new Course__c();
            //rc.ID = 'a0i6A000003h2XNQAY';
            rc.NAME = 'Sarasota, Florida (Nathan Bendersen Lake)';
            rc.COURSE_CITY__C = 'Sarasota';
            rc.COURSE_STATE__C = 'Florida';
            rc.COURSE_ADDRESS_LINE_1__C = '';
            rc.COURSE_ADDRESS_LINE_2__C = '';
            rc.COURSE_COUNTRY__C = 'United States';
            rc.RACING_LANES__C = 8;
            insert rc;

            List<Course__c> course = [select id from course__c where name like 'Sarasota%Bendersen%' limit 1];

            System.debug(' >> Created course Id = ' + course[0].Id);

            System.debug('Create your regatta --------------------------------------------------------');

           Regatta__c testregatta = new Regatta__c(

                Start_Date_Time__c = Date.today().AddDays(-2),
                End_Date_Time__c = Date.today().AddDays(-2),
                NAME = 'Eval Invite',
                REGATTA_CITY__C = 'Sarasota',
                REGATTA_COUNTRY__C = 'United States',
                REGATTA_COURSE__C = course[0].Id,
                REGATTA_DESCRIPTION__C = 'Test Regatta',
                REGATTA_REGION__C = 'Southeast',
                REGATTA_STATE__C = 'Florida',
                REGATTA_STATUS__C = 'On Schedule',
                REGATTA_TYPE__C = 'Sprint',
                Year__c = '2022',
                HOUSING_PROVIDED__C = FALSE,
                INVITE_ONLY__C = TRUE,
                STIPEND_OFFERED__C = FALSE,
                US_ROWING_REGISTERED__C = FALSE,
                NATIONALLY_RECOGNIZED_REGATTA__C = FALSE

            );
            Database.insert(testregatta);

            evalregatta = [select id, name, Start_Date_Time__c
                           from regatta__c where id =: testregatta.id limit 1];
        }
        // xx EvaluationQuestionsController.testEvalregatta = evalregatta.clone();
        System.debug('Loaded regatta ' + evalregatta.Name);

        System.debug('Run using Id ' + evaluatorusr.Id);
        System.RunAs(evaluatorusr) {

            System.debug('Loading contact ' + resumecontact.Name + ' contact id ' + resumecontact.id);
            System.debug('Loading user ' + resumeuser.Name + ' user id ' + resumeuser.id);
            System.debug('Loaded to ' + evalregatta.Name);
            Regatta_Participation__c rr = new Regatta_Participation__c(

                PARTICIPANT__C = resumecontact.id,
                REGATTA_PARTICIPANT_USER__C = resumeuser.id,

                PARTICIPATION_REGATTA__C = evalregatta.id,
                REGATTA_PARTICIPANT_ROLE__C = 'Referee',
                Days_Worked__c = 2,

                ALIGNER__C = TRUE,
                ASSISTANT_STARTER__C = FALSE,
                ATHLETE_WEIGHING__C = FALSE,
                BOAT_WEIGHING__C = FALSE,
                CHEF_DU_LAC__C = FALSE,
                CHIEF_JUDGE_AT_FINISH__C = TRUE,
                CHIEF_REFEREE__C = FALSE,
                COURSE_MARSHAL__C = FALSE,
                DEPUTY_CHIEF__C = FALSE,
                FINISH_LINE__C = FALSE,
                FINISH_MARSHAL__C = FALSE,
                JUDGE_AT_START__C = TRUE,
                JURY__C = FALSE,
                OMBUDSMAN__C = FALSE,
                REFEREE_POSITION__C = FALSE,
                SAFETY_CHECK__C = FALSE,
                START_MARSHAL__C = FALSE,
                STARTER_POSITION__C = FALSE,
                SUPERVISED_OTHER_REFEREES__C = FALSE,
                ZONAL_REFEREE__C = FALSE
            );
            System.debug('Inserting referee participant next');
            Database.insert(rr);
        }
    
        Integer p =  [select count() from regatta_participation__c where Participation_Regatta__c =: evalregatta.id];
        
        regattaparticipation = [SELECT Participation_Regatta__c, Participation_Regatta__r.name, 
                                Participation_Regatta__r.Start_Date_Time__c, Participation_Regatta__r.End_Date_Time__c 
                                FROM Regatta_Participation__c WHERE Participation_Regatta__c =: evalregatta.id];
        
        System.debug('Participants [' + p + '] loaded to regatta');
        System.debug('Particpants fetch count = '+ regattaparticipation.size());
        // Load to EvaluationQuestionController for processing tests
        // xx EvaluationQuestionsController.testRegattaParticipation = regattaparticipation.clone();
        // xx System.debug('EvaluationQuestionsController testRegattaParticipation count = '+ EvaluationQuestionsController.testRegattaParticipation.size());
        
        System.debug('Out LoadTestRegattaParticipantData');
        System.debug('-------------------------------------------------------------------------');
    }
    
    public static String getTimeBasedId() {
        Long ts = DateTime.now().getTime();
        String timeBasedVal = ts + '';
        System.debug('timeBaseVal='+timeBasedVal);
        return timeBasedVal;
    }

    //===================================================================


    @isTest    
    public static void testGenerateRefResumeVF() {

        Exception unexpectedException;
        try {

            //User u1 = [SELECT Id FROM User WHERE Alias='mmilla'];
            //System.RunAs(u1) {
            
            System.debug('>>> Begin testGenerateRefResumeVF');
            
            // url = ../apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM
            
            PageReference pageRef = Page.RefereeResumePage;

            string pageparam = 'pRequestedContactId';
            string yearparam = 'pDataCallYear';

            if(resumeuser == null) {
                LoadTestUserData();
                LoadTestRegattaParticipantData();
            }

            //string testuser = 'Mike Miller';
            string testuser = resumeuser.Name;  // original test
            //Integer cnt = [SELECT count() FROM CONTACT WHERE NAME = :testuser limit 1];

            Contact c = [SELECT Id FROM CONTACT WHERE NAME = :testuser limit 1];
            // Contact c = resumecontact;

            if(c == null) {
                System.debug('!! No contact data for ' + resumecontact.Name);
            }    

            string contactId = c.Id;
            integer paramyear = RefereeResumeController.currentDataCallYear()[RefereeResumeController.ENDDATE].year();  

            pageRef.getParameters().put(pageparam, contactId);
            pageRef.getParameters().put(yearparam, String.valueOf(paramyear));

            string param1 = pageRef.getParameters().get('pRequestedContactId');
            string param2 = pageRef.getParameters().get('pDataCallYear');
            System.debug('RefereeResumePage parameter pRequestedContactId = ' + param1);
            System.debug('RefereeResumePage parameter pDataCallYear = ' + param2);


            // MAIN METHOD
            //RefereeResumeController.generateRefResumeVF();
            
            //

            /* --------------------------------------------------
                TEST DATE METHODS
                A Data Call Year is 9-1 to 8-31, e.g., 9-1-2020 00:00 to 8-31-2021 24:00
                The current date will fall into the next Data Call Year
                Based upon the current date you can determine the last Data Call Year
                It will be the month prior to 8/31 of the current year
            */

            // THIS WILL CALCULATE A DATA CALL YEAR BASED UPON THE CURRENT DATE
            // THIS VALUE WILL NOT BE THE LAST COMPLETED DATA CALL YEAR
            // IT WILL BE THE NEXT DATA CALL YEAR
            Date currdate = date.today();
            integer year = currDate.Year();
            if (currdate.month() >= 9 && currdate.month() <= 12) {
                year = year + 1;
            }
            System.debug('currdate=' + currdate.format() + ' month-' + currdate.month() + ' datacallyear=' + year);
 
            // SINCE YEAR IS FROM THE NEXT DATA CALL YEAR - THE LAST DATA CALL YEAR
            // WILL BE YEAR - 1
            integer currDataCallYear = year-1;
 
            // THIS WILL DEMONSTRATE THE START AND END OF THE 'CURRENT' DATA CALL YEAR METHOD
            Date[] currDataCallYearApp = RefereeResumeController.CurrentDataCallYear();
            System.debug( 'CurrentDataCallYear returned: ' + currDataCallYearApp[RefereeResumeController.STARTDATE].format() + ' to ' + currDataCallYearApp[RefereeResumeController.ENDDATE].format() );
            
            // THIS WILL DEMONSTRATE CALC THE YEAR AS AN INT
            integer intCurrDataCallYear = RefereeResumeController.getDataCallYear(currdate);
            System.debug( 'getDataCallYear returned: ' + intCurrDataCallYear);

            // SINCE getDataCallYear WITH TODAY IS ACTIVITY IN THE NEXT DATA CALL YEAR
            // THIS YEAR SHOULD NOT BE THE SAME AS CURRENT DATA CALL YEAR 
            System.assert(currDataCallYearApp[RefereeResumeController.STARTDATE].Year() != intCurrDataCallYear,'getDataCallYear (' + currDataCallYearApp[RefereeResumeController.STARTDATE].Year() + ') & CurrentDataCallYear (' + intCurrDataCallYear + ') are diff year values'); 

            // --------------------------------------------------
            /* 
                TEST METHOD USED TO SELECT USER CONTACT DATA
                Run normal SOQL and compare to method for differences
                Note that some test SOQL values will be used later
            */
            System.debug('>>> testGenerateRefResumeVF Demographics - check demographic data');

            Contact resumecontact =[SELECT Name, Id, FirstName, LastName, Birthdate, 
                MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                Phone, MobilePhone,  npe01__WorkPhone__c, 
                Email, npe01__AlternateEmail__c, 
                Referee_License_Year__c, Referee_License_Number__c, Referee_Rank__c, Referee_Status__c, Region__c 
                FROM CONTACT WHERE Id =: contactId ];
        
            Contact contactData = RefereeResumeController.getContactData(contactId);

            // Since LIC year is important to summary - the lic year from getContactData must match our test query
            System.assert(resumecontact.Referee_License_Year__c == contactData.Referee_License_Year__c, 'License year from getContactData does not match test query ');

            integer licYear = Integer.valueOf(contactData.Referee_License_Year__c);
            if (licYear < (currDataCallYear - RefereeResumeController.MAXREPORTINGYEARS)) {
                licYear = currDataCallYear - RefereeResumeController.MAXREPORTINGYEARS;
            }
            integer maxYears = licYear;
			integer reportingYears = currDataCallYear - maxYears;

            System.assert(reportingYears <= RefereeResumeController.MAXREPORTINGYEARS ,'reportingYears should not exceed the max number of reporting years'); 


            //--------------------------------------------------
            /*
                TEST METHODS USED TO SELECT RANKS AND ENDORSEMENTS FROM DESIGNATION__C
                Run normal SOQL and compare to method for differences
            */
            System.debug('>>> testGenerateRefResumeVF Ranks - ranks should have at least one entry');
            
            List <Designation__c> testranks = [SELECT 
                 designation__c, Designation_Start_Date__c, Designation_End_Date__c 
                 FROM Designation__c WHERE designation__c in ('Emeritus', 'Full Referee','Assistant Referee','Candidate Referee') 
                 AND Designee__c =: contactId];

            integer testrankssz = testranks.size();

            RefereeResumeController.ranks =  RefereeResumeController.getRanks(contactId);   

            integer ranksz = RefereeResumeController.ranks.size();
            System.debug('>>> testGenerateRefResumeVF - ranks from method = ' + ranksz + ' ranks from test = ' + testrankssz);
            System.assert( ranksz == testrankssz, 'RefereeResumeController getRanks - ranks from method ' + ranksz + ' do not match test ' + testrankssz);
                        
            System.debug('>>> testGenerateRefResumeVF verify endorsements');

            List < Designation__c > testendorsements = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c 
                    FROM Designation__c WHERE designation__c not in ('Full Referee', 'Assistant Referee', 'Candidate Referee') 
                    AND Designee__c =: contactId WITH SECURITY_ENFORCED];
            
            integer testendorsementsz = testendorsements.size();

            RefereeResumeController.endorsements = RefereeResumeController.getEndorsements(contactId);

            integer endorsementsz = RefereeResumeController.endorsements.size();
            
            System.debug('>>> testGenerateRefResumeVF - endorsements from method = ' + endorsementsz + ' ranks from test = ' + testendorsementsz);
            System.assert( endorsementsz == testendorsementsz, 'RefereeResumeController getEndorsements - endorsements from method = ' + endorsementsz + ' ranks from test = ' + testendorsementsz);
            
            //--------------------------------------------------
            /*
                Reevauate Data Call Year and use to pull data for Regattas, Clinics, Ranks, and Endorsements
            */
            System.debug('>>> testGenerateRefResumeVF evaluate currentDataCallYear checking year ' + currDataCallYear);
            
            integer cyear = RefereeResumeController.currentDataCallYear()[RefereeResumeController.ENDDATE].year();
            //System.assert(currDataCallYear == cyear,'generateRefResumeVF - calculated year does not match currentCallYear year ' + cyear);

            Date dec1 = Date.newInstance(cyear, 12, 1);
            Date dt = Date.today();
            if(dt.month() >= 9) {
            	dec1 = Date.newInstance(dec1.year()-1, 12, 01);
            }
            integer testyear = dec1.year();
            
            System.debug('>>> testGenerateRefResumeVF evaluate dataCallPeriod using testyear ' + testyear);
            
            integer pyear = RefereeResumeController.dataCallPeriod(testyear)[RefereeResumeController.ENDDATE].year();
            System.assert(testyear == pyear,'generateRefResumeVF - calculated year does not match dataCallPeriod year ' + pyear);
            
            //---------------------------------------
            /*
                EXERCISE METHOD TO GET REGATTAS 
            */
            List <Regatta_Participation__c> testregattas = RefereeResumeController.getDataCallYearRegattas(contactId, cyear, reportingYears);
            RefereeResumeController.currRegattas = testregattas;
            System.debug('>>> testGenerateRefResumeVF currRegattas size ' + RefereeResumeController.currRegattas.size());

            //---------------------------------------
            /*
                EXERCISE METHOD TO GET CLINICS 
            */
            List <Clinic_Participation__c> testclinics = RefereeResumeController.getDataCallYearClinics( contactId, cyear, reportingYears);
            RefereeResumeController.currClinics = testclinics;
            System.debug('>>> testGenerateRefResumeVF currClinics + ' + RefereeResumeController.currClinics.size());

            //---------------------------------------
            /*
                EXERCISE METHOD TO GET RANKS 
            */
            List <Designation__c> appRanks = RefereeResumeController.getRanks(contactId);
            RefereeResumeController.ranks = appRanks;

            //---------------------------------------
            /*
                EXERCISE METHOD TO GET RANKS 
            */
            List <Designation__c> appEndorsements = RefereeResumeController.getEndorsements(contactId);
            RefereeResumeController.endorsements = appEndorsements;

            //---------------------------------------
            /*
                EXERCISE METHOD TO BUILD DATA CALL SUMMARY 
                This method will need access to global ranks and clinics in RefereeResumeController.DataCallSummaryYear.
                We'll set those values from prior tests.
            */

            RefereeResumeController.contactData = resumecontact;

            string testlicyear = string.valueOf(cyear+1);
            //  List<DataCallSummaryYear> dataCallSummary(string contactId, string refereeRegion, string refereeLicenseYear)
            List<RefereeResumeController.DataCallSummaryYear> summaryyear = RefereeResumeController.dataCallSummary(reportingYears );
            RefereeResumeController.rptDataCallSummaryYear = summaryyear;
            
            System.debug('>>> testGenerateRefResumeVF summary ' + summaryyear.size());
            
           // RefereeResumeController.DataCallSummaryYear onerow = RefereeResumeController.getDataCallSummaryData(contactId, resumecontact.Region__c, cyear+1);
           // System.debug('>>> testGenerateRefResumeVF DataCallSummaryYear ' + onerow.yrsumRank);
            
            // -----------------------------------------------------------------------------
            /*
                EVALUATE THE METHOD USED TO DETERMINE THE HIGHEST RANK WHEN IT CHANGES WITHIN A DATA CALL YEAR
            */
            List < Designation__c > testranks1 = new  List < Designation__c >();
            Designation__c d11 = new Designation__c();
            d11.Designation__c = 'Emeritus';
            Designation__c d12 = new Designation__c();
            d12.Designation__c = 'Full Referee';
            testranks1.add(d11);
            testranks1.add(d12);
            //string rtr1 = RefereeResumeController.getHighestRankDuringDataCallYear(testranks1);
            //System.debug('>>> testGenerateRefResumeVF testrank1 - ' + rtr1);
            
            List < Designation__c > testranks2 = new  List < Designation__c >();
            Designation__c d21 = new Designation__c();
            d21.Designation__c = 'Candidate Referee';
            Designation__c d22 = new Designation__c();
            d22.Designation__c = 'Assistant Referee';
            Designation__c d23 = new Designation__c();
            d23.Designation__c = 'Full Referee';
            testranks2.add(d21);
            testranks2.add(d22);
            testranks2.add(d23);
            //string rtr2 = RefereeResumeController.getHighestRankDuringDataCallYear(testranks2);
            //System.debug('>>> testGenerateRefResumeVF testrank2 - ' + rtr2);
            

            // -----------------------------------------------------------------------------
            /*
                ALL METHODS HAVE BEEN EXERCISED NOW WE'LL RUN THE MAIN METHOD
            */
            System.debug('---------------------------------------------------');
            System.debug('>>> PassParams - ALL');
    
            /*
                FULLY POPULATED PARAMS
                The only real param needed in production is pRequestedContactId - in test mode that's not really needed either
    
            ../apex/RefereeResumePage?pRequestedContactId={!LookupContactId.recordId}&pDataCallYear={!DataCallRptDateOptions.selectedValue}&pRenderPages={!DoRenderDemo}{!DoRenderDetail}{!DoRenderSummary}
            ../apex/RefereeResumePage?pRequestedContactId=0036A00000peZM1QAM&pDataCallYear=2021&pRenderPages=123
            
            ../apex/RefereeResumePage?
                pRequestedContactId={!LookupContactId.recordId}
                &pDataCallYear={!DataCallRptDateOptions.selectedValue}
                &pRenderPages={!DoRenderDemo}{!DoRenderDetail}{!DoRenderSummary}
    
            */
       
            string pContactId = c.Id;
            string pDataCallYear = String.valueOf(RefereeResumeController.currentDataCallYear()[RefereeResumeController.ENDDATE].year());
            string pRenderPages = '123';
        
            PageReference resumeVfPage = Page.RefereeResumePage;
            Test.setCurrentPage(resumeVfPage);
        
            // Put Id into the current page Parameters
            resumeVfPage.getParameters().put('pRequestedContactId',pContactId);
            resumeVfPage.getParameters().put('pDataCallYear',pDataCallYear);
            resumeVfPage.getParameters().put('pRenderPages',pRenderPages);
    
            // Confirm params are set
            String pgContactId = ApexPages.currentPage().getParameters().get('pRequestedContactId');
            String pgDataCallYear = ApexPages.currentPage().getParameters().get('pDataCallYear');
            String pgRenderPages = ApexPages.currentPage().getParameters().get('pRenderPages');
    
            System.debug('>> Simulated URL using test values:');
            System.debug('../apex/RefereeResumePage?pRequestedContactId=' + pgContactId + '&pDataCallYear=' + pgDataCallYear + '&pRenderPages=' + pgRenderPages);

            RefereeResumeController.generateRefResumeVF();

            System.debug('---------------------------------------------------');
            System.debug('>>> PassParams - CONTACT ONLY');

            PageReference resumeVfPage2 = Page.RefereeResumePage;
            Test.setCurrentPage(resumeVfPage2);
        
            // Put Id into the current page Parameters
            resumeVfPage2.getParameters().put('pRequestedContactId',pContactId);
    
            // Confirm params are set
            pgContactId = ApexPages.currentPage().getParameters().get('pRequestedContactId');
            pgDataCallYear = ApexPages.currentPage().getParameters().get('pDataCallYear');
            pgRenderPages = ApexPages.currentPage().getParameters().get('pRenderPages');
            
            System.debug('../apex/RefereeResumePage?pRequestedContactId=' + pgContactId + '&pDataCallYear=' + pgDataCallYear + '&pRenderPages=' + pgRenderPages);

            RefereeResumeController.generateRefResumeVF();

            System.debug('---------------------------------------------------');

            System.debug('<<< End testGenerateRefResumeVF');
			
            //}
            

        } catch (Exception err) {
            System.debug('RefereeResumeController err: ' + err);
            System.debug('RefereeResumeController err: ' + err.getStackTraceString());
            unexpectedException = err;
        }    
        system.assertEquals(null, unexpectedException, 'RefereeResumeController generateRefResumeVF unexpected Exception');
    }

}