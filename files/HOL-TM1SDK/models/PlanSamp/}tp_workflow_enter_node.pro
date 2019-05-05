601,100
602,"}tp_workflow_enter_node"
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
572,244


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


#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pTime, pAppId, pNode, pControl);
EndIf;

#***

cDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
If (cDisplayUserName @= '');
	cDisplayUserName = TM1User;
EndIf;

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


#***

if (cShadowApprovalDim @= '');
	cStateCube = cControlPrefix | 'tp_central_application_state';
	cStateMember = pAppId;
Else;

	#* Check node
	If (DIMIX(cShadowApprovalDim, pNode) = 0);
		ProcessError;
	EndIf;
	
	cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
	cStateMember = pNode;
EndIf;


If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check state cube: ' | cStateCube);
EndIf;

If (CubeExists(cStateCube) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cStateCube,
		'pControl', pControl);
	
	ProcessError;
EndIf;

#*** Check user view privilege
if (cShadowApprovalDim @<> '');
	StringGlobalVariable('gView');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
		'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', pNode, 'pUser', TM1User, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	If (gView @= 'F');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_NO_PERMISSION',
			'pErrorDetails', 'VIEW' | ', ' | pNode,
			'pControl', pControl);
		
		ProcessError;
	EndIf;
EndIf;

#*** Set state viewed
cViewed = 'Viewed';
CellPutS('Y', cStateCube, cStateMember, cViewed);

#*** Set state reviewed

cLocked = '4';
cState = 'State';
vValue = CellGetS(cStateCube, cStateMember, cState);

if (cShadowApprovalDim @<> '');
	StringGlobalVariable('gReject');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
		'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', pNode, 'pUser', TM1User, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	If (vValue @= cLocked & gReject @= 'T');
		cReviewed = 'Reviewed';
		CellPutS('Y', cStateCube, cStateMember, cReviewed);
	EndIf;
EndIf;

#*** Check owner
cWorkInProgress = '2';
cState = 'State';
cBeingEdited = 'BeingEdited';
cStartEditingDate = 'StartEditingDate';
cOffline = 'Offline';
If (cShadowApprovalDim @= '' % DTYPE(cShadowApprovalDim, pNode) @= 'N');
	vValue = CellGetS(cStateCube, cStateMember, cState);
	If (vValue @= cWorkInProgress);
		cCurrentOwner = 'CurrentOwnerId';
		cOwner = CellGetS(cStateCube, cStateMember, cCurrentOwner);
		If (TM1User @= cOwner);
	
			CellPutS('Y', cStateCube, cStateMember, cBeingEdited);
			CellPutS(pTime, cStateCube, cStateMember, cStartEditingDate);
			
			#*** Clear offline status
			CellPutS('', cStateCube, cStateMember, cOffline);
	
		EndIf;
	EndIf;
ElseIf (cShadowApprovalDim @<> '');
	
	#*** Escape the node to ensure valid MDX
	StringGlobalVariable('gEscapedId');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_util_escape_id', 
		'pExecutionId', pExecutionId, 'pNode', pNode, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Escaped Node name: ' | gEscapedId);
	EndIf;
						
	### Enter all leaf nodes under consolidation node
	vMDX = '{INTERSECT(TM1FILTERBYLEVEL({DESCENDANTS([' | cShadowApprovalDim | '].[' | gEscapedId | ']) }, 0), TM1SUBSETTOSET([' | cShadowApprovalDim | '], "' | cApprovalSubset |'")), ['
		| cShadowApprovalDim | '].[' | gEscapedId | ']}';
	vSubset = 'enterNode_onConsolidation_' | pExecutionId;
	If (SubsetExists(cShadowApprovalDim, vSubset) <> 0);
		SubsetDestroy(cShadowApprovalDim, vSubset);
	EndIf;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'SubsetCreateByMdx(vSubset, vMDX);:', vMDX);
	EndIf;
	SubsetCreateByMdx(vSubset, vMDX);
	SubsetElementInsert(cShadowApprovalDim, vSubset, pNode, 0);

	vSize = SubsetGetSize(cShadowApprovalDim, vSubset);
	looper = vSize;
	While (looper >=1);
		vNode = SubsetGetElementName(cShadowApprovalDim, vSubset, looper);

		IF (vNode @<> pNode);
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Enter descendant node ' | vNode);
			EndIf;

			vState = CellGetS(cStateCube, vNode, cState);	
			cCurrentOwner = 'CurrentOwnerId';
			cOwner = CellGetS(cStateCube, vNode, cCurrentOwner);
			If (TM1User @= cOwner & vState @= cWorkInProgress);
	
				CellPutS('Y', cStateCube, vNode, cBeingEdited);
				CellPutS(pTime, cStateCube, vNode, cStartEditingDate);
			
				#*** Clear offline status
				CellPutS('', cStateCube, vNode, cOffline);
			EndIf;
		EndIf;
		
		looper = looper -1;
	End;
EndIf;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,21


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
#################################################################


IF (SubsetExists(cShadowApprovalDim, vSubset) <>0);
	SubsetDestroy(cShadowApprovalDim, vSubset);
ENDIF;

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
