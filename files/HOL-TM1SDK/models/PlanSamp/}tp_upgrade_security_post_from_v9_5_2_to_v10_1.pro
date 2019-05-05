601,100
602,"}tp_upgrade_security_post_from_v9_5_2_to_v10_1"
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
pCubeInfo
pUpgrade
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
pCubeInfo,"None"
pUpgrade,"N"
pControl,"Y"
637,5
pExecutionId,""
pAppId,""
pCubeInfo,""
pUpgrade,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,324


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

cApprovalDIM = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalDimension');
cApprovalSubset = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'ApprovalSubset');
cAppActive = ATTRS(cControlPrefix | 'tp_applications', pAppId, 'IsActive'); 


cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
cTemporaryCubesDimension = cControlPrefix | 'tp_temp_app_cubes_'|pAppId;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set flag in application_cubes pAppId=' | pAppId | ' pCubeInfo=' | pCubeInfo );
EndIf;

If (DimensionExists(cTemporaryCubesDimension) = 1);
	DimensionDestroy(cTemporaryCubesDimension);
EndIf;

DimensionCreate(cTemporaryCubesDimension);

# parse application cube string and set values in a temporary dimension 
cubeSeparater = '*';
vPosCube = 0;
vStringToScan = pCubeInfo;
vPosCube = SCAN(cubeSeparater, vStringToScan);
vFirstElement = 1;


While (vPosCube >0);
	vCubeName = SUBST(vStringToScan, 1, vPosCube-1);
	vFlagCube = SUBST(vStringToScan, vPosCube+1, 1);
	
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set flag in application_cubes pAppId=' | pAppId | ' CubeName=' | vCubeName | ' Flag=' | vFlagCube);
	EndIf;
	
	If (vFlagCube @= 'A' % cApprovalDIM @= '');
		DimensionElementInsert(cTemporaryCubesDimension, '', vCubeName, 'S');
	EndIf;
	
	vStringToScan = SUBST(vStringToScan, vPosCube +3, LONG(vStringToScan)-vPosCube);
	vPosCube = SCAN(cubeSeparater, vStringToScan);
End;



If (cGenerateLog @= 'Y');
	vNumCubes = DIMSIZ(cTemporaryCubesDimension);
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The temporary cubes dimension ' | cTemporaryCubesDimension | ' has ' | STR(vNumCubes, 6, 0)  | ' members');
	vTempCubesIdx = 1;
	While (vTempCubesIdx <= vNumCubes);
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '---------------------------------------');
		vThisCubeName = DIMNM(cTemporaryCubesDimension, vTempCubesIdx);
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), '-------' | vThisCubeName | '-------------');
		vTempCubesIdx = vTempCubesIdx + 1;
	End;
EndIf;


totalCubes = DIMSIZ('}Cubes');
indexCube = 0;
cCubePropertiesCube = '}CubeProperties';
cCentralApplicationStateCube = cControlPrefix | 'tp_central_application_state';
cApplicationStateCube = cControlPrefix | 'tp_application_state}'|pAppId;

If (cGenerateLog @= 'Y');
	cLogCubeText = 'Reserve cube number cubes to check' | NumberToString(totalCubes);
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
EndIf;

