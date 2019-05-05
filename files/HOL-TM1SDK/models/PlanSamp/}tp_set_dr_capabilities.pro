601,100
602,"}tp_set_dr_capabilities"
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
pControl
561,2
2
2
590,2
pExecutionId,"None"
pControl,"N"
637,2
pExecutionId,""
pControl,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,37
cControlPrefix = '';
If (pControl @= 'Y');
	cControlPrefix = '}';
EndIf;

cSystemConfigDim = cControlPrefix | 'tp_system_config';
If (DimensionExists(cSystemConfigDim) = 0);
	ProcessError;
EndIf;

cSecurityModeNode = 'IntegratedSecurityMode';
cConfigValueAttr = 'ConfigValue';
vSecurityMode = ATTRS(cSystemConfigDim, cSecurityModeNode, cConfigValueAttr);

#Grant DataReservation capabilities to the tp_everyone group

cCapabilityCube = '}Capabilities';

cCognosEveryoneGroup = 'CAMID("::Everyone")';
cTpEveryoneGroup = cControlPrefix | 'tp_Everyone';
If (vSecurityMode @= '5');

	If (DIMIX('}Groups', cCognosEveryoneGroup) = 0);
		ProcessError;
	EndIf;
	CellPutS('Grant', cCapabilityCube, 'ManageDataReservation', 'EXECUTE', cCognosEveryoneGroup);
	CellPutS('Grant', cCapabilityCube, 'DataReservationOverride', 'EXECUTE', cCognosEveryoneGroup);
Else;
	If (DIMIX('}Groups', cTpEveryoneGroup) = 0);
		ProcessError;
	EndIf;
	CellPutS('Grant', cCapabilityCube, 'ManageDataReservation', 'EXECUTE', cTpEveryoneGroup);
	CellPutS('Grant', cCapabilityCube, 'DataReservationOverride', 'EXECUTE', cTpEveryoneGroup);
EndIf;

#***

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
