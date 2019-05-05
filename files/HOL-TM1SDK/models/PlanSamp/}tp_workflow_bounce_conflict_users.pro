601,100
602,"}tp_workflow_bounce_conflict_users"
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
560,9
pExecutionId
pAppId
pNode
pApprovalDim
pTime
pNewOwnerID
pCheckBouncingOnly
pBouncingMode
pControl
561,9
2
2
2
2
2
2
2
2
2
590,9
pExecutionId,"None"
pAppId,"MyApp"
pNode,"NA"
pApprovalDim,"NA"
pTime,"0"
pNewOwnerID,"None"
pCheckBouncingOnly,"N"
pBouncingMode,"NEVER"
pControl,"N"
637,9
pExecutionId,""
pAppId,""
pNode,""
pApprovalDim,""
pTime,""
pNewOwnerID,""
pCheckBouncingOnly,""
pBouncingMode,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,318
################################################################
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
cVersionSlicesWrite =ATTRS('}tp_applications', pAppId, 'VersionSlicesWrite');

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cIsActive,cShadowApprovalDim,cVersionDim,cVersionSlicesWrite );
EndIf;

pApprovalDim = cApprovalDim;

#***

cConfigDim = cControlPrefix | 'tp_config';
If (DimensionExists(cConfigDim) = 1);
	cGenerateLog = ATTRS(cControlPrefix | 'tp_config', 'Generate TI Log', 'String Value');
Else;
	cGenerateLog = 'N';
EndIf;

If (cGenerateLog @= 'Y');
	cLogCubeText = 'parameters: pAppId=' | pAppId | '|pNode=' | pNode | '|pApprovalDim=' | pApprovalDim | '|pTime=' | pTime;
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
EndIf;

#***
cStateCube = cControlPrefix | 'tp_application_state}' | pAppId;
cTakeOwnershipNode = 'TakeOwnershipNode';
vOwnershipNodeOnCurrentNode = CellGetS(cStateCube, pNode, cTakeOwnershipNode);
#***

cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';
totalCubes = DIMSIZ('}Cubes');
indexCube = 1;

If (cGenerateLog @= 'Y');
	cLogCubeText = 'number cubes to check=' | NumberToString(totalCubes);
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
EndIf;

