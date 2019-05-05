601,100
602,"}tp_deploy_app_cubes_add"
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
pCubeName
561,3
2
2
2
590,3
pExecutionId,"None"
pAppId,"None"
pCubeName,"None"
637,3
pExecutionId,""
pAppId,""
pCubeName,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,140
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

cControlPrefix = '}';

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
'pProcess', cTM1Process, 'pControl', 'Y');
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
Endif;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#***
cCubePropertiesCube = '}CubeProperties';
cCentralApplicationStateCube = cControlPrefix | 'tp_central_application_state';
cApplicationStateCube = cControlPrefix | 'tp_application_state}'|pAppId;
cApprovalDIM = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalDimension');
cApprovalSubset = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalSubset');
cAppActive = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'IsActive'); 
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');
cVersionSlicesRead =ATTRS('}tp_applications', pAppId, 'VersionSlicesRead');

cDataReservationType = '';
If (cAppActive @= 'Y');
	cDataReservationType = 'REQUIREDSHARED';
	If (cApprovalDIM @= '');
		cDataReservationType = 'ALLOWED';
	EndIf;
EndIf;

#***
vCubeName = pCubeName;
vCurrentDRMode = CellGetS( cCubePropertiesCube, vCubeName, 'DATARESERVATIONMODE');
		
IF (cDataReservationType @<> '');
	# set DR mode when it has a valide mode type, otherwise do not overide other application's valid DR mode
	CellPutS(cDataReservationType, cCubePropertiesCube, vCubeName, 'DATARESERVATIONMODE');
Endif;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Data Reservation is now ' | cDataReservationType | ' on cube ' | vCubeName);
EndIf;

#***
#Add data reservations, update security overlay and RD cell security cube if this is a new cube
If (cApprovalDIM @= '');
	# If the Central app has an existing owner make sure any new cubes get a data reservation.
	cState = CellGetS(cCentralApplicationStateCube, pAppId, 'State');
	If (cState @= '2');
		cCurrentOwner = CellGetS(cCentralApplicationStateCube, pAppId, 'CurrentOwnerId');
		If (cCurrentOwner @<> '');
			vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_util_reserve_cube_slices', 'pExecutionId', pExecutionId, 
				'pAppId', pAppId, 'pCube', vCubeName, 'pApprovalDim', '', 'pNode', '',  'pReserve', 'Y', 'pUser', cCurrentOwner, 'pControlDim','','pControlWritableSlices', '');

			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
		EndIf;
	EndIf;
Else;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check for existing ownership for cube ' | vCubeName);
	EndIf;

	# If there are any existing node owners make sure any new cubes get a data reservation. 
	#Also we need to update the newly created security overlay cube
	#We need to update the newly created Reduced Dimensionality cell security cube based on planning rights
	If (CubeExists(cApplicationStateCube) = 1);
		cApprovalSubsetSize = SubsetGetSize(cApprovalDim,cApprovalSubset );
		vIndex = 1;
		While (vIndex <= cApprovalSubsetSize);
			vApprovalNode = SubsetGetElementName(cApprovalDIM, cApprovalSubset, vIndex);
			cState = CellGetS(cApplicationStateCube, vApprovalNode, 'State');
			If (cState @= '4');
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_util_lock_cube_slices', 'pExecutionId', pExecutionId, 
					'pAppId', pAppId, 'pCube', vCubeName, 'pApprovalDim', cApprovalDIM, 'pNode', vApprovalNode, 'pLock', 'Y','pControlDim','','pControlWritableSlices', '');
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			Endif;

			If (DTYPE(cApprovalDIM, vApprovalNode) @<> 'C');

				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Node state for node ' | vApprovalNode | ' in cube ' | vCubeName | ' is ' | cState);
				EndIf;

				If (cState @= '2');
					cCurrentOwner = CellGetS(cApplicationStateCube, vApprovalNode, 'CurrentOwnerId');
					cOwnershipNode = CellGetS(cApplicationStateCube, vApprovalNode, 'TakeOwnershipNode');
					If (cCurrentOwner @<> '' & cOwnershipNode @<> '');
						vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_util_reserve_cube_slices', 'pExecutionId', pExecutionId, 
							'pAppId', pAppId, 'pCube', vCubeName, 'pApprovalDim', cApprovalDIM, 'pNode', cOwnershipNode, 'pReserve', 'Y', 'pUser', cCurrentOwner,'pControlDim','','pControlWritableSlices', '');
						If (vReturnValue <> ProcessExitNormal());
							ProcessError;
						EndIf;
					EndIf;
				Endif;
			EndIf;

			vIndex = vIndex + 1;
		End;
	EndIf;
EndIf;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,1

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
