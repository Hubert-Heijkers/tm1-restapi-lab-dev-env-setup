601,100
602,"}tp_upgrade_from_v9_5_2_to_v10_1"
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
560,4
pExecutionId
pAppId
pVersion
pControl
561,4
2
2
2
2
590,4
pExecutionId,"None"
pAppId,"MyApp"
pVersion,"10.1"
pControl,"N"
637,4
pExecutionId,""
pAppId,""
pVersion,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,175

#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
##################################################################


cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

#*** Log File Name
cConfigDim = cControlPrefix | 'tp_config';
If (DimensionExists(cConfigDim) = 1);
	cGenerateLog = ATTRS(cConfigDim, 'Generate TI Log', 'String Value');
Else;
	cGenerateLog = 'N';
EndIf;

cTM1Process = GetProcessName();
StringGlobalVariable('gPrologLog');
StringGlobalVariable('gEpilogLog');
StringGlobalVariable('gDataLog');

IF (cGenerateLog @= 'Y' % cGenerateLog @= 'T');
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_log_file_names', 'pExecutionId', pExecutionId,
'pProcess', cTM1Process, 'pControl', pControl);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
Endif;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#***Get approval dimension, approval subset and isActive

StringGlobalVariable('gApprovalDim');
StringGlobalVariable('gApprovalSubset');
StringGlobalVariable('gIsActive');

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_application_attributes', 'pExecutionId', pExecutionId,
	'pAppId', pAppId, 'pControl',  pControl);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', gApprovalDim, gApprovalSubset, gIsActive);
EndIf;

#***Insert CubeView 
cApplicationsDim = cControlPrefix | 'tp_applications';
cAppAttrDim = '}ElementAttributes_' | cApplicationsDim;
cCubeViewsAttr = 'CubeViews';
If (DimensionExists(cApplicationsDim) > 0);

	If (DIMIX(cAppAttrDim, cCubeViewsAttr) = 0);
		AttrInsert(cApplicationsDim, '', cCubeViewsAttr, 'S');
	EndIf;
EndIf;


#***get "everyone" group

cSystemConfigDim = cControlPrefix | 'tp_system_config';
If (DimensionExists(cSystemConfigDim) = 0);
	ProcessError;
EndIf;

cSecurityModeNode = 'IntegratedSecurityMode';
cConfigValueAttr = 'ConfigValue';
vSecurityMode = ATTRS(cSystemConfigDim, cSecurityModeNode, cConfigValueAttr);

cCognosEveryoneGroup = 'CAMID("::Everyone")';
cTpEveryoneGroup = cControlPrefix | 'tp_Everyone';
If (vSecurityMode @= '5');

	If (DIMIX('}Groups', cCognosEveryoneGroup) = 0);
		ProcessError;
	EndIf;

	cEveryoneGroup = cCognosEveryoneGroup;

Else;

	cEveryoneGroup = cTpEveryoneGroup;

	If (DIMIX('}Groups', cEveryoneGroup) = 0);
		ProcessError;
	EndIf;

EndIf;

#Grant DataReservation capabilities to the tp_everyone group
cCapabilityCube = '}Capabilities';
CellPutS('Grant', cCapabilityCube, 'ManageDataReservation', 'EXECUTE', cEveryoneGroup);
CellPutS('Grant', cCapabilityCube, 'DataReservationOverride', 'EXECUTE', cEveryoneGroup);


#***Set security
sProcessSecurityCube = '}ProcessSecurity';
cExecuteActionProc = cControlPrefix | 'tp_workflow_execute_action';
cBounceConflictUsersProc = cControlPrefix | 'tp_workflow_bounce_conflict_users';

CellPutS('Read', sProcessSecurityCube, cExecuteActionProc, cEveryoneGroup);
CellPutS('Read', sProcessSecurityCube, cBounceConflictUsersProc, cEveryoneGroup);

#*** create applicationCubes cube

cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';

sCubesDim = '}Cubes';

If (CubeExists(cApplicationCubesCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create application cubes cube');
	EndIf;

	CubeCreate(cApplicationCubesCube, cApplicationsDim, sCubesDim);
	CubeSetLogChanges(cApplicationCubesCube, 1);

EndIf;

#***
# Remove owner groups, do it first so that there are less rows to scan when upgrading security
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_clean_owner_groups', 'pExecutionId', pExecutionId, 'pApprovalDim', gApprovalDim);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_upgrade_security_pre_from_v9_5_2_to_v10_1', 'pExecutionId', pExecutionId,
	'pAppId', pAppId, 'pApprovalDim', gApprovalDim, 'pApprovalSubset', gApprovalSubset);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

cNodeInfoDim = cControlPrefix | 'tp_node_info';
cAnnotationChangeUser = 'AnnotationChangeUser';
cAnnotationChangeDate = 'AnnotationChangeDate';

If (DIMIX(cNodeInfoDim, cAnnotationChangeUser) <> 0);
	DimensionElementDelete(cNodeInfoDim, cAnnotationChangeUser);
EndIf;

If (DIMIX(cNodeInfoDim, cAnnotationChangeDate) <> 0);
	DimensionElementDelete(cNodeInfoDim, cAnnotationChangeDate);
EndIf;

#***












573,1

574,1

575,30

#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
##################################################################

cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

### Set value to version attribute
If (DIMIX(cApplicationsDim, pAppId) = 0);
	ProcessError;
EndIf;

cVersionAttr = 'Version';
AttrPutS(pVersion, cApplicationsDim, pAppId, cVersionAttr);



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
