601,100
602,"}tp_util_import_cube"
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
pCube
pSourceFile
pSlicer
pDelimiter
pQuote
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
pCube,"None"
pSourceFile,"None"
pSlicer,"*|*|*|*|"
pDelimiter,"9"
pQuote,"0"
pControl,"Y"
637,7
pExecutionId,""
pCube,""
pSourceFile,""
pSlicer,""
pDelimiter,""
pQuote,""
pControl,""
577,5
varValue
varElement1
varElement2
varElement3
varElement4
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
572,192


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
cTM1Process = GetProcessName();
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
DatasourceASCIIDelimiter = CHAR(StringToNumber(pDelimiter));
DatasourceASCIIQuoteCharacter = char(StringToNumber(pQuote));
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

#***

If (CubeExists(pCube) = 0);
	ProcessError;
EndIf;

If (FileExists(pSourceFile) = 0);
	ProcessError;
EndIf;

cDimMax = 4;
cDim1 = '';
cDim2 = '';
cDim3 = '';
cDim4 = '';

vIndex = 1;
While (vIndex <> 0);
	vDim = TABDIM(pCube, vIndex);
	
	If (vIndex = 1);
		cDim1 = vDim;
	ElseIf (vIndex = 2);
		cDim2 = vDim;
	ElseIf (vIndex = 3);
		cDim3 = vDim;
	ElseIf (vIndex = 4);
		cDim4 = vDim;
	EndIf;
	
	If (vDim @<> '');
		vIndex = vIndex + 1;
	Else;
		cDimCount = vIndex - 1;
		vIndex = 0;
	EndIf;
End;

If (cDimCount > cDimMax);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Dimension count:', NumberToString(cDimCount));
	EndIf;
	
	ProcessError;
EndIf;


#*** Split slicer
vSlicer = pSlicer;
cScanDelimiter = '|';

cSlicer1 = '';
cSlicer2 = '';
cSlicer3 = '';
cSlicer4 = '';

cStarPos1 = 0;
cStarPos2 = 0;
cStarPos3 = 0;
cStarPos4 = 0;

vStarIndex = 0;
vIndex = 1;
While (vIndex <= cDimCount);
    vScanIndex = SCAN(cScanDelimiter, vSlicer);
    If (vScanIndex <> 0);
    	vScanToken = SUBST(vSlicer, 1, vScanIndex - 1);
    	vSlicer = SUBST(vSlicer, vScanIndex + 1, LONG(vSlicer) - vScanIndex);
    Else;
    	vScanToken = vSlicer;
    	vSlicer = '';
    EndIf;
    
    If (vIndex = 1);
		cSlicer1 = vScanToken;
	ElseIf (vIndex = 2);
		cSlicer2 = vScanToken;
	ElseIf (vIndex = 3);
		cSlicer3 = vScanToken;
	ElseIf (vIndex = 4);
		cSlicer4 = vScanToken;
	EndIf;
	
	If (vScanToken @= '*' % vScanToken @= '');
		vStarIndex = vStarIndex + 1;
		
		If (vStarIndex = 1);
			cStarPos1 = vIndex;
		ElseIf (vStarIndex = 2);
			cStarPos2 = vIndex;
		ElseIf (vStarIndex = 3);
			cStarPos3 = vIndex;
		ElseIf (vStarIndex = 4);
			cStarPos4 = vIndex;
		EndIf;
	EndIf;
	
	vIndex = vIndex + 1;
	If (vSlicer @= cScanDelimiter % vSlicer @= '');
		vIndex = cDimCount + 1;
	EndIf;
End;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Slicer:',
				cSlicer1, cSlicer2, cSlicer3, cSlicer4);
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Star positions:',
				NumberToString(cStarPos1), NumberToString(cStarPos2), NumberToString(cStarPos3), NumberToString(cStarPos4));
EndIf;



#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;


573,1

574,93


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


cTM1Log = cDataLog;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Values:',
				varValue, varElement1, varElement2, varElement3, varElement4);
EndIf;

vElem1 = cSlicer1;
vElem2 = cSlicer2;
vElem3 = cSlicer3;
vElem4 = cSlicer4;

vIndex = 1;
While (vIndex <= cDimCount);
	If (vIndex = 1 & cStarPos1 <> 0);
		If (cStarPos1 = 1);
			vElem1 = varElement1;
		ElseIf (cStarPos1 = 2);
			vElem2 = varElement1;
		ElseIf (cStarPos1 = 3);
			vElem3 = varElement1;
		ElseIf (cStarPos1 = 4);
			vElem4 = varElement1;
		EndIf;
	ElseIf (vIndex = 2 & cStarPos2 <> 0);
		If (cStarPos2 = 1);
			vElem1 = varElement2;
		ElseIf (cStarPos2 = 2);
			vElem2 = varElement2;
		ElseIf (cStarPos2 = 3);
			vElem3 = varElement2;
		ElseIf (cStarPos2 = 4);
			vElem4 = varElement2;
		EndIf;	
	ElseIf (vIndex = 3 & cStarPos3 <> 0);
		If (cStarPos3 = 1);
			vElem1 = varElement3;
		ElseIf (cStarPos3 = 2);
			vElem2 = varElement3;
		ElseIf (cStarPos3 = 3);
			vElem3 = varElement3;
		ElseIf (cStarPos3 = 4);
			vElem4 = varElement3;
		EndIf;
	ElseIf (vIndex = 4 & cStarPos4 <> 0);
		If (cStarPos4 = 1);
			vElem1 = varElement4;
		ElseIf (cStarPos4 = 2);
			vElem2 = varElement4;
		ElseIf (cStarPos4 = 3);
			vElem3 = varElement4;
		ElseIf (cStarPos4 = 4);
			vElem4 = varElement4;
		EndIf;
	EndIf;

	vIndex = vIndex + 1;
End;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'New Values:',
				varValue, vElem1, vElem2, vElem3, vElem4);
EndIf;


#*** Insert value into cube

vReturnValue = ExecuteProcess('}tp_util_insert_value_into_cube',
'pCube', pCube, 'pValue', varValue, 'pElem1', vElem1, 'pElem2', vElem2, 'pElem3', vElem3, 'pElem4', vElem4);

If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;



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
