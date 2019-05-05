601,100
602,"}tp_application_deploy"
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
560,14
pExecutionId
pAppId
pApprovalDim
pApprovalSubset
pCubeViews
pSubsetAlias
pVersionDim
pVersionSubset
pVersionSubsetIsExpandAbove
pVersionSlicesWrite
pVersionSlicesRead
pOfflineGroups
pIncrShadowDimUpdate
pControl
561,14
2
2
2
2
2
2
2
2
2
2
2
2
2
2
590,14
pExecutionId,"None"
pAppId,"MyApp"
pApprovalDim,"TestElist"
pApprovalSubset,"TestElist"
pCubeViews,"None"
pSubsetAlias,"None"
pVersionDim,"None"
pVersionSubset,"None"
pVersionSubsetIsExpandAbove,"N"
pVersionSlicesWrite,"None"
pVersionSlicesRead,"None"
pOfflineGroups,"None"
pIncrShadowDimUpdate,"N"
pControl,"Y"
637,14
pExecutionId,""
pAppId,""
pApprovalDim,""
pApprovalSubset,""
pCubeViews,""
pSubsetAlias,""
pVersionDim,""
pVersionSubset,""
pVersionSubsetIsExpandAbove,""
pVersionSlicesWrite,""
pVersionSlicesRead,""
pOfflineGroups,""
pIncrShadowDimUpdate,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,382


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
	pExecutionId, pAppId, pApprovalDim, pApprovalSubset, pControl);
EndIf;

#*** Check if the application has been deployed
vIsNewDeployment = 'N';
seIsNewVersionDimensionAdded = 'N';
cApplicationsDim = cControlPrefix | 'tp_applications';
If (DIMIX(cApplicationsDim, pAppId) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Insert current application id');
	EndIf;

	vIsNewDeployment = 'Y';
	DimensionElementInsert(cApplicationsDim, '', pAppId, 'S');

Else;

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'This application already existed: ' | pAppId);
	EndIf;
	
	StringGlobalVariable('gVersionDimension');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_application_attributes', 'pExecutionId', pExecutionId,
		'pAppId', pAppId, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	If (gVersionDimension @= '' & pVersionDim @<> '');
		seIsNewVersionDimensionAdded = 'Y';			
	EndIf;
	
	If (seIsNewVersionDimensionAdded @= 'Y');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Version dimension is added in redeployment: ' | pVersionDim);
		EndIf;
	EndIf;
EndIf;

#**Insert application ID to intermediate applications dim
cIntermediateApplicationsDim =  '}tp_intermediate_security_applications';
cParent = 'all_applications';

