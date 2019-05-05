601,100
602,"}tp_workflow_release_node"
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
560,6
pExecutionId
pTime
pAppId
pNode
pUser
pControl
561,6
2
2
2
2
2
2
590,6
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
pUser,"NA"
pControl,"N"
637,6
pExecutionId,""
pTime,""
pAppId,""
pNode,""
pUser,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,367
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

vIsAdmin = CellGetS('}ClientGroups', TM1User, 'ADMIN');

#*** If an owner was specified then the caller must be an admin, 
If (pUser @<> '' & vIsAdmin @= '');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_NO_PERMISSION',
		'pErrorDetails', TM1User,
		'pControl', pControl);
	
	ProcessError;
EndIf;

cDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
If (cDisplayUserName @= '');
	cDisplayUserName = TM1User;
EndIf;

#*** 

If (cShadowApprovalDim @= '');
	cStateCube = cControlPrefix | 'tp_central_application_state';
	cStateMember = pAppId;
Else;

	#* Check node
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Check node: ' | pNode);
	EndIf;
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

#*** 

#constant
cLocked = '4';
cNotStarted = '0';
cWorkInProgress = '2';
cState = 'State';

cCurrentOwner = 'CurrentOwner';
cCurrentOwnerId = 'CurrentOwnerId';
cTakeOwnershipNode = 'TakeOwnershipNode';
cBeingEdited = 'BeingEdited';
cOffline = 'Offline';
cStateChangeUser = 'StateChangeUser';
cStateChangeDate = 'StateChangeDate';

#****
If (cShadowApprovalDim @<> '');
	pNode = DimensionElementPrincipalName(cShadowApprovalDim, pNode);
EndIf;

# If at the leaf level
If (cShadowApprovalDim @= '' % DTYPE(cShadowApprovalDim, pNode) @='N');

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Check node state');
	EndIf;
	vStateValue = CellGetS(cStateCube, cStateMember, cState);

	If (vStateValue @<> cWorkInProgress);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_STATE',
			'pErrorDetails', 'Release' | ', ' | pNode | ', ' | vStateValue,
			'pControl', pControl);
		
		ProcessError;
	EndIf;

	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Get current ownerID and ownershipNode');
	EndIf;
	
	vCurrentOwner = CellGetS(cStateCube, cStateMember, cCurrentOwner);
	vCurrentOwnerId = CellGetS(cStateCube, cStateMember, cCurrentOwnerId);
	vOwnershipNode = CellGetS(cStateCube, cStateMember, cTakeOwnershipNode);
	
	#*** When no user is specified, admins are releasing current owner
	If (pUser @= '');
		If (vIsAdmin @<> '');
			pUser = vCurrentOwnerId;
		Else;
			pUser = TM1User;
		EndIf;
	EndIf;
	
	If (pUser @<> vCurrentOwnerId);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_OWNER',
			'pErrorDetails', 'Release' | ', ' | pNode | ', ' | vCurrentOwner,
			'pControl', pControl);
		
		ProcessError;
	EndIf;
	
	If (cShadowApprovalDim @<> '' & pNode @<> vOwnershipNode);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_WRONG_OWNERSHIP_LEVEL',
			'pErrorDetails', 'Release' | ', ' | pNode | ', ' | vCurrentOwner,
			'pControl', pControl);
		
		ProcessError;
	EndIf;
		
	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Release owner data slice');
	EndIf;

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
			'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'N', 'pUser', pUser, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	#*** 
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Clear ownership fields');
	EndIf;

	CellPutS('', cStateCube, cStateMember, cCurrentOwner);
	CellPutS('', cStateCube, cStateMember, cCurrentOwnerId);
	CellPutS('', cStateCube, cStateMember, cTakeOwnershipNode);
	CellPutS('', cStateCube, cStateMember, cBeingEdited);
	CellPutS('', cStateCube, cStateMember, cOffline);
	
	If (cShadowApprovalDim @= '');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Set state');
		EndIf;
		CellPutS(cNotStarted, cStateCube, cStateMember, cState);
		CellPutS(cDisplayUserName, cStateCube, cStateMember, cStateChangeUser);
		CellPutS(pTime, cStateCube, cStateMember, cStateChangeDate);
	Else;
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Change state');
		EndIf;
	
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_change_node_state', 'pExecutionId', pExecutionId, 
			'pTime', pTime, 'pAppId', pAppId, 'pNode', pNode, 'pPrivilege', 'RELEASE', 'pUpdateAncestorState', 'Y','pControl', pControl);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	EndIf;

