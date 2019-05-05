601,100
602,"}tp_delete_drill_view"
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
pCube
pView
pControl
561,4
2
2
2
2
590,4
pExecutionId,"None"
pCube,"None"
pView,"None"
pControl,"Y"
637,4
pExecutionId,""
pCube,""
pView,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,106
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
	TextOutput(cTM1Log, 'Parameters:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pExecutionId, pCube, pView, 'Y');
EndIf;

cDrillPrefix = 'DRILL.';
cDrillPrefixLength = LONG(cDrillPrefix);

If (pCube @<> '' & CubeExists(pCube) <> 0);
	If (cGenerateLog @= 'Y');
		If (LONG(pView) >= cDrillPrefixLength & SUBST(pView, 1, cDrillPrefixLength) @= cDrillPrefix);
			TextOutput(cTM1Log, 'View has correct prefix:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, pView);
		Else;
			TextOutput(cTM1Log, 'View has wrong prefix:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), SUBST(pView, 1, cDrillPrefixLength), STR(cDrillPrefixLength, 3, 0));
		EndIf;
		If (ViewExists(pCube, pView) <> 0);
			TextOutput(cTM1Log, 'View does exist:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, pView);
		Else;
			TextOutput(cTM1Log, 'View does not exist:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, pView);
		EndIf;
	EndIf;
	If (LONG(pView) >= cDrillPrefixLength & SUBST(pView, 1, cDrillPrefixLength) @= cDrillPrefix & ViewExists(pCube, pView) <> 0);
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Executing ViewDestroy:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, pView);
		EndIf;
		ViewDestroy(pCube, pView);
		cSubsetName = pView;
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Search Cube Dimensions for Subset:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, cSubsetName);
		EndIf;
		vDimIndex = 1;
		cDimName = TABDIM(pCube, vDimIndex);
		While ( cDimName @<> '' );
			If (SubsetExists(cDimName, cSubsetName) = 1);
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Subset exists, delete the subset:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, cDimName, cSubsetName);
				EndIf;
				SubsetDestroy(cDimName, cSubsetName);
			Else;
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, 'Subset does not exist:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, cDimName, cSubsetName);
				EndIf;
			EndIf;
			vDimIndex = vDimIndex + 1;
			cDimName = TABDIM(pCube, vDimIndex);
		End;
	Else;
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'View does not exist:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube, pView);
		EndIf;
	EndIf;
Else;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Cube does not exist:', TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pCube);
	EndIf;
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