If (DimensionExists(cIntermediateApplicationsDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create Intermediate security applications dimension');
	EndIf;

	DimensionCreate(cIntermediateApplicationsDim);
	DimensionElementInsert(cIntermediateApplicationsDim, '', cParent,'C');
EndIf;

If (DIMIX(cIntermediateApplicationsDim, pAppId) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Insert current application id');
	EndIf;

	DimensionElementInsert(cIntermediateApplicationsDim, '', pAppId, 'N');
	DimensionElementComponentAdd(cIntermediateApplicationsDim, cParent,pAppId, 1);
EndIf;


#*** Application with approval dimension
If (pApprovalDim @<> '');
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check approval dimension');
	EndIf;
	
	If (DimensionExists(pApprovalDim) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_DIM_NOT_EXIST',
		'pErrorDetails', pApprovalDim,
		'pControl', pControl);
		
		ProcessError;
	EndIf;
	
	StringGlobalVariable('gDoesDimHaveCubeName');
	vReturnValue = ExecuteProcess('}tp_util_does_dim_have_cube_name',
	'pExecutionId', pExecutionId, 'pDim', pApprovalDim, 'pControl',  pControl);
	
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	If (gDoesDimHaveCubeName @= 'Y');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'There is a cube with the same name as approval dimension');
		EndIf;
	EndIf;

	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check approval subset');
	EndIf;
	
	If (SubsetExists(pApprovalDim, pApprovalSubset) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_SUBSET_NOT_EXIST',
		'pErrorDetails', pApprovalDim | ', ' | pApprovalSubset,
		'pControl', pControl);
		
		ProcessError;
	EndIf;

	#***
	cShadowApprovalDim = '}tp_tasks}' | pAppId;
	cPermissionCube = cControlPrefix | 'tp_application_permission}' | pAppId;
	cCellSecurityCube = '}CellSecurity_' | cPermissionCube;
	cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
	
	#***
	vReturnValue = ExecuteProcess('}tp_deploy_create_shadow_dimension', 'pExecutionId', pExecutionId,
		'pAppId', pAppId, 'pApprovalDim', pApprovalDim, 'pApprovalSubset', pApprovalSubset, 'pSubsetAlias', pSubsetAlias, 'pIncrShadowDimUpdate', pIncrShadowDimUpdate);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check permission dimension');
	EndIf;

	cPermissionsDim = cControlPrefix | 'tp_permissions';
	If (DimensionExists(cPermissionsDim) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_DIM_NOT_EXIST',
		'pErrorDetails', cPermissionsDim,
		'pControl', pControl);
		
		ProcessError;
	EndIf;

	#***

	If (CubeExists(cPermissionCube) = 0);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create permission cube: ' | cPermissionCube);
		EndIf;
	
		CubeCreate(cPermissionCube, cShadowApprovalDim, cPermissionsDim);
		CubeSetLogChanges(cPermissionCube, 1);
	EndIf;

	#***

	If (CubeExists(cCellSecurityCube) = 0);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create permission cell security cube: ' | cCellSecurityCube);
		EndIf;
	
		CubeCreate(cCellSecurityCube, cShadowApprovalDim, cPermissionsDim, '}Groups');
		CubeSetLogChanges(cCellSecurityCube, 1);
	EndIf;

	#***
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check node info dimension');
	EndIf;
	
	cNodeInfoDim = cControlPrefix | 'tp_node_info';
	If (DimensionExists(cNodeInfoDim) = 0);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_DIM_NOT_EXIST',
		'pErrorDetails', cNodeInfoDim,
		'pControl', pControl);
		
		ProcessError;
	EndIf;

	#***
	
	cDefaultView = 'Default';
	cAllView = 'All';
	If (CubeExists(cStateCube) = 0);
		
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create state cube: ' | cStateCube);
		EndIf;
	
		CubeCreate(cStateCube, cShadowApprovalDim, cNodeInfoDim);
		CubeSetLogChanges(cStateCube, 1);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create default view');
		EndIf;
	
		ViewCreate(cStateCube, cDefaultView);
		ViewColumnDimensionSet(cStateCube, cDefaultView, cNodeInfoDim, 1);
		ViewRowDimensionSet(cStateCube, cDefaultView, cShadowApprovalDim, 1);
		ViewSubsetAssign(cStateCube, cDefaultView, cShadowApprovalDim, pApprovalSubset);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create All view');
		EndIf;
	
		ViewCreate(cStateCube, cAllView);
		ViewColumnDimensionSet(cStateCube, cAllView, cNodeInfoDim, 1);
		ViewRowDimensionSet(cStateCube, cAllView, cShadowApprovalDim, 1);
	
	
	EndIf;
	
	#***create intermediate security measure dimension
	cIntermediateSecurityMeasuresDim = '}tp_intermediate_security_measures';

	If (DimensionExists(cIntermediateSecurityMeasuresDim) = 0);

		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, 'Create Intermediate security measure dimension');
		EndIf;

		DimensionCreate(cIntermediateSecurityMeasuresDim);
		DimensionElementInsert(cIntermediateSecurityMeasuresDim, '', 'Rights','S');
		DimensionElementInsert(cIntermediateSecurityMeasuresDim, '', 'WriteCount','N');
		DimensionElementInsert(cIntermediateSecurityMeasuresDim, '', 'ReadCount','N');
	EndIf;

EndIf;

#***
vSecuritySet = '';
If (vIsNewDeployment @= 'N');
	vSecuritySet = ATTRS(cApplicationsDim, pAppId, 'SecuritySet');
EndIf;

