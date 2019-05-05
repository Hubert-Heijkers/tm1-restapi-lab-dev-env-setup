601,100
602,"}tp_update_application_DR"
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
pExecutionId
pAppId
pCube
561,3
2
2
2
590,3
pExecutionId,"None"
pAppId,"MyApp"
pCube,"None"
637,3
pExecutionId,""
pAppId,""
pCube,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,112


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
cShadowApprovalDim = ATTRS('}tp_applications', pAppId, 'ApprovalShadowDimension');
cControlDim = ATTRS('}tp_applications', pAppId,  'VersionDimension');
cWritableSlicesOld = ATTRS('}tp_applications', pAppId,  'VersionSlicesWriteOld');
cWritableSlicesNew = ATTRS('}tp_applications', pAppId,  'VersionSlicesWrite');
cStateCube = '}tp_application_state}' | pAppId;
cNodeInfoDim = '}tp_node_info';
cStateField = 'State';
cOwnerIdField = 'CurrentOwnerId';
cOwnershipNodeField = 'TakeOwnershipNode';
vSingleQ = '''';

IF (cWritableSlicesOld @<> cWritableSlicesNew);
	vMdx = '{FILTER([' | cShadowApprovalDim | '].MEMBERS, [' | cStateCube | '].[' | cNodeInfoDim | '].[' | cStateField | '] =' | vSingleQ | '2' | vSingleQ | ')}';
	vSubsetOwnedNodes = 'tp_temp_owned_nodes';
	IF (SubsetExists(cShadowApprovalDim, vSubsetOwnedNodes) =1);
		SubsetDestroy(cShadowApprovalDim,vSubsetOwnedNodes);
	Endif;

	SubsetCreateByMdx(vSubsetOwnedNodes, vMdx, cShadowApprovalDim);

	vTotalOwnedNodes = SubsetGetSize(cShadowApprovalDim,vSubsetOwnedNodes );

	vLooper =1 ;

	While (vLooper <= vTotalOwnedNodes);
		vOwnedNode = SubsetGetElementName(cShadowApprovalDim, vSubsetOwnedNodes, vLooper);
		IF (DTYPE(cShadowApprovalDim, vOwnedNode) @<> 'C');

			vOwner = CellGetS(cStateCube, vOwnedNode, cOwnerIdField);
			vOwnershipNode = CellGetS(cStateCube, vOwnedNode, cOwnershipNodeField);
			#First release all old DRs on old control slices
			vReturnValue = ExecuteProcess('}tp_workflow_util_reserve_cube_slices', 'pExecutionId', pExecutionId, 
				'pAppId', pAppId, 'pCube', pCube, 'pApprovalDim', cApprovalDim, 'pNode', vOwnershipNode,  'pReserve', 'N', 
				'pUser', vOwner, 'pControlDim', cControlDim, 'pControlWritableSlices', cWritableSlicesOld );

			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'DR released on node: ' | vOwnedNode | ', user: ' | vOwner | ', cube: ' | pCube);
			EndIf;

			#Next reacquire new DRs on new control slices
			vReturnValue = ExecuteProcess('}tp_workflow_util_reserve_cube_slices', 'pExecutionId', pExecutionId, 
				'pAppId', pAppId, 'pCube', pCube, 'pApprovalDim', cApprovalDim, 'pNode', vOwnershipNode,  'pReserve', 'Y', 
				'pUser', vOwner, 'pControlDim', cControlDim, 'pControlWritableSlices', cWritableSlicesNew );

			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;

			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'DR reacquired on node: ' | vOwnedNode | ', user: ' | vOwner | ', cube:' | pCube);
			EndIf;

		Endif;
		vLooper = vLooper +1;
	End;

Endif;

#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

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
## (C) Copyright IBM Corp. 2008, 2009, 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################

#*** Log File Name
cTM1Log = cEpilogLog;

#***
IF (SubsetExists(cShadowApprovalDim, vSubsetOwnedNodes) =1);
SubsetDestroy(cShadowApprovalDim,vSubsetOwnedNodes);
Endif;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
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
