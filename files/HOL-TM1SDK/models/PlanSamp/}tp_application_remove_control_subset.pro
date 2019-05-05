601,100
602,"}tp_application_remove_control_subset"
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
pAppId
561,2
2
2
590,2
pExecutionId,"None"
pAppId,"MyApp"
637,2
pExecutionId,""
pAppId,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,175
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


#<<set_log$'Y'$'Logs\'>>

### action=init_log:begin ###

a_pExecutionId = pExecutionId;

a_vLogPrefix = GetProcessName();
If (SUBST(a_vLogPrefix, 1, 1) @= '}');
	a_vLogPrefix = SUBST(a_vLogPrefix, 2, (LONG(a_vLogPrefix) - 1));
EndIf;

#*** Check tp_config dimension
a_cConfigDim = '}tp_config';

If (DimensionExists(a_cConfigDim) = 1);
	global_GenerateLog = ATTRS(a_cConfigDim, 'Generate TI Log', 'String Value');
	a_cLogDirectory = ATTRS(a_cConfigDim, 'Log Directory', 'String Value');
	If (a_cLogDirectory @<> '' & SUBST(a_cLogDirectory, (LONG(a_cLogDirectory) - 1), 1) @<> '\');
		a_cLogDirectory = a_cLogDirectory | '\';
	EndIf;
	
	global_PrologLog = a_cLogDirectory | a_vLogPrefix | '_' | a_pExecutionId | '_prolog.log';
	global_EpilogLog = a_cLogDirectory | a_vLogPrefix | '_' | a_pExecutionId | '_epilog.log';
	global_DataLog = a_cLogDirectory | a_vLogPrefix | '_' | a_pExecutionId | '_data.log';
	global_MetadataLog = a_cLogDirectory | a_vLogPrefix | '_' | a_pExecutionId | '_metadata.log';
Else;
	global_GenerateLog = 'Y';
	global_PrologLog = a_vLogPrefix | '_' | a_pExecutionId | '_prolog.log';
	global_EpilogLog = a_vLogPrefix | '_' | a_pExecutionId | '_epilog.log';
	global_DataLog = a_vLogPrefix | '_' | a_pExecutionId | '_data.log';
	global_MetadataLog = a_vLogPrefix | '_' | a_pExecutionId | '_metadata.log';
EndIf;

### action=init_log:end ###


#**remove control subset filter
vDimensions = '}Dimensions';
vTotalDimensions = DIMSIZ(vDimensions);

### action=p_log:begin ###

b_pMessage = 'Number of dimensions: ' | NumberToString(vTotalDimensions);


### action=log:begin ###

b_a_pSection = 'prolog';
b_a_pMessage = b_pMessage;

If (global_GenerateLog @= 'Y');
	If (b_a_pSection @= 'prolog');
		b_a_cTM1Log = global_PrologLog;
	ElseIf (b_a_pSection @= 'epilog');
		b_a_cTM1Log = global_EpilogLog;
	ElseIf (b_a_pSection @= 'data');
		b_a_cTM1Log = global_DataLog;
	ElseIf (b_a_pSection @= 'metadata');
		b_a_cTM1Log = global_MetadataLog;
	Else;
		b_a_cTM1Log = b_a_pSection;
	EndIf;
	
	TextOutput(b_a_cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), b_a_pMessage);
EndIf;

### action=log:end ###


### action=p_log:end ###


looper = vTotalDimensions;
While (looper >= 1);
	vDimension = DIMNM(vDimensions, looper);
	If (SUBST(vDimension, 1,1) @<> '}');
		vSubset = 'tp_' | pAppId;
		If (SubsetExists(vDimension, vSubset) >0);
		    
### action=p_log:begin ###

c_pMessage = 'Data Cube: ' | vDimension | ' has control subset (SubsetDeleteAllElements)' | vSubset;


### action=log:begin ###

c_a_pSection = 'prolog';
c_a_pMessage = c_pMessage;

If (global_GenerateLog @= 'Y');
	If (c_a_pSection @= 'prolog');
		c_a_cTM1Log = global_PrologLog;
	ElseIf (c_a_pSection @= 'epilog');
		c_a_cTM1Log = global_EpilogLog;
	ElseIf (c_a_pSection @= 'data');
		c_a_cTM1Log = global_DataLog;
	ElseIf (c_a_pSection @= 'metadata');
		c_a_cTM1Log = global_MetadataLog;
	Else;
		c_a_cTM1Log = c_a_pSection;
	EndIf;
	
	TextOutput(c_a_cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), c_a_pMessage);
EndIf;

### action=log:end ###


### action=p_log:end ###

			SubsetDeleteAllElements(vDimension, vSubset);
		EndIf;
	EndIf;
	looper = looper -1;
End;

looper = vTotalDimensions;
While (looper >= 1);
	vDimension = DIMNM(vDimensions, looper);
	If (SUBST(vDimension, 1,1) @<> '}');
		vSubset = 'tp_' | pAppId;
		If (SubsetExists(vDimension, vSubset) >0);
		    
### action=p_log:begin ###

d_pMessage = 'Data Cube: ' | vDimension | ' has control subset (SubsetDestroy)' | vSubset;


### action=log:begin ###

d_a_pSection = 'prolog';
d_a_pMessage = d_pMessage;

If (global_GenerateLog @= 'Y');
	If (d_a_pSection @= 'prolog');
		d_a_cTM1Log = global_PrologLog;
	ElseIf (d_a_pSection @= 'epilog');
		d_a_cTM1Log = global_EpilogLog;
	ElseIf (d_a_pSection @= 'data');
		d_a_cTM1Log = global_DataLog;
	ElseIf (d_a_pSection @= 'metadata');
		d_a_cTM1Log = global_MetadataLog;
	Else;
		d_a_cTM1Log = d_a_pSection;
	EndIf;
	
	TextOutput(d_a_cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), d_a_pMessage);
EndIf;

### action=log:end ###


### action=p_log:end ###

			SubsetDestroy(vDimension, vSubset);
		EndIf;
	EndIf;
	looper = looper -1;
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
