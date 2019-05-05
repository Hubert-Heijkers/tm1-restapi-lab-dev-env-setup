601,100
602,"}tp_set_access_to_cube"
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
560,5
pExecutionId
pCube
pRight
pSourceFile
pControl
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pCube,"None"
pRight,"None"
pSourceFile,"None"
pControl,"Y"
637,5
pExecutionId,""
pCube,""
pRight,""
pSourceFile,""
pControl,""
577,1
varGroup
578,1
2
579,1
1
580,1
0
581,1
0
582,0
603,0
572,109


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
cTM1Process = cControlPrefix | 'tp_set_access_to_cube';
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
pExecutionId, pSourceFile, pControl);
EndIf;

#*** Set local variables
DataSourceType = 'CHARACTERDELIMITED';
DatasourceASCIIDelimiter = CHAR(9);
DatasourceASCIIHeaderRecords = 0;
DatasourceNameForServer = pSourceFile;

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'DataSourceType: ' | DataSourceType);
TextOutput(cTM1Log, 'DatasourceASCIIDelimiter: ' | DatasourceASCIIDelimiter);
TextOutput(cTM1Log, 'DatasourceASCIIHeaderRecords: ' | NumberToString(DatasourceASCIIHeaderRecords));
TextOutput(cTM1Log, 'DatasourceNameForServer: ' | DatasourceNameForServer);
EndIf;

#*** Set input file encoding as UTF-8

SetInputCharacterSet('TM1CS_UTF8');

#*** Check TM1 security right

cAdmin = 'ADMIN';
cLock = 'LOCK';
cReserve = 'RESERVE';
cWrite = 'WRITE';
cRead = 'READ';
cNone = 'NONE';

vRight = '';
If (pRight @= cAdmin);
vRight = cAdmin;
ElseIf (pRight @= cLock);
vRight = cLock;
ElseIf (pRight @= cReserve);
vRight = cReserve;
ElseIf (pRight @= cWrite);
vRight = cWrite;
ElseIf (pRight @= cRead);
vRight = cRead;
ElseIf (pRight @= cNone);
vRight = cNone;
Else;

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
'pGuid', pExecutionId,
'pProcess', cTM1Process,
'pErrorCode', 'TI_WRONG_PERMISSION',
'pErrorDetails', pRight | ', ' | pCube,
'pControl', pControl);

ProcessError;
EndIf;

#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;


573,1

574,48


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

cCubeSecurityCube = '}CubeSecurity';
cDimensionSecurityCube = '}DimensionSecurity';
cElementAttributesPrefix = '}ElementAttributes_';

CellPutS(vRight, cCubeSecurityCube, pCube, varGroup);

vIndex = 1;
While (vIndex <> 0);
vDim = TABDIM(pCube, vIndex);

If (vDim @<> '' & vRight @<> cNone);

CellPutS(cRead, cDimensionSecurityCube, vDim, varGroup);
vElementAttributes = cElementAttributesPrefix | vDim;
If (DimensionExists(vElementAttributes) <> 0);
CellPutS(cRead, cDimensionSecurityCube, cElementAttributesPrefix | vDim, varGroup);
EndIf;
If (CubeExists(vElementAttributes) <> 0);
CellPutS(cRead, cCubeSecurityCube, cElementAttributesPrefix | vDim, varGroup);
EndIf;

EndIf;

If (vDim @<> '');
vIndex = vIndex + 1;
Else;
vIndex = 0;
EndIf;
End;



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
