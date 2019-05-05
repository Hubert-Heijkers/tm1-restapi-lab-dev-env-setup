601,100
602,"}tp_custom_TI_update_error_code_caption"
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
560,5
pExecutionId
pErrorCode
pLocaleName
pLocaleValue
pIsDefault
561,5
2
2
2
2
2
590,5
pExecutionId,"None"
pErrorCode,"None"
pLocaleName,"None"
pLocaleValue,"None"
pIsDefault,"Y"
637,5
pExecutionId,""
pErrorCode,""
pLocaleName,""
pLocaleValue,""
pIsDefault,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,85

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


If (cGenerateLog @= 'Y');
	TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), pErrorCode, pLocaleName, pLocaleValue);
EndIf;

#***
vErrorDim = '}tp_process_errors_localization';
vAttrCube = '}ElementAttributes_' | vErrorDim;
vAttrDim = vAttrCube;

IF (DIMIX(vErrorDim, pErrorCode) >0);
	IF (DIMIX(vAttrDim, 'Caption') =0);
		AttrInsert(vErrorDim, '', 'Caption', 'A');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'Alias Caption is added.');
		EndIf;
	Endif;

	IF (DIMIX(vAttrDim, 'CaptionDefaultLocale') =0);
		AttrInsert(vErrorDim, '', 'CaptionDefaultLocale', 'S');
		If (cGenerateLog @= 'Y');
			TextOutput(cTM1Log, TIMST(NOW, '\Y-\m-\d \h:\i:\s'), 'String Attribute CaptionDefaultLocale is added.');
		EndIf;
	Endif;

Else;

	vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube',
		'pGuid', pExecutionId,
		'pProcess', cTM1Process,
		'pErrorCode', 'TI_NODE_NOT_EXIST',
		'pErrorDetails', vErrorDim | ', ' | pErrorCode,
		'pControl', 'Y');

Endif;

#*** No error

If (cGenerateLog @= 'Y');
TextOutput(cTM1Log, 'The end has been reached.');
EndIf;

573,1

574,1

575,35

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

#***
cTM1Log = cEpilogLog;

#Set caption support
cCultureDim = '}Cultures';
IF (DIMIX(cCultureDim, pLocaleName)>0);
	IF (pIsDefault @= 'Y');
		#set default caption
		AttrPutS(pLocaleValue, vErrorDim ,pErrorCode , 'Caption');
		AttrPutS(pLocaleName, vErrorDim ,pErrorCode , 'CaptionDefaultLocale');
	Endif;
	AttrPutS(pLocaleValue, vErrorDim ,pErrorCode , 'Caption', pLocaleName);
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
