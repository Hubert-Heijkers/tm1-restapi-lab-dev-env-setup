601,100
602,"}tp_workflow_util_own_node"
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
560,8
pExecutionId
pTime
pAppId
pNode
pNewOwnerID
pCheckBouncingOnly
pBouncingMode
pControl
561,8
2
2
2
2
2
2
2
2
590,8
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
pNewOwnerID,"None"
pCheckBouncingOnly,"N"
pBouncingMode,"NEVER"
pControl,"N"
637,8
pExecutionId,""
pTime,""
pAppId,""
pNode,""
pNewOwnerID,""
pCheckBouncingOnly,""
pBouncingMode,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,552
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

If (cGenerateLog @= 'Y' % cGenerateLog @= 'T');
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

cDisplayUserName = ATTRS('}Clients', pNewOwnerID, '}TM1_DefaultDisplayValue');
If (cDisplayUserName @= '');
	cDisplayUserName = pNewOwnerID;
EndIf;
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Current user is ' | cDisplayUserName);
EndIf;

#*** 

if (cShadowApprovalDim @= '');
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

#constant
cLocked = '4';
cWorkInProgress = '2';
cState = 'State';

cCurrentOwner = 'CurrentOwner';
cCurrentOwnerId = 'CurrentOwnerId';
cTakeOwnershipNode = 'TakeOwnershipNode';
cStateChangeUser = 'StateChangeUser';
cStateChangeDate = 'StateChangeDate';
cBeingEdited = 'BeingEdited';

#****
StringGlobalVariable('gShowBouncingMessage');
StringGlobalVariable('gBouncingType');
gShowBouncingMessage = 'N';
gBouncingType = 'OWN';
#****

If (cShadowApprovalDim @<> '');
	pNode = DimensionElementPrincipalName(cShadowApprovalDim, pNode);
EndIf;

