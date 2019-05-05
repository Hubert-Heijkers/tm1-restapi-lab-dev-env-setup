601,100
602,"}tp_deploy_app_cubes_cleanup"
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
572,219
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

cApprovalDIM = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalDimension');
cApprovalSubset = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalSubset');
cAppActive = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'IsActive'); 
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');
cVersionSlicesRead =ATTRS('}tp_applications', pAppId, 'VersionSlicesRead');

cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
cCubePropertiesCube = '}CubeProperties';
cCentralApplicationStateCube = cControlPrefix | 'tp_central_application_state';
cApplicationStateCube = cControlPrefix | 'tp_application_state}'|pAppId;

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
vAppSubset = 'temp_app_' | pAppId;
vAppDim = '}tp_intermediate_security_applications';
IF (SubsetExists(vAppDim, vAppSubset)>0);
	SubsetDestroy(vAppDim, vAppSubset);
Endif;
SubsetCreate(vAppDim, vAppSubset);
SubsetElementInsert(vAppDim, vAppSubset, pAppId, 1);
#***

#clear existing cube flags in case this is a redeployment
vCubeName = pCubeName;
vSecuirtyOverlayCube = '}SecurityOverlayGlobal_' | vCubeName;
vRDCellSecurityCube = '}CellSecurity_' | vCubeName;
vRDCLSIntermediateCube = '}tp_intermediate_RDCLS}' | vCubeName;
vIntermediateApplicationsDim = '}tp_intermediate_security_applications';
vIntermediateSecurityMeasureDim = '}tp_intermediate_security_measures';

cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, vCubeName);

If (cIsAppCube @= 'A' % (cApprovalDIM @= '' & cIsAppCube @<> ''));

	#***Remove task security cube for this application
	cTaskSecurityCube = '}tp_task_security}' | pCubeName | '}' | pAppId;
	CubeDestroy(cTaskSecurityCube);

	#check whether this cube is shared by other applications
	vAppLooper = 1;
	vIsOtherAppCube = '';
	vUsedByOtherApp = 'F';
	vAppDimension = '}tp_applications';
	vOtherAppIsActive = 'F';
	vTotalApps = DIMSIZ(vAppDimension);
	vNewDRMode = '';
	While (vAppLooper <= vTotalApps);
		vOtherAppId = DIMNM(vAppDimension, vAppLooper);
		IF (trim(vOtherAppId) @<> trim(pAppId));
			vIsOtherAppCube = CellGetS(cApplicationCubesCube, vOtherAppId, vCubeName);
			vOtherAppActive = ATTRS(cControlPrefix | 'tp_applications', vOtherAppId, 'IsActive'); 
			vOtherAppApprovalDim = ATTRS(cControlPrefix | 'tp_applications', vOtherAppId, 'ApprovalDimension'); 
			IF (vIsOtherAppCube @= 'A' );
				vUsedByOtherApp = 'T';
				IF (vOtherAppActive @= 'Y');
					vOtherAppIsActive = 'T';
					vNewDRMode = ' REQUIREDSHARED';
				Endif;
 			Elseif (vIsOtherAppCube @='Y' & vOtherAppApprovalDim @='');
				vUsedByOtherApp = 'T';
				IF (vOtherAppActive @= 'Y');
					vOtherAppIsActive = 'T';
					vNewDRMode =  'ALLOWED';
				Endif;
			Endif;

		Endif;
		vAppLooper = vAppLooper +1;
	End;

	IF (vUsedByOtherApp @= 'F');
		#remove security overlay cube
		IF (CubeExists(vSecuirtyOverlayCube) = 1);
			SecurityOverlayDestroyGlobalDefault(vCubeName);
		Endif;

		#remove RDCellSecurity cube
		#IF (CubeExists(vRDCellSecurityCube) = 1);
		#	CellSecurityCubeDestroy (vCubeName);
		#Endif;

		#remove RDCLS intermediate cube
		IF (CubeExists(vRDCLSIntermediateCube) = 1);
			CubeDestroy(vRDCLSIntermediateCube);
		Endif;

	Else;
		vDimIndex =1;
		vDimension = TABDIM(vCubeName, vDimIndex);
		vFoundVersion = 'F';
		While (vDimension @<> '');
			IF (vDimension @= cVersionDim);
				vFoundVersion = 'T';
			EndIf;
			vDimIndex = vDimIndex +1;
			vDimension = TABDIM(vCubeName, vDimIndex);
		End;

		#clear security overlay cube for this application only
		IF (CubeExists(vSecuirtyOverlayCube)>0);
			vAllView = 'tp_temp_scurity_overlay_view_' | pExecutionId;
			ViewCreate(vSecuirtyOverlayCube, vAllView);
			ViewColumnDimensionSet(vSecuirtyOverlayCube, vAllView, '}Groups', 1);
			ViewRowDimensionSet(vSecuirtyOverlayCube, vAllView, cApprovalDim, 1);
			IF (cVersionDim @<> '' & cVersionSlicesWrite @<> '' & vFoundVersion @= 'T' );
				ViewTitleDimensionSet(vSecuirtyOverlayCube, vAllView, cVersionDim);
				ViewSubsetAssign(vSecuirtyOverlayCube, vAllView, cVersionDim, vVersionSubset);
			Endif;
			ViewZeroOut(vSecuirtyOverlayCube, vAllView);
			ViewDestroy(vSecuirtyOverlayCube, vAllView);
		Endif;


		#sync up StaticRights field in intermediate cell security cube
		vReturnValue = ExecuteProcess('}tp_rights_update_RDCLS_static_rights', 'pExecutionId', pExecutionId,
			'pAppId', pAppId, 'pCube', pCubeName, 'pApprovalDim', cApprovalDim, 'pUpdateSubset', cApprovalSubset,
			'pVersionDim', cVersionDim, 'pGroupsDim', '}Groups');

		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;

	Endif;

	# clear the require reservation 
	CellPutS(vNewDRMode, cCubePropertiesCube, vCubeName, 'DATARESERVATIONMODE');
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Reset DR mode in ' | vCubeName);
	EndIf;
			
	#remove any existing data reservations by this application only
	#do NOT remove data reservations made by other applications
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_util_reserve_cube_slices', 'pExecutionId', pExecutionId, 'pAppId', pAppId, 
		'pCube', vCubeName, 'pApprovalDim', '', 'pNode', '', 'pReserve', 'N', 'pUser', '','pControlDim','','pControlWritableSlices', '');
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	## clear the flag
	CellPutS('', cApplicationCubesCube, pAppId, vCubeName);
EndIf;

573,1

574,1

575,23
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

#***
IF (SubsetExists(cVersionDim, vVersionSubset) >0);
	SubsetDestroy(cVersionDim, vVersionSubset);
Endif;

IF (SubsetExists(vAppDim, vAppSubset) >0);
	SubsetDestroy(vAppDim, vAppSubset);
Endif;

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
