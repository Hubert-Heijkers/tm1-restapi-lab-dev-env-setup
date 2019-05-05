601,100
602,"}tp_add_user_security_from_file"
562,"CHARACTERDELIMITED"
586,"dummy.txt"
585,"dummy.txt"
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
pReviewerEditOn
pSourceFile
pCubeInfo
pIncremental
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
pReviewerEditOn,"F"
pSourceFile,"None"
pCubeInfo,"None"
pIncremental,"N"
pControl,"N"
637,7
pExecutionId,""
pAppId,""
pReviewerEditOn,""
pSourceFile,""
pCubeInfo,""
pIncremental,""
pControl,""
577,5
vNode
vGroup
vRight
vViewDepth
vReviewDepth
578,5
2
2
2
2
2
579,5
1
2
3
4
5
580,5
0
0
0
0
0
581,5
0
0
0
0
0
582,0
603,0
572,378

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
cTM1Process = cControlPrefix | 'tp_add_user_security_from_file';
StringGlobalVariable('gPrologLog');
StringGlobalVariable('gEpilogLog');
StringGlobalVariable('gDataLog');
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_log_file_names',
'pExecutionId', pExecutionId, 'pProcess', cTM1Process, 'pControl', pControl);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

cConfigDim = cControlPrefix | 'tp_config';
If (DimensionExists(cConfigDim) = 1);
	cGenerateLog = ATTRS(cControlPrefix | 'tp_config', 'Generate TI Log', 'String Value');
Else;
	cGenerateLog = 'N';
EndIf;

#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:',
		pExecutionId, pAppId, pReviewerEditOn, pSourceFile, pCubeInfo, pControl);
EndIf;

#*** Set local variables
DataSourceType = 'CHARACTERDELIMITED';
DatasourceASCIIDelimiter = CHAR(9);
DatasourceASCIIQuoteCharacter = '';
DatasourceASCIIHeaderRecords = 1;
DatasourceNameForServer = pSourceFile;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'DataSourceType: ' | DataSourceType);
	TextOutput(cTM1Log, 'DatasourceASCIIDelimiter: ' | DatasourceASCIIDelimiter);
	TextOutput(cTM1Log, 'DatasourceASCIIHeaderRecords: ' | NumberToString(DatasourceASCIIHeaderRecords));
	TextOutput(cTM1Log, 'DatasourceNameForServer: ' | DatasourceNameForServer);
EndIf;

#*** Set input file encoding as UTF-8

SetInputCharacterSet('TM1CS_UTF8');

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check application dimension');
EndIf;

cApplicationsDim = cControlPrefix | 'tp_applications';
cAppElementSecurityCube = '}ElementSecurity_' | cApplicationsDim;
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
	TextOutput(cTM1Log, 'Check application id', pAppId);
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
	TextOutput(cTM1Log, 'Get Approval dimension and subset');
EndIf;

cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cSecuritySet = ATTRS('}tp_applications', pAppId,  'SecuritySet');
cShadowApprovalDim = '}tp_tasks}' | pAppId;
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');
cVersionSlicesRead =ATTRS('}tp_applications', pAppId, 'VersionSlicesRead');
cSecurityMethod = ATTRS('}tp_applications', pAppId, 'SecurityMethod');
cElementSecurity = 'ELEMENT_SECURITY';

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
		'tp_get_application_attributes', cApprovalDim, cApprovalSubset, 
		cSecuritySet,cShadowApprovalDim,cVersionDim, cVersionSlicesWrite );
EndIf;

#***
IF (cVersionDim @<> '' & cVersionSlicesWrite @<> '');
	#create version subset that contains this version only
	vVersionSubset = 'temp_app_version' | pAppId;
	IF (SubsetExists(cVersionDim, vVersionSubset)>0);
		subsetDestroy(cVersionDim, vVersionSubset);
	EndIf;
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
		EndIf;
		

		vStringToScan = SUBST(vStringToScan, vPosVersion +1, LONG(vStringToScan)-vPosVersion);
		vPosVersion = SCAN(versionSeparater, vStringToScan);
	End;

EndIf;

#***

If (cApprovalDim @= '');
	cOwnPermissionElement = 'OWN';
	cAppPermSecurityCube = '}CellSecurity_' | cControlPrefix | 'tp_application_root_permissions';
	
	cGroupsDimSize = DIMSIZ('}Groups');
	vIndexI = 1;
	While (vIndexI <= cGroupsDimSize);
	
		vGroup = DIMNM('}Groups', vIndexI);
		If (vGroup @<> 'Admin' & vGroup @<> 'DataAdmin' & vGroup @<> 'SecurityAdmin');
			CellPutS('NONE', cAppElementSecurityCube, pAppId, vGroup);
			CellPutS('NONE', cAppPermSecurityCube, pAppId, cOwnPermissionElement, vGroup);
		EndIf;
	
		vIndexI = vIndexI + 1;
	End;
