601,100
602,"}tp_custom_TI_update_TI_cube"
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
560,8
pExecutionId
pApplicationId
pWorkflowAction
pPreActionTI
pPreActionTIEnabled
pPostActionTI
pPostActionTIEnabled
pClearCube
561,8
2
2
2
2
2
2
2
2
590,8
pExecutionId,"None"
pApplicationId,"MyApp"
pWorkflowAction,"None"
pPreActionTI,"None"
pPreActionTIEnabled,"N"
pPostActionTI,"None"
pPostActionTIEnabled,"N"
pClearCube,"N"
637,8
pExecutionId,""
pApplicationId,""
pWorkflowAction,""
pPreActionTI,""
pPreActionTIEnabled,""
pPostActionTI,""
pPostActionTIEnabled,""
pClearCube,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,212

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
'pProcess', cTM1Process, 'pControl', 'Y');
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
Endif;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#***
cSystemConfigDim = cControlPrefix | 'tp_system_config';
If (DimensionExists(cSystemConfigDim) = 0);
	ProcessError;
EndIf;
cSecurityModeNode = 'IntegratedSecurityMode';
cConfigValueAttr = 'ConfigValue';
vSecurityMode = ATTRS(cSystemConfigDim, cSecurityModeNode, cConfigValueAttr);

cCognosEveryoneGroup = 'CAMID("::Everyone")';
cTpEveryoneGroup = cControlPrefix | 'tp_Everyone';
If (vSecurityMode @= '5');
	cEveryoneGroup = cCognosEveryoneGroup;
Else;
	cEveryoneGroup = cTpEveryoneGroup;

EndIf;

cProcessesDim = '}Processes';
cProcessSecurityCube = '}ProcessSecurity';

#***
vAppSubset = 'temp_app_' | pApplicationId;
vAppDim = '}tp_applications';
cActionTICube = '}tp_workflow_action_TI';
cActionDimension = '}tp_workflow_actions';
cActionTIMeasuresDimension = '}tp_workflow_action_TI_measures';
cFieldPreActionTI = 'PreActionTI';
cFieldPreActionTIEnabled = 'PreActionTIEnabled';
cFieldPostActionTI = 'PostActionTI';
cFieldPostActionTIEnabled = 'PostActionTIEnabled';
IF (CubeExists(cActionTICube) =0);
	#something went wrong when creating planning artifacts
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_CUBE_NOT_EXIST',
		'pErrorDetails', cActionTICube,
		'pControl', 'Y');
	
	ProcessError;

Endif;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pApplicationId, pPreActionTI, pPreActionTIEnabled, 
		pPostActionTI, pPostActionTIEnabled, pClearCube);
EndIf;

