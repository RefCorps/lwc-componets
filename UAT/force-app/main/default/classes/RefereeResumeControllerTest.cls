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
            string contactId = '0036A00000peZM1QAM';
            
            string pageparam = 'pRequestedContactId';
            pageRef.getParameters().put(pageparam,contactId);   
            string param = pageRef.getParameters().get('pRequestedContactId');
            System.debug('RefereeResumePage parameter pRequestedContactId = ' + param);
            
            RefereeResumeController.generateRefResumeVF();
            
            Contact resumecontact =[SELECT Name, Id, FirstName, LastName, Birthdate, 
            MailingStreet, MailingCity, MailingState, MailingPostalCode, 
            Phone, MobilePhone,  npe01__WorkPhone__c, 
            Email, npe01__AlternateEmail__c, 
            Referee_License_Year__c, Referee_License_Number__c, Referee_Rank__c, Referee_Status__c, Region__c 
            FROM CONTACT WHERE Id =: contactId ];
            
        RefereeResumeController.name = resumecontact.Name;
        RefereeResumeController.mailingstreet  = resumecontact.MailingStreet;
        RefereeResumeController.mailingcity = resumecontact.MailingCity;
        RefereeResumeController.mailingstate  = resumecontact.MailingState;
        RefereeResumeController.mailingpostalcode  = resumecontact.MailingPostalCode;
        RefereeResumeController.phone  = resumecontact.Phone;
        RefereeResumeController.mobilephone  = resumecontact.MobilePhone;
        RefereeResumeController.npe01Workphone  = resumecontact.npe01__WorkPhone__c;
        RefereeResumeController.email  = resumecontact.Email;
        RefereeResumeController.npe01AlternateEmail  = resumecontact.npe01__AlternateEmail__c;
        RefereeResumeController.refereeLicenseYear = resumecontact.Referee_License_Year__c;
        RefereeResumeController.refereeLicenseNumber = resumecontact.Referee_License_Number__c;
        RefereeResumeController.birthdate = resumecontact.Birthdate;
        RefereeResumeController.fmtDOB = resumecontact.birthdate.format();
        RefereeResumeController.refereeRank = resumecontact.Referee_Rank__c;
        RefereeResumeController.refereeStatus = resumecontact.Referee_Status__c;
        RefereeResumeController.refereeRegion = resumecontact.Region__c;
            
            //RefereeResumeController.generateRefResumeVF();
            
            System.debug('>>> testGenerateRefResumeVF required demographics follows ');
            
			System.assert( !String.isBlank(RefereeResumeController.name),'RefereeResumeController generateRefResumeVF - A referee name was not selected');
            System.debug('>>> testGenerateRefResumeVF verify name = ' + RefereeResumeController.name );
            System.assert( !String.isBlank(RefereeResumeController.refereeLicenseYear),'RefereeResumeController generateRefResumeVF - Referee license year empty');
            System.assert( !String.isBlank(RefereeResumeController.refereeLicenseNumber),'RefereeResumeController generateRefResumeVF - Referee license number empty');
            System.assert( !String.isBlank(RefereeResumeController.refereeRank),'RefereeResumeController generateRefResumeVF - Referee rank empty');
            System.assert( !String.isBlank(RefereeResumeController.refereeStatus),'RefereeResumeController generateRefResumeVF - Referee status empty');
            System.assert( !String.isBlank(RefereeResumeController.refereeRegion),'RefereeResumeController generateRefResumeVF - Referee region empty');
            
            System.debug('>>> testGenerateRefResumeVF verify rank is populated');
            
            List <Designation__c> testranks = [SELECT 
                 designation__c, Designation_Start_Date__c, Designation_End_Date__c 
                 FROM Designation__c WHERE designation__c in ('Emeritus', 'Full Referee','Assistant Referee','Candidate Referee') 
                 AND Designee__c =: contactId];
            
            System.debug('>>> testGenerateRefResumeVF testrank size ' + testranks.size());
            
            RefereeResumeController.ranks = testranks;
            
            integer ranksz = RefereeResumeController.ranks.size();
            System.assert( ranksz > 0, 'RefereeResumeController ranks -no referee ranks identified');
                        
            Date currdate = date.today();
        	integer testyear = currdate.year();
        	if(currdate.month() < 1) {
        		testyear = testyear-1;
        	}
            
            System.debug('>>> testGenerateRefResumeVF evaluate currentDataCallYear checking year ' + testyear);
            
            integer cyear = RefereeResumeController.currentDataCallYear()[RefereeResumeController.ENDDATE].year();
            System.assert(testyear == cyear,'generateRefResumeVF - calculated year does not match currentCallYear year ' + cyear);
            
            System.debug('>>> testGenerateRefResumeVF evaluate dataCallPeriod checking year');
            
            integer pyear = RefereeResumeController.dataCallPeriod(testyear)[RefereeResumeController.ENDDATE].year();
            System.assert(testyear == pyear,'generateRefResumeVF - calculated year does not match dataCallPeriod year ' + pyear);
            
            List <Regatta_Participation__c> testregattas = RefereeResumeController.getDataCallYearRegattas(contactId, cyear);
            RefereeResumeController.currRegattas = testregattas;
            System.debug('>>> testGenerateRefResumeVF currRegattas + ' + RefereeResumeController.currRegattas.size());
                
            List <Clinic_Participation__c> testclinics = RefereeResumeController.getDataCallYearClinics( contactId, cyear);
            RefereeResumeController.currClinics = testclinics;
            System.debug('>>> testGenerateRefResumeVF currClinics + ' + RefereeResumeController.currRegattas.size());
            
            string testlicyear = string.valueOf(cyear+1);
            //  List<DataCallSummaryYear> dataCallSummary(string contactId, string refereeRegion, string refereeLicenseYear)
            List<RefereeResumeController.DataCallSummaryYear> summaryyear = RefereeResumeController.dataCallSummary(contactId, resumecontact.Region__c, testlicyear );
            RefereeResumeController.rptDataCallSummaryYear = summaryyear;
            
            System.debug('>>> testGenerateRefResumeVF summary ' + summaryyear.size());
            
            RefereeResumeController.DataCallSummaryYear onerow = RefereeResumeController.getDataCallSummaryData(contactId, resumecontact.Region__c, cyear+1);
            System.debug('>>> testGenerateRefResumeVF DataCallSummaryYear ' + onerow.dcRank);
            
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