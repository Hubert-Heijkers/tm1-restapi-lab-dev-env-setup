601,100
602,"}tp_workflow_util_reject_ancestors"
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
pTime
pAppId
pNode
561,4
2
2
2
2
590,4
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
637,4
pExecutionId,""
pTime,""
pAppId,""
pNode,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,230


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
cConfigDim = '}tp_config';
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
vReturnValue = ExecuteProcess('}tp_get_log_file_names', 'pExecutionId', pExecutionId,
'pProcess', cTM1Process, 'pControl', 'Y');
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
EndIf;

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
	vReturnValue = ExecuteProcess('}tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_APP_NOT_ACTIVE',
		'pErrorDetails', pAppId,
		'pControl', 'Y');
	
	ProcessError;
EndIf;


#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pTime, pAppId, pNode);
EndIf;

#*** Check state cube

cStateCube = '}tp_application_state}' | pAppId;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check state cube: ' | cStateCube);
EndIf;

If(CubeExists(cStateCube) = 0);
	vReturnValue = ExecuteProcess('}tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cStateCube,
		'pControl', 'Y');

	ProcessError;
EndIf;

#***

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check node: ' | pNode);
EndIf;

If (DIMIX(cShadowApprovalDim, pNode) = 0);
ProcessError;
EndIf;

#*** State constants

cNotStarted = '0';
cIncomplete = '1';
cWorkInProgress = '2';
cReady = '3';
cLocked = '4';

#*** Change node state
StringGlobalVariable('gParentInSubset');
cState= 'State';

#***
#First step: loop all parent nodes and put locked ones into a temp subset 
##the user must have Reject permission on each locked parent node
#Second Step:  unlock any locked parents in temp subset,
#Start with the top most parent lower subset index and walk down the tree

cNodeEsc = '';
If (SCAN(',', pNode) = 0);
	cNodeEsc = pNode;
Else;
	cNodeLength = LONG(pNode);
	looper = 1;
	While (looper <= cNodeLength);
		cIdChar = SUBST(pNode, looper, 1);
		If (cIdChar @= ',');
			cNodeEsc = cNodeEsc | '_';
		Else;
			cNodeEsc = cNodeEsc | cIdChar;
		EndIf;
		
		looper = looper + 1;
	End;
EndIf;

#create a temp subset
vTempSubset = 'tp_temp_parents_to_reject_' | cNodeEsc | '_' | pTime;
IF (SubsetExists(cApprovalDim, vTempSubset) >1);
	SubsetDestroy(cApprovalDim, vTempSubset);
EndIf;
SubsetCreate(cApprovalDim, vTempSubset);

vReturnValue = ExecuteProcess('}tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
	'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', pNode);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

vNodeParent = gParentInSubset;
While (vNodeParent @<> '');
	vNodeParentState = CellGetS(cStateCube, vNodeParent, cState);

	#*** Check user  privilege
	If (vNodeParentState @= cLocked);
		StringGlobalVariable('gReject');
		vReturnValue = ExecuteProcess('}tp_get_user_permissions', 
			'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode',  vNodeParent, 'pUser', TM1User, 'pControl', 'Y');
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;

		If (gReject @= 'F');
			IF (SubsetExists(cApprovalDim, vTempSubset)>0);
				SubsetDestroy(cApprovalDim, vTempSubset);	
			EndIf;

			vReturnValue = ExecuteProcess('}tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_NO_PERMISSION_DETAILS',
				'pErrorDetails', 'REJECT' | ', ' |  vNodeParent,
				'pControl', 'Y');

			ProcessError;

		EndIf;

		#Insert this parent node into a temp subset in approval dimension
		#Always insert into the first position
		SubsetElementInsert(cApprovalDim, vTempSubset, vNodeParent, 1);
	Endif;

	vReturnValue = ExecuteProcess('}tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
		'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode',  vNodeParent);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	vNodeParent = gParentInSubset;
End;

#***
#Now loop through the temp subset and reject node from top down
totalRejectNodes = SubsetGetSize(cApprovalDim, vTempSubset);
looper = 1;
While (looper <= totalRejectNodes);
	vNodeToReject = SubsetGetElementName(cApprovalDim, vTempSubset, looper);
	
	vReturnValue = ExecuteProcess('}tp_workflow_util_lock_app_node', 
		'pExecutionId', pExecutionId, 
		'pAppId', pAppId, 
		'pNode', vNodeToReject, 'pLock', 'N');
	If (vReturnValue <> ProcessExitNormal());
			ProcessError;
	EndIf;
		
	vReturnValue = ExecuteProcess('}tp_workflow_change_node_state', 
		'pExecutionId', pExecutionId,
		'pTime', pTime, 
		'pAppId', pAppId, 
		'pNode', vNodeToReject, 
		'pPrivilege', 'REJECT', 
		'pUpdateAncestorState', 'Y',
		'pControl',	'Y');
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	looper = looper +1;
End;

If (SubsetExists(cApprovalDim, vTempSubset)>0);
	SubsetDestroy(cApprovalDim, vTempSubset);	
EndIf;





573,1

574,1

575,1

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
