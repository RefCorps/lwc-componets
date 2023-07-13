// THE FOLLOWING CAN BE RUN AS ANONYMOUS APEX 
// CHECK LOGS TO REVIEW PROCESSING
// OUTPUT SHOULD APPEAR UNDER FILES

string permissionsetname = '%Referee%';
string objectname = 'Contact';
string permname = permissionsetname.replace('%', '');

System.debug(LoggingLevel.DEBUG, '\n\tpermissionsetname ' + permissionsetname);
System.debug(LoggingLevel.DEBUG, '\n\tobjectname ' + objectname);

// CALL METHOD GetAListOfObjects
//GetAListOfObjects();

// CALL METHOD GetAListOfPermissions WITH VARIED PARAMETERS
String[] permlist = new List<String>();  // Create empty list
// permlist =  GetAListOfPermissions();   // Get all PermissionSets
permlist = GetAListOfPermissions(permissionsetname);   // Get PermissionSets - uses wildcard chars
// permlist = GetAListOfPermissions(permname);  // Get PermissionSets - single defined PermissionSet

// THIS WILL LOOP OVER A LIST OF PERMISSION SETS - YOU CAN USE THIS AGAINST AN OBJECT TO CALL ALL PERMISSIONS AGAINST THAT OBJECT
//
Integer ctr = 1;
for(string pl : permlist) {
    string[] p = pl.split('\t');
    System.debug(LoggingLevel.DEBUG, 'LOOP ' + ctr + ' GetFieldPermissionByPermissionName ' + p[1] + '\t' + objectname );
    // CALL METHOD GetFieldPermissionByPermissionName 
    GetFieldPermissionByPermissionName(p[1], objectname);
    ctr = ctr + 1;
    // loop test follows - limiting to 4 should result in 4 reports
    //if (ctr > 4) {
    // break;  // used to test in single loop
    //}
}


// ------------------------------------------------------------------------------
//  METHODS FOLLOW
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
//    GET A LIST OF OBJECTS
//
public static void GetAListOfObjects() {

    System.debug(LoggingLevel.DEBUG,'>> Begin GetAListOfObjects');

    EntityDefinition[] typeresp = [
    SELECT QualifiedApiName, Label, IsRetrieveable FROM EntityDefinition 
    where IsRetrieveable = True and IsDeprecatedAndHidden = False and IsCustomizable = True
    order by QualifiedApiName 
    ];

    string EntityDefinitionNames = '';  // SEND TO PRINT
    string objectList = '(';            // OBJECT LIST THAT CAN BE USED IN SOQL
    for(EntityDefinition tr : typeresp) {

        if(objectList.length() > 4) {
            objectList = objectList + ',' + '\''  + tr.QualifiedApiName + '\'';
            EntityDefinitionNames = EntityDefinitionNames + '\n' + tr.QualifiedApiName;
        } else {
            objectList = objectList + '\''+ tr.QualifiedApiName + '\'';
            EntityDefinitionNames = EntityDefinitionNames + '\n' + tr.QualifiedApiName;
        }
        
    }
    objectList = objectList + ')';
    // System.debug(LoggingLevel.DEBUG,objectList);
   
    string title = 'EntityDefinitionNames.txt';  // alternate extension .csv
    createFile(EntityDefinitionNames,title);
    System.debug(LoggingLevel.DEBUG,'Created file title: ' + title);

    System.debug(LoggingLevel.DEBUG,'Completed GetAListOfObjects');
}

// ------------------------------------------------------------------------------
//  GET A LIST OF PERMISSIONS WHERE NAME IS NOT EMPTY
//
public static String[] GetAListOfPermissions() {

     String[] permsets = new List<String>();

    System.debug(LoggingLevel.DEBUG,'> Begin GetAListOfPermissions');
    GetAListOfPermissions('');
    System.debug(LoggingLevel.DEBUG,'< Completed GetAListOfPermissions');

    return permsets; //  GetAListOfPermissions('');
}

