601,100
602,"}tp_util_export_hierarchy"
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
560,6
pExecutionId
pDim
pSubset
pBlob
pIncludeWeight
pControl
561,6
2
2
2
2
2
2
590,6
pExecutionId,"None"
pDim,"None"
pSubset,"None"
pBlob,"None"
pIncludeWeight,"N"
pControl,"Y"
637,6
pExecutionId,""
pDim,""
pSubset,""
pBlob,""
pIncludeWeight,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,161


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

DatasourceASCIIDelimiter = char(9);
DatasourceASCIIQuoteCharacter='';

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

If (cGenerateLog @= 'Y' % cGenerateLog @= 'T');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_log_file_names', 'pExecutionId', pExecutionId,
	'pProcess', cTM1Process, 'pControl', pControl);
	
	If (vReturnValue <> ProcessExitNormal());
		processError;
	EndIf;
EndIf;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#***

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters: ', 
	pDim, pSubset, pBlob, pControl);
EndIf;

If (DimensionExists(pDim) = 0);
	ProcessError;
EndIf;

If (SubsetExists(pDim, pSubset) = 0);
	ProcessError;
EndIf;

#***
StringGlobalVariable('gTopNode');
NumericGlobalVariable('gTopLevel');

vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_top_node',
'pExecutionId', pExecutionId, 'pDim', pDim, 'pSubset', pSubset);
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 
	'tp_get_top_node', gTopNode, NumberToString(gTopLevel));
EndIf;

StringGlobalVariable('gIsInSubset');

cSubsetSize = SubsetGetSize(pDim, pSubset);
cTopPNode = DimensionElementPrincipalName(pDim, gTopNode);

vIndex = 1;
While (vIndex <= cSubsetSize);
	vNode = SubsetGetElementName(pDim, pSubset, vIndex);
	vPNode = DimensionElementPrincipalName(pDim, vNode);
	
	vType = DTYPE(pDim, vPNode);
	
	vRealParent = '';
	If (vPNode @<> cTopPNode);		
		vParentCount = ELPARN(pDim, vPNode);
		
		If (vParentCount = 1);
			vRealParent = ELPAR(pDim, vPNode, 1);
		Else;
			vGap = 0;
			vParentIndex = 1;
			While (vParentIndex <= vParentCount);
				vParent = ELPAR(pDim, vPNode, vParentIndex);
							
				vParentIndexI = 0;
				vIndexI = 1;
				While (vIndexI <= cSubsetSize);
					vNodeI = SubsetGetElementName(pDim, pSubset, vIndexI);
					vPNodeI = DimensionElementPrincipalName(pDim, vNodeI);
					If (vParent @= vPNodeI);
						vParentIndexI = vIndexI;
						vIndexI = cSubsetSize;
					EndIf;
								
					vIndexI = vIndexI + 1;
				End;
		
				If (vParentIndexI > 0 & vIndex > vParentIndexI);
					If (vGap = 0 % vGap > vIndex - vParentIndexI);
						vRealParent = vParent;
						vGap = vIndex - vParentIndexI;
					EndIf;
				EndIf;
			
				vParentIndex = vParentIndex + 1;
			End;
		
			If (vRealParent @= '');
				ProcessError;
			EndIf;
		EndIf;
	EndIf;

    If (pIncludeWeight @= 'Y');
    	If (vRealParent @= '');
    		vWeight = 0.0;
    	Else;
			vWeight = ELWEIGHT(pDim, vRealParent, vPNode);
		EndIf;
	EndIf;
	
	SetOutputCharacterSet(pBlob | '.blb', 'TM1CS_UTF8');
	If (pIncludeWeight @= 'Y');
		TextOutput(pBlob | '.blb', vRealParent, vPNode, vType, NumberToString(vWeight));
	Else;
		TextOutput(pBlob | '.blb', vRealParent, vPNode, vType); 
	EndIf;

	vIndex = vIndex + 1;
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
