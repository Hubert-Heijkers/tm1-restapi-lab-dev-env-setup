601,100
602,"}tp_update_ownership"
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
pControl
561,3
2
2
2
590,3
pGuid,"None"
pAppId,"MyApp"
pControl,"N"
637,3
pGuid,""
pAppId,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,351


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
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_log_file_names', 'pExecutionId', pGuid,
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
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pGuid, pAppId,  pControl);
EndIf;

#*** Check application

cApplicationsDim = cControlPrefix |  'tp_applications';

If (DimensionExists(cApplicationsDim) = 0);
	ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pGuid, 
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_DIM_NOT_EXIST',
		'pErrorDetails', cApplicationsDim, 
		'pControl', pControl);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, cApplicationsDim | ' does not exist.');
	EndIf;
	ProcessError;
EndIf;

If (DIMIX(cApplicationsDim, pAppId) = 0);
	ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pGuid, 
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_NODE_NOT_EXIST',
		'pErrorDetails', pAppId, 
		'pControl', pControl);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, pAppId | ' does not exist.');
	EndIf;
	ProcessError;
EndIf;

#*** Check State cube
vStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
vNodeInfoDim = cControlPrefix | 'tp_node_info';

If (CubeExists(vStateCube) = 0);
	ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pGuid, 
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', vStateCube, 
		'pControl', pControl);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Cube ' | vStateCube | ' does not exist.');
	EndIf;
	ProcessError;
EndIf;

#* Check permission cube
cPermissionCube = cControlPrefix | 'tp_application_permission}' | pAppId;
cCellSecurityCube = '}CellSecurity_' | cPermissionCube;

If (CubeExists(cPermissionCube) = 0);
	ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pGuid, 
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cPermissionCube, 
		'pControl', pControl);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Cube ' | cPermissionCube | ' does not exist.');
	EndIf;
	ProcessError;
EndIf;

If (CubeExists(cCellSecurityCube) = 0);
	ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pGuid, 
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cCellSecurityCube, 
		'pControl', pControl);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Cube ' | cCellSecurityCube | ' does not exist.');
	EndIf;
	ProcessError;
EndIf;

#* Get Approval dimension and subset

#*** declare global variables

vApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cShadowApprovalDim =ATTRS('}tp_applications', pAppId, 'ApprovalShadowDimension');
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', vApprovalDim, cApprovalSubset, cShadowApprovalDim );
EndIf;


#***

vSubset = 'currentOwner_' | pGuid;

IF (SubsetExists(cShadowApprovalDim, vSubset) =1);
	SubsetDestroy(cShadowApprovalDim, vSubset);
ENDIF;

vDummyNode = DIMNM(cShadowApprovalDim, 1);
#If a mdx returns zero item, SubsetCreateByMdx will throw an error, add the first element as a dummy member
vMDX = '{ FILTER ( [' | cShadowApprovalDim | '].Members, [' | vStateCube | '].( [' | vNodeInfoDim | '].[CurrentOwner] ) <> "" ), [' | cShadowApprovalDim | '].['
	| vDummyNode | ']} ';
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Mdx to get nodes with current owner: ' | vMDX);
EndIf;
subsetCreateByMdx(vSubset, vMDX);
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_util_convert_dynamic_subset_to_static', 'pExecutionId', pGuid,
'pDim',cShadowApprovalDim, 'pSubset', vSubset);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

vSubsetSize = SubsetGetSize(cShadowApprovalDim, vSubset);
looper =vSubsetSize;
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'subset Size: ' | NumberToString(vSubsetSize));
EndIf;

vConsolidationOwnershipNodeDim = 'tp_temp_consolidation_ownership_node_' | pGuid;
vConsolidationOwnershipIdDim = 'tp_temp_consolidation_ownership_id_' | pGuid;

