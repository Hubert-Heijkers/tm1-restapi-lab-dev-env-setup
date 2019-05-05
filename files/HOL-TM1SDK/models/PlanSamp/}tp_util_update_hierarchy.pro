601,100
602,"}tp_util_update_hierarchy"
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
pDim
pSubset
pParent
pNode
pNodeType
pWeight
pAction
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
pDim,"NA"
pSubset,"NA"
pParent,"NA"
pNode,"NA"
pNodeType,"N"
pWeight,"1.0"
pAction,"ADD"
637,8
pExecutionId,""
pDim,""
pSubset,""
pParent,""
pNode,""
pNodeType,""
pWeight,""
pAction,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,174


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

#*** Check dimension

If (DimensionExists(pDim) = 0);
	ProcessError;
EndIf;

#*** Check subset

cSubsetSize = 0;
If (pSubset @<> '');
	If (SubsetExists(pDim, pSubset) = 0);
		ProcessError;
	EndIf;
	
	cSubsetSize = SubsetGetSize(pDim, pSubset);
EndIf;

#*** Check parent

cParentPName = '';
cParentDimIndex = 0;
cParentSubsetIndex = 0;
If (pParent @<> '');
	cParentDimIndex = DIMIX(pDim, pParent);
	If (cParentDimIndex = 0);
		ProcessError;
	EndIf;
	#If (DTYPE(pDim, pParent) @<> 'C');
	#	ProcessError;
	#EndIf;
	cParentPName = DimensionElementPrincipalName(pDim, pParent);
	
	If (pSubset @<> '');
		vIndex = 1;
		while (vIndex <= cSubsetSize);
			vElement = SubsetGetElementName(pDim, pSubset, vIndex);
			vElementPName = DimensionElementPrincipalName(pDim, vElement);
			If (cParentPName @= vElementPName);
				cParentSubsetIndex = vIndex;
				vIndex = cSubsetSize;
			EndIf;
			vIndex = vIndex +1;
		End;
		
		If (cParentSubsetIndex = 0);
			ProcessError;
		EndIf;
	EndIf;
EndIf;

#*** Check Node

If (pNode @= '');
	ProcessError;
EndIf;

cNodeDimIndex = 0;
cNodeSubsetIndex = 0;
cNodePName = DimensionElementPrincipalName(pDim, pNode);
cNodeDimIndex = DIMIX(pDim, pNode);
If (cNodeDimIndex > 0);
	vIndex = 1;
	while (vIndex <= cSubsetSize);
		vElement = SubsetGetElementName(pDim, pSubset, vIndex);
		vElementPName = DimensionElementPrincipalName(pDim, vElement);
		If (cNodePName @= vElementPName);
			cNodeSubsetIndex = vIndex;
			vIndex = cSubsetSize;
		EndIf;
		vIndex = vIndex +1;
	End;
EndIf;

#*** Check node type

If (pNodeType @<> 'N' & pNodeType @<> 'C' & pNodeType @<> 'S');
	ProcessError;
EndIf;

#*** Convert weight

cWeight = StringToNumber(pWeight);

#*** Action

If (pAction @= 'ADD');

	If (cNodeDimIndex = 0);

		If (cParentDimIndex = 0);
			DimensionElementInsert(pDim, '', pNode, pNodeType);
		Else;
			vNode = DIMNM(pDim, cParentDimIndex + 1);
			If (vNode @<> '');
				DimensionElementInsert(pDim, vNode, pNode, pNodeType);
			Else;
				DimensionElementInsert(pDim, '', pNode, pNodeType);
			EndIf;
		EndIf;

	Else;
		ProcessError;
	EndIf;

	If (cParentPName @<> '');
		DimensionElementComponentAdd(pDim, cParentPName, pNode, cWeight);
	EndIf;

ElseIf (pAction @= 'DELETE');

	If (cNodeDimIndex = 0);
		ProcessError;
	EndIf;

	DimensionElementDelete(pDim, pNode);
ElseIf (pAction @= 'REMOVE_PARENT');
	If (cParentDimIndex > 0);
		DimensionElementComponentDelete(pDim, pParent, pNode);
	EndIf;
	
	If (pSubset @<> '' & cNodeSubsetIndex > 0);
		SubsetElementDelete(pDim, pSubset, cNodeSubsetIndex);
	EndIf;
ElseIf (pAction @= 'INSERT_CHILD');
	If (cParentDimIndex > 0);
		If (pNodeType @<> DTYPE(pDim, pNode));
			DimensionElementDelete(pDim, pNode);
			vNode = DIMNM(pDim, cParentDimIndex + 1);
			If (vNode @<> '');
				DimensionElementInsert(pDim, vNode, pNode, pNodeType);
			Else;
				DimensionElementInsert(pDim, '', pNode, pNodeType);
    		EndIf;
		EndIf;
		
		DimensionElementComponentAdd(pDim, cParentPName, pNode, cWeight);
	Else;
		ProcessError;
	EndIf;
ElseIf (pAction @= 'MODIFY_WEIGHT');
	If (cNodeDimIndex > 0);
	    If (cParentDimIndex > 0 & ELISPAR(pDim, pParent, pNode) = 1);
			DimensionElementComponentDelete(pDim, cParentPName, pNode);
			DimensionElementComponentAdd(pDim, cParentPName, pNode, cWeight);
		Else;
			ProcessError;
		EndIf;
	Else;
		ProcessError;
	EndIf;
Else;
	ProcessError;
EndIf;

573,1

574,1

575,51


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




#*** Action

If (pAction @= 'ADD');

	If (cParentPName @<> '');
		If (pSubset @<> '');
		    If (pNode @<> SubsetGetElementName(pDim, pSubset, cParentSubsetIndex + 1));
				SubsetElementInsert(pDim, pSubset, pNode, cParentSubsetIndex + 1);
			EndIf;
		EndIf;
	EndIf;

ElseIf (pAction @= 'DELETE');
	# Do nothing
ElseIf (pAction @= 'REMOVE_PARENT');
	# Do nothing
ElseIf (pAction @= 'INSERT_CHILD');
	If (cParentDimIndex > 0);
		If (pSubset @<> '');
			If (pNode @<> SubsetGetElementName(pDim, pSubset, cParentSubsetIndex + 1));
				SubsetElementInsert(pDim, pSubset, pNode, cParentSubsetIndex + 1);
			EndIf;
		EndIf;
	Else;
		ProcessError;
	EndIf;
ElseIf (pAction @= 'MODIFY_WEIGHT');
	# Do nothing
Else;
	ProcessError;
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