If (cShadowApprovalDim @= '' % DTYPE(cShadowApprovalDim, pNode) @='N');

	cStateValue = CellGetS(cStateCube, cStateMember, cState);
	vOwnerId = CellGetS(cStateCube, cStateMember, cCurrentOwnerId);

	If (pNewOwnerID @<> vOwnerId % cStateValue @<> cWorkInProgress);

		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Check node state');
		EndIf;

		If (cStateValue @= cLocked);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_WRONG_STATE',
				'pErrorDetails', 'Own' | ', ' | pNode | ', ' | cStateValue,
				'pControl', pControl);
			
			ProcessError;
		EndIf;

		#*** 
		If (cShadowApprovalDim @<> '');
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Check user privilege');
			EndIf;
	
			StringGlobalVariable('gEdit');
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
				'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', pNode, 'pUser', pNewOwnerID, 'pControl', pControl);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
	
			If (gEdit @= 'F');
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
					'pGuid', pExecutionId, 
					'pProcess', cTM1Process, 
					'pErrorCode', 'TI_NO_PERMISSION',
					'pErrorDetails', 'EDIT' | ', ' | pNode,
					'pControl', pControl);
				
				ProcessError;
			EndIf;
		EndIf;

		#***
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Get current ownerID and ownershipNode');
		EndIf;
		
		vOwnerIdToBounce = CellGetS(cStateCube, cStateMember, cCurrentOwnerId);
		vOwnershipNodeToBounce = CellGetS(cStateCube, cStateMember, cTakeOwnershipNode);

		IF (pNewOwnerID @<> vOwnerId & cStateValue @= cWorkInProgress & pCheckBouncingOnly @= 'Y');

			IF ((pBouncingMode @= 'ALWAYS' % pBouncingMode @='ACTIVE'));
												
				#bouncing messages for taking ownership action
				vEdited = CellGetS(cStateCube, cStateMember, cBeingEdited);
				If (vEdited @= 'Y');
					vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
					'pGuid', pExecutionId, 
					'pProcess', cTM1Process, 
					'pErrorCode', 'NODE_OWNER_ACTIVE',
					'pErrorDetails', pAppId,
					'pControl', pControl);
					gShowBouncingMessage = 'Y';
				ElseIf (pBouncingMode @= 'ALWAYS');
					vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
					'pGuid', pExecutionId, 
					'pProcess', cTM1Process, 
					'pErrorCode', 'NODE_OWNER_INACTIVE',
					'pErrorDetails', pAppId,
					'pControl', pControl);	
					gShowBouncingMessage = 'Y';	
				EndIf;
			EndIf;
		ElseIf (pCheckBouncingOnly @= 'N');
			If (cShadowApprovalDim @= '' & vOwnerIdToBounce @<> '');
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Bounce central owner ' | vOwnerIdToBounce);
				EndIf;
			
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
					'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'N', 'pUser', vOwnerIdToBounce, 'pControl', pControl);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			EndIf;
		
			#***
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Reserve owner data slice');
			EndIf;

			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
				'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'Y', 'pUser', pNewOwnerID, 'pControl', pControl);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			#*** 
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Set owner');
			EndIf;

			CellPutS(cDisplayUserName, cStateCube, cStateMember, cCurrentOwner);
			CellPutS(pNewOwnerID, cStateCube, cStateMember, cCurrentOwnerId);
			If (cShadowApprovalDim @<> '');
				CellPutS(pNode, cStateCube, cStateMember, cTakeOwnershipNode);
			EndIf;

			#***
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Add being edited');
			EndIf;
		
			#If new owner is not the current user, then it is part of reject action that returns the ownership back
			#to original owner, don't set BeingEdited and StartEditingDate fields for that scenario
			IF (pNewOwnerId @=TM1User);
				cBeingEdited = 'BeingEdited';
				CellPutS('Y', cStateCube, cStateMember, cBeingEdited);

				cStartEditingDate = 'StartEditingDate';
				CellPutS(pTime, cStateCube, cStateMember, cStartEditingDate);
			EndIf;

			#***		
			If (cShadowApprovalDim @= '');
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Set state');
				EndIf;
				CellPutS(cWorkInProgress, cStateCube, cStateMember, cState);
				CellPutS(cDisplayUserName, cStateCube, cStateMember, cStateChangeUser);
				CellPutS(pTime, cStateCube, cStateMember, cStateChangeDate);
			ElseIf (cStateValue @<> cWorkInProgress);
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Change state');
				EndIf;
			
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_change_node_state', 'pExecutionId', pExecutionId, 
					'pTime', pTime, 'pAppId', pAppId, 'pNode', pNode, 'pPrivilege', 'EDIT','pUpdateAncestorState', 'Y', 'pControl', pControl);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			Else;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Update state change time');
				EndIf;
				CellPutS(pTime, cStateCube, cStateMember, cStateChangeDate);
			EndIf;
		EndIf;

		If (cShadowApprovalDim @<> '' & vOwnerIdToBounce @<> '' & vOwnershipNodeToBounce @<> '' & gShowBouncingMessage @= 'N');
		
			#Don't bounce myself on the same leaf node
			If (vOwnerIdToBounce @= pNewOwnerId & vOwnershipNodeToBounce @= pNode);

			Else;
				# Bounce related nodes
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Bounce related nodes');
				EndIf;

				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_bounce_nodes', 'pExecutionId', pExecutionId,'pAppId', pAppId,
					'pOwnerIdToBounce', vOwnerIdToBounce, 'pOwnershipNodeToBounce', vOwnershipNodeToBounce,'pSourceNode', pNode,
 					'pTime', pTime,'pCheckBouncingOnly', pCheckBouncingOnly,'pBouncingMode', pBouncingMode, 'pParentTIUpdateStateCube','N', 'pControl', pControl);

				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			EndIf;
		EndIf;
	EndIf;

