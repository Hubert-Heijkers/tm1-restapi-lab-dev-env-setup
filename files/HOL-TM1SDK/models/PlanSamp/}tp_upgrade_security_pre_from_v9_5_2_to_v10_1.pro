601,100
602,"}tp_upgrade_security_pre_from_v9_5_2_to_v10_1"
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
pApprovalDim
pApprovalSubset
561,4
2
2
2
2
590,4
pExecutionId,"None"
pAppId,"MyApp"
pApprovalDim,"None"
pApprovalSubset,"None"
637,4
pExecutionId,""
pAppId,""
pApprovalDim,""
pApprovalSubset,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,118

#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################


pControl = 'Y';
 cControlPrefix = '}';


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

#*** update element level security
cPermissionsCube = '}CellSecurity_' | cControlPrefix | 'tp_application_permission}' | pAppId;
cSecurityRead = 'READ';
cSecurityWrite = 'WRITE';
cSecurityLock = 'WRITE';

cApprovalSubsetSize = SubsetGetSize(pApprovalDim, pApprovalSubset);
vIndex = cApprovalSubsetSize;

cGroupsDim = '}Groups';

While ( vIndex > 0 );
	cApprovalElement = SubsetGetElementName (pApprovalDim, pApprovalSubset, vIndex);
	vIsLeafNode = 'T';
	If (DTYPE(pApprovalDim, cApprovalElement) @= 'C');
		vIsLeafNode = 'F';
	Else;
		vIsLeafNode = 'T';
	EndIf;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Found Element ', cApprovalElement, ' isLeaf=', vIsLeafNode);
	EndIf;
	

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Loop through groups on leaf node ', cGroupsDim);
	EndIf;
	groupLooper = 1;
	cGroupName =  DIMNM(cGroupsDim,groupLooper);
	While (cGroupName @<> '');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Get permission for group ', cGroupName, cPermissionsCube);
		EndIf;
		cView = CellGetS(cPermissionsCube, cApprovalElement, 'VIEW', cGroupName);
		cEdit = CellGetS(cPermissionsCube, cApprovalElement, 'EDIT', cGroupName);
		cSubmit = CellGetS(cPermissionsCube, cApprovalElement, 'SUBMIT', cGroupName);
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'EDIT permission for group ', cGroupName, ' is ', cEdit);
		EndIf;

		If (vIsLeafNode @= 'T');
			If (cEdit @= 'READ' );
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Change Element security to WRITE', cApprovalElement);
				EndIf;
				ElementSecurityPut (cSecurityWrite, pApprovalDim, cApprovalElement, cGroupName);
			EndIf;

			If (cSubmit @= 'READ' );
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Change Element security to WRITE', cApprovalElement);
				EndIf;
				ElementSecurityPut (cSecurityLock, pApprovalDim, cApprovalElement, cGroupName);
			EndIf;
		Else;
			If (cView @= 'READ' );
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Change Element security to WRITE', cApprovalElement);
				EndIf;
				ElementSecurityPut (cSecurityWrite, pApprovalDim, cApprovalElement, cGroupName);
			EndIf;
		EndIf;

		groupLooper = groupLooper + 1;
		cGroupName =  DIMNM(cGroupsDim,groupLooper);
	End;

	
	vIndex = vIndex - 1;
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
