601,100
602,"}tp_update_application_cubes_pre"
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
560,2
pExecutionId
pAppId
561,2
2
2
590,2
pExecutionId,"None"
pAppId,"None"
637,2
pExecutionId,""
pAppId,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,134
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

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters', pExecutionId, pAppId);
EndIf;


#*** Get application info
cApprovalDIM = ATTRS('}tp_applications', pAppId, 'ApprovalDimension');
cApprovalSubset = ATTRS('}tp_applications', pAppId, 'ApprovalSubset');
cAppActive = ATTRS('}tp_applications', pAppId, 'IsActive'); 
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cVersionDimOld = ATTRS('}tp_applications', pAppId, 'VersionDimensionOld');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');
cVersionSlicesRead =ATTRS('}tp_applications', pAppId, 'VersionSlicesRead');

#*** Check if a new version dimension is added.
seIsNewVersionDimensionAdded = 'N';
IF (cVersionDimOld @='' & cVersionDim @<> '');
	seIsNewVersionDimensionAdded = 'Y';
Endif;
If (seIsNewVersionDimensionAdded @= 'Y');
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Version dimension is added in redeployment');
	EndIf;
EndIf;


#*** Export security overlay cube data, destroy and recreate security overlay cubes
NumericGlobalVariable('gDim_1IndexInCube');
NumericGlobalVariable('gDim_2IndexInCube');
NumericGlobalVariable('gDim_3IndexInCube');
StringGlobalVariable('gSecurityOverlayTokenString');
StringGlobalVariable('gImportPattern');

If (seIsNewVersionDimensionAdded @= 'Y');
	cApplicationCubesCube = '}tp_application_cubes';
	sCubesDim = '}Cubes';
	cCubesDimSize = DIMSIZ(sCubesDim);
	vIndex = 1;

	While (vIndex <= cCubesDimSize);
		vCubeName = DIMNM(sCubesDim, vIndex);
		vFlagCube = CellGetS(cApplicationCubesCube, pAppId, vCubeName);
	    	vSecurityOverlayCube = '}SecurityOverlayGlobal_' | vCubeName;
		If (vFlagCube @= 'A' );
			If (CubeExists(vSecurityOverlayCube) = 0);
				ProcessError;
			EndIf;
			
			vReturnValue = ExecuteProcess('}tp_util_is_dim_in_cube', 'pCube', vCubeName, 'pDim_1', cVersionDim, 'pDim_2', cApprovalDIM);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
			vVersionIndexInCube = gDim_1IndexInCube;
			vApprovalIndexInCube = gDim_2IndexInCube;
			vSecurityOverlayTokenString = gSecurityOverlayTokenString;
			
			vReturnValue = ExecuteProcess('}tp_util_is_dim_in_cube', 'pCube', vSecurityOverlayCube, 'pDim_1', cVersionDim);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
			vVersionIndexInSecurityOverlayCube = gDim_1IndexInCube;
			
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
				'cube: ' | vCubeName, 'dim: ' | cVersionDim, 'index in cube: ' | NumberToString(vVersionIndexInCube), 'index in security overlay cube: ' | NumberToString(vVersionIndexInSecurityOverlayCube));
			EndIf;
			
			If (vVersionIndexInCube > 0 & vVersionIndexInSecurityOverlayCube = 0);
				vReturnValue = ExecuteProcess('}tp_util_export_cube', 'pExecutionId', pExecutionId | vCubeName,
					'pCube', vSecurityOverlayCube, 'pBlob', vSecurityOverlayCube | '_' | pExecutionId, 'pAlt', 'Y');
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
				
				SecurityOverlayDestroyGlobalDefault(vCubeName);
				
				vReturnValue = ExecuteProcess('}tp_deploy_create_security_overlay_cube', 'pExecutionId',pExecutionId, 'pAppId', pAppId, 'pCubeName',vCubeName );
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			EndIf;
		EndIf;
	
		vIndex = vIndex + 1;
	End;
EndIf;


#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,77
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


cTM1Log = cEpilogLog;


#*** Import security overlay cube data.
If (seIsNewVersionDimensionAdded @= 'Y');

	cCubesDimSize = DIMSIZ(sCubesDim);
	vIndex = 1;
	While (vIndex <= cCubesDimSize);
		vCubeName = DIMNM(sCubesDim, vIndex);
		vFlagCube = CellGetS(cApplicationCubesCube, pAppId, vCubeName);
		
		If (vFlagCube @= 'A' );
			vSecurityOverlayCube = '}SecurityOverlayGlobal_' | vCubeName;
			If (CubeExists(vSecurityOverlayCube) = 0);
				ProcessError;
			EndIf;
			
			vSecurityOverlayBlb = vSecurityOverlayCube | '_' | pExecutionId | '.blb';
			If (FileExists(vSecurityOverlayBlb) = 1);
			
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
						'Find security overlay import file: ' | vSecurityOverlayBlb);
				EndIf;
				
				vReturnValue = ExecuteProcess('}tp_util_is_dim_in_cube', 'pCube', vSecurityOverlayCube, 'pDim_1', cVersionDim);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
				vVersionIndexInSecurityOverlayCube = gDim_1IndexInCube;
				vImportPatternForSecurityOverlayCube = gImportPattern;
				
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
						'Version index in security overlay cube: ' | NumberToString(vVersionIndexInSecurityOverlayCube),
						'Import pattern for security overlay cube: ' | vImportPatternForSecurityOverlayCube);
				EndIf;
				
				vReturnValue = ExecuteProcess('}tp_util_import_cube', 'pExecutionId', pExecutionId | vCubeName,
					'pCube', vSecurityOverlayCube, 'pSourceFile', vSecurityOverlayBlb, 'pSlicer', vImportPatternForSecurityOverlayCube);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			Else;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
						'Cannot find security overlay import file: ' | vSecurityOverlayBlb);
				EndIf;
			EndIf;
		EndIf;
	
		vIndex = vIndex + 1;
	End;
EndIf;


#***
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
