601,100
602,"}tp_update_application"
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
pAppId,"MyApp"
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
572,122


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
cApprovalSubset =  ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cControlDim = ATTRS('}tp_applications', pAppId,  'VersionDimension');
cControlDimOld = ATTRS('}tp_applications', pAppId,  'VersionDimensionOld');

cWritableSlicesOld = ATTRS('}tp_applications', pAppId,  'VersionSlicesWriteOld');
cWritableSlicesNew = ATTRS('}tp_applications', pAppId,  'VersionSlicesWrite');
cReadableSlicesOld = ATTRS('}tp_applications', pAppId,  'VersionSlicesReadOld');
cReadableSlicesNew = ATTRS('}tp_applications', pAppId,  'VersionSlicesRead');

#*** Check if a new version dimension is added.
seIsNewVersionDimensionAdded = 'N';
IF (cControlDimOld @='' & cControlDim @<> '');
seIsNewVersionDimensionAdded = 'Y';
Endif;

#if a new version dimension is added, we need to recreate security overlay cubes with added dimension
IF (seIsNewVersionDimensionAdded @= 'Y');
	vReturnValue = ExecuteProcess('}tp_update_application_cubes_pre', 'pExecutionId', pExecutionId, 'pAppId', pAppId);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
Endif;

cApplicationCubesCube = '}tp_application_cubes';
totalCubes = DIMSIZ('}Cubes');
indexCube = 1;

While (indexCube <= totalCubes);
	cCubeName = DIMNM('}Cubes', indexCube);
	cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);
	If (cIsAppCube @= 'A');

		IF (seIsNewVersionDimensionAdded @= 'Y');
			#IF a new version demension is added, we need to remove all DRs from the data cube
			vDimIndex = 1;
			vAddress = '';
			vDimension = TABDIM(cCubeName, vDimIndex);
			While (vDimension @<> '');
				If (vDimIndex = 1);
					vAddress = '';
				Else;
					vAddress = vAddress |  '|';
				Endif;
				vDimIndex = vDimIndex +1;
				vDimension = TABDIM(cCubeName, vDimIndex);
			End;
			CubeDataReservationReleaseAll(cCubeName,'',vAddress);

		Endif;

		IF (seIsNewVersionDimensionAdded @= 'N' & cControlDim @<> '' & (cWritableSlicesOld @='' & cReadableSlicesOld @=''));
			#This is an initial rights saving, do nothing here
		Else;
			IF (cWritableSlicesOld @<> cWritableSlicesNew);
				vReturnValue = ExecuteProcess('}tp_update_application_DR', 'pExecutionId', pExecutionId, 'pAppId', pAppId, 'pCube', cCubeName);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;

				#update security overlay cube with new writable slices
				vReturnValue = ExecuteProcess('}tp_update_application_securityOverlay', 'pExecutionId', pExecutionId, 'pAppId', pAppId, 'pCube', cCubeName);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
			Endif;
		Endif;
	EndIf;

	indexCube = indexCube +1;
End;


#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
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
