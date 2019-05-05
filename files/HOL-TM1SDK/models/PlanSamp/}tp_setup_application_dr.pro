601,100
602,"}tp_setup_application_dr"
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
pEnable
pControl
561,4
2
2
2
2
590,4
pExecutionId,"None"
pAppId,"MyApp"
pEnable,"NA"
pControl,"N"
637,4
pExecutionId,""
pAppId,""
pEnable,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,127
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

#*** Log Parameters

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Parameters:', 
pExecutionId, pAppId, pEnable, pControl);
EndIf;

#***
If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Check application id', pAppId);
EndIf;

cApplicationsDim = cControlPrefix | 'tp_applications';
If (DIMIX(cApplicationsDim, pAppId) = 0);
vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
'pGuid', pExecutionId, 
'pProcess', cTM1Process, 
'pErrorCode', 'TI_NODE_NOT_EXIST',
'pErrorDetails', cApplicationsDim | ', ' | pAppId,
'pControl', pControl);

ProcessError;
EndIf;

#Set '}CubeProperties' data reservation flag
cApprovalDIM = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalDimension');

cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';

totalCubes = DIMSIZ('}Cubes');
indexCube = totalCubes;
cCubePropertiesCube = '}CubeProperties';

If (cGenerateLog @= 'Y');
	cLogCubeText = 'Reserve cube number cubes to check' | NumberToString(totalCubes);
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
EndIf;

#clear existing cube flags in case this is a redeployment
While (indexCube >= 1);
	cCubeName = DIMNM('}Cubes', indexCube);

	cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);

	If ((cApprovalDIM @= '' & cIsAppCube @= 'Y') % cIsAppCube @= 'A');

		#Decide the final DR mode on this cube
		vAppLooper = 1;
		vIsOtherAppCube = '';
		vAppDimension = '}tp_applications';
		vTotalApps = DIMSIZ(vAppDimension);
		vNewDRMode = '';
		While (vAppLooper <= vTotalApps);
			vOtherAppId = DIMNM(vAppDimension, vAppLooper);
			vIsOtherAppCube = CellGetS(cApplicationCubesCube, vOtherAppId, cCubeName);
			vOtherAppActive = ATTRS(cControlPrefix | 'tp_applications', vOtherAppId, 'IsActive'); 
			vOtherAppApprovalDim = ATTRS(cControlPrefix | 'tp_applications', vOtherAppId, 'ApprovalDimension'); 
			IF (vIsOtherAppCube @= 'A' );
				IF (vOtherAppActive @= 'Y');
					vNewDRMode = ' REQUIREDSHARED';
				Endif;
 			Elseif (vIsOtherAppCube @='Y' & vOtherAppApprovalDim @='');
				IF (vOtherAppActive @= 'Y');
					vNewDRMode =  'ALLOWED';
				Endif;
			Endif;

			vAppLooper = vAppLooper +1;
		End;
		CellPutS(vNewDRMode, cCubePropertiesCube, cCubeName, 'DATARESERVATIONMODE');

	EndIf;
	
	indexCube = indexCube - 1;
End;

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
