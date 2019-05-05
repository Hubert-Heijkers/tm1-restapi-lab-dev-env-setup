601,100
602,"}tp_upgrade_from_v9_5_1_to_v9_5_2"
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
pVersion,"9.5.2"
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
572,47


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

cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

### Add element: TakeOwnershipNode
cNodeInfoDim = cControlPrefix | 'tp_node_info';
If (DimensionExists(cNodeInfoDim) = 0);
	ProcessError;
EndIf;

cTakeOwnershipNode = 'TakeOwnershipNode';
cStartEditingDate = 'StartEditingDate';
If (DIMIX(cNodeInfoDim, cTakeOwnershipNode) = 0);
	DimensionElementInsert(cNodeInfoDim, cStartEditingDate, cTakeOwnershipNode, 'S');
EndIf;

### Add attribute: Version
cApplicationsDim = cControlPrefix | 'tp_applications';
cApplicationsAttributesDim = '}ElementAttributes_' | cApplicationsDim;

If (DimensionExists(cApplicationsDim) = 0 % DimensionExists(cApplicationsAttributesDim) = 0);
	ProcessError;
EndIf;

cApprovalDimensionAttr = 'ApprovalDimension';
cVersionAttr = 'Version';
If (DIMIX(cApplicationsAttributesDim, cVersionAttr) = 0);
	AttrInsert(cApplicationsDim, cApprovalDimensionAttr, cVersionAttr, 'S');
EndIf;

573,1

574,1

575,156


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

cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

### Set value to version attribute
If (DIMIX(cApplicationsDim, pAppId) = 0);
	ProcessError;
EndIf;

AttrPutS(pVersion, cApplicationsDim, pAppId, cVersionAttr);

cTM1Process = cControlPrefix | 'tp_update_from_v9_5_1_to_v9_5_2';

### Get Approval dimension and subset

#* declare global variables
StringGlobalVariable('gApprovalDim');
StringGlobalVariable('gApprovalSubset');

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_application_attributes', 'pExecutionId', pExecutionId, 'pAppId', pAppId, 'pControl',  pControl);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

cApprovalDim = gApprovalDim;
cApprovalSubset = gApprovalSubset;

If (DimensionExists(cApprovalDim) = 0);
	ProcessError;
EndIf;


### Write taking ownership nodes 
cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
If (CubeExists(cStateCube) = 0);
	ProcessError;
EndIf;

cCurrentOwner = 'CurrentOwner';
cTakeOwnershipNode = 'TakeOwnerShipNode';

cApprovalDimSize = DIMSIZ(cApprovalDim);
vIndex = 1;
While (vIndex <= cApprovalDimSize);
	vNode = DIMNM(cApprovalDim, vIndex);
	
	vCurrentOwnerValue = CellGetS(cStateCube, vNode, cCurrentOwner);
	vTakeOwnershipNode = CellGetS(cStateCube, vNode, cTakeOwnershipNode);
	If (vCurrentOwnerValue @<> '' & vTakeOwnershipNode @= '');
		If (CellIsUpdateable(cStateCube, vNode, cTakeOwnershipNode) = 0);
			vDetail=INSRT(cTakeOwnershipNode,')',1);
			vDetail=INSRT(',',vDetail,1);
			vDetail=INSRT(vNode,vDetail,1);
			vDetail=INSRT('(',vDetail,1);
			vDetail=INSRT(cStateCube,vDetail,1);
			vReturnValue = ExecuteProcess('|tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
			'pErrorDetails', vDetail,
			'pControl', pControl);
			ProcessError;
		EndIf;
		CellPutS(vNode, cStateCube, vNode, cTakeOwnershipNode);
	EndIf;
	
	vIndex = vIndex + 1;
End;

### Create "everyone" group

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
	
	If (DIMIX('}Groups', cTpEveryoneGroup) <> 0);
		DeleteGroup(cTpEveryoneGroup);
	EndIf;
	
	cEveryoneGroup = cCognosEveryoneGroup;

Else;

	cEveryoneGroup = cTpEveryoneGroup;
	
	If (DIMIX('}Groups', cEveryoneGroup) = 0);
		AddGroup(cEveryoneGroup);
	EndIf;

EndIf;

### Give everyone access to process: tp_workflow_submit_leaf_children

sProcessesDim = '}Processes';
sProcessSecurityCube = '}ProcessSecurity';
If (CubeExists(sProcessSecurityCube) = 0);
	
	CubeCreate(sProcessSecurityCube, sProcessesDim, '}Groups');
	CubeSetLogChanges(sProcessSecurityCube, 1);
EndIf;

cSubmitLeafChildrenProc = cControlPrefix | 'tp_workflow_submit_leaf_children';
If (DIMIX(sProcessesDim, cSubmitLeafChildrenProc) = 0);
	ProcessError;
Else;
	cCurrentCellValue = CellGetS(sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup); 
	If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
		If (CellIsUpdateable(sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup) = 0);
			vDetail=INSRT(cEveryoneGroup,')',1);
			vDetail=INSRT(',',vDetail,1);
			vDetail=INSRT(cSubmitLeafChildrenProc,vDetail,1);
			vDetail=INSRT('(',vDetail,1);
			vDetail=INSRT(sProcessSecurityCube,vDetail,1);
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_SEMAPHORE_NOT_UPDATEABLE',
			'pErrorDetails', vDetail,
			'pControl', pControl);
			ProcessError;
		EndIf;
		CellPutS('Read', sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup);
	EndIf;
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