# Take ownership on consolidation
Else;
	
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
	vParentTIUpdateStateCube='N';
	If (vSize > 100);
		vUpdateAncestorState = 'N';
		vParentTIUpdateStateCube = 'Y';
	EndIf;

	vInactiveLeaf = 'N';
	looper = vSize;
	vLeafOwnedAtRightLevel = 0;
	While (looper >= 1);
		vLeafChild = SubsetGetElementName(cShadowApprovalDim, vSubsetLeafChildren, looper);

		# leaf node, not the dummy node
		If (vLeafChild @<> pNode);

			#check permission
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Check user privilege');
			EndIf;

			StringGlobalVariable('gEdit');
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions',
			'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', vLeafChild, 'pUser', pNewOwnerID, 'pControl', pControl);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			# must have EDIT privilege to take ownership
			If (gEdit @= 'T');
				cStateValue = CellGetS(cStateCube, vLeafChild, cState);

				# skip submitted node
				If (cStateValue @<> cLocked);
					
					#*****'
					If (cGenerateLog @= 'Y');
						TextOutput(cTM1Log, 'Get current owner and ownership node');
					EndIf;

					vOwnerIdToBounce = CellGetS(cStateCube, vLeafChild, cCurrentOwnerId);
					vOwnershipNodeToBounce = CellGetS(cStateCube, vLeafChild, cTakeOwnershipNode);

					If (vOwnerIdToBounce @<> pNewOwnerID % vOwnershipNodeToBounce @<> pNode);
						IF (pNewOwnerID @<> vOwnerId & cStateValue @= cWorkInProgress & pCheckBouncingOnly @= 'Y');

							IF (pBouncingMode @= 'ALWAYS' % pBouncingMode @='ACTIVE');
												
								#bouncing messages for taking ownership action
								vEdited = CellGetS(cStateCube,  vLeafChild, cBeingEdited);
								If (vEdited @= 'Y');
									vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
										'pGuid', pExecutionId, 
										'pProcess', cTM1Process, 
										'pErrorCode', 'NODE_OWNER_ACTIVE',
										'pErrorDetails', pAppId,
										'pControl', pControl);
									gShowBouncingMessage = 'Y';
									vInactiveLeaf = 'N';
									looper = 1;
								ElseIf (pBouncingMode @= 'ALWAYS');
									gShowBouncingMessage = 'Y';
									vInactiveLeaf = 'Y';
								EndIf;
							EndIf;
						ElseIf (pCheckBouncingOnly @= 'N');

							vLeafOwnedAtRightLevel = vLeafOwnedAtRightLevel +1;

							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, 'Set new owner');
							EndIf;

							CellPutS(cDisplayUserName, cStateCube, vLeafChild, cCurrentOwner);
							CellPutS(pNewOwnerID, cStateCube, vLeafChild, cCurrentOwnerId);
							CellPutS(pNode, cStateCube, vLeafChild, cTakeOwnershipNode);
						
							#***
							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, 'Add being edited');
							EndIf;
						
							#If new owner is not the current user, then it is part of reject action that returns the ownership back
							#to original owner, don't set BeingEdited and StartEditingDate fields for that scenario		
							If (pNewOwnerId @=TM1User);
								cBeingEdited = 'BeingEdited';
								CellPutS('Y', cStateCube, vLeafChild, cBeingEdited);
						
								cStartEditingDate = 'StartEditingDate';
								CellPutS(pTime, cStateCube, vLeafChild, cStartEditingDate);
								
								#rollup sandboxes to the ownership node
								vTotalSandbox = ServerSandboxListCountGet;
								vSandboxLooper = vTotalSandbox;
								vLookupString = '_[' | cShadowApprovalDim | '].[' | vleafChild | ']_' | pAppId;

								While (vSandboxLooper >=1);
									vLeafSandbox = ServerSandboxGet(vSandboxLooper);
									vStartPos = SCAN(vLookupString, vLeafSandbox);
									vDisplayName = SUBST(vLeafSandbox, 1, vStartPos -1);
									IF (vStartPos >0);
										 vParentSandbox = vDisplayName |  '_[' | cShadowApprovalDim | '].[' | pNode | ']_' | pAppId;
	 	 	 	 	 	 	 	 	 	 IF (ServerSandboxExists(vParentSandbox) =0);
		 	 	 	 	 	 	 	 	 	 ServerSandboxCreate(vParentSandbox);
	 	 	 	 	 	 	 	 	 	 EndIf;
	 	 	 	 	 	 	 	 	 	 ServerSandboxMerge(vLeafSandbox, vParentSandbox);
 	  	  	  	  	  	  	  	  	  	 ServerSandboxesDelete('client:=:' | TM1User | ', name:=:' | vLeafSandbox);

									EndIf;							
									vSandboxLooper = vSandboxLooper -1;	
								End;
							EndIf;
	
							#***
							If (cStateValue @<> cWorkInProgress);
								If (cGenerateLog @= 'Y');
									TextOutput(cTM1Log, 'Change state');
								EndIf;
	
								vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_change_node_state', 'pExecutionId', pExecutionId,
									'pTime', pTime, 'pAppId', pAppId, 'pNode', vLeafChild, 'pPrivilege', 'EDIT', 'pUpdateAncestorState', vUpdateAncestorState,'pControl', pControl);
								If (vReturnValue <> ProcessExitNormal());
									ProcessError;
								EndIf;
							Else;
								If (cGenerateLog @= 'Y');
									TextOutput(cTM1Log, 'Update state change time');
								EndIf;
								CellPutS(pTime, cStateCube, vLeafChild, cStateChangeDate);
							EndIf;

							#***
							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, 'Bounce related nodes');
							EndIf;
						EndIf;

						If (vOwnerIdToBounce @<> '' & vOwnershipNodeToBounce @<> '' & gShowBouncingMessage @= 'N');

							vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_bounce_nodes', 'pExecutionId', pExecutionId,'pAppId', pAppId,
								'pOwnerIdToBounce', vOwnerIdToBounce, 'pOwnershipNodeToBounce', vOwnershipNodeToBounce,
								'pSourceNode', pNode, 'pTime', pTime, 'pCheckBouncingOnly', pCheckBouncingOnly,'pBouncingMode', pBouncingMode,  'pParentTIUpdateStateCube',vParentTIUpdateStateCube,'pControl', pControl);
								
							If (vReturnValue <> ProcessExitNormal());
								ProcessError;
							EndIf;

							IF (pCheckBouncingOnly @= 'Y' & gShowBouncingMessage @='Y');
								looper = 1;
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	
		looper = looper -1;
	End;
	
	If (vInactiveLeaf @= 'Y');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'NODE_OWNER_INACTIVE',
		'pErrorDetails', pAppId,
		'pControl', pControl);	
	EndIf;

	If (pCheckBouncingOnly @= 'N');
		If (vLeafOwnedAtRightLevel = 0);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_NO_LEAF_OWNED_AT_RIGHT_LEVEL',
				'pErrorDetails', 'Own' | ', ' | pNode,
				'pControl', pControl);
		
			ProcessError;
		EndIf;
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Update consolidated node state change time');
		EndIf;
		CellPutS(pTime, cStateCube, pNode, cStateChangeDate);

		#****

		#If we didn't update ancestors' state for an individual leaf node, we must update state cube for all consolidated nodes now
		IF (vUpdateAncestorState @= 'N');
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_update_state_cube', 'pGuid', pExecutionId,'pAppId', pAppId, 'pUpdateLeafState', 'N', 'pControl', pControl);
								
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
		Endif;
	
		#***
		# At last, take care of the consolidated nodes in the package

		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
			'pAppId', pAppId, 'pNode', pNode, 'pApprovalDim', cApprovalDim, 'pReserve', 'Y', 'pUser', pNewOwnerID, 'pControl', pControl);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	Endif;

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