While (indexCube <= totalCubes);
	cCubeName = DIMNM('}Cubes', indexCube);

	If (cGenerateLog @= 'Y');
		cLogCubeText = 'Getting Check Reserve cube flag ' | cCubeName;
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
	EndIf;

	cIsAppCube = CellGetS(cApplicationCubesCube, pAppId, cCubeName);

	If (cGenerateLog @= 'Y');
		cLogCubeText = 'Reserve cube flag ' | cCubeName | ' is ' | cIsAppCube;
		TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
	EndIf;

	If (cIsAppCube @= 'A' & pNewOwnerID @<>'' & DIMIX('}Clients', pNewOwnerID) >0 );

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

					IF (cCubeDimensionName @=cVersionDim & vVersionSlice @<> '');
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
				
					IF (pApprovalDim @<> '');
						IF (cCubeDimensionName @= pApprovalDim & pNode @<> '');
							IF (vOwnershipNodeOnCurrentNode @= '');
								vOwnershipNodeOnCurrentNode = pNode;
							Endif;
							cCubeAddress = cCubeAddress | vOwnershipNodeOnCurrentNode;
							vApprovalDimIndex = dimensionIndex;
						Endif;
			
					Endif;

				EndIf;
			
				If (cGenerateLog @= 'Y');
					cLogCubeText = 'Reserve address = ' | cCubeAddress;
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
				EndIf;
				dimensionIndex = dimensionIndex + 1;
			End;

			## get conflict reservations
			## we need two rounds, the first round get all conflict DRs from other users and bounce
			## the second round get overlapping DRs from the same user and bounce
			vRound = 1;
			While (vRound <=2);
				vIndex = 1;
				vDelim = '|';
				If (vRound = 1);
					vConflictAddress =CubeDataReservationGetConflicts(vIndex, cCubeName, pNewOwnerID, cCubeAddress, vDelim) ;
				Else;
					vConflictAddress = CubeDataReservationGet(vIndex, cCubeName, pNewOwnerID,vDelim) ;
				EndIf;

				If (vConflictAddress @= '' & cGenerateLog @= 'Y');
					cLogCubeText = 'There are no conflict reservations on cube ' | cCubeName;
					TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
				EndIf;

				WHILE (vConflictAddress @<> '' );
					If (cGenerateLog @= 'Y');
						cLogCubeText = 'Conflict reservation on cube ' | cCubeName | ' for - ' | vConflictAddress;
						TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), cLogCubeText);
					EndIf;

					#Get conflict DR time
					vPos = SCAN(vDelim, vConflictAddress);
					vLength=LONG(vConflictAddress);
					vConflictDRTime = SUBST(vConflictAddress, 1, vPos-1);

					#Get conflict DR user
					vConflictAddress=SUBST(vConflictAddress, vPos+1, vLength-vPos);
					vPos = SCAN(vDelim, vConflictAddress);
					vLength=LONG(vConflictAddress);
					vConflictUser = SUBST(vConflictAddress, 1, vPos-1);

					#Get conflict address
					vFinalConflictAddress = SUBST(vConflictAddress, vPos+1, vLength-vPos);
					
					#
					If (vApprovalDimIndex>0 & vConflictUser @<> '');
						#Step 1: Get conflict ownership node
						vParseAddress = vFinalConflictAddress;
						vParseDimIndex = 1;
						While (vParseDimIndex <> vApprovalDimIndex);
							vParsePos = SCAN(vDelim, vParseAddress);
							vParseAddress = SUBST(vParseAddress, vParsePos+1, LONG(vParseAddress)-vParsePos); 
							vParseDimIndex = vParseDimIndex +1;
						End;
						vParsePos = SCAN(vDelim, vParseAddress);
						IF (vParsePos >0);
							vConflictOwnershipNode = SUBST(vParseAddress, 1, vParsePos-1);
						Else;
							vConflictOwnershipNode  = vParseAddress;
						Endif;

						#Step 2:  Check overlapped leaf nodes between bouncer ownership node and conflict node ID
						IF (vConflictOwnershipNode @<> '');	
							vMDX = '{INTERSECT(TM1FILTERBYLEVEL({DESCENDANTS([' | cShadowApprovalDim | '].[' | vConflictOwnershipNode | ']) }, 0), 
								TM1FILTERBYLEVEL({DESCENDANTS([' | cShadowApprovalDim | '].[' | vOwnershipNodeOnCurrentNode | ']) }, 0)) }';

							vSubsetConflictLeafChildren = 'tp_conflictLeafChildren_' | pExecutionId;
							If (SubsetExists(cShadowApprovalDim, vSubsetConflictLeafChildren) <>0);
								SubsetDestroy(cShadowApprovalDim, vSubsetConflictLeafChildren);
							EndIf;
							SubsetCreateByMdx(vSubsetConflictLeafChildren, vMDX, cShadowApprovalDim);

							#Step 3: If both users have EDIT permission on one of leaf nodes, we need to bounce the conflict user
							vTotalConflictLeafNodes = SubsetGetSize(cShadowApprovalDim, vSubsetConflictLeafChildren);
							vHasConflict = 'F';
							vLooper = 1;
							While (vLooper <= vTotalConflictLeafNodes);
								vConflictLeafNode = SubsetGetElementName(cShadowApprovalDim, vSubsetConflictLeafChildren, vLooper);

								#Check conflict user privilege on the node
								StringGlobalVariable('gEdit');
								vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
									'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', vConflictLeafNode, 'pUser', vConflictUser, 'pControl', pControl);
								If (vReturnValue <> ProcessExitNormal());
									ProcessError;
								EndIf;
								vConflictUserRight = gEdit;

								StringGlobalVariable('gEdit');
								vReturnValue = ExecuteProcess(cControlPrefix | 'tp_get_user_permissions', 
									'pGuid', pExecutionId, 'pApplication', pAppId, 'pNode', vConflictLeafNode, 'pUser', pNewOwnerId, 'pControl', pControl);
								If (vReturnValue <> ProcessExitNormal());
									ProcessError;
								EndIf;
								vNewOwnerRight = gEdit;

								IF (vConflictUserRight @= 'T' & vNewOwnerRight @= 'T');
									vHasConflict = 'T';
									vLooper = vTotalConflictLeafNodes;
								Endif;

								vLooper = vLooper +1;

							End;

						Endif;

						#Bounce conflict user's revervation/ownership
						If (vHasConflict @= 'T');

							vDoBounce = 'N';
							IF (vRound = 1 );
								vDoBounce = 'Y';
							ElseIf (vRound =2 & ( ELISANC(cShadowApprovalDim, vConflictOwnershipNode, vOwnershipNodeOnCurrentNode) =1 
								% ELISANC(cShadowApprovalDim, vConflictOwnershipNode, vOwnershipNodeOnCurrentNode)  =1));
								#Don't bounce yourself if ownershipnodes are the same
								#Bounce yourself if ownership nodes are different, applies to rejecting a leaf node
								IF (vOwnershipNodeOnCurrentNode @<> vConflictOwnershipNode);
									vDoBounce = 'Y';
								Endif;
							Endif;

							IF (vDoBounce @='Y');
								vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_bounce_nodes', 'pExecutionId', pExecutionId,'pAppId', pAppId,
									'pOwnerIdToBounce',vConflictUser, 'pOwnershipNodeToBounce', vConflictOwnershipNode,'pSourceNode', pNode, 'pTime', pTime,
									'pCheckBouncingOnly', pCheckBouncingOnly, 'pBouncingMode', pBouncingMode, 'pParentTIUpdateStateCube','N', 'pControl', pControl);

								If (vReturnValue <> ProcessExitNormal());
									ProcessError;
								EndIf;	
		
							Endif;
						EndIf;
					Endif;

					vIndex = vIndex + 1;

					If (vRound = 1);
						vConflictAddress =CubeDataReservationGetConflicts(vIndex, cCubeName, pNewOwnerID, cCubeAddress, vDelim) ;
					Else;
						vConflictAddress = CubeDataReservationGet(vIndex, cCubeName, pNewOwnerID,vDelim) ;
					Endif;
					
				End;	
			
				vRound = vRound +1;
			End;
		End;
	EndIf;
 
	indexCube = indexCube + 1;
End;

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'The end has been reached.');
EndIf;

573,1

574,1

575,19
################################################################
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


If (SubsetExists(cShadowApprovalDim, vSubsetConflictLeafChildren) <>0);
	SubsetDestroy(cShadowApprovalDim, vSubsetConflictLeafChildren);
EndIf;

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
