601,100
602,"}tp_workflow_execute_action"
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
pTime
pAppId
pNode
pUser
pAction
pAnnotationBody
pAnnotationTitle
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
pTime,"0"
pAppId,"MyApp"
pNode,"NA"
pUser,"NA"
pAction,"NA"
pAnnotationBody,"NA"
pAnnotationTitle,"NA"
pControl,"Y"
637,9
pExecutionId,""
pTime,""
pAppId,""
pNode,""
pUser,""
pAction,""
pAnnotationBody,""
pAnnotationTitle,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,169

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
EndIf;

cPrologLog = gPrologLog;
cEpilogLog = gEpilogLog;
cDataLog = gDataLog;
cTM1Log = cPrologLog;

#*** Log Parameters

If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Parameters:', pExecutionId, pTime, pAppId, pNode, pUser, pAction, pAnnotationBody, pAnnotationTitle, pControl);
EndIf;

#***
actionAllowAnnotate = 'F';
IF (pAction @= 'Own');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_own_node',
		'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 
		'pNewOwnerID', TM1User(), 'pCheckBouncingOnly', 'N', 'pBouncingMode', '', 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
ELSEIF (pAction @= 'Offline');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_offline_node',
		'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pUser', pUser, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	actionAllowAnnotate = 'T';
	
ELSEIF (pAction @= 'Online');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_online_node',
		'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pUser', pUser, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	actionAllowAnnotate = 'T';
	
ELSEIF (pAction @= 'Release');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_release_node',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pUser', pUser, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	actionAllowAnnotate = 'T';

ELSEIF (pAction @= 'SubmitChildren');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_submit_leaf_children',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	actionAllowAnnotate = 'T';

ELSEIF (pAction @= 'Submit');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_submit_node',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

	actionAllowAnnotate = 'T';

ELSEIF (pAction @= 'Reject');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_reject_nodes',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;
	
	actionAllowAnnotate = 'T';

ELSEIF (pAction @= 'Enter');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_enter_node',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

ELSEIF (pAction @= 'Save');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_save_node',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;


ELSEIF (pAction @= 'Leave');

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_workflow_leave_node',
	'pExecutionId', pExecutionId,'pTime', pTime,  'pAppId', pAppId, 'pNode', pNode, 'pControl',  pControl);
	If (vReturnValue <> ProcessExitNormal());
		ProcessError;
	EndIf;

ELSEIF (pAction @= 'Annotate');
	actionAllowAnnotate = 'T';

ENDIF;

#*** No error

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
