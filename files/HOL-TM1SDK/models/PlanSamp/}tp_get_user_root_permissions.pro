601,100
602,"}tp_get_user_root_permissions"
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
560,3
pGuid
pAppId
pUser
561,3
2
2
2
590,3
pGuid,"None"
pAppId,"None"
pUser,"None"
637,3
pGuid,""
pAppId,""
pUser,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,96
#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2014
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################


### This utility process is used by central applications. 
### Approval applications can also use it to get the OFFLINE permission.

## Check if the user has permissions on EDIT, OWN, OFFLINE.
StringGlobalVariable('gEdit');
StringGlobalVariable('gOwn');
StringGlobalVariable('gOffline');

gEdit = 'F';
gOwn = 'F';
gOffline = 'F';

cApplicationDim = '}tp_applications';
If (DIMIX(cApplicationDim, pAppId) = 0);
    ProcessError;
EndIf;

cApplicationElementSecurityCube = '}ElementSecurity_' | cApplicationDim;
If (CubeExists(cApplicationElementSecurityCube) = 0);
    ProcessError;
EndIf;

cRootPermissionsCube = '}tp_application_root_permissions';
cRootPermissionsCellSecurityCube = '}CellSecurity_' | cRootPermissionsCube;
If (CubeExists(cRootPermissionsCellSecurityCube) = 0);
    ProcessError;
EndIf;

If (DIMIX('}Clients', pUser) > 0);
	pUser = DimensionElementPrincipalName('}Clients', pUser);
Else;
	ProcessError;
EndIf;

vSubset='user_group_' | pGuid;
If (subsetExists('}Groups', vSubset)<>0);
	SubsetDestroy('}Groups', vSubset);
EndIf;

# If a mdx return zero item, SubsetsetCreateByMdx will throw an error
# workaround, add SecurityAdmin as a dummy member
vMDX = '{FILTER ([}Groups].Members, [}ClientGroups].( [}Clients].[' | pUser | ']) <> "" ), [}Groups].[SecurityAdmin]}';
subsetCreateByMdx(vSubset, vMDX);
SubsetElementInsert('}Groups', vSubset, 'SecurityAdmin', 0);

looper = 1;
vSubsetSize = SubsetGetSize('}Groups', vSubset);
While (looper <= vSubsetSize);
	vGroup = SubsetGetElementName ('}Groups', vSubset, looper);
	If (UPPER(vGroup) @= 'ADMIN' % UPPER(vGroup) @= 'DATAADMIN');
		gEdit = 'T';
		gOwn = 'T';
		gOffline = 'T';
	Else;
		#EDIT permission
		vSecurity = CellGetS(cApplicationElementSecurityCube, pAppId, vGroup);
		If (vSecurity @= 'READ');
			gEdit = 'T';
		EndIf;

		#OWN permission
		vSecurity = CellGetS(cRootPermissionsCellSecurityCube, pAppId, 'OWN', vGroup);
		If (vSecurity @= 'READ');
			gOwn = 'T';
		EndIf;
		
		#OFFLINE permission
		vSecurity = CellGetS(cRootPermissionsCellSecurityCube, pAppId, 'OFFLINE', vGroup);
		If (vSecurity @= 'READ');
			gOffline = 'T';
		EndIf;
	EndIf;
	
	looper = looper + 1;
End;

If (SubsetExists('}Groups', vSubset) = 1);
	SubsetDestroy('}Groups', vSubset);
EndIf;


573,1

574,1

575,1

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
