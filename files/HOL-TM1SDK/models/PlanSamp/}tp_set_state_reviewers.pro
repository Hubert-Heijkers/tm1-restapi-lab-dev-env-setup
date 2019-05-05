601,100
602,"}tp_set_state_reviewers"
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
560,3
pExecutionId
pAppId
pControl
561,3
2
2
2
590,3
pExecutionId,"None"
pAppId,"None"
pControl,"Y"
637,3
pExecutionId,""
pAppId,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,64


cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

cConfigDim = cControlPrefix | 'tp_config';
If (DimensionExists(cConfigDim) = 0);
	ProcessError;
EndIf;

cGenerateLog = ATTRS(cConfigDim, 'Generate TI Log', 'String Value');

#*** Log File Name
cTM1Process = cControlPrefix | 'tp_set_state_reviewers';
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

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:',
	pExecutionId, pControl, pAppId);
EndIf;



cApplicationsDim = cControlPrefix | 'tp_applications';
cAppAttrDim = '}ElementAttributes_' | cApplicationsDim;
cShadowApprovalDim = '}tp_tasks}' | pAppId;
cPermissionsSecurityCube = '}CellSecurity_}tp_application_permission}'|pAppId;
cStateCube = '}tp_application_state}'|pAppId;
cGroupsDimension = '}Groups';
vGroupsSize = DIMSIZ(cGroupsDimension);

cApprovalDimSize = DIMSIZ(cShadowApprovalDim);
vIndex = 1;
While (vIndex <= cApprovalDimSize);
	cNodeId = DIMNM(cShadowApprovalDim, vIndex);
	cReviewer = '';
	vGroupIndex = 1;
	While (vGroupIndex <= vGroupsSize & cReviewer @= '');
		cGroupId = DIMNM(cGroupsDimension, vGroupIndex);
		vPermValue = CellGetS(cPermissionsSecurityCube, cNodeId, 'REJECT', cGroupId);
		If (vPermValue @= 'READ');
			cReviewer = cGroupId; 
		EndIf;
		vGroupIndex = vGroupIndex + 1;
	End;
	CellPutS(cReviewer, cStateCube, cNodeId, 'Reviewer'); 
	vIndex = vIndex + 1;
End;

  

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