Else;

	#***
	vAppSubset = 'temp_app_' | pAppId;
	vAppDim = '}tp_intermediate_security_applications';
	IF (SubsetExists(vAppDim, vAppSubset)>0);
		SubsetDestroy(vAppDim, vAppSubset);
	EndIf;
	SubsetCreate(vAppDim, vAppSubset);
	SubsetElementInsert(vAppDim, vAppSubset, pAppId, 1);
	#***

	cApprovalDimSize = DIMSIZ(cApprovalDim);
	cApprovalSubsetSize = SubsetGetSize(cApprovalDim, cApprovalSubset);
	
	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Check permission cube');
	EndIf;
	
	cPermissionCube = cControlPrefix | 'tp_application_permission}' | pAppId;
	If (CubeExists(cPermissionCube) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cPermissionCube,
		'pControl', pControl);
	
		ProcessError;
	EndIf;

	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Check cell level security cube');
	EndIf;

	cCellSecurityCube = '}CellSecurity_' | cPermissionCube;

	If (CubeExists(cCellSecurityCube) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cCellSecurityCube,
		'pControl', pControl);
		
		ProcessError;
	EndIf;

	#***
	StringGlobalVariable('gTopNode');
	NumericGlobalVariable('gTopLevel');
	
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_top_node',
	'pExecutionId', pExecutionId, 'pDim', cApprovalDim, 'pSubset', cApprovalSubset);
	If (vReturnValue <> ProcessExitNormal());
	ProcessError;
	EndIf;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
			'tp_get_top_node', gTopNode, NumberToString(gTopLevel));
	EndIf;

	#*** Zero out the values in cubes that are not in the approval subset
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Zero out the values in cubes that are not in the approval subset');
	EndIf;

	cElementSecurityCube = '}ElementSecurity_' | cShadowApprovalDim;
	cElementSecurityCubeOnApproval = '}ElementSecurity_' | cApprovalDim;

	cPermissionsDim = cControlPrefix | 'tp_permissions';
	cPermissionCube = cControlPrefix | 'tp_application_permission}' | pAppId;
	cCellSecurityCube = '}CellSecurity_' | cPermissionCube;


	#* Zero out cell security cube
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Zero out cell security cube');
	EndIf;

	IF (pIncremental @= 'N');
		vAllView = 'tp_all_cell_security_view_' | pExecutionId;
		ViewCreate(cCellSecurityCube, vAllView);
		ViewColumnDimensionSet(cCellSecurityCube, vAllView, '}Groups', 1);
		ViewRowDimensionSet(cCellSecurityCube, vAllView, cShadowApprovalDim, 1);
		ViewTitleDimensionSet(cCellSecurityCube, vAllView, cPermissionsDim);

		ViewZeroOut(cCellSecurityCube, vAllView);
		ViewDestroy(cCellSecurityCube, vAllView);
	EndIf;

	# Zero out RDCLS intermediate cubes for this applications only
	cubeSeparater = '*';
	vPosCube = 0;
	vStringToScan = pCubeInfo;
	vPosCube = SCAN(cubeSeparater, vStringToScan);
	vFirstElement = 1;


	While (vPosCube >0);
		vCubeName = SUBST(vStringToScan, 1, vPosCube-1);
		vFlagCube = SUBST(vStringToScan, vPosCube+1, 1);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Udate RDCS cubes pAppId=' | pAppId | ' CubeName=' | vCubeName );
		EndIf;
	
		If (vFlagCube @= 'A' );
			vRDCLSIntermediateCube = '}tp_intermediate_RDCLS}' | vCubeName;
			vIntermediateSecurityMeasureDim = '}tp_intermediate_security_measures';
		
			#clear RDCLS intermediate cube for this application only
			IF (cubeExists(vRDCLSIntermediateCube) >0);
				IF (pIncremental @= 'N');
					vAllView = 'tp_temp_RDCLS_view_' | pExecutionId;
					ViewCreate(vRDCLSIntermediateCube, vAllView);
					ViewColumnDimensionSet(vRDCLSIntermediateCube, vAllView, vIntermediateSecurityMeasureDim, 1);
					ViewRowDimensionSet(vRDCLSIntermediateCube, vAllView, cApprovalDim, 1);
					ViewTitleDimensionSet(vRDCLSIntermediateCube, vAllView, vAppDim);
					ViewSubsetAssign(vRDCLSIntermediateCube, vAllView, vAppDim, vAppSubset);
					ViewZeroOut(vRDCLSIntermediateCube, vAllView);
					ViewDestroy(vRDCLSIntermediateCube, vAllView);
				Else;
					#TODO zero out complement subset view
				EndIf;
			EndIf;

		EndIf;
	
		vStringToScan = SUBST(vStringToScan, vPosCube +3, LONG(vStringToScan)-vPosCube);
		vPosCube = SCAN(cubeSeparater, vStringToScan);
	End;

	#* TODO Zero out element security intermediate cubes for this application only


	#* Zero out element security cube for shadow approval dimension
	IF (pIncremental @= 'N');
		vAllView = 'tp_all_elem_security_view_' | pExecutionId;
		ViewCreate(cElementSecurityCube, vAllView);
		ViewColumnDimensionSet(cElementSecurityCube, vAllView, '}Groups', 1);
		ViewRowDimensionSet(cElementSecurityCube, vAllView,cShadowApprovalDim , 1);
		ViewZeroOut(cElementSecurityCube, vAllView);
		ViewDestroy(cElementSecurityCube, vAllView);
		
		IF (cSecurityMethod @= cElementSecurity);
			vAllView = 'tp_all_elem_security_view_' | pExecutionId;
			ViewCreate(cElementSecurityCubeOnApproval, vAllView);
			ViewColumnDimensionSet(cElementSecurityCubeOnApproval, vAllView, '}Groups', 1);
			ViewRowDimensionSet(cElementSecurityCubeOnApproval, vAllView,cShadowApprovalDim , 1);
			ViewZeroOut(cElementSecurityCubeOnApproval, vAllView);
			ViewDestroy(cElementSecurityCubeOnApproval, vAllView);
		Endif;
	EndIf;

	#* Zero out application element security cube
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Zero out application element security cube');
	EndIf;

	vAppSubset = 'temp_app_' | pAppId;
	IF (SubsetExists(cApplicationsDim, vAppSubset)>0);
		subsetDestroy(cApplicationsDim, vAppSubset);
	EndIf;
	SubsetCreate(cApplicationsDim, vAppSubset);
	SubsetElementInsert(cApplicationsDim, vAppSubset, pAppId, 1);

	IF (pIncremental @= 'N');
		vAllView = 'tp_all_app_security_view_' | pExecutionId;
		ViewCreate(cAppElementSecurityCube, vAllView);
		ViewColumnDimensionSet(cAppElementSecurityCube, vAllView, '}Groups', 1);
		ViewRowDimensionSet(cAppElementSecurityCube, vAllView,cApplicationsDim , 1);
		ViewSubsetAssign(cAppElementSecurityCube, vAllView, cApplicationsDim, vAppSubset);
		ViewZeroOut(cAppElementSecurityCube, vAllView);
		ViewDestroy(cAppElementSecurityCube, vAllView);
	EndIf;

