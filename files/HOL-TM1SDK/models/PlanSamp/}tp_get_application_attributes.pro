601,100
602,"}tp_get_application_attributes"
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



cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

#*** declare global variables
StringGlobalVariable('gApprovalDim');
StringGlobalVariable('gApprovalSubset');
StringGlobalVariable('gIsActive');
StringGlobalVariable('gStoreId');
StringGlobalVariable('gSecuritySet');
StringGlobalVariable('gVersionDimension');
StringGlobalVariable('gApprovalSubsetComplementMdx');

#* Check application

cApplicationsDim = cControlPrefix | 'tp_applications';
If (DIMIX(cApplicationsDim, pAppId) = 0);
	ProcessError;
EndIf;

#*** Get Application attributes

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
cVersionSlicesRead = 'VersionSlicesRead';
cVersionDimension = 'VersionDimension';
cApplicationType = 'ApplicationType';

gIsActive = ATTRS(cApplicationsDim, pAppId, cIsActiveAttr);
gStoreId = ATTRS(cApplicationsDim, pAppId, cStoreIdAttr);
gSecuritySet = ATTRS(cApplicationsDim, pAppId, cSecuritySetAttr);
gApprovalDim = ATTRS(cApplicationsDim, pAppId, cApprovalDimensionAttr);
gApprovalSubset = ATTRS(cApplicationsDim, pAppId, cApprovalSubsetAttr);
gVersionDimension = ATTRS(cApplicationsDim, pAppId, cVersionDimension);

#* Check approval dimension
If (gApprovalDim @= '');
		gApprovalSubset = '';
		gApprovalSubsetComplementMdx = '';
Else;

	If (gApprovalSubset @= '');
		ProcessError;
	EndIf;

	If (DimensionExists(gApprovalDim) = 0);
		ProcessError;
	EndIf;

	#* Check approval subset
	
	If (SubsetExists(gApprovalDim, gApprovalSubset) <> 0);

		cApprovalSubsetSize = SubsetGetSize(gApprovalDim, gApprovalSubset);

		#* Subset Complement
		gApprovalSubsetComplementMdx = '';
		If (DIMSIZ(gApprovalDim) > cApprovalSubsetSize);
			If (cApprovalSubsetSize = 0);
				ProcessError;
			ElseIf (cApprovalSubsetSize = 1);
				vNode = SubsetGetElementName(gApprovalDim, gApprovalSubset, 1);
				vMDX = 'EXCEPT([' | gApprovalDim | '].MEMBERS, {[' | gApprovalDim | '].[' | vNode | ']})';
				gApprovalSubsetComplementMdx = vMDX;
			Else;
				If (CubeExists(gApprovalDim) = 0);
					vMDX = 'EXCEPT([' | gApprovalDim | '].MEMBERS, TM1SubsetToSet([' | gApprovalDim | '], "' | gApprovalSubset | '"))';
				Else;
					vMDX = 'EXCEPT([' | gApprovalDim | '].MEMBERS, TM1SubsetToSet([' | gApprovalDim | '].[' | gApprovalDim | '], "' | gApprovalSubset | '"))';
				EndIf;
				gApprovalSubsetComplementMdx = vMDX;
			EndIf;
		EndIf;
	Else;
		gApprovalSubset = '';
		gApprovalSubsetComplementMdx = '';
	EndIf;
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
