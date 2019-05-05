601,100
602,"}tp_create_planning_artifacts"
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
560,2
pExecutionId
pControl
561,2
2
2
590,2
pExecutionId,"None"
pControl,"N"
637,2
pExecutionId,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,657

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


#***create error log objects
cErrorCube = cControlPrefix | 'tp_process_errors';
If (CubeExists(cErrorCube) = 0);
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_setup', 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
EndIf;

#***Insert a field in "}tp_config" dimension to enable element security on approval dimension 
#default value is  "Y"
cEnableElementSecurity = 'EnableElementSecurityOnApproval';
cConfigDim =cControlPrefix | 'tp_config';
vIsInitialSetup = 'N';
if (DimensionExists(cConfigDim)=0);
DimensionCreate(cConfigDim);
endif;
IF (DIMIX(cConfigDim, cEnableElementSecurity)=0);
DimensionElementInsert(cConfigDim, '', cEnableElementSecurity,'S');
vIsInitialSetup = 'Y';
Endif;

cServerMaintenanceRunning = 'ApplicationMaintenanceRunning';
IF (DIMIX(cConfigDim, cServerMaintenanceRunning)=0);
DimensionElementInsert(cConfigDim, '', cServerMaintenanceRunning,'S');
Endif;

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
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pControl);
EndIf;

cTpPrefix = cControlPrefix | 'tp_';
cTpPrefixLength = LONG(cTpPrefix);

#***

cApplicationsDim = cControlPrefix | 'tp_applications';

cApprovalDimensionAttr = 'ApprovalDimension';
cApprovalSubsetAttr = 'ApprovalSubset';
cApprovalShadowDimAttr = 'ApprovalShadowDimension';
cIsActiveAttr = 'IsActive';
cStoreIdAttr = 'StoreId';
cSecuritySetAttr = 'SecuritySet';
cVersionAttr = 'Version';
cCubeViewsAttr = 'CubeViews';
cMaintenanceAttr = 'IsRunningMaintenance';
cVersionSlicesWrite = 'VersionSlicesWrite';
cVersionSlicesWriteOld =  'VersionSlicesWriteOld';
cVersionSlicesRead = 'VersionSlicesRead';
cVersionSlicesReadOld =  'VersionSlicesReadOld';
cVersionDimension = 'VersionDimension';
cVersionDimensionOld = 'VersionDimensionOld';
cApplicationType = 'ApplicationType';
cApplicationLastSavedTime = 'ApplicationLastSaved';
cSecurityMethod = 'SecurityMethod';
cBounceMode='BounceMode';