#***
If (pApprovalDim @<> '');

	#***First check the condition on whether we should delete the element level security cube on approvla Dimension
	vDeleteElementSecurity = 'Y';
	vAppLooper = 1;
	vTotalApplications = DIMSIZ(cApplicationsDim);
	While (vAppLooper <= vTotalApplications);
		vLoopAppId = DIMNM(cApplicationsDim, vAppLooper);
		vSecuritySetOnApp='';
		IF (vLoopAppId @= pAppId);
			If (vIsNewDeployment @= 'N');
				vSecuritySetOnApp = ATTRS(cApplicationsDim, pAppId, 'SecuritySet');
			EndIf;
			IF (vSecuritySetOnApp @='Y');
				vDeleteElementSecurity = 'N';
			Endif;

		Else;
			vSecuritySetOnApp =  ATTRS(cApplicationsDim, vLoopAppId, 'SecuritySet');
			vApprovalDim =ATTRS( cApplicationsDim, vLoopAppId, 'ApprovalDimension');
			IF (vSecuritySetOnApp @= 'Y' & vApprovalDim @= pApprovalDim);
				vDeleteElementSecurity = 'N';
			Endif;
				
		Endif;
		IF (vDeleteElementSecurity @= 'N');
			vAppLooper = vTotalApplications;
		Endif;
		vAppLooper = vAppLooper +1;
	End;

	#****delete element security cube for approval dimension
	#an existing element security cube will impact non-admin users access approval nodes
	IF (vDeleteElementSecurity @= 'Y');
		cElementSecurityCube = '}ElementSecurity_' | pApprovalDim;
		IF (CubeExists(cElementSecurityCube) >0);
			CubeDestroy(cElementSecurityCube);
		EndIf;
	Endif;

	If (vIsNewDeployment @= 'N' & vSecuritySet @= 'N');
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Reset permission cell security cube if the previous deployment failed');
		EndIf;
	
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reset_permission_on_failure',
		'pGuid',  pExecutionId, 'pAppId', pAppId, 'pControl',  pControl);
		
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;
	
	EndIf;

	sGroupsDim = '}Groups';
	cApprovalElementSecurityCube = '}ElementSecurity_' | cShadowApprovalDim;
	If (CubeExists(cApprovalElementSecurityCube) = 0);
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create element security cube for approval hierarchy');
		EndIf;
	
		CubeCreate(cApprovalElementSecurityCube, cShadowApprovalDim, sGroupsDim);
		CubeSetLogChanges(cApprovalElementSecurityCube, 1);
	
	Else;
	
		If (vIsNewDeployment @= 'Y');
		
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Destroy element security cube for approval hierarchy for new deployment');
			EndIf;
	
			CubeDestroy(cApprovalElementSecurityCube);
			CubeCreate(cApprovalElementSecurityCube,cShadowApprovalDim, sGroupsDim);
			CubeSetLogChanges(cApprovalElementSecurityCube, 1);
	
		EndIf;
	
	EndIf;

EndIf;

#*** No error

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,402


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

#*** Log File Name
cTM1Log = cEpilogLog;

#***

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Insert approval dimension and subset attributes');
EndIf;

cApprovalDimensionAttr = 'ApprovalDimension';
cApprovalSubsetAttr = 'ApprovalSubset';
cIsActiveAttr = 'IsActive';
cCubeViews = 'CubeViews';
cShadowDimAttr = 'ApprovalShadowDimension';
cVersionSlicesWriteAttr = 'VersionSlicesWrite';
cVersionSlicesWriteAttrOld = 'VersionSlicesWriteOld';
cVersionSlicesReadAttr = 'VersionSlicesRead';
cVersionSlicesReadAttrOld = 'VersionSlicesReadOld';
cVersionDimAttr = 'VersionDimension';
cVersionDimAttrOld = 'VersionDimensionOld';
cAppTypeAttr = 'ApplicationType';

if (vIsNewDeployment @= 'Y');
	vVersionDimensionOld = pVersionDim;
else;
	vVersionDimensionOld = AttrS(cApplicationsDim, pAppId, cVersionDimAttr);
endif;

