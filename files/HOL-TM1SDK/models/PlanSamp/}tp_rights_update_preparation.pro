601,100
602,"}tp_rights_update_preparation"
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
pAppId
pIncremental
pMultiThreads
561,4
2
2
2
2
590,4
pExecutionId,"None"
pAppId,"None"
pIncremental,"N"
pMultiThreads,"5"
637,4
pExecutionId,""
pAppId,""
pIncremental,""
pMultiThreads,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,130


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
cConfigDim = '}tp_config';
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
vReturnValue = ExecuteProcess('}tp_get_log_file_names', 'pExecutionId', pExecutionId,
'pProcess', cTM1Process, 'pControl', 'Y');
If (vReturnValue <> ProcessExitNormal());
	ProcessError;
EndIf;
Endif;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:',pExecutionId, pAppId);
EndIf;

#***
cIMApplicationDim = '}tp_intermediate_security_applications';
cIMMeasures = '}tp_intermediate_security_measures';
vIncrGroupDim = 'tp_incr_temp_groups_' | pAppId;
cApprovalDim = ATTRS('}tp_applications', pAppId, 'ApprovalDimension');
cApprovalSubset = ATTRS('}tp_applications', pAppId, 'ApprovalSubset');

#***
#create an application subset that contains this application Id only
vTempAppSubset = 'temp_app_' | pAppId;
IF (SubsetExists(cIMApplicationDim, vTempAppSubset)>0);
	SubsetDestroy(cIMApplicationDim, vTempAppSubset);
Endif;
SubsetCreate(cIMApplicationDim, vTempAppSubset);
SubsetElementInsert(cIMApplicationDim, vTempAppSubset, pAppId, 1);

#***
#create a group subset that contains groups in the vIncrGroupDim
IF (pIncremental @= 'Y');
	vTempGroupSubset = 'temp_group_' | pAppId;
	vGroupsControlDim = '}Groups';
	IF (SubsetExists(vGroupsControlDim, vTempGroupSubset)>0);
		SubsetDestroy(vGroupsControlDim, vTempGroupSubset);
	Endif;
	SubsetCreate(vGroupsControlDim, vTempGroupSubset);

	vTotalTempGroups = DIMSIZ(vIncrGroupDim);
	groupLooper = 1;
	While (groupLooper <= vTotalTempGroups);
		vGroup = DIMNM(vIncrGroupDim, groupLooper);
		SubsetElementInsert(vGroupsControlDim, vTempGroupSubset, vGroup, 1);
		groupLooper = groupLooper +1;
	End;
Endif;

#***split approval subset into a small subsets based on available thread number
cTotalNodes = SubsetGetSize(cApprovalDim, cApprovalSubset);
vNodesInSubset = cTotalNodes;
vMultiThreads = StringToNumber(pMultiThreads);

IF (vMultiThreads > vNodesInSubset);
	vMultiThreads = vNodesInSubset;
Endif;

IF (vMultiThreads >1);
	vRemainingNodes = Mod(cTotalNodes, vMultiThreads);
	IF ( vRemainingNodes>0);
		vAvgNodesInSubset = Int((cTotalNodes-vRemainingNodes)/vMultiThreads);
	Else;
		vAvgNodesInSubset = Int(cTotalNodes/vMultiThreads);
	Endif;


	looper = 1;
	While (looper <= vMultiThreads);
		vSubsetName = 'update_thread' | numberToString(looper);

		IF (SubsetExists(cApprovalDim, vSubsetName) >0);
			SubsetDestroy(cApprovalDim, vSubsetName);
		Endif;
	
		SubsetCreate(cApprovalDim, vSubsetName);
	
		IF (looper <vMultiThreads);
			vNodesInSubsets = vAvgNodesInSubset;
		Else;
			vNodesInSubsets = vRemainingNodes + vAvgNodesInSubset;
		Endif;

		nodeLooper = 1;
		While (nodeLooper <= vNodesInSubsets);
			vNodeIndex = (looper -1)*vAvgNodesInSubset + nodeLooper;
			vNode = SubsetGetElementName(cApprovalDim, cApprovalSubset, vNodeIndex);
			SubsetElementInsert(cApprovalDim, vSubsetName, vNode, 0);
			nodeLooper = nodeLooper +1;
		End;
		looper = looper +1;
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
