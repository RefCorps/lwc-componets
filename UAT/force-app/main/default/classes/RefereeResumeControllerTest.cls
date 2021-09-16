@isTest
public with sharing class RefereeResumeControllerTest {

    @isTest(SeeAllData=true) 
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

            string testuser = 'Mike Miller';
            Contact c = [SELECT Id FROM CONTACT WHERE NAME = :testuser limit 1];
            
            string contactId = c.Id;
            integer paramyear = RefereeResumeController.currentDataCallYear()[RefereeResumeController.ENDDATE].year();  

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

            List < Designation__c > testendorsements = [SELECT designation__c, Designation_Start_Date__c, Designation_End_Date__c FROM Designation__c WHERE
            designation__c not in ('Full Referee', 'Assistant Referee', 'Candidate Referee') AND Designee__c =: contactId WITH SECURITY_ENFORCED
            ];
            
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