vVersionSlicesWriteOld = AttrS(cApplicationsDim, pAppId, cVersionSlicesWriteAttr);
vVersionSlicesReadOld = AttrS(cApplicationsDim, pAppId, cVersionSlicesReadAttr);

AttrPutS(pApprovalDim, cApplicationsDim, pAppId, cApprovalDimensionAttr);
AttrPutS(pApprovalSubset, cApplicationsDim, pAppId, cApprovalSubsetAttr);
AttrPutS('Y', cApplicationsDim, pAppId, cIsActiveAttr);
AttrPutS(pCubeViews, cApplicationsDim, pAppId, cCubeViews);
AttrPutS(cShadowApprovalDim, cApplicationsDim, pAppId,cShadowDimAttr);
AttrPutS('', cApplicationsDim, pAppId, cAppTypeAttr);
AttrPutS(pVersionDim, cApplicationsDim, pAppId, cVersionDimAttr);
AttrPutS(vVersionDimensionOld, cApplicationsDim, pAppId, cVersionDimAttrOld);
AttrPutS(pVersionSlicesWrite, cApplicationsDim, pAppId, cVersionSlicesWriteAttr);
AttrPutS(vVersionSlicesWriteOld, cApplicationsDim, pAppId, cVersionSlicesWriteAttrOld);
AttrPutS(pVersionSlicesRead, cApplicationsDim, pAppId, cVersionSlicesReadAttr);
AttrPutS(vVersionSlicesReadOld, cApplicationsDim, pAppId, cVersionSlicesReadAttrOld);

