601,100
602,"}tp_workflow_change_node_state"
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
560,7
pExecutionId
pTime
pAppId
pNode
pPrivilege
pUpdateAncestorState
pControl
561,7
2
2
2
2
2
2
2
590,7
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
pPrivilege,"EDIT"
pUpdateAncestorState,"Y"
pControl,"N"
637,7
pExecutionId,""
pTime,""
pAppId,""
pNode,""
pPrivilege,""
pUpdateAncestorState,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,288

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

#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pTime, pAppId, pNode, pPrivilege, pControl);
EndIf;

#***

cDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
If (cDisplayUserName @= '');
	cDisplayUserName = TM1User;
EndIf;

#*** 

cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check state cube: ' | cStateCube);
EndIf;

If (CubeExists(cStateCube) = 0);
	ProcessError;
EndIf;

#*** 

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Make sure node is in approval dimension: ' | pNode);
EndIf;

If (DIMIX(cShadowApprovalDim, pNode) = 0);
	ProcessError;
EndIf;

#*** 

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Make sure the privilege can change state: ' | pPrivilege);
EndIf;

If ((UPPER(pPrivilege) @<> 'EDIT') & (UPPER(pPrivilege) @<> 'RELEASE') & (UPPER(pPrivilege) @<> 'REJECT') & (UPPER(pPrivilege) @<> 'SUBMIT') & (UPPER(pPrivilege) @<> 'BOUNCE'));
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_NO_PERMISSION',
		'pErrorDetails', pPrivilege | ', ' | pNode,
		'pControl', pControl);

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
cStateChangeUser = 'StateChangeUser';
cStateChangeDate = 'StateChangeDate';

cNodeState = CellGetS(cStateCube, pNode, cState);

vStateChanged = 0;
If (UPPER(pPrivilege) @= 'EDIT');

	If (DTYPE(cShadowApprovalDim, pNode) @<> 'N');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_NODE_TYPE',
			'pErrorDetails', pPrivilege | ', ' | 'Consolidation',
			'pControl', pControl);
	
		ProcessError;
	EndIf;

	If ((cNodeState @= '') % (cNodeState @= cNotStarted));
		CellPutS(cWorkInProgress, cStateCube, pNode, cState);
		vStateChanged = 1;
	
	ElseIf (cNodeState @= cWorkInProgress);
		# Do nothing
	Else;
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', pPrivilege | ', ' | cNodeState,
			'pControl', pControl);
		
		ProcessError;
	EndIf;
ElseIf (UPPER(pPrivilege) @= 'RELEASE');

	If (DTYPE(cShadowApprovalDim, pNode) @<> 'N');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_NODE_TYPE',
			'pErrorDetails', pPrivilege | ', ' | 'Consolidation',
			'pControl', pControl);
	
		ProcessError;
	EndIf;

	If (cNodeState @<> cWorkInProgress);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', pPrivilege | ', ' | cNodeState,
			'pControl', pControl);
		
		ProcessError;
	Else;
		CellPutS(cNotStarted, cStateCube, pNode, cState);
		vStateChanged = 1;
	EndIf;
ElseIf (UPPER(pPrivilege) @= 'REJECT');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
		'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', pNode);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	If (cNodeState @<> cLocked);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', pPrivilege | ', ' | cNodeState,
			'pControl', pControl);
		
		ProcessError;
	EndIf;

	If (DTYPE(cShadowApprovalDim, pNode) @= 'N');
		CellPutS(cNotStarted, cStateCube, pNode, cState);
	Else;
		CellPutS(cReady, cStateCube, pNode, cState);
	EndIf;

	vStateChanged = 1;
