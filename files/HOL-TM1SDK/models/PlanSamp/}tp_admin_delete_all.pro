601,100
602,"}tp_admin_delete_all"
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
pControl,"Y"
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
572,226


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

#Release all data reservation acquired for the application
#clear requires data reservation flag for  application cubes
#remove all control dimension filter subsets
cApplicationCubesCube = cControlPrefix | 'tp_application_cubes';

totalApplications = DIMSIZ(cControlPrefix | 'tp_applications');
indexApplication = 0;
While (indexApplication < totalApplications);
	cApplicationID = DIMNM(cControlPrefix | 'tp_applications', indexApplication+1);

	#**remove control subset filter
	vDimensions = '}Dimensions';
	vTotalDimensions = DIMSIZ(vDimensions);
	looper = vTotalDimensions;

	While (looper >= 1);
		vDimension = DIMNM(vDimensions, looper);
		IF (SUBST(vDimension, 1,1) @<> '}');
			vSubset = 'tp_' | cApplicationID;
			IF (SubsetExists(vDimension, vSubset) >0);
				SubsetDestroy(vDimension, vSubset);
			Endif;
		Endif;
		looper = looper -1;
	End;
	
	# remove existing reservations for the application
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_reserve_release_all', 'pExecutionId', pExecutionId, 
			'pAppId', cApplicationID, 'pControl', pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	cApprovalDIM = ATTRS(cControlPrefix | 'tp_applications', cApplicationID, 'ApprovalDimension');
	cCubePropertiesCube = '}CubeProperties';
	if (CubeExists(cApplicationCubesCube) <> 0);
		totalCubes = DIMSIZ('}Cubes');
		indexCube = 0;
		While (indexCube < totalCubes);
			cCubeName = DIMNM('}Cubes', indexCube+1);
		
			cIsAppCube = CellGetS(cApplicationCubesCube, cApplicationID, cCubeName);
		
			If ((cApprovalDIM @= '' & cIsAppCube @= 'Y') % cIsAppCube @= 'A');
				# clear the require reservation lag
				CellPutS('', cCubePropertiesCube, cCubeName, 'DATARESERVATIONMODE');
			EndIf;
			
			indexCube = indexCube + 1;
		End;
	EndIf;
	indexApplication = indexApplication+1;
End;
	
cCubesDim = '}Cubes';
cDimensionsDim = '}Dimensions';
cClientsDim = '}Clients';
cGroupsDim = '}Groups';

cCubesDimSize = DIMSIZ(cCubesDim);
cDimensionsDimSize = DIMSIZ(cDimensionsDim);
cClientsDimSize = DIMSIZ(cClientsDim);
cGroupsDimSize = DIMSIZ(cGroupsDim);

cTpPrefix = cControlPrefix | 'tp_';
cTpPrefixLength = LONG(cTpPrefix);
cCellSecurityPrefix = '}CellSecurity_';
cCellSecurityPrefixLength = LONG(cCellSecurityPrefix);

#*** Destroy TP cubes

cTpCubesDim = 'tptemp_cubes';
DimensionDestroy(cTpCubesDim);
DimensionCreate(cTpCubesDim);

vIndex = 1;
While (vIndex <= cCubesDimSize);
	vElement = DIMNM(cCubesDim, vIndex);
	vNamePrefix = SUBST(vElement, 1, cTpPrefixLength);

	If (cTpPrefix @= vNamePrefix);
		DimensionElementInsert(cTpCubesDim, '', vElement, 'S');
	EndIf;

	If (SUBST(vElement, 1, cCellSecurityPrefixLength + cTpPrefixLength) @= 
	    		(cCellSecurityPrefix | cTpPrefix));
		DimensionElementInsert(cTpCubesDim, '', vElement, 'S');
	EndIf;

	vIndex = vIndex + 1;
End;

cTpCubesDimSize = DIMSIZ(cTpCubesDim);
vIndex = 1;
While (vIndex <= cTpCubesDimSize);
	vElement = DIMNM(cTpCubesDim, vIndex);
	CubeDestroy(vElement);
	vIndex = vIndex + 1;
End;

DimensionDestroy(cTpCubesDim);

#*** Destroy TP dimensions

cTpDimensionsDim = 'tptemp_dimensions';
DimensionDestroy(cTpDimensionsDim);
DimensionCreate(cTpDimensionsDim);

cTpConfigDim = cControlPrefix | 'tp_config';
cTpSystemConfigDim = cControlPrefix | 'tp_system_config';

vIndex = 1;
While (vIndex <= cDimensionsDimSize);
	vElement = DIMNM(cDimensionsDim, vIndex);
	vNamePrefix = SUBST(vElement, 1, cTpPrefixLength);

	If (cTpPrefix @= vNamePrefix);

		If(vElement @<> cTpConfigDim & vElement @<> cTpSystemConfigDim);
			DimensionElementInsert(cTpDimensionsDim, '', vElement, 'S');
		EndIf;

	EndIf;

	vIndex = vIndex + 1;
End;

cTpDimensionsDimSize = DIMSIZ(cTpDimensionsDim);
vIndex = 1;
While (vIndex <= cTpDimensionsDimSize);
	vElement = DIMNM(cTpDimensionsDim, vIndex);
	DimensionDestroy(vElement);
	vIndex = vIndex + 1;
End;

DimensionDestroy(cTpDimensionsDim);

#*** Remove TP test users

cTpUsersDim = 'tptemp_users';
DimensionDestroy(cTpUsersDim);
DimensionCreate(cTpUsersDim);

vIndex = 1;
While (vIndex <= cClientsDimSize);
	vElement = DIMNM(cClientsDim, vIndex);
	vNamePrefix = SUBST(vElement, 1, cTpPrefixLength);
	
	If (cTpPrefix @= vNamePrefix);
		DimensionElementInsert(cTpUsersDim, '', vElement, 'S');
	EndIf;
	
	vIndex = vIndex + 1;
End;

cTpUsersDimSize = DIMSIZ(cTpUsersDim);
vIndex = 1;
While (vIndex <= cTpUsersDimSize);
	vElement = DIMNM(cTpUsersDim, vIndex);
	DeleteClient(vElement);
	vIndex = vIndex + 1;
End;

DimensionDestroy(cTpUsersDim);

#*** Remove TP groups

cTpGroupsDim = 'tptemp_groups';
DimensionDestroy(cTpGroupsDim);
DimensionCreate(cTpGroupsDim);

vIndex = 1;
While (vIndex <= cGroupsDimSize);
	vElement = DIMNM(cGroupsDim, vIndex);
	vNamePrefix = SUBST(vElement, 1, cTpPrefixLength);
	
	If (cTpPrefix @= vNamePrefix);
		DimensionElementInsert(cTpGroupsDim, '', vElement, 'S');
	EndIf;
	
	vIndex = vIndex + 1;
End;

cTpGroupsDimSize = DIMSIZ(cTpGroupsDim);
vIndex = 1;
While (vIndex <= cTpGroupsDimSize);
	vElement = DIMNM(cTpGroupsDim, vIndex);
	DeleteGroup(vElement);
	vIndex = vIndex + 1;
End;

DimensionDestroy(cTpGroupsDim);

CubeDestroy(cApplicationCubesCube);

# clean up tm1 distributed cubes
cPlanningControlCube = cControlPrefix | 'PlanningControl';
cApplicationNamesDim = cControlPrefix | 'ApplicationNames';

CubeDestroy(cPlanningControlCube);
DimensionDestroy(cApplicationNamesDim);


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