If (DimensionExists(cApplicationsDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create applications dimension');
	EndIf;

	DimensionCreate(cApplicationsDim);
	AttrInsert(cApplicationsDim, '', cApprovalDimensionAttr, 'S');
	AttrInsert(cApplicationsDim, '', cApprovalSubsetAttr, 'S');
	AttrInsert(cApplicationsDim, '', cApprovalShadowDimAttr, 'S');
	AttrInsert(cApplicationsDim, '', cIsActiveAttr, 'S');
	AttrInsert(cApplicationsDim, '', cStoreIdAttr, 'S');
	AttrInsert(cApplicationsDim, '', cSecuritySetAttr, 'S');
	AttrInsert(cApplicationsDim, '', cVersionAttr, 'S');
	AttrInsert(cApplicationsDim, '', cCubeViewsAttr, 'S');
	AttrInsert(cApplicationsDim, '', cMaintenanceAttr, 'S');
	AttrInsert(cApplicationsDim, '', cVersionDimension, 'S');
	AttrInsert(cApplicationsDim, '', cVersionDimensionOld, 'S');
	AttrInsert(cApplicationsDim, '', cVersionSlicesWrite, 'S');
	AttrInsert(cApplicationsDim, '', cVersionSlicesWriteOld, 'S');
	AttrInsert(cApplicationsDim, '', cVersionSlicesRead, 'S');
	AttrInsert(cApplicationsDim, '', cVersionSlicesReadOld, 'S');
	AttrInsert(cApplicationsDim, '', cApplicationType, 'S');
	AttrInsert(cApplicationsDim, '', cApplicationLastSavedTime, 'S');
	AttrInsert(cApplicationsDim, '', cSecurityMethod, 'S');
	AttrInsert(cApplicationsDim, '', cBounceMode, 'S');
Else;
	# fix tp_applications when upgraded from 9.5.2 server data.
	cAppAttrDim = '}ElementAttributes_' | cApplicationsDim;

	If (DIMIX(cAppAttrDim, cVersionAttr) = 0);
		AttrInsert(cApplicationsDim, '', cVersionAttr, 'S');
	EndIf;
	
	If (DIMIX(cAppAttrDim, cCubeViewsAttr) = 0);
		AttrInsert(cApplicationsDim, '', cCubeViewsAttr, 'S');
	EndIf;

	
	If (DIMIX(cAppAttrDim, cMaintenanceAttr) = 0);
		AttrInsert(cApplicationsDim, '', cMaintenanceAttr, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cApprovalShadowDimAttr) = 0);
		AttrInsert(cApplicationsDim, '', cApprovalShadowDimAttr, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cVersionSlicesWrite) = 0);
		AttrInsert(cApplicationsDim, '', cVersionSlicesWrite, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cVersionSlicesWriteOld) = 0);
		AttrInsert(cApplicationsDim, '', cVersionSlicesWriteOld, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cVersionSlicesReadOld) = 0);
		AttrInsert(cApplicationsDim, '', cVersionSlicesReadOld, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cVersionSlicesRead) = 0);
		AttrInsert(cApplicationsDim, '', cVersionSlicesRead, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim,  cVersionDimension) = 0);
		AttrInsert(cApplicationsDim, '',  cVersionDimension, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim,  cVersionDimensionOld) = 0);
		AttrInsert(cApplicationsDim, '',  cVersionDimensionOld, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cApplicationType) = 0);
		AttrInsert(cApplicationsDim, '', cApplicationType, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cApplicationLastSavedTime) = 0);
		AttrInsert(cApplicationsDim, '', cApplicationLastSavedTime, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cSecurityMethod) = 0);
		AttrInsert(cApplicationsDim, '', cSecurityMethod, 'S');
	EndIf;

	If (DIMIX(cAppAttrDim, cBounceMode) = 0);
		AttrInsert(cApplicationsDim, '', cBounceMode, 'S');
	EndIf;
EndIf;

IF (subsetExists(cApplicationsDim, 'Default') =0);
	SubsetCreate(cApplicationsDim, 'Default');
Endif;
SubsetIsAllSet(cApplicationsDim, 'Default', 1);

#***

cElementSecurityApplicationsCube = '}ElementSecurity_' | cApplicationsDim;

sGroupsDim = '}Groups';

If (CubeExists(cElementSecurityApplicationsCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create applications element security cube');
	EndIf;

	CubeCreate(cElementSecurityApplicationsCube, cApplicationsDim, sGroupsDim);
	CubeSetLogChanges(cElementSecurityApplicationsCube, 1);

EndIf;

#***

cElementAttributesApplicaitonsDim = '}ElementAttributes_' | cApplicationsDim;
cElementAttributesApplicaitonsCube = cElementAttributesApplicaitonsDim;
If (DimensionExists(cElementAttributesApplicaitonsDim) = 0);
    ProcessError;
EndIf;

If (CubeExists(cElementAttributesApplicaitonsCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create applications element attributes cube');
	EndIf;
      
   	CubeCreate(cElementAttributesApplicaitonsCube, cApplicationsDim, cElementAttributesApplicaitonsDim);
	CubeSetLogChanges(cElementAttributesApplicaitonsCube, 1);
EndIf;

#***

cPermissionsDim = cControlPrefix | 'tp_permissions';

cView = 'VIEW';
cAnnotate = 'ANNOTATE';
cEdit = 'EDIT';
cReject = 'REJECT';
cSubmit = 'SUBMIT';

If (DimensionExists(cPermissionsDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create permissions dimension');
	EndIf;

	DimensionCreate(cPermissionsDim);
	
	DimensionElementInsert(cPermissionsDim, '',cView,'S');
	DimensionElementInsert(cPermissionsDim, '',cAnnotate,'S');
	DimensionElementInsert(cPermissionsDim, '',cEdit,'S');
	DimensionElementInsert(cPermissionsDim, '',cReject,'S');
	DimensionElementInsert(cPermissionsDim, '',cSubmit,'S');
	
	SubsetCreate(cPermissionsDim, 'Default');
	SubsetIsAllSet(cPermissionsDim, 'Default', 1);

EndIf;


#***

cNodeInfoDim = cControlPrefix | 'tp_node_info';

cState = 'State';
cViewed = 'Viewed';
cSaved = 'Saved';
cReviewed = 'Reviewed';
cBeingEdited = 'BeingEdited';
cOffline = 'Offline';
cCurrentOwner = 'CurrentOwner';
cCurrentOwnerId = 'CurrentOwnerId';
cTakeOwnershipNode = 'TakeOwnershipNode';
cStartEditingDate = 'StartEditingDate';
cStateChangeUser = 'StateChangeUser';
cStateChangeDate = 'StateChangeDate';
cDataChangeUser = 'DataChangeUser';
cDataChangeDate = 'DataChangeDate';
cNodeInfoReviewer = 'Reviewer';
cAddedNodeInfoReviewer = 'N';

If (DimensionExists(cNodeInfoDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create node info dimension');
	EndIf;

	DimensionCreate(cNodeInfoDim);
	
	DimensionElementInsert(cNodeInfoDim, '', cState, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cViewed, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cSaved, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cReviewed, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cBeingEdited, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cOffline, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cCurrentOwner, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cCurrentOwnerId, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cNodeInfoReviewer, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cTakeOwnershipNode, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cStartEditingDate, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cStateChangeUser, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cStateChangeDate, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cDataChangeUser, 'S');
	DimensionElementInsert(cNodeInfoDim, '', cDataChangeDate, 'S');
Else;
	# fix tp_node_info when upgraded from 9.5.2 server data.
	cTakeOwnershipNode = 'TakeOwnershipNode';
	cStartEditingDate = 'StartEditingDate';
	If (DIMIX(cNodeInfoDim, cTakeOwnershipNode) = 0);
		DimensionElementInsert(cNodeInfoDim, cStartEditingDate, cTakeOwnershipNode, 'S');
	EndIf;
	
	If (DIMIX(cNodeInfoDim, cOffline) = 0);
		DimensionElementInsert(cNodeInfoDim, cCurrentOwner, cOffline, 'S');
	EndIf;
	
	cAnnotationChangeUser = 'AnnotationChangeUser';
	cAnnotationChangeDate = 'AnnotationChangeDate';
	If (DIMIX(cNodeInfoDim, cAnnotationChangeUser) <> 0);
		DimensionElementDelete(cNodeInfoDim, cAnnotationChangeUser);
	EndIf;
	
	If (DIMIX(cNodeInfoDim, cAnnotationChangeDate) <> 0);
		DimensionElementDelete(cNodeInfoDim, cAnnotationChangeDate);
	EndIf;
	
	If (DIMIX(cNodeInfoDim, cNodeInfoReviewer) = 0);
		DimensionElementInsert(cNodeInfoDim, cTakeOwnershipNode, cNodeInfoReviewer, 'S');
		cAddedNodeInfoReviewer = 'Y';
	EndIf;
	
EndIf;



#*** Create subset for dimension }Groups

cTpDefaultSubset = 'tp_default';
If (SubsetExists('}Groups', cTpDefaultSubset) = 0);
	SubsetCreate('}Groups', cTpDefaultSubset);
	SubsetIsAllSet('}Groups', cTpDefaultSubset, 1);
	SubsetAliasSet('}Groups', cTpDefaultSubset, '}TM1_DefaultDisplayValue');
EndIf;

#*** create applicationCubes cube

cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';

sCubesDim = '}Cubes';

If (CubeExists(cApplicationCubesCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create application cubes cube');
	EndIf;

	CubeCreate(cApplicationCubesCube, cApplicationsDim, sCubesDim);
	CubeSetLogChanges(cApplicationCubesCube, 1);

EndIf;

#*** create cube to store state of central applications 

cCentralApplicationStateCube = cControlPrefix | 'tp_central_application_state';
If (CubeExists(cCentralApplicationStateCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create central application state cube');
	EndIf;

	CubeCreate(cCentralApplicationStateCube, cApplicationsDim, cNodeInfoDim);
	CubeSetLogChanges(cCentralApplicationStateCube, 1);

EndIf;

#***create objects for storing intermediate security information (rule driven)
vIntermediateSecurityMeasureDim  ='}tp_intermediate_security_measures';


If (DimensionExists(vIntermediateSecurityMeasureDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create Intermediate security measure dimension');
	EndIf;

	DimensionCreate(vIntermediateSecurityMeasureDim);
	DimensionElementInsert(vIntermediateSecurityMeasureDim, '', 'StaticRights','S');
	DimensionElementInsert(vIntermediateSecurityMeasureDim, '', 'Rights','S');
	DimensionElementInsert(vIntermediateSecurityMeasureDim, '', 'WriteCount','N');
	DimensionElementInsert(vIntermediateSecurityMeasureDim, '', 'ReadCount','N');
Endif;


vIntermediateSecurityApplications = '}tp_intermediate_security_applications';
If (DimensionExists(vIntermediateSecurityApplications) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create Intermediate security applications dimension');
	EndIf;

	DimensionCreate(vIntermediateSecurityApplications);
	DimensionElementInsert(vIntermediateSecurityApplications, '', 'all_applications','C');
Endif;

#create objects to store workflow action pre and post TI
# create dimension }tp_workflow_action_TI_measures
vActionTIDimension = '}tp_workflow_action_TI_measures';
IF (DimensionExists(vActionTIDimension) =0);
	vMeasurePreTI = 'PreActionTI';
	vMeasurePreTIEnabled = 'PreActionTIEnabled';
	vMeasurePostTI = 'PostActionTI';
	vMeasurePostTIEnabled = 'PostActionTIEnabled';

	DimensionCreate(vActionTIDimension);
	DimensionElementInsert(vActionTIDimension, '', vMeasurePreTI, 'S');
	DimensionElementInsert(vActionTIDimension, '', vMeasurePreTIEnabled, 'S');
	DimensionElementInsert(vActionTIDimension, '',  vMeasurePostTI, 'S');
	DimensionElementInsert(vActionTIDimension,'', vMeasurePostTIEnabled , 'S');
Endif;

vActionTypeDimension = '}tp_workflow_actions';
IF (DimensionExists(vActionTypeDimension) =0);
	vEnter = 'ENTER';
	vOwn = 'OWN';
	vSave = 'SAVE';
	vSubmit = 'SUBMIT'; 
	vReject = 'REJECT';
	vLeave = 'LEAVE';
	vSubmitChildren = 'SUBMITCHILDREN';
	vAnnotate = 'ANNOTATE';
	vRelease = 'RELEASE';
	vOffline = 'OFFLINE';
	vOnline = 'ONLINE';
	DimensionCreate(vActionTypeDimension);
	DimensionElementInsert(vActionTypeDimension, '', vEnter, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vOwn, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vSave, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vSubmit, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vReject, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vLeave, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vSubmitChildren, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vAnnotate, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vRelease, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vOffline, 'N');
	DimensionElementInsert(vActionTypeDimension, '', vOnline, 'N');
Endif;

#Create a cube to store workflow action pre-TI and post-TI
vApplicationsDimension = '}tp_applications';
vWorkflowActionTICube = '}tp_workflow_action_TI';

IF (CubeExists(vWorkflowActionTICube) =0);
	CubeCreate(vWorkflowActionTICube, vApplicationsDimension, vActionTypeDimension,vActionTIDimension);
Endif;

#Create a dimension to store action TI error codes
#Use dimension attributes for localized strings
vActionTIErrorDim = '}tp_process_errors_localization';
vActionTIErrorAttrDim ='}ElementAttributes_' | vActionTIErrorDim;
vActionTIErrorAttrCube = vActionTIErrorAttrDim;
IF (DimensionExists(vActionTIErrorDim) = 0);
	DimensionCreate(vActionTIErrorDim);

Endif;

cAttrErrorType = 'ErrorType';
IF (DIMIX(vActionTIErrorAttrDim, cAttrErrorType) =0);
AttrInsert(vActionTIErrorDim, '', cAttrErrorType, 'S');
Endif;

#***Create task navigation dimension
cTaskNavDimension = '}tp_task_navigations';
cNavElemField = 'NavigationElement';
IF (DimensionExists( cTaskNavDimension) = 0);
	DimensionCreate( cTaskNavDimension);
	DimensionElementInsert( cTaskNavDimension, '',cNavElemField , 'S');
Endif;


#*** No error

cRootPermissionsDim = cControlPrefix | 'tp_root_permissions';

cOffline = 'OFFLINE';
cOwnership = 'OWN';

If (DimensionExists(cRootPermissionsDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create root permissions dimension');
	EndIf;

	DimensionCreate(cRootPermissionsDim);
	
	DimensionElementInsert(cRootPermissionsDim, '',cOffline,'S');
	DimensionElementInsert(cRootPermissionsDim, '', cOwnership, 'S');
	
	SubsetCreate(cRootPermissionsDim, 'Default');
	SubsetIsAllSet(cRootPermissionsDim, 'Default', 1);
Else;
	If (DIMIX(cRootPermissionsDim, cOffline) = 0);
		DimensionElementInsert(cRootPermissionsDim, '', cOffline, 'S');
	EndIf;
	If (DIMIX(cRootPermissionsDim, cOwnership) = 0);
		DimensionElementInsert(cRootPermissionsDim, '', cOwnership, 'S');
	EndIf;
EndIf;

cRootPermissionsCube = cControlPrefix | 'tp_application_root_permissions';
cCellSecurityRootPermissionsCube = '}CellSecurity_' | cRootPermissionsCube;

If (CubeExists(cRootPermissionsCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create application root permissions');
	EndIf;

	CubeCreate(cRootPermissionsCube, cApplicationsDim, cRootPermissionsDim);
	CubeSetLogChanges(cRootPermissionsCube, 1);
	
EndIf;

If (CubeExists(cCellSecurityRootPermissionsCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Create application root permissions cell security cube: ' | cCellSecurityRootPermissionsCube);
	EndIf;

	CubeCreate(cCellSecurityRootPermissionsCube, cApplicationsDim, cRootPermissionsDim, '}Groups');
	CubeSetLogChanges(cCellSecurityRootPermissionsCube, 1);
EndIf;

#***

cJobsDim = cControlPrefix | 'tp_jobs';

If (DimensionExists(cJobsDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create jobs dimension');
	EndIf;

	DimensionCreate(cJobsDim);
EndIf;

#***

cJobInfoDim = cControlPrefix | 'tp_job_info';

cJobAppId = 'ApplicationId';
cJobAppName = 'ApplicationName';
cJobType = 'JobType';
cJobOwner = 'Owner';
cJobOwnerId = 'OwnerId';
cJobStartDate = 'StartDate';
cJobEndDate = 'EndDate';
cJobStatus = 'JobStatus';

If (DimensionExists(cJobInfoDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create job info dimension');
	EndIf;

	DimensionCreate(cJobInfoDim);
	
	DimensionElementInsert(cJobInfoDim, '', cJobAppId, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobAppName, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobType, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobOwner, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobOwnerId, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobStartDate, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobEndDate, 'S');
	DimensionElementInsert(cJobInfoDim, '', cJobStatus, 'S');
EndIf;

#*** create cube to store application jobs 

cApplicationJobCube = cControlPrefix | 'tp_application_jobs';
If (CubeExists(cApplicationJobCube) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create application jobs cube');
	EndIf;

	CubeCreate(cApplicationJobCube, cJobsDim, cJobInfoDim);
	CubeSetLogChanges(cApplicationJobCube, 1);

EndIf;

cApplicationUserPreferencesDim = cControlPrefix | 'tp_app_user_preference';
cWorkflowLayout = 'WorkflowLayout';
If (DimensionExists(cApplicationUserPreferencesDim) = 0);

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, 'Create user app preference dimension');
	EndIf;

	DimensionCreate(cApplicationUserPreferencesDim);
	
	DimensionElementInsert(cApplicationUserPreferencesDim, '', cWorkflowLayout, 'S');
Else;
	If (DIMIX(cApplicationUserPreferencesDim,cWorkflowLayout) = 0);
		DimensionElementInsert(cApplicationUserPreferencesDim, '', cWorkflowLayout, 'S');
	EndIf;
EndIf;

cApplicationUserPreferencesCube = cControlPrefix | 'tp_app_user_preferences';
If (CubeExists(cApplicationUserPreferencesCube) = 0);
	CubeCreate(cApplicationUserPreferencesCube, '}Clients', cApplicationsDim, cApplicationUserPreferencesDim);
EndIf;


If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'The end has been reached.');
EndIf;

573,1

574,1

575,825


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

#***By default enforce element security on approval dimension
IF (vIsInitialSetup @= 'Y');
AttrPutS('Y', cConfigDim, cEnableElementSecurity, 'String Value');
Endif;

#*** Check security cubes

sDimensionsDim = '}Dimensions';
sDimensionSecurityCube = '}DimensionSecurity';
If (CubeExists(sDimensionSecurityCube) = 0);

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Create }DimensionSecurity');
EndIf;

CubeCreate(sDimensionSecurityCube, sDimensionsDim, sGroupsDim);
CubeSetLogChanges(sDimensionSecurityCube, 1);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, '}Groups', cEveryoneGroup); 
If ( cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, '}Groups', cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT('((}Groups,',vDetail,1);
		vDetail=INSRT(sDimensionSecurityCube,vDetail,1);
		vDetail=INSRT(CellGetS(sDimensionSecurityCube, '}Groups', cEveryoneGroup),vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sDimensionSecurityCube, '}Groups', cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, '}ElementAttributes_}Groups', cEveryoneGroup); 
If ( cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, '}ElementAttributes_}Groups', cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT('((}ElementAttributes_}Groups,',vDetail,1);
		vDetail=INSRT(sDimensionSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sDimensionSecurityCube, '}ElementAttributes_}Groups', cEveryoneGroup);
EndIf;


sCubesDim = '}Cubes';
sCubeSecurityCube = '}CubeSecurity';
If (CubeExists(sCubeSecurityCube) = 0);

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Create }CubeSecurity');
EndIf;

CubeCreate(sCubeSecurityCube, sCubesDim, sGroupsDim);
CubeSetLogChanges(sCubeSecurityCube, 1);
EndIf;

CellPutS('Read', sCubeSecurityCube, '}ElementAttributes_}Groups', cEveryoneGroup);
CellPutS('Read', sCubeSecurityCube, cElementSecurityApplicationsCube, cEveryoneGroup);

sProcessesDim = '}Processes';
sProcessSecurityCube = '}ProcessSecurity';
If (CubeExists(sProcessSecurityCube) = 0);

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Create }ProcessSecurity');
EndIf;

CubeCreate(sProcessSecurityCube, sProcessesDim, sGroupsDim);
CubeSetLogChanges(sProcessSecurityCube, 1);
EndIf;

#*** Add TP processes to everyone group

cEnterNodeProc = cControlPrefix | 'tp_workflow_enter_node';
cLeaveNodeProc = cControlPrefix | 'tp_workflow_leave_node';
cOwnNodeProc = cControlPrefix | 'tp_workflow_own_node';
cRejectNodeProc = cControlPrefix | 'tp_workflow_reject_node';
cSaveNodeProc = cControlPrefix | 'tp_workflow_save_node';
cSubmitNodeProc = cControlPrefix | 'tp_workflow_submit_node';
cSubmitLeafChildrenProc = cControlPrefix | 'tp_workflow_submit_leaf_children';
cUpdateUserNameProc = cControlPrefix | 'tp_workflow_update_user_name';
cInitializeSessionProc = cControlPrefix | 'tp_initialize_session';
cExecuteActionProc = cControlPrefix | 'tp_workflow_execute_action';
cBounceConflictUsersProc = cControlPrefix | 'tp_workflow_bounce_conflict_users';
cDeleteDrillViewProc = cControlPrefix | 'tp_delete_drill_view';

cCurrentCellValue = CellGetS(sProcessSecurityCube, cEnterNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cEnterNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cEnterNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cEnterNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cLeaveNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cLeaveNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cLeaveNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cLeaveNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cOwnNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cOwnNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cOwnNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cOwnNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cRejectNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cRejectNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cRejectNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cRejectNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cSaveNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cSaveNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cSaveNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cSaveNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cSubmitNodeProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cSubmitNodeProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cSubmitNodeProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cSubmitNodeProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cSubmitLeafChildrenProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cSubmitLeafChildrenProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cUpdateUserNameProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cUpdateUserNameProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cUpdateUserNameProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cUpdateUserNameProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cInitializeSessionProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cInitializeSessionProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cInitializeSessionProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cInitializeSessionProc , cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cExecuteActionProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cExecuteActionProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cExecuteActionProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cExecuteActionProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cBounceConflictUsersProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cBounceConflictUsersProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cBounceConflictUsersProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cBounceConflictUsersProc, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sProcessSecurityCube, cDeleteDrillViewProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cDeleteDrillViewProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cDeleteDrillViewProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cDeleteDrillViewProc, cEveryoneGroup);
EndIf;

#***

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Add applications dimension, its attributes dimension and cube to everyone group');
EndIf;

cApplicationsAttributesDim = '}ElementAttributes_' | cApplicationsDim;
cApplicationsAttributesCube = '}ElementAttributes_' | cApplicationsDim;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cApplicationsDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cApplicationsDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationsDim,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sDimensionSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', sProcessSecurityCube,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sDimensionSecurityCube, cApplicationsDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cApplicationsAttributesDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cApplicationsAttributesDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationsAttributesDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cApplicationsAttributesDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, cApplicationsAttributesCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, cApplicationsAttributesCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationsAttributesCube,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sCubeSecurityCube,vDetail,1);
		vDetail=INSRT(CellGetS(sCubeSecurityCube, cApplicationsAttributesCube, cEveryoneGroup),vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sCubeSecurityCube, cApplicationsAttributesCube, cEveryoneGroup);
EndIf;

#***

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Add permissions dimension to everyone group');
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cPermissionsDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cPermissionsDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cPermissionsDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cPermissionsDim, cEveryoneGroup);
EndIf;

#***

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Add node info dimension to everyone group');
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cNodeInfoDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cNodeInfoDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cNodeInfoDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cNodeInfoDim, cEveryoneGroup);
EndIf;


#***

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'Set security on error cube');
EndIf;

cErrorCube = cControlPrefix | 'tp_process_errors';
cErrorGuidsDim = cControlPrefix |  'tp_process_guids';
cErrorMeasuresDim = cControlPrefix | 'tp_process_error_measures';
cCentralApplicationStateCube = cControlPrefix | 'tp_central_application_state';
cApplicationRootPermissionsCube = cControlPrefix | 'tp_application_root_permissions';
cApplicationRootPermissionsDimension = cControlPrefix | 'tp_root_permissions';

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cErrorGuidsDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cErrorGuidsDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cErrorGuidsDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cErrorGuidsDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cErrorMeasuresDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cErrorMeasuresDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cErrorMeasuresDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cErrorMeasuresDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, cErrorCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, cErrorCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cErrorCube,vDetail,1);
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
	CellPutS('Read', sCubeSecurityCube, cErrorCube, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, cCentralApplicationStateCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, cCentralApplicationStateCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cCentralApplicationStateCube,vDetail,1);
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
	CellPutS('Read', sCubeSecurityCube, cCentralApplicationStateCube, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, vActionTIDimension, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, vActionTIDimension, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vActionTIDimension,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, vActionTIDimension, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, vActionTypeDimension, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, vActionTypeDimension, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vActionTypeDimension,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, vActionTypeDimension, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, vWorkflowActionTICube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube,vWorkflowActionTICube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vWorkflowActionTICube,vDetail,1);
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
	CellPutS('Read', sCubeSecurityCube, vWorkflowActionTICube, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, vActionTIErrorDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, vActionTIErrorDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vActionTIErrorDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, vActionTIErrorDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, vActionTIErrorAttrDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, vActionTIErrorAttrDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vActionTIErrorAttrDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, vActionTIErrorAttrDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, vActionTIErrorAttrCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, vActionTIErrorAttrCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(vActionTIErrorAttrCube,vDetail,1);
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
	CellPutS('Read', sCubeSecurityCube, vActionTIErrorAttrCube, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, cApplicationRootPermissionsCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, cApplicationRootPermissionsCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationRootPermissionsCube,vDetail,1);
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
	CellPutS('Read', sCubeSecurityCube, cApplicationRootPermissionsCube, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cApplicationRootPermissionsDimension, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cApplicationRootPermissionsDimension, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationRootPermissionsDimension,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cApplicationRootPermissionsDimension, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cTaskNavDimension, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cTaskNavDimension, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cTaskNavDimension,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cTaskNavDimension, cEveryoneGroup);
EndIf;

currentMaintenanceValue = ATTRS(cConfigDim, cServerMaintenanceRunning, 'StringValue');
If(currentMaintenanceValue @= '');
	AttrPutS('N', cConfigDim, cServerMaintenanceRunning, 'StringValue');
EndIf;

If (cAddedNodeInfoReviewer @= 'Y');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_set_state_reviewers_all',
		'pExecutionId', pExecutionId, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
EndIf;


cCurrentCellValue = CellGetS(sDimensionSecurityCube, '}Clients', cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, '}Clients', cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT('}Clients',vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, '}Clients', cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sDimensionSecurityCube, cApplicationUserPreferencesDim, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sDimensionSecurityCube, cApplicationUserPreferencesDim, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationUserPreferencesDim,vDetail,1);
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
	CellPutS('Read', sDimensionSecurityCube, cApplicationUserPreferencesDim, cEveryoneGroup);
EndIf;

cCurrentCellValue = CellGetS(sCubeSecurityCube, cApplicationUserPreferencesCube, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sCubeSecurityCube, cApplicationUserPreferencesCube, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cApplicationUserPreferencesCube,vDetail,1);
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
	CellPutS('Write', sCubeSecurityCube, cApplicationUserPreferencesCube, cEveryoneGroup);
EndIf;

cSetApplicationUserPreferenceProc = cControlPrefix | 'tp_set_app_user_preference';
cCurrentCellValue = CellGetS(sProcessSecurityCube, cSetApplicationUserPreferenceProc, cEveryoneGroup); 
If (cCurrentCellValue @= '' % cCurrentCellValue @= 'NONE');
	If (CellIsUpdateable(sProcessSecurityCube, cSetApplicationUserPreferenceProc, cEveryoneGroup) = 0);
		vDetail=INSRT(cEveryoneGroup,')',1);
		vDetail=INSRT(',',vDetail,1);
		vDetail=INSRT(cSetApplicationUserPreferenceProc,vDetail,1);
		vDetail=INSRT('(',vDetail,1);
		vDetail=INSRT(sProcessSecurityCube,vDetail,1);
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_SECURITY_NOT_UPDATEABLE',
		'pErrorDetails', vDetail,
		'pControl', pControl);
		ProcessError;
	EndIf;
	CellPutS('Read', sProcessSecurityCube, cSetApplicationUserPreferenceProc, cEveryoneGroup);
EndIf;






#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
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
