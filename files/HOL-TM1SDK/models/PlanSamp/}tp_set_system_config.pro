601,100
602,"}tp_set_system_config"
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
560,6
pExecutionId
pControl
pIntegratedSecurityMode
pAdminHost
pServerCAMURI
pClientCAMURI
561,6
2
2
2
2
2
2
590,6
pExecutionId,"None"
pControl,"N"
pIntegratedSecurityMode,"None"
pAdminHost,"None"
pServerCAMURI,"None"
pClientCAMURI,"None"
637,6
pExecutionId,""
pControl,""
pIntegratedSecurityMode,""
pAdminHost,""
pServerCAMURI,""
pClientCAMURI,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,34
#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2009, 2009, 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################

cControlPrefix = '';
If (pControl @= 'Y');
cControlPrefix = '}';
EndIf;

vDimension =cControlPrefix | 'tp_system_config';
vAttrConfigValue='ConfigValue';

IF ( DimensionExists ( vDimension ) = 0 );
  	DimensionCreate(vDimension);
ENDIF;

AttrInsert(vDimension, '', vAttrConfigValue, 'S');
	
DimensionDeleteAllElements(vDimension);
DimensionElementInsert(vDimension, '', 'IntegratedSecurityMode', 'S');
DimensionElementInsert(vDimension, '', 'AdminHost', 'S');
DimensionElementInsert(vDimension, '', 'ServerCAMURI', 'S');
DimensionElementInsert(vDimension, '', 'ClientCAMURI', 'S');

573,1

574,1

575,19
#################################################################
## IBM Confidential
##
## OCO Source Materials
##
## BI and PM: pmpsvc
##
## (C) Copyright IBM Corp. 2009, 2009, 2010
##
## The source code for this program is not published or otherwise
## divested of its trade secrets, irrespective of what has been
## deposited with the U.S. Copyright Office.
#################################################################

AttrPutS(pIntegratedSecurityMode, vDimension, 'IntegratedSecurityMode', vAttrConfigValue);
AttrPutS(pAdminHost, vDimension, 'AdminHost', vAttrConfigValue);
AttrPutS(pServerCAMURI, vDimension, 'ServerCAMURI', vAttrConfigValue);
AttrPutS(pClientCAMURI, vDimension, 'ClientCAMURI', vAttrConfigValue);

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