public static String[] GetAListOfPermissions(string permname) {

    System.debug(LoggingLevel.DEBUG,'>> Begin GetAListOfPermissions');
    
    String[] permsets = new List<String>();

    string querystmt = 'Select Id, Profile.Name, Type from PermissionSet ';    

    if(String.isNotEmpty(permname )) {
        if( permname.contains('%')) {
            querystmt = querystmt + 'where Profile.Name like \'' + permname + '\' ';
        } else {
            querystmt = querystmt + 'where Profile.Name = \'' + permname + '\' ';
        }
    }
    querystmt = querystmt + ' order by Profile.Name';

    System.debug(LoggingLevel.DEBUG, '\n------------------------\n' + querystmt + '\n------------------------\n');

    PermissionSet[] typeresp = Database.query(querystmt);

    string line = '';
    line = 'Id\t' + 
           //'Name\t' + 
           //'Label\t' + 
           //'LicenseId\t' + 
           //'ProfileId\t' + 
           'Profile.Name\t' + 
            //Description + '\t' + 
            //NamespacePrefix + '\t' + 
            //PermissionSetGroupId + '\t' + 
           'Type\n';
    string Permissions = line;

    for(PermissionSet tr : typeresp) {
        line = tr.Id + '\t' + 
            //tr.Name  + '\t' + 
            //tr.Label + '\t' + 
            //tr.LicenseId + '\t' + 
            //tr.ProfileId  + '\t' + 
            tr.Profile.Name + '\t' + 
            //tr.Description + '\t' + 
            //tr.NamespacePrefix + '\t' + 
            // tr.PermissionSetGroupId + '\t' + 
            tr.Type + '\n';
        permsets.add(tr.Id + '\t' + tr.Profile.Name + '\t' + tr.Type);    
        Permissions = Permissions + line;
        //System.debug(LoggingLevel.DEBUG, line);
    }
    
    string focus = '';
    //System.debug(LoggingLevel.DEBUG, 'permname = ' + permname);
    if( permname.contains('%')) {
        focus = permname.replace('%', '');
        focus = focus + '_wc_';
    } else if (string.isNotEmpty(permname)) {
        focus = permname + '_';
    }
    //System.debug(LoggingLevel.DEBUG, 'focus = ' + focus);

    string title = focus + 'PermissionSets.txt';  // alternate extension .csv - set delimiter to tab to view in Excel
    createFile(Permissions,title);
    System.debug(LoggingLevel.DEBUG,'Output file ' + title);

    System.debug(LoggingLevel.DEBUG,'<< Completed GetAListOfPermissions');

    return permsets;
}


// ------------------------------------------------------------------------------
//    GET FIELD PERMISSIONS BY PERMISSION NAME
//
public static string[] GetFieldPermissionByPermissionName(string permissionsetname, string objectname) {

    System.debug(LoggingLevel.DEBUG,'>> Begin GetFieldPermissionByPermissionName');

    String[] fieldpermlines = new List<String>(); 

    string querystmt = 'SELECT Id, Field, SObjectType, PermissionsRead, PermissionsEdit FROM FieldPermissions '; 
    querystmt = querystmt + 'WHERE parentId IN ( '; 
    querystmt = querystmt + 'select Id from PermissionSet where Profile.Name = \''  + permissionsetname + '\'' ;
    // querystmt = querystmt + 'select Id from PermissionSet where Profile.Name = \'Referee\'';
    querystmt = querystmt + ') ';
    querystmt = querystmt + ' and SObjectType = \'' + objectname + '\'' ;
    //System.debug(LoggingLevel.DEBUG, '\n------------------------\n' + querystmt + '\n------------------------\n');

    FieldPermissions[] fieldperm = Database.query(querystmt);
    // System.debug(LoggingLevel.DEBUG,'Size of returned fieldperm =  ' + fieldperm.size() );

    string line  = '';
    string rptline = 'Field\tProfile\tRead\tEdit\n';
    for(FieldPermissions fp : fieldperm) {
        line = fp.Field  + '\t' + permissionsetname  + '\t' +  fp.PermissionsRead  + '\t' + fp.PermissionsEdit; 
        rptline = rptline + line + '\n';
        //System.debug(LoggingLevel.DEBUG, 'LINE\t' + line);   
        fieldpermlines.Add(line);
    }

    string title = 'perms_' + permissionsetname + '_' + objectname + '.txt';
    createFile(rptline, title);  
    System.debug(LoggingLevel.DEBUG,'Output file ' + title);

    System.debug(LoggingLevel.DEBUG,'Completed GetFieldPermissionByPermissionName');

    return fieldpermlines;
}

// ------------------------------------------------------------------------------
//    Create a file under Files Owned By Me
//
public static void createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;
}