#***remove read Access to all custom TIs and then clear them from the Custom TI cube
IF (pClearCube @= 'Y');

	#***Remove read access on all custom TIs if they are not used by other applications
	vTotalActions = DIMSIZ(cActionDimension);
	vActionLooper = 1;
	While (vActionLooper <= vTotalActions);
		vAction = DIMNM(cActionDimension, vActionLooper);
		vCustomPreTI = CellGetS(cActionTICube, pApplicationId, vAction, cFieldPreActionTI );
		vCustomPostTI = CellGetS(cActionTICube, pApplicationId, vAction, cFieldPostActionTI );
		vPreTIUsedByOtherApp = 'N';
		vPostTIUsedByOtherApp = 'N';

		vTotalApplications = DIMSIZ(vAppDim);
		vAppLooper = 1;

		While (vAppLooper <= vTotalApplications);
			vOtherApp = DIMNM(vAppDim, vAppLooper);
			IF (vOtherApp @<> pApplicationId);
				vActionLooper2 = 1;
				While (vActionLooper2 <= vTotalActions);
					vOtherAppPreTI = CellGetS(cActionTICube, vOtherApp, vAction, cFieldPreActionTI );
					vOtherAppPostTI = CellGetS(cActionTICube, vOtherApp, vAction, cFieldPostActionTI );
					IF (vCustomPreTI @<>'' & (vCustomPreTI @= vOtherAppPreTI % vCustomPreTI @= vOtherAppPostTI));
						vPreTIUsedByOtherApp = 'Y';
					Endif;
					IF (vCustomPostTI @<>'' & (vCustomPostTI @= vOtherAppPreTI % vCustomPostTI @= vOtherAppPostTI));
						vPostTIUsedByOtherApp = 'Y';
					Endif;
					vActionLooper2 = vActionLooper2 +1;
				End;
			Endif;
			vAppLooper = vAppLooper +1;
		End;

		IF (vPreTIUsedByOtherApp @= 'N');
			IF (DIMIX(cProcessesDim, vCustomPreTI)>0);
				cCurrentCellValue = CellGetS(cProcessSecurityCube, vCustomPreTI, cEveryoneGroup); 
				If (cCurrentCellValue @= 'Read' % cCurrentCellValue @= 'Write');
					If (CellIsUpdateable(cProcessSecurityCube, vCustomPreTI, cEveryoneGroup) = 0);
						vDetail=INSRT(cEveryoneGroup,')',1);
						vDetail=INSRT(',',vDetail,1);
						vDetail=INSRT(cProcessSecurityCube,vDetail,1);
						vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
							'pGuid', pExecutionId, 
							'pProcess', cTM1Process, 
							'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
							'pErrorDetails', vDetail,
							'pControl', 'Y');
				
						ProcessError;
					EndIf;
				Endif;
				CellPutS('NONE', cProcessSecurityCube, vCustomPreTI, cEveryoneGroup);
			Endif;
		Endif;

		IF (vPostTIUsedByOtherApp @= 'N');
			IF (DIMIX(cProcessesDim, vCustomPostTI)>0);
				cCurrentCellValue = CellGetS(cProcessSecurityCube, vCustomPostTI, cEveryoneGroup); 
				If (cCurrentCellValue @= 'Read' % cCurrentCellValue @= 'Write');
					If (CellIsUpdateable(cProcessSecurityCube, vCustomPostTI, cEveryoneGroup) = 0);
						vDetail=INSRT(cEveryoneGroup,')',1);
						vDetail=INSRT(',',vDetail,1);
						vDetail=INSRT(cProcessSecurityCube,vDetail,1);
						vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
							'pGuid', pExecutionId, 
							'pProcess', cTM1Process, 
							'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
							'pErrorDetails', vDetail,
							'pControl', 'Y');
				
						ProcessError;
					EndIf;
				Endif;
				CellPutS('NONE', cProcessSecurityCube, vCustomPostTI, cEveryoneGroup);
			Endif;

		Endif;

		vActionLooper = vActionLooper +1;
	End;

	#***clear entries from the custom TI cube for this application only

	IF (SubsetExists(vAppDim, vAppSubset)>0);
		SubsetDestroy(vAppDim, vAppSubset);
	Endif;
	SubsetCreate(vAppDim, vAppSubset);
	SubsetElementInsert(vAppDim, vAppSubset, pApplicationId, 1);
	#***
	vTempView = 'tp_temp_view_' | pExecutionId;
	ViewCreate(cActionTICube, vTempView);
	ViewRowDimensionSet(cActionTICube, vTempView, cActionDimension, 1);
	ViewColumnDimensionSet(cActionTICube, vTempView,cActionTIMeasuresDimension, 1);
	ViewTitleDimensionSet(cActionTICube, vTempView, vAppDim);
	ViewSubsetAssign(cActionTICube, vTempView, vAppDim, vAppSubset);
	ViewZeroOut(cActionTICube, vTempView);
	ViewDestroy(cActionTICube, vTempView);
	SubsetDestroy(vAppDim, vAppSubset);

Endif;

#***

vSetTIAccess = 'N';
IF (DIMIX(cActionDimension, pWorkflowAction) >0);

	CellPutS(pPreActionTI, cActionTICube, pApplicationId, pWorkflowAction, cFieldPreActionTI);
	CellPutS(pPreActionTIEnabled, cActionTICube, pApplicationId, pWorkflowAction, cFieldPreActionTIEnabled);
	CellPutS(pPostActionTI, cActionTICube, pApplicationId, pWorkflowAction, cFieldPostActionTI);
	CellPutS(pPostActionTIEnabled, cActionTICube, pApplicationId, pWorkflowAction, cFieldPostActionTIEnabled);
	vSetTIAccess = 'Y';

Endif;
#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,85

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

IF (vSetTIAccess @= 'Y' & pPreActionTI @<> '');

	IF (DIMIX(cProcessesDim, pPreActionTI)>0);
		cCurrentCellValue = CellGetS(cProcessSecurityCube, pPreActionTI, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(cProcessSecurityCube, pPreActionTI, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(pPreActionTI,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cProcessSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
					'pGuid', pExecutionId, 
					'pProcess', cTM1Process, 
					'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
					'pErrorDetails', vDetail,
					'pControl', 'Y');
				
				ProcessError;
			EndIf;
			CellPutS('Read', cProcessSecurityCube, pPreActionTI, cEveryoneGroup);
		Endif;
	Else;

		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_COSTOM_TI_NOT_EXIST',
			'pErrorDetails', pPreActionTI,
			'pControl', 'Y');
				
		ProcessError;
	Endif;
EndIf;

IF (vSetTIAccess @= 'Y' & pPostActionTI @<> '');

	IF (DIMIX(cProcessesDim, pPostActionTI)>0);
		cCurrentCellValue = CellGetS(cProcessSecurityCube, pPostActionTI, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(cProcessSecurityCube, pPostActionTI, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(pPostActionTI,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cProcessSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
					'pGuid', pExecutionId, 
					'pProcess', cTM1Process, 
					'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
					'pErrorDetails', vDetail,
					'pControl', 'Y');
				
				ProcessError;
			EndIf;
			CellPutS('Read', cProcessSecurityCube, pPostActionTI, cEveryoneGroup);
		Endif;
	Else;
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
			'pGuid', pExecutionId, 
			'pProcess', cTM1Process, 
			'pErrorCode', 'TI_COSTOM_TI_NOT_EXIST',
			'pErrorDetails', pPreActionTI,
			'pControl', 'Y');
				
		ProcessError;
	Endif;
EndIf;
#***

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