ElseIf (UPPER(pPrivilege) @= 'SUBMIT');

	If (cNodeState @= cLocked);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', pPrivilege | ', ' | cNodeState,
			'pControl', pControl);
		
		ProcessError;
	EndIf;

	If (DTYPE(cShadowApprovalDim, pNode) @= 'N');
		CellPutS(cLocked, cStateCube, pNode, cState);
	Else;

		If (cNodeState @<> cReady);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_WRONG_STATE',
				'pErrorDetails', pPrivilege | ', ' | cNodeState | ', ' | 'Consolidation',
				'pControl', pControl);
			
			ProcessError;
		EndIf;

		CellPutS(cLocked, cStateCube, pNode, cState);

	EndIf;

	vStateChanged = 1;
ElseIf (UPPER(pPrivilege) @= 'BOUNCE');

	If (DTYPE(cShadowApprovalDim, pNode) @<> 'N');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
			'pGuid', pExecutionId,
			'pProcess', cTM1Process,
			'pErrorCode', 'TI_WRONG_NODE_TYPE',
			'pErrorDetails', pPrivilege | ', ' | 'Consolidation',
			'pControl', pControl);
		
		ProcessError;
	EndIf;

	If ((cNodeState @= '') % (cNodeState @=cWorkInProgress ));
		CellPutS(cNotStarted, cStateCube, pNode, cState);
		vStateChanged = 1;
	
	Else;
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
			'pGuid', pExecutionId,
			'pProcess', cTM1Process,
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', pPrivilege | ', ' | cNodeState,
			'pControl', pControl);
		
		ProcessError;
	EndIf;
EndIf;

#*** If state is changed, set values.
If (vStateChanged = 1);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'State has been changed: ' | pNode);
	EndIf;

	CellPutS(cDisplayUserName, cStateCube, pNode, cStateChangeUser);
	
	CellPutS(pTime, cStateCube, pNode, cStateChangeDate);

EndIf;


#*** No error
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,232


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

