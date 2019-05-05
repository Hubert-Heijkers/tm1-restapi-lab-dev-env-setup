601,100
602,"}tp_util_create_cube"
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
pCubeName
pDimensions
pDelimiter
561,4
2
2
2
2
590,4
pExecutionId,"None"
pCubeName,"None"
pDimensions,"None"
pDelimiter,"None"
637,4
pExecutionId,""
pCubeName,""
pDimensions,""
pDelimiter,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,235

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


IF (pDelimiter @= '');
pDelimiter = '*';
ENDIF;

vDimension1= '';
vDimension2= '';
vDimension3= '';
vDimension4= '';
vDimension5= '';
vDimension6= '';
vDimension7= '';
vDimension8= '';
vDimension9= '';
vDimension10= '';
vDimension11= '';
vDimension12= '';
vDimension13= '';
vDimension14= '';
vDimension15= '';
vDimension16= '';
vDimension17= '';
vDimension18= '';
vDimension19= '';
vDimension20= '';
vDimension21= '';
vDimension22= '';
vDimension23= '';
vDimension24= '';
vDimension25= '';
vDimension26= '';
vDimension27= '';
vDimension28= '';
vDimension29= '';
vDimension30= '';


IF (CubeExists(pCubeName) =0);

vDimension = '';
vLength = 0;
vDimensions= pDimensions;
vPosition = SCAN(pDelimiter, vDimensions);
vOrder =1;
WHILE (vPosition >0);
vLength = Long(vDimensions);
vDimension = SUBST(vDimensions, 1, vPosition-1);
vDimensions= SUBST(vDimensions, vPosition +1, vLength - vPosition);
IF (vOrder =1);
vDimension1 = vDimension;
ELSEIF (vOrder =2);
vDimension2=vDimension;
ELSEIF (vOrder =3);
vDimension3=vDimension;
ELSEIF (vOrder =4);
vDimension4=vDimension;
ELSEIF (vOrder =5);
vDimension5=vDimension;
ELSEIF (vOrder =6);
vDimension6=vDimension;
ELSEIF (vOrder =7);
vDimension7=vDimension;
ELSEIF (vOrder =8);
vDimension8=vDimension;
ELSEIF (vOrder =9);
vDimension9=vDimension;
ELSEIF (vOrder =10);
vDimension10=vDimension;
ELSEIF (vOrder =11);
vDimension11=vDimension;
ELSEIF (vOrder =12);
vDimension12=vDimension;
ELSEIF (vOrder =13);
vDimension13=vDimension;
ELSEIF (vOrder =14);
vDimension14=vDimension;
ELSEIF (vOrder =15);
vDimension15=vDimension;
ELSEIF (vOrder =16);
vDimension16=vDimension;
ELSEIF (vOrder =17);
vDimension17=vDimension;
ELSEIF (vOrder =18);
vDimension18=vDimension;
ELSEIF (vOrder =19);
vDimension19=vDimension;
ELSEIF (vOrder =20);
vDimension20=vDimension;
ELSEIF (vOrder =21);
vDimension21=vDimension;
ELSEIF (vOrder =22);
vDimension22=vDimension;
ELSEIF (vOrder =23);
vDimension23=vDimension;
ELSEIF (vOrder =24);
vDimension24=vDimension;
ELSEIF (vOrder =25);
vDimension25=vDimension;
ELSEIF (vOrder =26);
vDimension26=vDimension;
ELSEIF (vOrder =27);
vDimension27=vDimension;
ELSEIF (vOrder =28);
vDimension28=vDimension;
ELSEIF (vOrder =29);
vDimension29=vDimension;
ELSEIF (vOrder =30);
vDimension30=vDimension;
ENDIF;

vOrder = vOrder + 1;
vPosition = SCAN(pDelimiter, vDimensions);

END;

vTotalDimensions = vOrder -1;

IF (vTotalDimensions =2);
CubeCreate(pCubeName , vDimension1, vDimension2);
ELSEIF (vTotalDimensions = 3);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3);
ELSEIF (vTotalDimensions = 4);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4);
ELSEIF (vTotalDimensions = 5);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5);
ELSEIF (vTotalDimensions = 6);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6);
ELSEIF (vTotalDimensions = 7);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7);
ELSEIF (vTotalDimensions = 8);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8);
ELSEIF (vTotalDimensions = 9);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, vDimension9);
ELSEIF (vTotalDimensions = 10);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6,vDimension7, vDimension8, vDimension9, vDimension10);
ELSEIF (vTotalDimensions = 11);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6, vDimension7, vDimension8, vDimension9, vDimension10, vDimension11);
ELSEIF (vTotalDimensions = 12);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6, vDimension7, vDimension8, vDimension9, vDimension10, vDimension11, vDimension12);
ELSEIF (vTotalDimensions = 13);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6, vDimension7, vDimension8, vDimension9, vDimension10, vDimension11, vDimension12, vDimension13);
ELSEIF (vTotalDimensions = 14);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6, vDimension7, vDimension8, vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14);
ELSEIF (vTotalDimensions = 15);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, 
vDimension6, vDimension7, vDimension8, vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15);
ELSEIF (vTotalDimensions = 16);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16);
ELSEIF (vTotalDimensions = 17);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17);
ELSEIF (vTotalDimensions = 18);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18);
ELSEIF (vTotalDimensions = 19);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19);
ELSEIF (vTotalDimensions = 20);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20);
ELSEIF (vTotalDimensions = 21);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21);
ELSEIF (vTotalDimensions = 22);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22);
ELSEIF (vTotalDimensions = 23);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23);
ELSEIF (vTotalDimensions = 24);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24);
ELSEIF (vTotalDimensions = 25);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25);
ELSEIF (vTotalDimensions = 26);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25, vDimension26);
ELSEIF (vTotalDimensions = 27);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25, vDimension26, vDimension27);
ELSEIF (vTotalDimensions = 28);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25, vDimension26, vDimension27, vDimension28);
ELSEIF (vTotalDimensions = 29);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25, vDimension26, vDimension27, vDimension28,
vDimension29);
ELSEIF (vTotalDimensions = 30);
CubeCreate(pCubeName , vDimension1, vDimension2, vDimension3, vDimension4, vDimension5, vDimension6, vDimension7, vDimension8, 
vDimension9, vDimension10, vDimension11, vDimension12, vDimension13, vDimension14, vDimension15, vDimension16, vDimension17, vDimension18, 
vDimension19, vDimension20, vDimension21, vDimension22, vDimension23, vDimension24, vDimension25, vDimension26, vDimension27, vDimension28,
vDimension29, vDimension30);
ENDIF;

CubeSetLogChanges(pCubeName, 1);

ENDIF;





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
