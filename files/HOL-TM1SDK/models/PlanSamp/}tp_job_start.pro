601,100
602,"}tp_job_start"
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
560,7
pExecutionId
pJobId
pAppId
pAppName
pJobType
pTime
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
pJobId,"MyJob"
pAppId,"MyApp"
pAppName,"MyApp"
pJobType,"None"
pTime,"0"
pControl,"Y"
637,7
pExecutionId,""
pJobId,""
pAppId,""
pAppName,""
pJobType,""
pTime,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,89


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
EndIf;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:',
	pExecutionId, pJobId, pAppId, pAppName, pJobType, pTime, pControl);
EndIf;

#*** Insert the job element
cJobsDim = cControlPrefix | 'tp_jobs';
If (DIMIX(cJobsDim, pJobId) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Insert current job id');
	EndIf;

	DimensionElementInsert(cJobsDim, '', pJobId, 'S');

EndIf;

cDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
If (cDisplayUserName @= '');
	cDisplayUserName = TM1User;
EndIf;

cJobCube = cControlPrefix | 'tp_application_jobs';
If (CubeExists(cJobCube) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cJobCube,
		'pControl', pControl);
	
	ProcessError;
EndIf;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,33


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


#*** Set values
cJobAppId = 'ApplicationId';
cJobAppName = 'ApplicationName';
cJobType = 'JobType';
cJobOwner = 'Owner';
cJobOwnerId = 'OwnerId';
cJobStartDate = 'StartDate';

CellPutS(pAppId, cJobCube, pJobId, cJobAppId);
CellPutS(pAppName, cJobCube, pJobId, cJobAppName);
CellPutS(pJobType, cJobCube, pJobId, cJobType);
CellPutS(cDisplayUserName, cJobCube, pJobId, cJobOwner);
CellPutS(TM1User, cJobCube, pJobId, cJobOwnerId);
CellPutS(pTime, cJobCube, pJobId, cJobStartDate);


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
