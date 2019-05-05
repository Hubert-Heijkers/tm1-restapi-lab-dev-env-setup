601,100
602,"}tp_util_check_approval_overlap"
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
pAppIdToCompare
561,3
2
2
2
590,3
pExecutionId,"None"
pAppId,"None"
pAppIdToCompare,"None"
637,3
pExecutionId,""
pAppId,""
pAppIdToCompare,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,97

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
cApprovalDim =  ATTRS('}tp_applications', pAppId,  'ApprovalDimension');
cApprovalSubset =ATTRS('}tp_applications', pAppId,  'ApprovalSubset');
cShadowApprovalDim ='}tp_tasks}' | pAppId;

#***

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application attributes', cApprovalDim, cApprovalSubset, cShadowApprovalDim );
EndIf;

#***
cApprovalDimToCompare  =  ATTRS('}tp_applications', pAppIdToCompare,  'ApprovalDimension');
cApprovalSubsetToCompare =ATTRS('}tp_applications', pAppIdToCompare,  'ApprovalSubset');
cShadowApprovalDimToCompare  ='}tp_tasks}' | pAppIdToCompare;

#***
If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, 'get application_to_compare attributes', cApprovalDimToCompare, 
		cApprovalSubsetToCompare, cShadowApprovalDimToCompare );
EndIf;

#***
isApprovalHierarchyOverlap = 'N';

IF (cApprovalDim @= cApprovalDimToCompare & cApprovalSubset @=cApprovalSubsetToCompare);
	isApprovalHierarchyOverlap = 'Y';
Elseif (cApprovalDim @= cApprovalDimToCompare & cApprovalSubset @<>cApprovalSubsetToCompare);
	vSubset = 'approval_overlap' | pExecutionId;
	IF (SubsetExists(cApprovalDim, vSubset) =1);
		SubsetDestroy(cApprovalDim, vSubset);
	Endif;
	
	vMdx = '{INTERSECT(Tm1SubsetToSet( [' | cApprovalDim | '], "' | cApprovalSubset | '" ) , Tm1SubsetToSet( [' | cApprovalDimToCompare | '], "' | cApprovalSubsetToCompare | '" ) )}';
	SubsetCreateByMdx(vSubset, vMdx, cApprovalDim);
	vTotalOverlap = SubsetGetSize(cApprovalDim, vSubset);
	IF (vTotalOverlap >0);
		isApprovalHierarchyOverlap = 'Y';
	Endif;
	If (cGenerateLog @= 'Y');
		TextOutput(cTM1Log, vMdx, NumberToString(vTotalOverlap) );
	EndIf;
Endif;

If (isApprovalHierarchyOverlap @= 'Y');
	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
		'pGuid', pExecutionId, 
		'pProcess', cTM1Process, 
		'pErrorCode', 'TI_APPROVAL_OVERLAPPED',
		'pErrorDetails', pAppId,
		'pControl', 'Y');
	
EndIf;

573,1

574,1

575,30
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


IF (SubsetExists(cApprovalDim, vSubset) =1);
	SubsetDestroy(cApprovalDim, vSubset);
Endif;

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
