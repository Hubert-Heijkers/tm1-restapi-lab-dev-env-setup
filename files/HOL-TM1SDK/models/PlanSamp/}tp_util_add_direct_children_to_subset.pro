601,100
602,"}tp_util_add_direct_children_to_subset"
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
560,4
pExecutionId
pDim
pSubset
pParent
561,4
2
2
2
2
590,4
pExecutionId,"None"
pDim,"NA"
pSubset,"NA"
pParent,"NA"
637,4
pExecutionId,""
pDim,""
pSubset,""
pParent,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,62


#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2013
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################


#*** Check dimension

If (DimensionExists(pDim) = 0);
	ProcessError;
EndIf;

#*** Check subset

If (SubsetExists(pDim, pSubset) = 0);
	ProcessError;
EndIf;


#*** Check parent

If (DIMIX(pDim, pParent) = 0);
	ProcessError;
EndIf;

#*** Check node type

If (DTYPE(pDim, pParent) @<> 'C');
	ProcessError;
EndIf;

#*** Add Children

vTotalChildren = ELCOMPN(pDim, pParent);
vIndex = 1;
While (vIndex <= vTotalChildren);
	vChild = ELCOMP(pDim, pParent, vIndex);
	SubsetElementInsert(pDim, pSubset, vChild, 0);
	
	If (DTYPE(pDim, vChild) @= 'C');
		vReturnValue = ExecuteProcess('}tp_util_add_direct_children_to_subset', 'pExecutionId', pExecutionId,'pDim', pDim,
			'pSubset', pSubset, 'pParent', vChild);
		If (vReturnValue <> ProcessExitNormal());
			ProcessError;
		EndIf;	
	EndIf;
        
	vIndex = vIndex + 1;
End;


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