# Else at a consolidation
Else;

	# If no user was specified, then the current user's ownership is being released
	If (pUser @= '');
		pUser = TM1User;
	EndIf;
	
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

	# Take care of the leaf nodes in the package
	vMDX = '{INTERSECT(TM1FILTERBYLEVEL({DESCENDANTS([' | cShadowApprovalDim | '].[' | gEscapedId | ']) }, 0), TM1SUBSETTOSET([' | cShadowApprovalDim | '],"' | cApprovalSubset | '")), ['
		| cShadowApprovalDim | '].[' | gEscapedId | ']}';
	vSubsetLeafChildren = 'takeOwnership_onConsolidation_' | pExecutionId;
	If (SubsetExists(cShadowApprovalDim, vSubsetLeafChildren) <>0);
		SubsetDestroy(cShadowApprovalDim, vSubsetLeafChildren);
	EndIf;
	SubsetCreateByMdx(vSubsetLeafChildren, vMDX);
	SubsetElementInsert(cShadowApprovalDim, vSubsetLeafChildren, pNode, 0);
	vSize = SubsetGetSize(cShadowApprovalDim, vSubsetLeafChildren);
	vUpdateAncestorState = 'Y';
	IF (vSize > 100);
		vUpdateAncestorState = 'N';
	EndIf;
	looper = vSize;
	vLeafOwnedAtRightLevel = 0;
	While (looper >=1);
		vLeafChild = SubsetGetElementName(cShadowApprovalDim, vSubsetLeafChildren, looper);

		#leaf node, not the dummy node
		IF (vLeafChild @<> pNode);

			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Check status for leaf node: ' | vLeafChild);
			EndIf;
			vStateValue = CellGetS(cStateCube, vLeafChild, cState);
			vCurrentOwnerId = CellGetS(cStateCube, vLeafChild, cCurrentOwnerId);
			vOwnershipNode = CellGetS(cStateCube, vLeafChild, cTakeOwnershipNode);
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Status for leaf node: ' | vLeafChild | ' State=' | vStateValue | ' OwnerId=' | vCurrentOwnerId | ' OwnershipNode=' | vOwnershipNode);
			EndIf;

			# If the current user is the owner of this node take at the consolidation we can release it
			If ((vStateValue @= cWorkInProgress) & (pUser @= vCurrentOwnerId) & (pNode @= vOwnershipNode));


				#*** 
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Clear leaf node ownership fields');
				EndIf;
			
				CellPutS('', cStateCube, vLeafChild, cCurrentOwner);
				CellPutS('', cStateCube, vLeafChild, cCurrentOwnerId);
				CellPutS('', cStateCube, vLeafChild, cTakeOwnershipNode);
				CellPutS('', cStateCube, vLeafChild, cBeingEdited);
				CellPutS('', cStateCube, vLeafChild, cOffline);
						
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Change leaf node state');
				EndIf;
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_change_node_state', 'pExecutionId', pExecutionId, 
					'pTime', pTime, 'pAppId', pAppId, 'pNode', vLeafChild, 'pPrivilege', 'RELEASE', 'pUpdateAncestorState', vUpdateAncestorState, 'pControl', pControl);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
				vLeafOwnedAtRightLevel = vLeafOwnedAtRightLevel +1;
							
			EndIF;
		EndIf;
	
		looper = looper -1;
	End;

	If (vLeafOwnedAtRightLevel =0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_NO_LEAF_OWNED_AT_RIGHT_LEVEL',
			'pErrorDetails', 'Release' | ', ' | pNode,
			'pControl', pControl);
		
		ProcessError;
	EndIf;

	#If we didn't update ancestors' state for an individual leaf node, we must update all consolidated nodes now
	If (vUpdateAncestorState @= 'N');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_update_state_cube', 'pGuid', pExecutionId,'pAppId', pAppId,'pUpdateLeafState', 'N', 'pControl', pControl);
								
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	EndIf;

	#remove DR on consolidated node
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
		'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'N', 'pUser', vCurrentOwnerId, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Finished checking for leaf nodes');
	EndIf;
	
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
## (C) Copyright IBM Corp. 2008, 2009
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################


IF (SubsetExists(cShadowApprovalDim, vSubsetLeafChildren) <>0);
	SubsetDestroy(cShadowApprovalDim, vSubsetLeafChildren);
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
