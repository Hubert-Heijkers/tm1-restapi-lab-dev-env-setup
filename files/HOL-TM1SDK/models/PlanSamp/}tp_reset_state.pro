601,100
602,"}tp_reset_state"
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
pControl
561,4
2
2
2
2
590,4
pExecutionId,"None"
pTime,"0"
pAppId,"MyApp"
pControl,"N"
637,4
pExecutionId,""
pTime,""
pAppId,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,362

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
#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Parameters:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pExecutionId, pAppId, pControl);
EndIf;

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check application dimension');
EndIf;

cApplicationsDim = cControlPrefix | 'tp_applications';

If (DimensionExists(cApplicationsDim) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_DIM_NOT_EXIST',
		'pErrorDetails', cApplicationsDim,
		'pControl', pControl);
	
	ProcessError;
EndIf;

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check application id', pAppId);
EndIf;

If (DIMIX(cApplicationsDim, pAppId) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_NODE_NOT_EXIST',
		'pErrorDetails', cApplicationsDim | ', ' | pAppId,
		'pControl', pControl);
	
	ProcessError;
EndIf;

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Get Approval dimension and subset');
EndIf;

cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cShadowApprovalDim = '}tp_tasks}' | pAppId;
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');

#***
IF (cVersionDim @<> '' & cVersionSlicesWrite @<> '');
	#create version subset that contains this version only
	vVersionSubset = 'temp_app_version' | pAppId;
	IF (SubsetExists(cVersionDim, vVersionSubset)>0);
		subsetDestroy(cVersionDim, vVersionSubset);
	Endif;
	SubsetCreate(cVersionDim, vVersionSubset);
	versionSeparater = '|';
	vPosVersion = 0;
	vStringToScan = cVersionSlicesWrite;
	vPosVersion = SCAN(versionSeparater, vStringToScan);

	While (vPosVersion >0);
		vVersionSlice  = SUBST(vStringToScan, 1, vPosVersion-1);
		IF (DIMIX(cVersionDim, vVersionSlice) >0);
			SubsetElementInsert(cVersionDim, vVersionSubset, vVersionSlice, 1);
		Else;
			vReturnValue = ExecuteProcess('}tp_error_update_error_cube',
				'pGuid', pExecutionId,
				'pProcess', cTM1Process,
				'pErrorCode', 'TI_WRITABLE_SLICE_NOT_EXISTS',
				'pErrorDetails', cVersionDim  | '.' | vVersionSlice | ', ' |  pAppId,
				'pControl', 'Y');
	
			ProcessError;			
		Endif;

		vStringToScan = SUBST(vStringToScan, vPosVersion +1, LONG(vStringToScan)-vPosVersion);
		vPosVersion = SCAN(versionSeparater, vStringToScan);
	End;

Endif;
#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check state cube');
EndIf;

If (cApprovalDim @= '');
	cStateCube = cControlPrefix | 'tp_central_application_state';
Else;
	cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
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

cState = 'State';
cStateChangeUser = 'StateChangeUser';
cStateChangeDate = 'StateChangeDate';
cCurrentOwner = 'CurrentOwner';
cWorkInProgress = '2';

cNodeInfoDim = cControlPrefix | 'tp_node_info';
	
# remove existing reservations for the application
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Revoke all owners');
EndIf;
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_release_all', 'pExecutionId', pExecutionId, 
		'pAppId', pAppId, 'pControl', pControl);
		
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
	
If (cApprovalDim @= '');
	
	cApplicationsDim = cControlPrefix | 'tp_applications';
	cApplicationSubset = 'tp_temp_reset_application_subset_' | pExecutionId;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Application reset subset : ' | cApplicationSubset);
	EndIf;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Zero out application values on State cube');
	EndIf;
	
	If (SubsetExists(cApplicationsDim, cApplicationSubset) = 1);
		SubsetDestroy(cApplicationsDim, cApplicationSubset);
	EndIf;	
	SubsetCreate(cApplicationsDim, cApplicationSubset);
	SubsetElementInsert(cApplicationsDim, cApplicationSubset, pAppId, 0);
		
	cApplicationView = 'tp_temp_reset_application_view_' | pExecutionId;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Application reset view : ' | cApplicationView);
	EndIf;
	If (ViewExists(cStateCube, cApplicationView) = 1);
		ViewDestroy(cStateCube, cApplicationView);	
	EndIf;	
	ViewCreate(cStateCube, cApplicationView);
	ViewColumnDimensionSet(cStateCube, cApplicationView, cNodeInfoDim, 1);
	ViewRowDimensionSet(cStateCube, cApplicationView, cApplicationsDim, 1);
	ViewSubsetAssign(cStateCube, cApplicationView, cApplicationsDim, cApplicationSubset);	
	ViewZeroOut(cStateCube, cApplicationView);
	ViewDestroy(cStateCube, cApplicationView);	
	SubsetDestroy(cApplicationsDim, cApplicationSubset);