EndIf;

#***
#If this is an incremental security update, 
#We need to create a temp dimension that records all groups that have new updates
vIncrGroupDim = 'tp_incr_temp_groups_' | pAppId;

IF (pIncremental @= 'Y');
	IF (DimensionExists(vIncrGroupDim) >0);
		DimensionDestroy(vIncrGroupDim);
	EndIf;

	DimensionCreate(vIncrGroupDim);
EndIf;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,850


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
cTM1Log = cDataLog;

cRightView = 'VIEW';
cRightEdit = 'EDIT';
cRightSubmit = 'SUBMIT';
cRightReview = 'REVIEW';
cRightOwn = 'OWN';

cView = 'VIEW';
cAnnotate = 'ANNOTATE';
cEdit = 'EDIT';
cReject = 'REJECT';
cSubmit = 'SUBMIT';

cCubeSecurityCube = '}CubeSecurity';
cDimensionSecurityCube = '}DimensionSecurity';
cElementAttributesPrefix = '}ElementAttributes_';

IF (pReviewerEditOn @= 'T');
	cReviewerEditOn ='T';
Else;
	cReviewerEditOn = 'F';
ENDIF;

cViewDepth = NUMBR(vViewDepth);
cReviewDepth = NUMBR(vReviewDepth);

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Security set', cSecuritySet, 'Node', vNode, 'Group', vGroup, 'Right', vRight);
EndIf;

cNone = 'NONE';
cRead = 'READ';
cWrite = 'WRITE';
cLock = 'WRITE';

#***
IF (DIMIX('}Groups', vGroup)>0);
	cGroupPName = DimensionElementPrincipalName('}Groups', vGroup);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Group principal name', cGroupPName);
	EndIf;
Else;
	cGroupPName = '';

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Group not found');
	EndIf;
EndIf;

