601,100
602,"}tp_application_remove"
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
pAppId,"MyApp"
pControl,"N"
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
572,243
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

#***
cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cIsActive =ATTRS('}tp_applications', pAppId, 'IsActive');
cShadowApprovalDim =ATTRS('}tp_applications', pAppId, 'ApprovalShadowDimension');
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
cSecurityMethod = ATTRS('}tp_applications', pAppId, 'SecurityMethod');

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cIsActive,cShadowApprovalDim,cVersionDim);
EndIf;


#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pAppId, pControl);
EndIf;

cApplicationsDim = cControlPrefix | 'tp_applications';
cIntermediateAppDim = '}tp_intermediate_security_applications';
If (DIMIX(cApplicationsDim, pAppId) <> 0);

	#***
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Release all data reservations', pAppId);
	EndIf;
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_release_all', 'pExecutionId', pExecutionId, 
			'pAppId', pAppId, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	#***Remove all persisted views for this application
	vReturnValue = ExecuteProcess('}tp_reset_views',
		'pExecutionId', pExecutionId, 'pAppId', pAppId);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
		
	#***
	If (cApprovalDim @<> '');

		cPermissionCube = cControlPrefix | 'tp_application_permission}' | pAppId;
		cCellSecurityCube = '}CellSecurity_' | cPermissionCube;
	
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Destroy permissions cubes');
		EndIf;
	
		CubeDestroy(cPermissionCube);
		CubeDestroy(cCellSecurityCube);
	
		cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
		CubeDestroy(cStateCube);

		#***
		cApprovalElementSecurityCube = '}ElementSecurity_' | cShadowApprovalDim;
		CubeDestroy(cApprovalElementSecurityCube);

		IF (cSecurityMethod @= 'ELEMENT_SECURITY');
			cElementSecurityCubeOnApproval = '}ElementSecurity_' | cApprovalDim;
			CubeDestroy(cElementSecurityCubeOnApproval);
		Endif;

		#***Remove Shadow approval dimension
		DimensionDestroy(cShadowApprovalDim);

		cSecurityCube = cControlPrefix | 'tp_application_security}' | pAppId;
		CubeDestroy(cSecurityCube);
	
		cSecurityUpdateCube = cControlPrefix | 'tp_application_security_update}' | pAppId;
		CubeDestroy(cSecurityUpdateCube);

		#***Remove task navigation cube
		cTaskNavigationCube = '}tp_task_navigations}' | pAppId;
		CubeDestroy(cTaskNavigationCube);

		#***Remove task navigation dimension
		cTaskNavigationDim = '}tp_task_navigation_dims}' | pAppId;
		DimensionDestroy(cTaskNavigationDim);

		#Finally, remove element security cube, and IM element security cube  for an approval dimension 
		#if no other applications are using the same approval dimension
		vTotalApplications = DIMSIZ(cApplicationsDim);
		vDeleteElementSecurity = 'Y';
		looper =1;
		While (looper <= vTotalApplications);
			vOtherAppId = DIMNM(cApplicationsDim, looper);
			IF (vOtherAppId @<> pAppId);
				vOtherAppApprovalDim =ATTRS('}tp_applications', vOtherAppId,  'ApprovalDimension');
				IF (vOtherAppApprovalDim @= cApprovalDim);
					vDeleteElementSecurity = 'N';
					looper = vTotalApplications;
				Endif;

			Endif;
			looper = looper +1;
		End;

		IF (vDeleteElementSecurity @= 'Y');
			vElementSecurityOnApprovalDim = '}ElementSecurity_' | cApprovalDim;
			IF (CubeExists(vElementSecurityOnApprovalDim)>0);
				CubeDestroy(vElementSecurityOnApprovalDim);
			Endif;
			vIMElementSecurityOnApprovalDim = '}tp_intermediate_ElementSecurity}' | cApprovalDim;
			IF (CubeExists(vIMElementSecurityOnApprovalDim)>0);
				CubeDestroy(vIMElementSecurityOnApprovalDim);
			Endif;
		Endif;

	EndIf;

	#***Remove application related cubes
	cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
	
	totalCubes = DIMSIZ('}Cubes');
	indexCube = totalCubes;
	
	While (indexCube >= 1);
		cCubeName = DIMNM('}Cubes', indexCube);
	
		cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);

		IF (cIsAppCube @= 'A' % (cIsAppCube @<> '' & cApprovalDim @= ''));
			vReturnValue = ExecuteProcess('}tp_deploy_app_cubes_cleanup', 'pExecutionId', pExecutionId,'pAppId', pAppId, 'pCubeName', cCubeName);
			If (vReturnValue <> ProcessExitNormal());
				ProcessError;
			EndIf;
		Endif;
		
		indexCube = indexCube - 1;
	End;

	#***
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Remove application node: ' | pAppId);
	EndIf;

	DimensionElementDelete(cApplicationsDim, pAppId);
	DimensionElementDelete(cIntermediateAppDim, pAppId);

	#*** Remove sandboxes associated with the application
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_delete_sandboxes',
		'pExecutionId', pExecutionId, 'pAppId', pAppId, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	#Remove all blb files created by this applications
	vBlbFile = 'tp_AdminBkup_' | pAppId | '.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_SecurityBkup_' | pAppId | '.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_ModelBkup_' | pAppId |  '.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = '}tp_tasks}' | pAppId | '_weighted_struct.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_app_approval_hierarchy}' | pAppId | '.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_app_full_security}' | pAppId | '.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_app_full_security}' | pAppId | '_alias.blb';
	AsciiDelete(vBlbFile);
	vBlbFile = 'tp_app_security}' | pAppId | '.blb';
	AsciiDelete(vBlbFile);

	#**remove control subset filter
	#vDimensions = '}Dimensions';
	#vTotalDimensions = DIMSIZ(vDimensions);
	#looper = vTotalDimensions;
	#
	#While (looper >= 1);
	#	vDimension = DIMNM(vDimensions, looper);
	#	IF (SUBST(vDimension, 1,1) @<> '}');
	#		vSubset = 'tp_' | pAppId;
	#		IF (SubsetExists(vDimension, vSubset) >0);
	#			SubsetDestroy(vDimension, vSubset);
	#		Endif;
	#	Endif;
	#	looper = looper -1;
	#End;
Else;

	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Application does not exist: ' | pAppId);
	EndIf;

EndIf;

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