vAppWasAlreadyDeployed = 0;
#clear existing cube flags in case this is a redeployment
While (indexCube < totalCubes);
	cCubeName = DIMNM('}Cubes', indexCube+1);

	If (cGenerateLog @= 'Y');
		cLogCubeText = 'Getting Check Reserve cube flag ' | cCubeName;
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
	EndIf;

	cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);

	If (cGenerateLog @= 'Y');
		cLogCubeText = 'Reserve flag=' | cIsAppCube;
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
	EndIf;

	If (cIsAppCube @= 'A' % (cApprovalDIM @= '' & cIsAppCube @<> ''));
		vAppWasAlreadyDeployed = 1;
		If (DIMIX(cTemporaryCubesDimension, cCubeName) < 1);
			If (cGenerateLog @= 'Y');
				cLogCubeText = 'Cube '|cCubeName|' was used by this application but is no longer';
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
				cLogCubeText = 'Clear data reservations for cube '|cCubeName;
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
				cLogCubeText = 'Clear locks for cube '|cCubeName;
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
			EndIf;
			
			#remove security overlay cube
			vSecuirtyOverlayCube = '}SecurityOverlayGlobal_' | cCubeName;				
			IF (CubeExists(vSecuirtyOverlayCube) = 1);
				SecurityOverlayDestroyGlobalDefault(cCubeName);
			Endif;

			# clear the require reservation lag
			CellPutS('', cCubePropertiesCube, cCubeName, 'DATARESERVATIONMODE');
			If (cGenerateLog @= 'Y');
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Data Reservation is no longer required on cube ' | cCubeName);
			EndIf;
			
			#remove any existing data reservations
			cCubeAddress = '';
			addConcatSymbol = 0;
			dimensionIndex = 1;
			While (dimensionIndex > 0 ); 
				cCubeDimensionName = TABDIM(cCubeName, dimensionIndex);
				If (cCubeDimensionName @= '');
					dimensionIndex = -1;
				Else;
					If (addConcatSymbol > 0);
						cCubeAddress = cCubeAddress | '|';
					Else;
						addConcatSymbol = 1;
					EndIf; 
				EndIf;
				
				If (cGenerateLog @= 'Y');
					cLogCubeText = 'Reserve address = ' | cCubeAddress;
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
				EndIf;
				dimensionIndex = dimensionIndex + 1;
			End;
			If (cGenerateLog @= 'Y');
				cLogCubeText = 'Calling CubeDataReservationReleaseAll(' | cCubeName | ',' | cCubeAddress;
				TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
			EndIf;
			CubeDataReservationReleaseAll(cCubeName, '', cCubeAddress);
			## clear the flag
			CellPutS('', cApplicationCubesCube, pAppId, cCubeName);
		EndIf;
		
	EndIf;
	
	
	indexCube = indexCube + 1;
End;

# parse application cube string and set values in application_cubes cube
cubeSeparater = '*';

cDataReservationType = '';
If (cAppActive @= 'Y');
	cDataReservationType = 'REQUIREDSHARED';
	If (cApprovalDIM @= '');
		cDataReservationType = 'ALLOWED';
	EndIf;
EndIf;

vPosCube = 0;
vStringToScan = pCubeInfo;
vPosCube = SCAN(cubeSeparater, vStringToScan);