#Insert the group into the incr temp group dimension
#then zero out the views on this group
vContinueNodeUpdate = 'Y';
IF (pIncremental @= 'Y' & cGroupPName @<> '');

	IF (vNode @= '');
		vContinueNodeUpdate = 'N';
	EndIf;

	IF (DIMIX(vIncrGroupDim, cGroupPName) =0);

		#create a group subset that contains this group only
		vTempGroupSubset = 'temp_group_' | pAppId;
		vGroupDim = '}Groups';
		IF (SubsetExists(vGroupDim, vTempGroupSubset)>0);
			SubsetDestroy(vGroupDim, vTempGroupSubset);
		EndIf;
		SubsetCreate(vGroupDim, vTempGroupSubset);
		SubsetElementInsert(vGroupDim, vTempGroupSubset, cGroupPName, 1);

		#zero out views for this application and group slice
		vGroupView = 'tp_temp_group_view_' | pExecutionId;

		#zero out cell security permission cube on this group slice
		ViewCreate(cCellSecurityCube, vGroupView);
		ViewTitleDimensionSet(cCellSecurityCube, vGroupView, vGroupDim);
		ViewSubsetAssign(cCellSecurityCube, vGroupView, vGroupDim, vTempGroupSubset );
		ViewRowDimensionSet(cCellSecurityCube, vGroupView, cShadowApprovalDim, 1);
		ViewColumnDimensionSet(cCellSecurityCube, vGroupView, cPermissionsDim,1);

		ViewZeroOut(cCellSecurityCube, vGroupView);
		ViewDestroy(cCellSecurityCube, vGroupView);

		#zero out element security on shadow approval dimension on this group slice
		ViewCreate(cElementSecurityCube, vGroupView);
		ViewColumnDimensionSet(cElementSecurityCube, vGroupView, vGroupDim, 1);
		ViewSubsetAssign(cElementSecurityCube, vGroupView, vGroupDim, vTempGroupSubset );
		ViewRowDimensionSet(cElementSecurityCube, vGroupView,cShadowApprovalDim , 1);
		ViewZeroOut(cElementSecurityCube, vGroupView);
		ViewDestroy(cElementSecurityCube, vGroupView);

		IF (cSecurityMethod @= cElementSecurity);
			#zero out element security on approval dimension on this group slice
			ViewCreate(cElementSecurityCubeOnApproval, vGroupView);
			ViewColumnDimensionSet(cElementSecurityCubeOnApproval, vGroupView, vGroupDim, 1);
			ViewSubsetAssign(cElementSecurityCubeOnApproval, vGroupView, vGroupDim, vTempGroupSubset );
			ViewRowDimensionSet(cElementSecurityCubeOnApproval, vGroupView,cShadowApprovalDim , 1);
			ViewZeroOut(cElementSecurityCubeOnApproval, vGroupView);
			ViewDestroy(cElementSecurityCubeOnApproval, vGroupView);
		Endif;
		#***
		#zero out RDCLS intermediate cube on the group and application slice
		cubeSeparater = '*';
		vPosCube = 0;
		vStringToScan = pCubeInfo;
		vPosCube = SCAN(cubeSeparater, vStringToScan);

		While (vPosCube >0);
			vCubeName = SUBST(vStringToScan, 1, vPosCube-1);
			vFlagCube = SUBST(vStringToScan, vPosCube+1, 1);
	
			If (vFlagCube @= 'A' );
				vRDCLSIntermediateCube = '}tp_intermediate_RDCLS}' | vCubeName;
				vIntermediateSecurityMeasureDim = '}tp_intermediate_security_measures';
		
				IF (cubeExists(vRDCLSIntermediateCube) >0);

					ViewCreate(vRDCLSIntermediateCube, vGroupView);
					ViewColumnDimensionSet(vRDCLSIntermediateCube, vGroupView, vIntermediateSecurityMeasureDim, 1);
					ViewRowDimensionSet(vRDCLSIntermediateCube, vGroupView, vGroupDim, 1);
					ViewSubsetAssign(vRDCLSIntermediateCube, vGroupView, vGroupDim, vTempGroupSubset );
					ViewTitleDimensionSet(vRDCLSIntermediateCube, vGroupView, vAppDim);
					ViewSubsetAssign(vRDCLSIntermediateCube, vGroupView, vAppDim, vAppSubset);
					ViewZeroOut(vRDCLSIntermediateCube, vGroupView);
					ViewDestroy(vRDCLSIntermediateCube, vGroupView);
				Endif;
			Endif;
			vStringToScan = SUBST(vStringToScan, vPosCube +3, LONG(vStringToScan)-vPosCube);
			vPosCube = SCAN(cubeSeparater, vStringToScan);
		End;

		#***
		#zero out application element security cube for group and application slice
		ViewCreate(cAppElementSecurityCube, vGroupView);
		ViewColumnDimensionSet(cAppElementSecurityCube, vGroupView, vGroupDim, 1);
		ViewSubsetAssign(cAppElementSecurityCube, vGroupView, vGroupDim, vTempGroupSubset );
		ViewRowDimensionSet(cAppElementSecurityCube, vGroupView,cApplicationsDim , 1);
		ViewSubsetAssign(cAppElementSecurityCube, vGroupView, cApplicationsDim, vAppSubset);
		ViewZeroOut(cAppElementSecurityCube, vGroupView);
		ViewDestroy(cAppElementSecurityCube, vGroupView);

		#Insert this group into the temp dimension
		DimensionElementInsertDirect(vIncrGroupDim, '',cGroupPName ,'N');

		IF (SubsetExists(vGroupDim, vTempGroupSubset)>0);
			SubsetDestroy(vGroupDim, vTempGroupSubset);
		Endif;
	Endif;
Endif;