#***
If (pApprovalDim @<> '');

	#***create task navigation dimensions/cube for this application
	vReturnValue = ExecuteProcess('}tp_deploy_create_task_navigation_cube', 'pExecutionId', pExecutionId,
		'pAppId', pAppId, 'pNavigationDimensions',  pApprovalDim | '*');
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	cApprovalDimSize = DIMSIZ(cShadowApprovalDim);
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set state cube value for state if the node is in the subset');
	EndIf;
	
	vIndex = 1;
	While (vIndex <= cApprovalDimSize);
		vElement = DIMNM(cShadowApprovalDim, vIndex);
		
		vValue = CellGetS(cStateCube, vElement, 'State');
		If (vValue @= '');
			If (CellIsUpdateable(cStateCube, vElement, 'State') = 0);
				vDetail=INSRT('State',')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(vElement,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(cStateCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_APPLICATION_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('0', cStateCube, vElement, 'State');
		EndIf;

		vIndex = vIndex + 1;
	End;

EndIf;

#*** Create "everyone" group

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

	If (DIMIX('}Groups', cCognosEveryoneGroup) = 0);
		ProcessError;
	EndIf;

	If (DIMIX('}Groups', cTpEveryoneGroup) <> 0);
		DeleteGroup(cTpEveryoneGroup);
	EndIf;

	cEveryoneGroup = cCognosEveryoneGroup;

Else;

	cEveryoneGroup = cTpEveryoneGroup;

	If (DIMIX('}Groups', cEveryoneGroup) = 0);
		AddGroup(cEveryoneGroup);
	EndIf;

EndIf;

#***

If (pApprovalDim @<> '');

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Give everyone group "Read" right to application artifacts.');
	EndIf;
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Make approval dimension readable');
	EndIf;
	
	sDimensionSecurityCube = '}DimensionSecurity';
	If (CubeExists(sDimensionSecurityCube) = 1);
		cCurrentCellValue = CellGetS(sDimensionSecurityCube, cShadowApprovalDim, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(sDimensionSecurityCube, cShadowApprovalDim, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(cShadowApprovalDim,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(sDimensionSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('Read', sDimensionSecurityCube, cShadowApprovalDim, cEveryoneGroup);
		EndIf;
		cCurrentCellValue = CellGetS(sDimensionSecurityCube, pApprovalDim, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(sDimensionSecurityCube, pApprovalDim, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(pApprovalDim,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(sDimensionSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('Read', sDimensionSecurityCube, pApprovalDim, cEveryoneGroup);
		EndIf;
	EndIf;
	
	#*
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Make permission cube readable');
	EndIf;
	
	sCubeSecurityCube = '}CubeSecurity';
	If (CubeExists(sCubeSecurityCube) = 1);
		cCurrentCellValue = CellGetS(sCubeSecurityCube, cPermissionCube, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(sCubeSecurityCube, cPermissionCube, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(cPermissionCube,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(sCubeSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('Read', sCubeSecurityCube, cPermissionCube, cEveryoneGroup);
			If (cGenerateLog @= 'Y');
		        TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'CellPutS: Make permission cube readable');
	        EndIf;
		EndIf;
		
		cCurrentCellValue = CellGetS(sCubeSecurityCube, cCellSecurityCube, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(sCubeSecurityCube, cCellSecurityCube, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(cCellSecurityCube,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(sCubeSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('Read', sCubeSecurityCube, cCellSecurityCube, cEveryoneGroup);
			If (cGenerateLog @= 'Y');
		        TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'CellPutS: Make cell security cube of permission cube readable');
	        EndIf;
		EndIf;

	EndIf;
	
	#*

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Make state cube readable');
	EndIf;
	
	If (CubeExists(sCubeSecurityCube) = 1);
		cCurrentCellValue = CellGetS(sCubeSecurityCube, cStateCube, cEveryoneGroup); 
		If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
			If (CellIsUpdateable(sCubeSecurityCube, cStateCube, cEveryoneGroup) = 0);
				vDetail=INSRT(cEveryoneGroup,')',1);
				vDetail=INSRT(',',vDetail,1);
				vDetail=INSRT(cStateCube,vDetail,1);
				vDetail=INSRT('(',vDetail,1);
				vDetail=INSRT(sCubeSecurityCube,vDetail,1);
				vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', cTM1Process, 
				'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
				'pErrorDetails', vDetail,
				'pControl', pControl);
				ProcessError;
			EndIf;
			CellPutS('Read', sCubeSecurityCube, cStateCube, cEveryoneGroup);
			If (cGenerateLog @= 'Y');
		        TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'CellPutS: Make state cube readable');
	        EndIf;
		EndIf;
	EndIf;
EndIf;

#****
#Put all readable slices and writable slices into one subset
#This subset will be used on client side to filter on a control dimension
IF (pVersionDim @<> '');
	vFilterSubset = 'tp_' | pAppId;
	IF (SubsetExists(pVersionDim, vFilterSubset) = 1);
		SubsetDeleteAllElements(pVersionDim, vFilterSubset);
	Else;
		SubsetCreate(pVersionDim, vFilterSubset);
	Endif;
	
	If (pVersionSubsetIsExpandAbove @= 'Y');
		SubsetExpandAboveSet( pVersionDim, vFilterSubset, 1);
	Else;
		SubsetExpandAboveSet( pVersionDim, vFilterSubset, 0);
	Endif;

	totalControlSlices= SubsetGetSize(pVersionDim, pVersionSubset);
	looper = totalControlSlices;
	While (looper >= 1);
		vSlice = SubsetGetElementName(pVersionDim, pVersionSubset, looper);
	
		#parse readable slices
		versionSeparater = '|';
		vPosVersion = 0;
		vStringToScan = pVersionSlicesRead;
		vSliceAdded = 'N';
		IF (pVersionSlicesRead @<> '' & vSliceAdded @='N');
			vPosVersion = SCAN(versionSeparater, vStringToScan);
			While (vPosVersion >0);
				vVersionSlice  = SUBST(vStringToScan, 1, vPosVersion-1);
				IF (vVersionSlice @= vSlice);
					SubsetElementInsert(pVersionDim, vFilterSubset, vVersionSlice, 1);
					vSliceAdded = 'Y';
				Endif;
				vStringToScan = SUBST(vStringToScan, vPosVersion +1, LONG(vStringToScan)-vPosVersion);
				vPosVersion = SCAN(versionSeparater, vStringToScan);
			End;
		Endif;
	
		#parse writable slices
		versionSeparater = '|';
		vPosVersion = 0;
		vStringToScan = pVersionSlicesWrite;
		IF (pVersionSlicesWrite @<> '' & vSliceAdded @= 'N');
			vPosVersion = SCAN(versionSeparater, vStringToScan);
			While (vPosVersion >0);
				vVersionSlice  = SUBST(vStringToScan, 1, vPosVersion-1);
				IF (vVersionSlice @= vSlice);
					SubsetElementInsert(pVersionDim, vFilterSubset, vVersionSlice, 1);
					vSliceAdded = 'Y';
				Endif;
				vStringToScan = SUBST(vStringToScan, vPosVersion +1, LONG(vStringToScan)-vPosVersion);
				vPosVersion = SCAN(versionSeparater, vStringToScan);
			End;
		Endif;
		
		looper = looper -1;
	End;

EndIf;

# Clear }CellSecurity_}tp_application_root_permissions, it will be re-populated with the current offline Groups
cOfflinePermissionElement = 'OFFLINE';
vOfflinePermissionViewName = 'temp_offline_perm_' | pAppId;
vOfflinePermissionCubeName = '}CellSecurity_}tp_application_root_permissions';

vDimOfflinePermissions = '}tp_root_permissions';
If (ViewExists(vOfflinePermissionCubeName, vOfflinePermissionViewName) = 0);
	vAppFilterSubset = 'temp_offline_perm_app' | pAppId;
	If (SubsetExists(cApplicationsDim, vAppFilterSubset) = 1);
		SubsetDestroy(cApplicationsDim, vAppFilterSubset);
	EndIf;
	SubsetCreate(cApplicationsDim, vAppFilterSubset);
	SubsetElementInsert(cApplicationsDim, vAppFilterSubset, pAppId, 1);
	
	vPermFilterSubset = 'temp_offline_perm_perm' | pAppId;
	If (SubsetExists(vDimOfflinePermissions, vPermFilterSubset) = 1);
		SubsetDestroy(vDimOfflinePermissions, vPermFilterSubset);
	EndIf;
	SubsetCreate(vDimOfflinePermissions, vPermFilterSubset);
	SubsetElementInsert(vDimOfflinePermissions, vPermFilterSubset, cOfflinePermissionElement, 1);
	
	ViewCreate(vOfflinePermissionCubeName, vOfflinePermissionViewName);
	ViewSubsetAssign(vOfflinePermissionCubeName, vOfflinePermissionViewName, cApplicationsDim, vAppFilterSubset);
	ViewSubsetAssign(vOfflinePermissionCubeName, vOfflinePermissionViewName, vDimOfflinePermissions, vPermFilterSubset);
EndIf;
ViewZeroOut(vOfflinePermissionCubeName, vOfflinePermissionViewName);
ViewDestroy(vOfflinePermissionCubeName, vOfflinePermissionViewName);
SubsetDestroy(cApplicationsDim, vAppFilterSubset);
SubsetDestroy(vDimOfflinePermissions, vPermFilterSubset);

#parse canoffile groups
offlineSeparater = '|';
vPosOffline = 0;
vStringToScan = pOfflineGroups;
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set offline groups:'|pOfflineGroups);
EndIf;
cOfflineRead = 'READ';
IF (pOfflineGroups @<> '');
	vPosOffline = SCAN(offlineSeparater, vStringToScan);
	While (vPosOffline >0);
		vOfflineGroup  = SUBST(vStringToScan, 1, vPosOffline-1);
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set offline group:'|cOfflineRead|':'|vOfflinePermissionCubeName|':'|pAppId|':OFFLINE:'|vOfflineGroup);
		EndIf;
		CellPutS(cOfflineRead, vOfflinePermissionCubeName, pAppId, cOfflinePermissionElement, vOfflineGroup);
		vStringToScan = SUBST(vStringToScan, vPosOffline +1, LONG(vStringToScan)-vPosOffline);
		vPosOffline = SCAN(offlineSeparater, vStringToScan);
		  
	End;
Endif;
vEveryoneSet = CellGetS(vOfflinePermissionCubeName, pAppId, cOfflinePermissionElement, cEveryoneGroup);
If (vEveryoneSet @= '');
	#*** set NONE for everyone
	CellPutS('NONE', vOfflinePermissionCubeName, pAppId, cOfflinePermissionElement, cEveryoneGroup);
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
