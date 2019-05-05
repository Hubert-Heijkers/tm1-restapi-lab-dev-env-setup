601,100
602,"}tp_workflow_submit_node"
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
560,5
pExecutionId
pTime
pAppId
pNode
pControl
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
pControl,"N"
637,5
pExecutionId,""
pTime,""
pAppId,""
pNode,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,220


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

#***
cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cIsActive =ATTRS('}tp_applications', pAppId, 'IsActive');
cShadowApprovalDim =ATTRS('}tp_applications', pAppId, 'ApprovalShadowDimension');

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cIsActive,cShadowApprovalDim );
EndIf;

If (cIsActive @<> 'Y');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_APP_NOT_ACTIVE',
		'pErrorDetails', pAppId,
		'pControl', pControl);
	
	ProcessError;
EndIf;


#*** Log Parameters

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pTime, pAppId, pNode, pControl);
EndIf;

#***

cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Check state cube: ' | cStateCube);
EndIf;

If(CubeExists(cStateCube) = 0);
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
'pGuid', pExecutionId, 
'pProcess', cTM1Process, 
'pErrorCode', 'TI_CUBE_NOT_EXIST',
'pErrorDetails', cStateCube,
'pControl', pControl);

ProcessError;
EndIf;

#***

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Check node: ' | pNode);
EndIf;

If (DIMIX(cShadowApprovalDim, pNode) = 0);
ProcessError;
EndIf;

#*** Check user  privilege
StringGlobalVariable('gSubmit');
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', pNode, 'pUser', TM1User, 'pControl', pControl);
If (vReturnValue <> ProcessExitNormal());
ProcessError;
EndIf;

If (gSubmit @= 'F');
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
'pGuid', pExecutionId, 
'pProcess', cTM1Process, 
'pErrorCode', 'TI_NO_PERMISSION',
'pErrorDetails', 'SUBMIT' | ', ' | pNode,
'pControl', pControl);

ProcessError;
EndIf;

#*** Check node state

cLocked = '4';
cState = 'State';
vValue = CellGetS(cStateCube, pNode, cState);
If (vValue @= cLocked);
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
'pGuid', pExecutionId, 
'pProcess', cTM1Process, 
'pErrorCode', 'TI_WRONG_STATE',
'pErrorDetails', 'Submit' | ', ' | pNode | ', ' | vValue,
'pControl', pControl);

ProcessError;
EndIf;

#*** Check node state

cWorkInProgress = '2';
cReady = '3';
cState = 'State';
vValue = CellGetS(cStateCube, pNode, cState);
If ((vValue @<> cReady) & (vValue @<> cWorkInProgress));
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
'pGuid', pExecutionId, 
'pProcess', cTM1Process, 
'pErrorCode', 'TI_WRONG_STATE',
'pErrorDetails', 'Submit' | ', ' | pNode | ', ' | vValue,
'pControl', pControl);

ProcessError;
EndIf;

#***Check ownership level
cOwnershipNode = 'TakeOwnershipNode';
vOwnershipNode = CellGetS(cStateCube, pNode, cOwnershipNode);
If (DTYPE(cShadowApprovalDim, pNode) @= 'N' & vOwnershipNode @<> pNode);

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_WRONG_OWNERSHIP_LEVEL',
		'pErrorDetails', 'Submit' | ', ' | pNode | ', ' | vValue,
		'pControl', pControl);
	ProcessError;
ENDIF;

#*** Remove being-edited status

cBeingEdited = 'BeingEdited';
cOffline = 'Offline';
CellPutS('', cStateCube, pNode, cBeingEdited);
CellPutS('', cStateCube, pNode, cOffline);

cStartEditingDate = 'StartEditingDate';
CellPutS('', cStateCube, pNode, cStartEditingDate);

#*** Change state

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_change_node_state', 'pExecutionId', pExecutionId,
'pTime', pTime, 'pAppId', pAppId, 'pNode', pNode, 'pPrivilege', 'SUBMIT','pUpdateAncestorState', 'Y', 'pControl', pControl);
If (vReturnValue <> ProcessExitNormal());
ProcessError;
EndIf;

#*** Reserve approval node slice using TM1 data reservation
ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
		'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'N', 'pUser', TM1User(), 'pControl', pControl);

#***Lock slice
cApplicationCubesCube = '}tp_application_cubes';
totalCubes = DIMSIZ('}Cubes');
indexCube = 1;

While (indexCube <= totalCubes);
	cCubeName = DIMNM('}Cubes', indexCube);
	cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);
	cCubeAddress = '';
	addConcatSymbol = 0;
	If (cIsAppCube @= 'A');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_util_lock_cube_slices', 'pExecutionId', pExecutionId, 'pAppId', pAppId, 
			'pCube', cCubeName, 'pApprovalDim', cApprovalDim, 'pNode', pNode, 'pLock', 'Y','pControlDim','','pControlWritableSlices', '');
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	EndIf;
	indexCube = indexCube +1;
End;


#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
EndIf;

573,1

574,1

575,45
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



#*** Log File Name
cTM1Log = cEpilogLog;

#*** Set children to be reviewed

cApprovalDimSize = DIMSIZ(cShadowApprovalDim);

cReviewed = 'Reviewed';

If (DTYPE(cShadowApprovalDim, pNode) @= 'C');

vIndex = 1;
While (vIndex <= cApprovalDimSize);
vElement = DIMNM(cShadowApprovalDim, vIndex);
If (ELISPAR(cShadowApprovalDim, pNode, vElement) = 1);
CellPutS('Y', cStateCube, vElement, cReviewed);
EndIf;

vIndex = vIndex + 1;
End;

EndIf;

#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
EndIf;

576,
930,0
638,1
804,0
1217,1
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