If (cApprovalDim @<> '' & cGroupPName @<> '' & vContinueNodeUpdate @= 'Y');

	If (DIMIX(cShadowApprovalDim, vNode) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_NODE_NOT_EXIST',
			'pErrorDetails', cShadowApprovalDim | ', ' | vNode,
			'pControl', pControl);
	
		ProcessError;
	EndIf;
	
	If (DIMIX('}Groups', vGroup) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_GROUP_NOT_EXIST',
			'pErrorDetails', '}Groups' | ', ' | vGroup,
			'pControl', pControl);
	
		ProcessError;
	EndIf;
	
	cNodePName = DimensionElementPrincipalName(cShadowApprovalDim, vNode);
	
	If ((cNodePName @<> gTopNode) & (ELISANC(cShadowApprovalDim, gTopNode, cNodePName) = 0));
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_NODE_NOT_EXIST_IN_SUBSET',
			'pErrorDetails', cApprovalDim | ', ' | cApprovalSubset | ', ' | cNodePName,
			'pControl', pControl);
	
		ProcessError;
	EndIf;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Get node and group principal name', cNodePName, cGroupPName);
	EndIf;
	
	# Give read right to the attributes dimension and cube of the approval dimension
	cElementAttributes = cElementAttributesPrefix | cShadowApprovalDim;
	If (DimensionExists(cElementAttributes) <> 0);
		CellPutS(cRead, cDimensionSecurityCube, cElementAttributes, cGroupPName);
	EndIf;
	If (CubeExists(cElementAttributes) <> 0);
		CellPutS(cRead, cCubeSecurityCube, cElementAttributes, cGroupPName);
	EndIf;
	
	# IF(1)
		If (DTYPE(cShadowApprovalDim, cNodePName) @= 'C');
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Consolidation node', cNodePName);
			EndIf;
	
			#***
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Assign rights to self', cNodePName);
			EndIf;
	
			If (vRight @= cRightSubmit);
	
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				EndIf;

				IF (cNodePName @<> gTopNode);
					If (vCellValue @= '');
						CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
					EndIf;
				Else;
					#Submit rights on top node can reject the top node
					CellPutS(cRead, cCellSecurityCube, cNodePName, cReject, cGroupPName);						
				Endif;

				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
				EndIf;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '142:ElementSecurityPut for submit ' | cNodePName | ',' | cRead | ',' | cGroupPName);
				EndIf;
				CellPutS(cWrite, cElementSecurityCube, cNodePName, cGroupPName);
				IF (cSecurityMethod @= cElementSecurity);
					CellPutS(cWrite, cElementSecurityCubeOnApproval, cNodePName, cGroupPName);
				Endif;

	
			ElseIf (vRight @= cRightReview);
	
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cReject, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
				EndIf;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '169:ElementSecurityPut for review ' | cNodePName | ',' | cRead | ',' | cGroupPName);
				EndIf;
				CellPutS(cWrite, cElementSecurityCube, cNodePName, cGroupPName);
				IF (cSecurityMethod @= cElementSecurity);
					CellPutS(cWrite, cElementSecurityCubeOnApproval, cNodePName, cGroupPName);
				Endif;
	
			ElseIf (vRight @= cRightView);
	
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cReject, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				If (vCellValue @= '');
					CellPutS(cNone, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
				EndIf;
				vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
				If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
					CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
				EndIf;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '197:ElementSecurityPut for view ' | cNodePName | ',' | cRead | ',' | cGroupPName);
				EndIf;
				CellPutS(cWrite, cElementSecurityCube , cNodePName, cGroupPName);
				IF (cSecurityMethod @= cElementSecurity);
					CellPutS(cWrite, cElementSecurityCubeOnApproval, cNodePName, cGroupPName);
				Endif;
	
			EndIf;
	

			#***
	
			cLevel = ELLEV(cShadowApprovalDim, cNodePName);

			#IF(2)
			If (cLevel > cReviewDepth);
	
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Level is greater than review depth: ' | NumberToString(cLevel));
				EndIf;
	
	
				cReviewDescendantsSubset = 'tp_temp_review_descendants_' | pExecutionId;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Pass review right down, review depth: ' | vReviewDepth);
				EndIf;
	
				StringGlobalVariable('gMdxFindDescendants');
	
				#IF(2.1)
				If ((vRight @= cRightSubmit % vRight @= cRightReview) & (cReviewDepth > 0));
	
					vReturnValue = ExecuteProcess(cControlPrefix | 'tp_mdx_find_descendants', 
						'pExecutionId', pExecutionId, 
						'pDim', cShadowApprovalDim, 'pSubset', '', 'pNode', cNodePName, 'pDepth', vReviewDepth, 'pSelf', 'Y');
					If (vReturnValue <> ProcessExitNormal());
						ProcessError;
					EndIf;
					SubsetDestroy(cShadowApprovalDim, cReviewDescendantsSubset);
					SubsetCreateByMDX(cReviewDescendantsSubset, gMdxFindDescendants);
					vReturnValue = ExecuteProcess(cControlPrefix | 'tp_util_convert_dynamic_subset_to_static', 'pExecutionId', pExecutionId,
					'pDim', cShadowApprovalDim, 'pSubset', cReviewDescendantsSubset);
					If (vReturnValue <> ProcessExitNormal());
						ProcessError;
					EndIf;
	
					cReviewDescendantsSubsetSize = SubsetGetSize(cShadowApprovalDim, cReviewDescendantsSubset);
					vIndex = 1;
					While (vIndex <= cReviewDescendantsSubsetSize);
						vReadOrWrite = cRead;
						vElement = SubsetGetElementName(cShadowApprovalDim, cReviewDescendantsSubset, vIndex);
						vElementPName = DimensionElementPrincipalName(cShadowApprovalDim, vElement);
	
						#IF(2.1.1)
						If (vElementPName @<> cNodePName);
	
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cReject, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cReject, cGroupPName);
							EndIf;
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
							EndIf;
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cView, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cView, cGroupPName);
							EndIf;
	
							#***Add additional privileges with reviewer edit on
							#IF(2.1.1.1)
							If (cReviewerEditOn @= 'T');
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
									CellPutS(cRead, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								EndIf;
	
								If (DTYPE(cShadowApprovalDim, vElementPName) @<> 'C');
									vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
										CellPutS(cRead, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									EndIf;
									vReadOrWrite = cLock;
	
								Else;
									vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									If (vCellValue @= '');
										CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									EndIf;
									vReadOrWrite = cWrite;
	
								EndIf;
	
							#IF(2.1.1.1)
							Else;
	
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								If (vCellValue @= '');
									CellPutS(cNone, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								EndIf;
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
								If (vCellValue @= '');
									CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
								EndIf;

	
							#IF(2.1.1.1)
							EndIf;
	
							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
									'306:ElementSecurityPut for ' | vElementPName | ',' | vRight | ',' | vReadOrWrite | ',' |  cGroupPName);
							EndIf;
							cCellValue = CellGetS(cElementSecurityCube , vElementPName, cGroupPName);
							If ( cCellValue @<> vReadOrWrite);
 								If (vReadOrWrite @= cLock);
									CellPutS(vReadOrWrite, cElementSecurityCube , vElementPName, cGroupPName);
										IF (cSecurityMethod @= cElementSecurity);
											CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
										Endif;
								Endif;

								If (vReadOrWrite @= cWrite & cCellValue @<> cLock);
									CellPutS(vReadOrWrite, cElementSecurityCube , vElementPName, cGroupPName);
									IF (cSecurityMethod @= cElementSecurity);
										CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
									Endif;										
								Endif;

								If (vReadOrWrite @= cRead & cCellValue @<>cLock & cCellValue @<> cWrite);
									CellPutS(vReadOrWrite, cElementSecurityCube , vElementPName, cGroupPName);
									IF (cSecurityMethod @= cElementSecurity);
										CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
									Endif;

								Endif;
		
							Endif;
		
						#IF(2.1.1)
						EndIf;
	
						vIndex = vIndex +1;
					End;
	
					SubsetDestroy(cShadowApprovalDim, cReviewDescendantsSubset);
	

				#IF(2.1)
				EndIf;
	
			#IF(2)
			Else;
	
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Level is less than or equal to review depth: ' | NumberToString(cLevel));
				EndIf;
	
				#IF(2.2)
				If ((vRight @= cRightSubmit % vRight @= cRightReview));
	
					vIndex = 1;
					While (vIndex <= cApprovalDimSize);
						vReadOrWrite = cRead;
						vElement = DIMNM(cShadowApprovalDim, vIndex);
						#IF(2.2.1)
						If (ELISANC(cShadowApprovalDim, cNodePName, vElement) = 1);
							vElementPName = DimensionElementPrincipalName(cShadowApprovalDim, vElement);
	
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cReject, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cReject, cGroupPName);
							EndIf;
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
							EndIf;
							vCellValue = CellGetS(cCellSecurityCube, vElementPName, cView, cGroupPName);
							If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
								CellPutS(cRead, cCellSecurityCube, vElementPName, cView, cGroupPName);
							EndIf;
	
							#***Add additional privileges with reviewer edit on
							#IF(2.2.1.1)
							If (cReviewerEditOn @= 'T');
	
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
									CellPutS(cRead, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								EndIf;
	
								If (DTYPE(cShadowApprovalDim, vElementPName) @<> 'C');
									vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
										CellPutS(cRead, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									EndIf;
									vReadOrWrite = cLock;
	
								Else;
									vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									If (vCellValue @= '');
										CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
									EndIf;
									vReadOrWrite = cWrite;
	
								EndIf;
	
							#IF(2.2.1.1)
							Else;
	
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								If (vCellValue @= '');
									CellPutS(cNone, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
								EndIf;
								vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
								If (vCellValue @= '');
									CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
								EndIf;
	
							#IF(2.2.1.1)
							EndIf;
	
							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
									'392:ElementSecurityPut for ' | vElementPName | ',' | vRight | ',' | vReadOrWrite | ',' |  cGroupPName);
							EndIf;

							cCellValue = CellGetS(cElementSecurityCube , vElementPName, cGroupPName);
							If ( cCellValue @<> vReadOrWrite);
 								If (vReadOrWrite @= cLock);
									CellPutS(vReadOrWrite, cElementSecurityCube , vElementPName, cGroupPName);
									IF (cSecurityMethod @= cElementSecurity);
										CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
									Endif;
								Endif;

								If (vReadOrWrite @= cWrite & cCellValue @<> cLock);
									CellPutS(vReadOrWrite, cElementSecurityCube , vElementPName, cGroupPName);	
									IF (cSecurityMethod @= cElementSecurity);
										CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
									Endif;
								Endif;

								If (vReadOrWrite @= cRead & cCellValue @<>cLock & cCellValue @<> cWrite);
									CellPutS(vReadOrWrite, cElementSecurityCube, vElementPName, cGroupPName);
									IF (cSecurityMethod @= cElementSecurity);
										CellPutS(vReadOrWrite, cElementSecurityCubeOnApproval, vElementPName, cGroupPName);
									Endif;
								Endif;
		
							Endif;
	
						#IF(2.2.1)
						EndIf;
	
						vIndex = vIndex + 1;
					End;
	
				#IF(2.2)
				EndIf;
	
			#IF(2)
			EndIf;
	
			#***
	
			#IF(3)
			If (((vRight @= cRightSubmit % vRight @= cRightReview) & (cViewDepth > cReviewDepth)) %
	    		(vRight @= cRightView));
	
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Pass View right down, view depth: ' | vViewDepth);
				EndIf;
	
				#IF(3.1)
				If (cLevel > cViewDepth);
	
				cViewDescendantsSubset = 'tp_temp_view_descendants_' | pExecutionId;
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_mdx_find_descendants', 
					'pExecutionId', pExecutionId, 
					'pDim', cShadowApprovalDim, 'pSubset', '', 'pNode', cNodePName, 'pDepth', vViewDepth, 'pSelf', 'Y');
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
				SubsetDestroy(cShadowApprovalDim, cViewDescendantsSubset);
				SubsetCreateByMDX(cViewDescendantsSubset, gMdxFindDescendants);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_util_convert_dynamic_subset_to_static', 'pExecutionId', pExecutionId,
					'pDim', cShadowApprovalDim, 'pSubset', cViewDescendantsSubset);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;

				cViewDescendantsSubsetSize = SubsetGetSize(cShadowApprovalDim, cViewDescendantsSubset);
				vIndex = 1;
				While (vIndex <= cViewDescendantsSubsetSize);
					vElement = SubsetGetElementName(cShadowApprovalDim, cViewDescendantsSubset, vIndex);
					vElementPName = DimensionElementPrincipalName(cShadowApprovalDim, vElement);
	
					If (vElementPName @<> cNodePName);
	
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cReject, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cReject, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cView, cGroupPName);
						If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
							CellPutS(cRead, cCellSecurityCube, vElementPName, cView, cGroupPName);
						EndIf;

						cCellValue = CellGetS(cElementSecurityCube , vElementPName, cGroupPName);
						If ( cCellValue @= '' % cCellValue @= cNone);
							CellPutS(cRead, cElementSecurityCube , vElementPName, cGroupPName);
							IF (cSecurityMethod @= cElementSecurity);
								CellPutS(cRead, cElementSecurityCubeOnApproval , vElementPName, cGroupPName);
							Endif;
						Endif;

	
					EndIf;
	
					vIndex = vIndex +1;
				End;
	
				SubsetDestroy(cShadowApprovalDim, cViewDescendantsSubset);
	
			#IF(3.1)
			Else;
	
				vIndex = 1;
				While (vIndex <= cApprovalDimSize);
					vElement = DIMNM(cShadowApprovalDim, vIndex);
					#IF(3.1.1)
					If (ELISANC(cShadowApprovalDim, cNodePName, vElement) = 1);
						vElementPName = DimensionElementPrincipalName(cShadowApprovalDim, vElement);
		
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cSubmit, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cReject, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cReject, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cEdit, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cEdit, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
						If (vCellValue @= '');
							CellPutS(cNone, cCellSecurityCube, vElementPName, cAnnotate, cGroupPName);
						EndIf;
						vCellValue = CellGetS(cCellSecurityCube, vElementPName, cView, cGroupPName);
						If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
							CellPutS(cRead, cCellSecurityCube, vElementPName, cView, cGroupPName);
						EndIf;
						If (cGenerateLog @= 'Y');
							TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
								'499:ElementSecurityPut for ' | vElementPName | ',' | vRight | ',' | cRead | ',' | cGroupPName);
						EndIf;
						cCellValue = CellGetS(cElementSecurityCube , vElementPName, cGroupPName);
						If ( cCellValue @= '' % cCellValue @= cNone);
							CellPutS(cRead, cElementSecurityCube, vElementPName, cGroupPName);
							IF (cSecurityMethod @= cElementSecurity);
								CellPutS(cRead, cElementSecurityCubeOnApproval, vElementPName, cGroupPName);
							Endif;
						EndIf;
		
					#IF(3.1.1)
					EndIf;
		
					vIndex = vIndex + 1;
				End;
	
			#IF(3.1)
			EndIf;
	
		#IF(3)
		Else;
	
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'No need to pass View right down, view depth: ' | vViewDepth);
			EndIf;
	
		#IF(3)
		EndIf;
	
	# IF(1)
	Else;
		If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Leaf node', cNodePName);
		EndIf;
	
		If (vRight @= cRightSubmit);
	
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cReject, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
			EndIf;
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '551:ElementSecurityPut for ' | cNodePName | ',' | vRight | ',' | cRead | ',' | cGroupPName);
			EndIf;

			CellPutS(cLock, cElementSecurityCube , cNodePName, cGroupPName);
			IF (cSecurityMethod @= cElementSecurity);
				CellPutS(cLock, cElementSecurityCubeOnApproval , cNodePName, cGroupPName);
			Endif;
		ElseIf (vRight @= cRightEdit);
	
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cReject, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
			EndIf;
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '582:ElementSecurityPut for ' | cNodePName | ',' | vRight | ',' | cWrite | ',' | cGroupPName);
			EndIf;
			cCellValue = CellGetS(cElementSecurityCube , cNodePName, cGroupPName);
			If ( cCellValue @<> cLock);
				CellPutS(cWrite, cElementSecurityCube , cNodePName, cGroupPName);
				IF (cSecurityMethod @= cElementSecurity);
					CellPutS(cWrite, cElementSecurityCubeOnApproval , cNodePName, cGroupPName);
				Endif;
			EndIf;
	
		ElseIf (vRight @= cRightView);
	
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cSubmit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cReject, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cReject, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cEdit, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			If (vCellValue @= '');
				CellPutS(cNone, cCellSecurityCube, cNodePName, cAnnotate, cGroupPName);
			EndIf;
			vCellValue = CellGetS(cCellSecurityCube, cNodePName, cView, cGroupPName);
			If (vCellValue @= '' % CODE(vCellValue, 1) <> CODE(cRead, 1));
				CellPutS(cRead, cCellSecurityCube, cNodePName, cView, cGroupPName);
			EndIf;
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '609:ElementSecurityPut for ' | cNodePName | ',' | vRight | ',' | cRead | ',' | cGroupPName);
			EndIf;
			cCellValue = CellGetS(cElementSecurityCube , cNodePName, cGroupPName);
			If ( cCellValue @<> cLock & cCellValue @<> cWrite);
				CellPutS(cRead, cElementSecurityCube , cNodePName, cGroupPName);
				IF (cSecurityMethod @= cElementSecurity);
					CellPutS(cRead, cElementSecurityCubeOnApproval , cNodePName, cGroupPName);
				Endif;
			EndIf;
	
		EndIf;
	
	# IF(1)
	EndIf;

