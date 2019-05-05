601,100
602,"}tp_update_application_cubes"
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
560,5
pExecutionId
pAppId
pCubeInfo
pIsUpgrade
pIsAddedCube
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pAppId,"None"
pCubeInfo,"None"
pIsUpgrade,"N"
pIsAddedCube,"Y"
637,5
pExecutionId,""
pAppId,""
pCubeInfo,""
pIsUpgrade,""
pIsAddedCube,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,96
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
cAppActive = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'IsActive'); 
cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
cCubePropertiesCube = '}CubeProperties';

#***
cDataReservationType = '';
If (cAppActive @= 'Y');
	cDataReservationType = 'REQUIREDSHARED';
	If (cApprovalDIM @= '');
		cDataReservationType = 'ALLOWED';
	EndIf;
EndIf;

# parse application cube string and set values in application cubes and set DR mode
cubeSeparater = '*';
vPosCube = 0;
vStringToScan = pCubeInfo;
vPosCube = SCAN(cubeSeparater, vStringToScan);
vFirstElement = 1;


While (vPosCube >0);
	vCubeName = SUBST(vStringToScan, 1, vPosCube-1);
	vFlagCube = SUBST(vStringToScan, vPosCube+1, 1);
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set flag in application_cubes pAppId=' | pAppId | ' CubeName=' | vCubeName | ' Flag=' | vFlagCube);
	EndIf;
	
	If (pIsAddedCube @= 'Y');
		If (vFlagCube @= 'A' % cApprovalDIM @= '') ;
			IF (cDataReservationType @<> '');
				# set DR mode when it has a valide mode type, otherwise do not overide other application's valid DR mode
				CellPutS(cDataReservationType, cCubePropertiesCube, vCubeName, 'DATARESERVATIONMODE');
			Endif;
		EndIf;

		CellPutS(vFlagCube, cApplicationCubesCube, pAppId, vCubeName);
	Else;
		#this is a cube that is removed from the application definition
		CellPutS('', cApplicationCubesCube, pAppId, vCubeName);
	Endif;
	
	vStringToScan = SUBST(vStringToScan, vPosCube +3, LONG(vStringToScan)-vPosCube);
	vPosCube = SCAN(cubeSeparater, vStringToScan);
End;

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
