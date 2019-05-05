601,100
602,"}tp_util_update_hierarchy_from_file"
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
pDim
pSubset
pSourceFile
pDelimiter
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pDim,"NA"
pSubset,"NA"
pSourceFile,"None"
pDelimiter,"9"
637,5
pExecutionId,""
pDim,""
pSubset,""
pSourceFile,""
pDelimiter,""
577,5
varAction
varParent
varNode
varNodeType
varWeight
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
572,101


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
cTM1Process = GetProcessName();
StringGlobalVariable('gPrologLog');
StringGlobalVariable('gEpilogLog');
StringGlobalVariable('gDataLog');

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_log_file_names',
'pExecutionId', pExecutionId, 'pProcess', cTM1Process, 'pControl', 'Y');

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
				pExecutionId, pSourceFile);
EndIf;

#*** Set local variables
DataSourceType = 'CHARACTERDELIMITED';
DatasourceASCIIDelimiter = CHAR(StringToNumber(pDelimiter));
DatasourceASCIIQuoteCharacter = char(0);
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

#*** Check file

If (FileExists(pSourceFile) = 0);
	ProcessError;
EndIf;

#*** Check dimension

If (DimensionExists(pDim) = 0);
	ProcessError;
EndIf;

#*** Check subset

cSubsetSize = 0;
If (pSubset @<> '');
	If (SubsetExists(pDim, pSubset) = 0);
		ProcessError;
	EndIf;
	
	cSubsetSize = SubsetGetSize(pDim, pSubset);
EndIf;


#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;


573,1

574,25


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


vReturnValue = ExecuteProcess('}tp_util_update_hierarchy',
'pExecutionId', pExecutionId, 'pDim', pDim, 'pSubset', pSubset,
'pParent', varParent, 'pNode', varNode, 'pNodeType', varNodeType, 'pWeight', varWeight, 'pAction', varAction);

If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

575,45


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

#*** Sort order

StringGlobalVariable('gTopNode');
vReturnValue = ExecuteProcess('}tp_get_top_node', 'pExecutionId', pExecutionId,'pDim', pDim, 'pSubset', pSubset, 'pControl', 'Y');
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

SubsetDeleteAllElements(pDim, pSubset);
SubsetElementInsert(pDim, pSubset, gTopNode, 0);
vTotalChildren = ELCOMPN(pDim, gTopNode);
If (vTotalChildren >= 1);
	vReturnValue = ExecuteProcess('}tp_util_add_direct_children_to_subset', 
		'pExecutionId', pExecutionId,'pDim', pDim,
		'pSubset', pSubset, 'pParent', gTopNode);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;	
EndIf;

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
