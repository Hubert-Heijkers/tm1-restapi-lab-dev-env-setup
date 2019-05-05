601,100
602,"}tp_workflow_util_bounce_nodes_message"
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
pAppId
pOwnerIdToBounce
pOwnershipNodeToBounce
pSourceNode
pTime
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
pAppId,"MyApp"
pOwnerIdToBounce,"NA"
pOwnershipNodeToBounce,"NA"
pSourceNode,"NA"
pTime,"0"
pControl,"N"
637,7
pExecutionId,""
pAppId,""
pOwnerIdToBounce,""
pOwnershipNodeToBounce,""
pSourceNode,""
pTime,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,221

################################################################
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
cBounceMode = ATTRS('}tp_applications', pAppId,  'BounceMode');

#***Get Bounce Mode
cBounceMode = SUBST(cBounceMode, 1, SCAN('_', cBounceMode)-1);

#***

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cIsActive,cShadowApprovalDim );
EndIf;

#*** Log Parameters
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW,'\Y \M \d - \h:\i:\s'),
		'Parameters:', pExecutionId, pAppId, pOwnerIdToBounce, pOwnershipNodeToBounce, pControl);
EndIf;

#***
#constants
cLocked = '4';
cWorkInProgress = '2';
cState = 'State';
cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
cCurrentOwner = 'CurrentOwner';
cCurrentOwnerId = 'CurrentOwnerId';
cTakeOwnershipNode = 'TakeOwnershipNode';
cStateMeasureDim=cControlPrefix | 'tp_node_info';

#****
StringGlobalVariable('gBouncingType');

#****

#IF (Bounce 0)
IF (pOwnerIdToBounce @<>'' & pOwnershipNodeToBounce @<> '');
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Bounce nodes');
	EndIf;

	###bounce leaf nodes in the package
	IF (DIMIX('}Clients', pOwnerIdToBounce) >0);
		vOwnerToBounce = ATTRS('}Clients', pOwnerIdToBounce, '}TM1_DefaultDisplayValue');
	Else;
		vOwnerToBounce = pOwnerIdToBounce;
	EndIf;
	If (vOwnerToBounce @= '');
		vOwnerToBounce = pOwnerIdToBounce;
	EndIf;

	# *** escape double quotes characters, if found, in the user it (such as CAM user id)

	varX = vOwnerToBounce;
	vPos = SCAN('"', varX );
	If (vPos > 1);
		tempID = '';
		While (vPos > 1);	
			var1 = SUBST(varX , 1, vPos -1) ;
			var2 = SUBST(varX , vPos + 1, LONG(varX ) - vPos);	
			varX  = var2;
			vPos = SCAN('"', varX );
			If (vPos > 1);
				tempID = tempID | var1 | '""' ;
			Else;
				tempID = tempID | var1 | '""' | varX;
			EndIf;
		End;
        		vOwnerToBounce = tempID;
    	EndIf;
	
	#*** Escape the node to ensure valid MDX
	StringGlobalVariable('gEscapedId');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_util_escape_id', 
		'pExecutionId', pExecutionId, 'pNode', pSourceNode, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Escaped Node name: ' | gEscapedId);
	EndIf;

	vMdx = '{FILTER(TM1FILTERBYLEVEL( TM1SUBSETTOSET([' | cShadowApprovalDim  | '],"' | cApprovalSubset | '"), 0), ';
	vMdx = vMdx | '[' | cStateCube | '].[' | cStateMeasureDim | '].[CurrentOwner]="' | vOwnerToBounce | '"' ;
	vMdx = vMdx | 'AND [' | cStateCube | '].[' | cStateMeasureDim | '].[TakeOwnershipNode]="' | pOwnershipNodeToBounce | '" ),';
	vMdx = vMdx | '[' | cShadowApprovalDim | '].[' | gEscapedId | ']}';

	vSubsetNodesToBounce = 'nodesToBounce_by_' | pExecutionId;
	IF (SubsetExists(cShadowApprovalDim, vSubsetNodesToBounce) <>0);
		SubsetDestroy(cShadowApprovalDim, vSubsetNodesToBounce);
	ENDIF;
	SubsetCreateByMdx(vSubsetNodesToBounce, vMDX);
	SubsetElementInsert(cShadowApprovalDim, vSubsetNodesToBounce, pSourceNode, 0);

	vBounceSize = SubsetGetSize(cShadowApprovalDim, vSubsetNodesToBounce);

	looperBounce = vBounceSize;

	While (looperBounce >=1);
		vNodeBounce =  SubsetGetElementName(cShadowApprovalDim, vSubsetNodesToBounce, looperBounce);
		#IF (Bounce1)
		#exclude dummy node
		IF (vNodeBounce @<> pSourceNode);

			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'Bounce related nodes');
			EndIf;

			vBounceOwnerId = CellGetS(cStateCube, vNodeBounce, cCurrentOwnerId);
			vBounceOwnershipNode = CellGetS(cStateCube, vNodeBounce, cTakeOwnershipNode);
			vBounceState = CellGetS(cStateCube, vNodeBounce, cState);

			#IF (Bounce2)
			IF (vBounceOwnerId @=pOwnerIdToBounce & vBounceOwnershipNode @= pOwnershipNodeToBounce);

				#IF (Bounce3)
				If ((vBounceState @= '') % (vBounceState @=cWorkInProgress ));
					cBeingEdited = 'BeingEdited';
					cStartEditingDate = 'StartEditingDate';
					cOffline = 'Offline';
					IF (vBounceState @=cWorkInProgress & (cBounceMode @= 'ALWAYS' % cBounceMode @='ACTIVE') );
												
						IF (gBouncingType @= 'OWN');
							#bouncing messages for taking ownership action
							vActiveBounceCode = 'NODE_OWNER_ACTIVE';
							vInactiveBounceCode = 'NODE_OWNER_INACTIVE';
						
						Else;
							#bouncing messages for reject action 
							vActiveBounceCode = 'NODE_BOUNCE_OWNER_ACTIVE';
							vInactiveBounceCode = 'NODE_BOUNCE_OWNER_INACTIVE';
						Endif;

						vEdited = CellGetS(cStateCube, vNodeBounce, cBeingEdited);
						If (vEdited @= 'Y');
							vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
							'pGuid', pExecutionId, 
							'pProcess', cTM1Process, 
							'pErrorCode', vActiveBounceCode,
							'pErrorDetails', pAppId,
							'pControl', pControl);
							processError();
						Elseif (cBounceMode @= 'ALWAYS');
							vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
							'pGuid', pExecutionId, 
							'pProcess', cTM1Process, 
							'pErrorCode', vInactiveBounceCode,
							'pErrorDetails', pAppId,
							'pControl', pControl);	
							processError();
						EndIf;
						
					Endif;

				#***
				#IF (Bounce3)
				ENDIF;
			#***
			#IF (Bounce2)
			ENDIF;

		#IF (Bounce1)
		ENDIF;

		looperBounce = looperBounce-1;
	END;

#IF (Bounce 0)
ENDIF;


573,1

574,1

575,22


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


IF (SubsetExists(cShadowApprovalDim, vSubsetNodesToBounce ) <>0);
SubsetDestroy(cShadowApprovalDim, vSubsetNodesToBounce );
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
