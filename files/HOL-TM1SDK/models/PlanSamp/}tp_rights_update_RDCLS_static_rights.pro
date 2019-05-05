601,100
602,"}tp_rights_update_RDCLS_static_rights"
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
560,7
pExecutionId
pAppId
pCube
pApprovalDim
pUpdateSubset
pVersionDim
pGroupsDim
561,7
2
2
2
2
2
2
2
590,7
pExecutionId,"None"
pAppId,"None"
pCube,"None"
pApprovalDim,"None"
pUpdateSubset,"None"
pVersionDim,"None"
pGroupsDim,"None"
637,7
pExecutionId,""
pAppId,""
pCube,""
pApprovalDim,""
pUpdateSubset,""
pVersionDim,""
pGroupsDim,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,107


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

#****String Caching Workaround
#This TI can be removed once String cache is implemented on TM1

#****

cIMRDCLSCube = '}tp_intermediate_RDCLS}' | pCube;
cGroupsDim = pGroupsDim;
cAllApplications = 'all_applications';

versionIndex = 0;
approvalIndex = 0;
dimensionIndex = 1;
While (dimensionIndex > 0 ); 
	cCubeDimensionName = TABDIM(pCube, dimensionIndex);
	If (cCubeDimensionName @= '');
		dimensionIndex = -1;
	Else;
		IF (cCubeDimensionName @=pVersionDim);
			versionIndex = dimensionIndex;
		Endif;
				
		IF (cCubeDimensionName @= pApprovalDim );
			approvalIndex =dimensionIndex ;
		Endif;

	EndIf;

	dimensionIndex = dimensionIndex + 1;
End;

IF (versionIndex < approvalIndex);
	versionFirst = 'Y';
Endif;

#*Update RD cell security cubes
IF (CubeExists(cIMRDCLSCube) >0);
vTotalGroups = DIMSIZ(cGroupsDim);
vGroupLooper = 1;
While (vGroupLooper <= vTotalGroups);
	vGroup = DIMNM(cGroupsDim, vGroupLooper);

	vTotalNodes = SubsetGetSize(pApprovalDim, pUpdateSubset);
	vNodeLooper = 1;
	While (vNodeLooper <= vTotalNodes);
		vApprovalNode = SubsetGetElementName(pApprovalDim, pUpdateSubset, vNodeLooper);
		vFinalCellSecurity ='NONE';

		IF (versionIndex >0);
			vTotalVersions = DIMSIZ(pVersionDim);
			vVersionLooper = 1;
			While (vVersionLooper <= vTotalVersions);
				vVersion = DIMNM(pVersionDim, vVersionLooper);
				IF (approvalIndex >0)	;	
					IF (versionFirst @= 'Y');
						vFinalCellSecurity=CellGetS(cIMRDCLSCube, vVersion, vApprovalNode, vGroup,cAllApplications,'Rights' );
						vCurrentCellSecurity = CellGetS(cIMRDCLSCube, vVersion, vApprovalNode,vGroup,cAllApplications, 'StaticRights');
						IF (vFinalCellSecurity @<> vCurrentCellSecurity);
							CellPutS(vFinalCellSecurity, cIMRDCLSCube, vVersion, vApprovalNode,vGroup,cAllApplications, 'StaticRights');
						Endif;
						
					Else;
						vFinalCellSecurity=CellGetS(cIMRDCLSCube, vApprovalNode, vVersion,vGroup,cAllApplications, 'Rights' );
						vCurrentCellSecurity = CellGetS(cIMRDCLSCube, vApprovalNode, vVersion,vGroup,cAllApplications, 'StaticRights');
						IF (vFinalCellSecurity @<> vCurrentCellSecurity);
							CellPutS(vFinalCellSecurity, cIMRDCLSCube, vApprovalNode, vVersion,vGroup,cAllApplications,'StaticRights');
						Endif;
					Endif;
				Else;
					vFinalCellSecurity=CellGetS(cIMRDCLSCube,vVersion, vGroup,cAllApplications, 'Rights' );
					vCurrentCellSecurity = CellGetS(cIMRDCLSCube,vVersion, vGroup,cAllApplications,'StaticRights' );
					IF (vFinalCellSecurity @<>vCurrentCellSecurity);
						CellPutS(vFinalCellSecurity, cIMRDCLSCube,vVersion, vGroup,cAllApplications, 'StaticRights');
					Endif;
				Endif;
				vVersionLooper = vVersionLooper +1;
			End;

		ElseIf (versionIndex = 0 & approvalIndex >0);
			vFinalCellSecurity=CellGetS(cIMRDCLSCube,vApprovalNode, vGroup,cAllApplications, 'Rights' );
			vCurrentCellSecurity = CellGetS(cIMRDCLSCube,vApprovalNode, vGroup,cAllApplications, 'StaticRights');
			IF (vFinalCellSecurity @<>vCurrentCellSecurity);
				CellPutS(vFinalCellSecurity, cIMRDCLSCube,vApprovalNode, vGroup,cAllApplications, 'StaticRights');
			Endif;
		Endif;
		vNodeLooper = vNodeLooper  +1;		
	End;
	vGroupLooper = vGroupLooper +1;
End;

Endif;

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