#*** 
If (vStateChanged = 1 & (pUpdateAncestorState @= 'T' % pUpdateAncestorState @= 'Y'));

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Change parent state');
	EndIf;

	cApprovalDimSize = DIMSIZ(cShadowApprovalDim);
	cApprovalSize = SubsetGetSize(cShadowApprovalDim, cApprovalSubset);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Subset size', cApprovalSubset, NumberToString(cApprovalSize));
	EndIf;

	If (UPPER(pPrivilege) @= 'EDIT');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Privilege is EDIT');
		EndIf;

		vParent = pNode;
		vIndexI = 1;
		While (vIndexI <= cApprovalDimSize);

			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
				'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', vParent);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			vParent = gParentInSubset;

			If (vParent @= '');
				
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Loop stopped');
				EndIf;

				vIndexI = cApprovalDimSize + 1;
			EndIf;

			If (vIndexI <= cApprovalDimSize);

				vAllWorkInProgressOrLocked = 1;
				vIndexJ = 1;

				While (vIndexJ <= cApprovalSize);
				
					vElement = SubsetGetElementName(cShadowApprovalDim, cApprovalSubset, vIndexJ);
				
					If (ELISPAR(cShadowApprovalDim, vParent, vElement) = 1);
						
						vSiblingValue = CellGetS(cStateCube, vElement, cState);
						If (vSiblingValue @= cNotStarted % vSiblingValue @= cIncomplete);
							vAllWorkInProgressOrLocked = 0;
							vIndexJ = cApprovalSize;
						EndIf;

					EndIf;

					vIndexJ = vIndexJ + 1;
				End;

				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'State has been changed: ' | vParent);
				EndIf;

				If (vAllWorkInProgressOrLocked = 1);
					CellPutS(cWorkInProgress, cStateCube, vParent, cState);
					CellPutS(cDisplayUserName, cStateCube, vParent, cStateChangeUser);
					CellPutS(pTime, cStateCube, vParent, cStateChangeDate);
				Else;
					CellPutS(cIncomplete, cStateCube, vParent, cState);
					CellPutS(cDisplayUserName, cStateCube, vParent, cStateChangeUser);
					CellPutS(pTime, cStateCube, vParent, cStateChangeDate);
				EndIf;

			EndIf;

			vIndexI = vIndexI + 1;
		End;
	ElseIf ((UPPER(pPrivilege) @= 'BOUNCE') % (UPPER(pPrivilege) @= 'RELEASE'));
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Privilege is BOUNCE or RELEASE');
		EndIf;

		vParent = pNode;
		vIndexI = 1;
		While (vIndexI <= cApprovalDimSize);

			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
				'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', vParent);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			vParent = gParentInSubset;

			If (vParent @= '');
			
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Loop stopped');
				EndIf;

				vIndexI = cApprovalDimSize + 1;
			EndIf;

			If (vIndexI <= cApprovalDimSize);

				vAllNotStarted = 1;
				vIndexJ = 1;
				
				While (vIndexJ <= cApprovalSize);

					vElement = SubsetGetElementName(cShadowApprovalDim, cApprovalSubset, vIndexJ);

					If (ELISPAR(cShadowApprovalDim, vParent, vElement) = 1);
					
						vSiblingValue = CellGetS(cStateCube, vElement, cState);
						If (vSiblingValue @= cWorkInProgress % vSiblingValue @= cIncomplete % vSiblingValue @=cLocked % vSiblingValue @=cReady);
							vAllNotStarted= 0;
							vIndexJ = cApprovalSize;
						EndIf;

					EndIf;

					vIndexJ = vIndexJ + 1;
				End;

				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'State has been changed: ' | vParent);
				EndIf;

				If (vAllNotStarted = 1);
					CellPutS(cNotStarted, cStateCube, vParent, cState);
					CellPutS(cDisplayUserName, cStateCube, vParent, cStateChangeUser);
					CellPutS(pTime, cStateCube, vParent, cStateChangeDate);
				Else;
					CellPutS(cIncomplete, cStateCube, vParent, cState);
					CellPutS(cDisplayUserName, cStateCube, vParent, cStateChangeUser);
					CellPutS(pTime, cStateCube, vParent, cStateChangeDate);
				EndIf;

			EndIf;

			vIndexI = vIndexI + 1;
		End;
	ElseIf (UPPER(pPrivilege) @= 'REJECT');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Privilege is REJECT');
		EndIf;
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
			'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', pNode);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;

		cNodeParent = gParentInSubset;
		If (cNodeParent @= '');
			cNodeParentState = '';
		Else;
			cNodeParentState = CellGetS(cStateCube, cNodeParent, cState);
		EndIf;

		If (cNodeParentState @= cReady);
			CellPutS(cWorkInProgress, cStateCube, cNodeParent, cState);
			CellPutS(cDisplayUserName, cStateCube, cNodeParent, cStateChangeUser);
			CellPutS(pTime, cStateCube, cNodeParent, cStateChangeDate);
		EndIf;
	ElseIf (UPPER(pPrivilege) @= 'SUBMIT');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Privilege is SUBMIT');
		EndIf;

		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_parent_in_subset', 'pExecutionId', pExecutionId,
			'pDim', cShadowApprovalDim, 'pSubset', cApprovalSubset, 'pNode', pNode);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;

		cNodeParent = gParentInSubset;

		vAllChildrenLocked = 1;
		vIndex = 1;
		
		While (vIndex <= cApprovalSize);

			vElement = SubsetGetElementName(cShadowApprovalDim, cApprovalSubset, vIndex);
			
			If (ELISPAR(cShadowApprovalDim, cNodeParent, vElement) = 1);
			
				vSiblingValue = CellGetS(cStateCube, vElement, cState);
				If (vSiblingValue @<> cLocked);
					vAllChildrenLocked = 0;
					vIndex = cApprovalSize;
				EndIf;
			
			EndIf;

			vIndex = vIndex + 1;
		End;

		If (vAllChildrenLocked = 1 & cNodeParent @<> '');
			CellPutS(cReady, cStateCube, cNodeParent, cState);
			CellPutS(cDisplayUserName, cStateCube, cNodeParent, cStateChangeUser);
			CellPutS(pTime, cStateCube, cNodeParent, cStateChangeDate);
		EndIf;
	EndIf;
EndIf;

#*** No error
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
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
