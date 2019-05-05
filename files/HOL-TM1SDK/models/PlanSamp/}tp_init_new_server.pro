601,100
602,"}tp_init_new_server"
562,"NULL"
586,
585,
564,
565,"hS0>\oHtaaJOD\jrxW\?ZFns:c`plOP[gqbv>LQ=dqStXwz=9w4`B7Qv2VK7m<D]n\extG;48<R@E:^fALaTlWVqTw?NN78vjl^_>Hg`M=?:bcaS;h`B7cKUZWbnRgw=I[PdOyb>j6ViODtoF<XmTi:u;0h=4582;:kfQMJFmLDKo7lo?p@6<ohhTz0LZQUUus8oL3wv"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,
568,""""
570,
571,
569,0
592,0
599,1000
560,2
pExecutionId
pAdminPassword
561,2
2
2
590,2
pExecutionId,"None"
pAdminPassword,"apple"
637,2
pExecutionId,""
pAdminPassword,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,86


#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2008, 2009, 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################

#*** Change the password of admin user

If (pAdminPassword @<> '');
AssignClientPassword('admin', pAdminPassword);
EndIf;

#*** Create test users

vClient = 'tp_Smith';
AddClient(vClient);

vClient = 'tp_Dale';
AddClient(vClient);

vClient = 'tp_Larry';
AddClient(vClient);

vClient = 'tp_Mike';
AddClient(vClient);

vClient = 'tp_Mary';
AddClient(vClient);

vClient = 'tp_Susan';
AddClient(vClient);

vClient = 'tp_Lisa';
AddClient(vClient);

vClient = 'tp_Jane';
AddClient(vClient);

vClient = 'tp_UK_user';
AddClient(vClient);

vClient = 'tp_Germany_user';
AddClient(vClient);

vClient = 'tp_Europe_user';
AddClient(vClient);

#*** Create test groups

vGroup = 'tp_Manager_Review';
AddGroup(vGroup);

vGroup = 'tp_Manager_Submit';
AddGroup(vGroup);

vGroup = 'tp_Corporate_Edit';
AddGroup(vGroup);

vGroup = 'tp_Corporate_Submit';
AddGroup(vGroup);

vGroup = 'tp_Operations_Edit';
AddGroup(vGroup);

vGroup = 'tp_Operations_Submit';
AddGroup(vGroup);

vGroup = 'tp_UK_submit';
AddGroup(vGroup);

vGroup = 'tp_Germany_submit';
AddGroup(vGroup);

vGroup = 'tp_Europe_submit';
AddGroup(vGroup);

573,1

574,1

575,126


#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2008, 2009, 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################


#*** Dimensions security cube

sGroupsDim = '}Groups';
sDimensionsDim = '}Dimensions';
sDimensionSecurityCube = '}DimensionSecurity';
If (CubeExists(sDimensionSecurityCube) = 0);
CubeCreate(sDimensionSecurityCube, sDimensionsDim, sGroupsDim);
CubeSetLogChanges(sDimensionSecurityCube, 1);
EndIf;

#*** Cubes security cube

sCubesDim = '}Cubes';
sCubeSecurityCube = '}CubeSecurity';
If (CubeExists(sCubeSecurityCube) = 0);
CubeCreate(sCubeSecurityCube, sCubesDim, sGroupsDim);
CubeSetLogChanges(sCubeSecurityCube, 1);
EndIf;

#*** Processes security cube

sProcessesDim = '}Processes';
sProcessSecurityCube = '}ProcessSecurity';
If (CubeExists(sProcessSecurityCube) = 0);
CubeCreate(sProcessSecurityCube, sProcessesDim, sGroupsDim);
CubeSetLogChanges(sProcessSecurityCube, 1);
EndIf;

#*** Assign password to test users

vClient = 'tp_Smith';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Dale';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Larry';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Mike';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Mary';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Susan';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Lisa';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Jane';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_UK_user';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Germany_user';
AssignClientPassword(vClient, 'apple');

vClient = 'tp_Europe_user';
AssignClientPassword(vClient, 'apple');

#*** Assign test users to test groups

vGroup = 'tp_Manager_Review';
AssignClientToGroup('tp_Smith', vGroup);
AssignClientToGroup('tp_Mary', vGroup);

vGroup = 'tp_Manager_Submit';
AssignClientToGroup('tp_Smith', vGroup);
AssignClientToGroup('tp_Mike', vGroup);

AssignClientToGroup('tp_Mary', vGroup);
AssignClientToGroup('tp_Susan', vGroup);

vGroup = 'tp_Corporate_Edit';
AssignClientToGroup('tp_Smith', vGroup);
AssignClientToGroup('tp_Mike', vGroup);
AssignClientToGroup('tp_Dale', vGroup);

AssignClientToGroup('tp_Mary', vGroup);
AssignClientToGroup('tp_Susan', vGroup);

vGroup = 'tp_Corporate_Submit';
AssignClientToGroup('tp_Mike', vGroup);
AssignClientToGroup('tp_Dale', vGroup);

AssignClientToGroup('tp_Susan', vGroup);

vGroup = 'tp_Operations_Edit';
AssignClientToGroup('tp_Lisa', vGroup);

vGroup = 'tp_Operations_Submit';
AssignClientToGroup('tp_Dale', vGroup);
AssignClientToGroup('tp_Larry', vGroup);

AssignClientToGroup('tp_Jane', vGroup);

vGroup = 'tp_UK_submit';
AssignClientToGroup('tp_UK_user', vGroup);

vGroup = 'tp_Germany_submit';
AssignClientToGroup('tp_Germany_user', vGroup);

vGroup = 'tp_Europe_submit';
AssignClientToGroup('tp_Europe_user', vGroup);


576,
930,0
638,1
804,0
1217,0
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