vDummyCount =0;
WHILE (looper >=1);
	vOwner = '';
	vNode = '';
	vNode = SubsetGetElementName (cShadowApprovalDim, vSubset, looper);
	
	#***Need to take care of dummy member
	
	IF (vNode @= vDummyNode);
		vDummyCount = vDummyCount +1;
		#***If dummy node shows up more than once, it is also a real one
		IF (vDummyCount >1);
			vOwner = CellGetS(vStateCube, vNode, 'CurrentOwner');
			vCurrentOwnerId = CellGetS(vStateCube, vNode, 'CurrentOwnerId');
		ENDIf;
	
	ELSE;
		vOwner = CellGetS(vStateCube, vNode, 'CurrentOwner');
		vCurrentOwnerId = CellGetS(vStateCube, vNode, 'CurrentOwnerId');
	ENDIF;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'node: ' | vNode);
		TextOutput(cTM1Log, 'Current Owner: ' | vOwner);
	ENDIF;
	
	IF (DIMIX('}Clients', vOwner) = 0);
		#***Node owner doesn't exist in }Clients dimension any more
		#***Reset currentOwner field,
		#***we need a separate TI to take care of ownership whose owner has been deleted
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Current Owner: ' | vOwner | ' does not exist.');
			TextOutput(cTM1Log, 'The current owner field for node ' | vNode | ' get reset.');
		ENDIF;
		If (CellIsUpdateable(vStateCube, vNode, 'State') = 0);
			vDetail=INSRT('State',')',1);
			vDetail=INSRT(',',vDetail,1);
			vDetail=INSRT(vNode,vDetail,1);
			vDetail=INSRT('(',vDetail,1);
			vDetail=INSRT(vStateCube,vDetail,1);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pGuid, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
			'pErrorDetails', vDetail,
			'pControl', pControl);
			ProcessError;
		EndIf;
		CellPutS('', vStateCube, vNode, 'CurrentOwner');
		
		If (CellIsUpdateable(vStateCube, vNode, 'CurrentOwnerId') = 0);
			vDetail=INSRT('CurrentOwnerId',')',1);
			vDetail=INSRT(',',vDetail,1);
			vDetail=INSRT(vNode,vDetail,1);
			vDetail=INSRT('(',vDetail,1);
			vDetail=INSRT(vStateCube,vDetail,1);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pGuid, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
			'pErrorDetails', vDetail,
			'pControl', pControl);
			ProcessError;
		EndIf;
		CellPutS('', vStateCube, vNode, 'CurrentOwnerId');
	
	ElseIf (DTYPE(cShadowApprovalDim, vNode) @= 'N');
	
		#***If leaf node: need to revoke ownership as well as clear currentOwer in state cube
	
		StringGlobalVariable('gEdit');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions',
			'pGuid', pGuid, 'pApplication', pAppId, 'pNode', vNode, 'pUser', vOwner, 'pControl', pControl);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	
		If (gEdit @= 'F');
	
			#*** Clear Reservation approval node slice using TM1 data reservation
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pGuid, 
				'pAppId', pAppId, 'pNode', vNode, 'pApprovalDim', vApprovalDim, 'pReserve', 'N', 'pUser', vCurrentOwnerId, 'pControl', pControl);
				
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
			If (CellIsUpdateable(vStateCube, vNode, 'CurrentOwner') = 0);
				vDetail=INSRT('CurrentOwner',')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vNode,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(vStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pGuid, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('', vStateCube, vNode, 'CurrentOwner');
			
			If (CellIsUpdateable(vStateCube, vNode, 'CurrentOwnerId') = 0);
				vDetail=INSRT('CurrentOwnerId',')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vNode,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(vStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pGuid, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('', vStateCube, vNode, 'CurrentOwnerId');
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, 'No edit permission. The ownership of ' | vNode | ' is revoked from user ' | vOwner);
				TextOutput(cTM1Log, 'The current owner field for node ' | vNode | ' get reset.');
			ENDIF;

			# Put TakeOwnershipNode in temp dimension
			vTakeOwnershipNode = CellGetS(vStateCube, vNode, 'TakeOwnershipNode');
			If (CellIsUpdateable(vStateCube, vNode, 'TakeOwnershipNode') = 0);
				vDetail=INSRT('TakeOwnershipNode',')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vNode,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(vStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pGuid, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('', vStateCube, vNode, 'TakeOwnershipNode');
			If (vTakeOwnershipNode @<> vNode);
				If (DTYPE(cShadowApprovalDim, vTakeOwnershipNode) @<> 'C');
					ProcessError;
				EndIf;
				If (DimensionExists(vConsolidationOwnershipNodeDim) = 0);
					DimensionCreate(vConsolidationOwnershipNodeDim);
					DimensionCreate(vConsolidationOwnershipIdDim);
				EndIf;
				If (DIMIX(vConsolidationOwnershipNodeDim, vTakeOwnershipNode) = 0 & vCurrentOwnerId @<> '');
					DimensionElementInsert(vConsolidationOwnershipNodeDim, '', vTakeOwnershipNode, 'S');
					DimensionElementInsert(vConsolidationOwnershipIdDim, '', vTakeOwnershipNode | '}' | vCurrentOwnerId, 'S');
				EndIf;
			EndIf;

		EndIf;
	
	Else;
	
		#***If consolidated node: clear currentOwer in state cube, we don't set owner on a consolidated node
		CellPutS('', vStateCube, vNode, 'CurrentOwner');
		CellPutS('', vStateCube, vNode, 'CurrentOwnerId');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'The current owner field for node ' | vNode | ' get reset.');
		ENDIF;
	
	EndIf;
	
	looper = looper -1 ;

END;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;


573,1

574,1

575,35
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

If (SubsetExists(cShadowApprovalDim, vSubset) =1);
	SubsetDestroy(cShadowApprovalDim, vSubset);
EndIf;

If (DimensionExists(vConsolidationOwnershipNodeDim) = 1);
	DimensionDestroy(vConsolidationOwnershipNodeDim);
EndIf;

If (DimensionExists(vConsolidationOwnershipIdDim) = 1);
	DimensionDestroy(vConsolidationOwnershipIdDim);
EndIf;

#*** No error
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'The end has been reached.');
EndIf;


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