Else;
	
	#*** 
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Zero out all view on State cube');
	EndIf;
	cAllView = 'All_reset_' | pAppId;
	If (ViewExists(cStateCube, cAllView) = 1);
		ViewDestroy(cStateCube, cAllView);	
	EndIf;	
	ViewCreate(cStateCube, cAllView);
	ViewColumnDimensionSet(cStateCube, cAllView, cNodeInfoDim, 1);
	ViewSubsetAssign(cStateCube, cAllView, cShadowApprovalDim, cApprovalSubset);
	ViewZeroOut(cStateCube, cAllView);
	ViewDestroy(cStateCube, cAllView);

	#***
	cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
	
	totalCubes = DIMSIZ('}Cubes');
	indexCube = totalCubes;
	
	#ZeroOut Global overlay cubes
	While (indexCube >= 1);
		cCubeName = DIMNM('}Cubes', indexCube);
	
		cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);
		cOverlayCube = '}SecurityOverlayGlobal_' | cCubeName;
		cOverlayMeasureDim = '}SecurityOverlay';
		If (cIsAppCube @= 'A' );
			#***check whether overlay cube contains version dimension
			vDimIndex =1;
			vDimension = TABDIM(cCubeName, vDimIndex);
			vFoundVersion = 'F';
			While (vDimension @<> '');
				IF (vDimension @= cVersionDim);
					vFoundVersion = 'T';
				EndIf;
				vDimIndex = vDimIndex +1;
				vDimension = TABDIM(cCubeName, vDimIndex);
			End;

			IF (CubeExists(cOverlayCube) >0);
				#*** reset secruity overlay cubes
				cAllView = 'All';
				If (ViewExists(cOverlayCube, cAllView) = 1);
					ViewDestroy(cOverlayCube, cAllView);
				EndIf;
				ViewCreate(cOverlayCube, cAllView);
				ViewColumnDimensionSet(cOverlayCube, cAllView, cOverlayMeasureDim, 1);
				ViewRowDimensionSet(cOverlayCube, cAllView, cApprovalDim, 1);
				IF (cVersionDim @<> '' & cVersionSlicesWrite @<> '' & vFoundVersion @= 'T' );
					ViewTitleDimensionSet(cOverlayCube, cAllView, cVersionDim);
					ViewSubsetAssign(cOverlayCube, cAllView, cVersionDim, vVersionSubset);
				Endif;
				ViewZeroOut(cOverlayCube, cAllView);
				ViewDestroy(cOverlayCube, cAllView);
			Endif;


		EndIf;
		
		indexCube = indexCube - 1;
	End;

	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set node state to Not Started if the node is in the subset');
	EndIf;
	
	#***
	
	cApprovalDimSize = DIMSIZ(cShadowApprovalDim);
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set state cube value for state if the node is in the subset');
	EndIf;
	
	cDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
	If (cDisplayUserName @= '');
		cDisplayUserName = TM1User;
	EndIf;
		
	vIndex = 1;
	While (vIndex <= cApprovalDimSize);
		vElement = DIMNM(cShadowApprovalDim, vIndex);
		
		vValue = CellGetS(cStateCube, vElement, 'State');
		If (vValue @= '');
			If (CellIsUpdateable(cStateCube, vElement, cState) = 0);
				vDetail=INSRT(cState,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vElement,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('0', cStateCube, vElement, cState);
			If (CellIsUpdateable(cStateCube, vElement, cStateChangeUser) = 0);
				vDetail=INSRT(cStateChangeUser,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vElement,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS(cDisplayUserName, cStateCube, vElement, cStateChangeDate);
			If (CellIsUpdateable(cStateCube, vElement, cStateChangeDate) = 0);
				vDetail=INSRT(cStateChangeDate,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vElement,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS(pTime, cStateCube, vElement, cStateChangeDate);
		EndIf;
		
		vIndex = vIndex + 1;
	End;
	
	#***
	
EndIf;

#***
IF (SubsetExists(cVersionDim, vVersionSubset) >0);
	SubsetDestroy(cVersionDim, vVersionSubset);
Endif;

#***
#Truncate the error dimension
vReturnValue = ExecuteProcess('}tp_util_truncate_error_dim');

#*** No error

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
