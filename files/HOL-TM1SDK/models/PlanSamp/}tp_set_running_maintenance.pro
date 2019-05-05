601,100
602,"}tp_set_running_maintenance"
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
pControl
pValue
561,3
2
2
2
590,3
pExecutionId,"None"
pControl,"N"
pValue,"N"
637,3
pExecutionId,""
pControl,""
pValue,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,29
cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

cConfigDim = cControlPrefix | 'tp_config';
If (DimensionExists(cConfigDim) = 0);
	ProcessError;
EndIf;

cServerMaintenanceRunning = 'ApplicationMaintenanceRunning';
If (pValue @= 'Y');
	vRunningMaintenanceMode = ATTRS(cConfigDim, cServerMaintenanceRunning, 'String Value');
	If (vRunningMaintenanceMode @= 'Y');
		vReturnValue = ExecuteProcess(cControlPrefix | 'tp_error_update_error_cube', 
				'pGuid', pExecutionId, 
				'pProcess', 'tp_set_running_maintenance', 
				'pErrorCode', 'TI_ATTR_ALREADY_SET',
				'pErrorDetails', 'ApplicationMaintenanceRunning',
				'pControl', pControl);
		ProcessError;
	EndIf;
EndIf;
	

AttrPutS(pValue, cConfigDim, cServerMaintenanceRunning, 'StringValue');



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