EndIf;

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Make Application element readable for group', cGroupPName);
EndIf;

cApplicationsDim = cControlPrefix | 'tp_applications';
If (vRight @= cRightView % vRight @= cRightEdit % vRight @= cRightReview % vRight @= cRightSubmit);
	CellPutS(cRead, cAppElementSecurityCube, pAppId, cGroupPName);
	
	# For Central applications view right is equivalent to own right
	If (cApprovalDim @= '' & vRight @= cRightView);
		CellPutS(cRead, cAppPermSecurityCube, pAppId, cOwnPermissionElement, vGroup);
	EndIf;
ElseIf (vRight @= cRightOwn);
	CellPutS(cRead, cAppElementSecurityCube, pAppId, cGroupPName);
	CellPutS(cRead, cAppPermSecurityCube, pAppId, cOwnPermissionElement, vGroup);
EndIf;
#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

575,54


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

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Starting epilog.');
EndIf;

#***
IF (SubsetExists(cVersionDim, vVersionSubset) >0);
	SubsetDestroy(cVersionDim, vVersionSubset);
Endif;

IF (SubsetExists(vAppDim, vAppSubset) >0);
	SubsetDestroy(vAppDim, vAppSubset);
Endif;

IF (SubsetExists(cApplicationsDim, vAppSubset) >0);
	subsetDestroy(cApplicationsDim, vAppSubset);
Endif;

#***
#If using element security is enforced by rule on the approval dimension
#We need to call SecurityRefresh after rights saving
cConfigAttrCube = '}ElementAttributes_}tp_config';
vEnforceElementSecurityOnApproval = CellGetS(cConfigAttrCube, 'EnableElementSecurityOnApproval', 'String Value');
cApplicationAttrCube = '}ElementAttributes_}tp_applications';
vSecurityMethod = CellGetS(cApplicationAttrCube, pAppId, 'SecurityMethod');
IF (vEnforceElementSecurityOnApproval @= 'Y' & vSecurityMethod @= 'CELL_SECURITY');
	SecurityRefresh();
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
