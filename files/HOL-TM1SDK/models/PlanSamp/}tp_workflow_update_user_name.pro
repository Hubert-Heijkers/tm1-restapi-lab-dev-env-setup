601,100
602,"}tp_workflow_update_user_name"
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
pUserName
pOldUserName
pControl
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pAppId,"None"
pUserName,"None"
pOldUserName,"None"
pControl,"Y"
637,5
pExecutionId,""
pAppId,""
pUserName,""
pOldUserName,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,160


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
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:',
		pExecutionId, pAppId, pUserName, pOldUserName, pControl);
EndIf;

#***

cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cIsActive =ATTRS('}tp_applications', pAppId, 'IsActive');
cShadowApprovalDim =ATTRS('}tp_applications', pAppId, 'ApprovalShadowDimension');

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cIsActive,cShadowApprovalDim );
EndIf;

#***
If (cShadowApprovalDim @= '');
	cStateCube = cControlPrefix | 'tp_central_application_state';
Else;
	cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
EndIf;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'Check state cube: ' | cStateCube);
EndIf;

If (CubeExists(cStateCube) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cStateCube,
		'pControl', pControl);
	
	ProcessError;
EndIf;

#*** 

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Update user name in state cube');
EndIf;

cCurrentOwner = 'CurrentOwner';
cCurrentOwnerId = 'CurrentOwnerId';
cStateChangeUser = 'StateChangeUser';
cDataChangeUser = 'DataChangeUser';

If (cShadowApprovalDim @= '');
	vOwnerValue = CellGetS(cStateCube, pAppId, cCurrentOwner);
	vOwnerIdValue = CellGetS(cStateCube, pAppId, cCurrentOwnerId);
	vStateChangeUserValue = CellGetS(cStateCube, pAppId, cStateChangeUser);
	vDataChangeUserValue = CellGetS(cStateCube, pAppId, cDataChangeUser);

	If (vOwnerIdValue @= TM1User);
		If (vOwnerValue @<> pUserName);
			CellPutS(pUserName, cStateCube, pAppId, cCurrentOwner);
		EndIf;
	EndIf;

	If (vStateChangeUserValue @= pOldUserName);
		CellPutS(pUserName, cStateCube, pAppId, cStateChangeUser);
	EndIf;

	If (vDataChangeUserValue @= pOldUserName);
		CellPutS(pUserName, cStateCube, pAppId, cDataChangeUser);
	EndIf;
Else;
	cApprovalDimSize = DIMSIZ(cShadowApprovalDim);
	vIndex = 1;
	While (vIndex <= cApprovalDimSize);
		vNodePName = DIMNM(cShadowApprovalDim, vIndex);
		
		vOwnerValue = CellGetS(cStateCube, vNodePName, cCurrentOwner);
		vOwnerIdValue = CellGetS(cStateCube, vNodePName, cCurrentOwnerId);
		vStateChangeUserValue = CellGetS(cStateCube, vNodePName, cStateChangeUser);
		vDataChangeUserValue = CellGetS(cStateCube, vNodePName, cDataChangeUser);
	
		If (vOwnerIdValue @= TM1User);
			If (vOwnerValue @<> pUserName);
				CellPutS(pUserName, cStateCube, vNodePName, cCurrentOwner);
			EndIf;
		EndIf;
	
		If (vStateChangeUserValue @= pOldUserName);
			CellPutS(pUserName, cStateCube, vNodePName, cStateChangeUser);
		EndIf;
	
		If (vDataChangeUserValue @= pOldUserName);
			CellPutS(pUserName, cStateCube, vNodePName, cDataChangeUser);
		EndIf;
	
		vIndex = vIndex + 1;
	End;
EndIf;

#*** 

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Update user name in }Clients');
EndIf;

vDisplayUserName = ATTRS('}Clients', TM1User, '}TM1_DefaultDisplayValue');
If (vDisplayUserName @<> pUserName);
	AttrPutS(pUserName, '}Clients', TM1User, '}TM1_DefaultDisplayValue');
EndIf;


573,1

574,1

575,1

576,
930,0
638,1
804,0
1217,1
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
