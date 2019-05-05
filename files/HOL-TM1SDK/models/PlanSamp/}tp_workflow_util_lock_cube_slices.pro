601,100
602,"}tp_workflow_util_lock_cube_slices"
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
pAppId
pCube
pApprovalDim
pNode
pLock
pControlDim
pControlWritableSlices
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
pAppId,"MyApp"
pCube,"NA"
pApprovalDim,"NA"
pNode,"NA"
pLock,"Y"
pControlDim,"NA"
pControlWritableSlices,"NA"
637,8
pExecutionId,""
pAppId,""
pCube,""
pApprovalDim,""
pNode,""
pLock,""
pControlDim,""
pControlWritableSlices,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,167
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
cTaskNavDimensions = '}tp_task_navigation_dims}' | pAppId;
cTaskNavigationCube = '}tp_task_navigations}' | pAppId;

#***
IF (pControlDim @='');
cVersionDim = ATTRS('}tp_applications', pAppId, 'VersionDimension');
Else;
cVersionDim = pControlDim;
Endif;

IF (pControlWritableSlices @='');
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');
Else;
cVersionSlicesWrite = pControlWritableSlices;
Endif;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cVersionDim,cVersionSlicesWrite );
EndIf;

#*** Log Parameters

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId,  pAppId, pCube, pApprovalDim, pNode, pLock);
EndIf;


#***Lock slices

cOverlayDim = '}SecurityOverlay';		
versionSeparater = '|';
vPosVersion = 0;
vStringToScan = cVersionSlicesWrite;
IF (cVersionSlicesWrite @<> '');
	vPosVersion = SCAN(versionSeparater, vStringToScan);
Else;
	vPosVersion = 1;
Endif;

While (vPosVersion >0);
	vVersionSlice  = SUBST(vStringToScan, 1, vPosVersion-1);
	vStringToScan = SUBST(vStringToScan, vPosVersion +1, LONG(vStringToScan)-vPosVersion);
	vPosVersion = SCAN(versionSeparater, vStringToScan);
	cCubeAddress = '';
	addConcatSymbol = 0;
	cOverlayCube = '}SecurityOverlayGlobal_' | pCube;

	dimensionIndex = 1;
	While (dimensionIndex > 0 ); 
		cCubeDimensionName = TABDIM(cOverlayCube, dimensionIndex);
		If (cCubeDimensionName @= '');
			dimensionIndex = -1;
		Else;
			If (addConcatSymbol > 0);
				IF (cCubeDimensionName @<> cOverlayDim);
					cCubeAddress = cCubeAddress | '|';
				Endif;

			Else;
				addConcatSymbol = 1;
			EndIf; 

			IF (cCubeDimensionName @=cVersionDim & vVersionSlice @<>'');
				IF (DIMIX(cVersionDim, vVersionSlice)=0);
					vReturnValue = ExecuteProcess('}tp_error_update_error_cube',
						'pGuid', pExecutionId,
						'pProcess', cTM1Process,
						'pErrorCode', 'TI_WRITABLE_SLICE_NOT_EXISTS',
						'pErrorDetails', cVersionDim  | '.' | vVersionSlice | ', ' |  pAppId,
						'pControl', 'Y');
	
					ProcessError;
				Endif;
				cCubeAddress = cCubeAddress | vVersionSlice; 
			Endif;

			vTotalNavDimensions = DIMSIZ(cTaskNavDimensions);
			vNavLooper = 1;
			While (vNavLooper <= vTotalNavDimensions);
				vNavDimension = DIMNM(cTaskNavDimensions, vNavLooper);
				IF (cCubeDimensionName @= vNavDimension);
					vNavElem = CellGetS(cTaskNavigationCube, pNode, vNavDimension, 'NavigationElement');
					IF (vNavElem @<>'');
						cCubeAddress = cCubeAddress | vNavElem;
					Endif;
				Endif;

				vNavLooper = vNavLooper +1;
			End;

			#IF (cCubeDimensionName @= pApprovalDim & pNode @<> '');
			#	cCubeAddress = cCubeAddress | pNode;
			#Endif;
		EndIf;
			
		If (cGenerateLog @= 'Y');
			cLogCubeText = 'Lock address = ' | cCubeAddress;
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
		EndIf;

		dimensionIndex = dimensionIndex + 1;
	End;

	IF (CubeExists(cOverlayCube)>0);
		IF (pLock @= 'Y');
			SecurityOverlayGlobalLockNode(1,pCube,cCubeAddress);
		Else;
			SecurityOverlayGlobalLockNode(0,pCube,cCubeAddress);
		Endif;
			
	Endif;

	If (cGenerateLog @= 'Y');
		cLogCubeText = 'lock cube: ' | pCube | ' on address: ' | cCubeAddress;
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
	EndIf;
end;

#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
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