While (vPosCube >0);
	vCubeName = SUBST(vStringToScan, 1, vPosCube-1);
	vFlagCube = SUBST(vStringToScan, vPosCube+1, 1);
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Set flag in application_cubes pAppId=' | pAppId | ' CubeName=' | vCubeName | ' Flag=' | vFlagCube);
	EndIf;

	vOldFlagValue = CellGetS(cApplicationCubesCube, pAppId, vCubeName); 
	CellPutS(vFlagCube, cApplicationCubesCube, pAppId, vCubeName);
	
	If (cApprovalDIM @= '' % vFlagCube @= 'A');
		# if this cube uses the approval hierarchy then require reservation to edit
		CellPutS(cDataReservationType, cCubePropertiesCube, vCubeName, 'DATARESERVATIONMODE');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Data Reservation is now ' | cDataReservationType | ' on cube ' | vCubeName);
		EndIf;
		#Add data reservations if this is a new cube there are currently owners of nodes in this application
		If ((vOldFlagValue @<> vFlagCube & vAppWasAlreadyDeployed = 1) % pUpgrade @= 'Y');
			If (cApprovalDIM @= '');
				# If the Central app has an existing owner make sure any new cubes get a data reservation.
				cState = CellGetS(cCentralApplicationStateCube, pAppId, 'State');
				If (cState @= '2');
					cCurrentOwner = CellGetS(cCentralApplicationStateCube, pAppId, 'CurrentOwnerId');
					If (cCurrentOwner @<> '');
						vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
								'pAppId', pAppId, 'pNode', '', 'pApprovalDim', '', 'pReserve', 'Y', 'pUser', cCurrentOwner, 'pControl', pControl);
						If (vReturnValue <> ProcessExitNormal());
							ProcessError;
						EndIf;
					EndIf;
				EndIf;
			Else;
				#***Security overlay cube
				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check for security overly cube for ' | vCubeName);
				EndIf;

				vSecuirtyOverlayCube = '}SecurityOverlayGlobal_' | vCubeName;				
				IF (CubeExists(vSecuirtyOverlayCube) = 0);
					vDimIndex =1;
					vDimension = TABDIM(vCubeName, vDimIndex);
					vTokenString = '';
					vFoundApproval = 'F';
					While (vDimension @<> '');
						IF (vDimension @= cApprovalDim);
							vSingleToken = '1';
							vFoundApproval = 'T';
						Else;
							vSingleToken = '0';
						EndIf;
						IF (vDimIndex > 1);
							vSingleToken = ':' | vSingleToken;
						Endif;
						vTokenString = vTokenString | vSingleToken;
						vDimIndex = vDimIndex +1;
						vDimension = TABDIM(vCubeName, vDimIndex);
					End;
					IF (vFoundApproval @= 'T');
						SecurityOverlayCreateGlobalDefault(vCubeName, vTokenString);
					Endif;

				Endif;

				If (cGenerateLog @= 'Y');
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Check for existing ownership for cube ' | vCubeName);
				EndIf;
				# If there are any existing node owners make sure any new cubes get a data reservation. 
				#Also we need to update the newly created security overlay cube
				If (CubeExists(cApplicationStateCube) = 1);
					cApprovalSubsetSize = SubsetGetSize(cApprovalDim,cApprovalSubset );
					vIndex = 1;
					While (vIndex <= cApprovalSubsetSize);
						vApprovalNode = SubsetGetElementName(cApprovalDIM, cApprovalSubset, vIndex);
						If (DTYPE(cApprovalDIM, vApprovalNode) @<> 'C');
							cState = CellGetS(cApplicationStateCube, vApprovalNode, 'State');
							If (cGenerateLog @= 'Y');
								TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Node state for node ' | vApprovalNode | ' in cube ' | vCubeName | ' is ' | cState);
							EndIf;
							If (cState @= '2');
								cCurrentOwner = CellGetS(cApplicationStateCube, vApprovalNode, 'CurrentOwnerId');
								cOwnershipNode = CellGetS(cApplicationStateCube, vApprovalNode, 'TakeOwnershipNode');
								If (cCurrentOwner @<> '' & cOwnershipNode @<> '');
									vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_slice', 'pExecutionId', pExecutionId, 
											'pAppId', pAppId, 'pNode', cOwnershipNode, 'pApprovalDim', cApprovalDIM, 'pReserve', 'Y', 'pUser', cCurrentOwner, 'pControl', pControl);
									If (vReturnValue <> ProcessExitNormal());
										ProcessError;
									EndIf;
								EndIf;
							ElseIf(cState @= '4');
								SecurityOverlayGlobalLockNode(1,vCubeName,vApprovalNode);
							EndIf;
						EndIf;
						vIndex = vIndex + 1;
					End;
				EndIf;
			EndIf;
		EndIf;
	EndIf;

	vStringToScan = SUBST(vStringToScan, vPosCube +3, LONG(vStringToScan)-vPosCube);
	vPosCube = SCAN(cubeSeparater, vStringToScan);
End;
#***

If (DimensionExists(cTemporaryCubesDimension) = 1);
	DimensionDestroy(cTemporaryCubesDimension);
EndIf;


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
