601,100
602,"}tp_deploy_create_task_navigation_cube"
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
pNavigationDimensions
561,3
2
2
2
590,3
pExecutionId,"None"
pAppId,"None"
pNavigationDimensions,"None"
637,3
pExecutionId,""
pAppId,""
pNavigationDimensions,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,36


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

cTaskNavigationDim = '}tp_task_navigation_dims}' | pAppId;
IF (DimensionExists(cTaskNavigationDim)=0);
DimensionCreate(cTaskNavigationDim);
Endif;

dimSeparater = '*';
vPosDim = 0;
vStringToScan = pNavigationDimensions;
vPosDim = SCAN(dimSeparater, vStringToScan);

While (vPosDim >0);
	vDimName = SUBST(vStringToScan, 1, vPosDim-1);
	DimensionElementInsert(cTaskNavigationDim, '', vDimName, 'N');
	vStringToScan = SUBST(vStringToScan, vPosDim +1, LONG(vStringToScan)-vPosDim);
	vPosDim = SCAN(dimSeparater, vStringToScan);
End;




573,1

574,1

575,39


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

cTaskNavigationCube = '}tp_task_navigations}' | pAppId;
cTaskDimension = '}tp_tasks}' | pAppId;
cTaskNavigationMeasureDim = '}tp_task_navigations';
IF (cubeExists(cTaskNavigationCube) =0);
CubeCreate(cTaskNavigationCube, cTaskDimension, cTaskNavigationDim, cTaskNavigationMeasureDim);
Endif;

#***
#If there is one navigation dimension only and it is the same as the approval dimension, 
#then use the task dimension element to populate the navigation element
cApprovalDIM = ATTRS('}tp_applications', pAppId, 'ApprovalDimension');
cNavElemField = 'NavigationElement';
IF (DIMSIZ(cTaskNavigationDim) =1 & DIMNM(cTaskNavigationDim, 1) @= cApprovalDim);
	vTotalTasks = DIMSIZ(cTaskDimension);
	looper = 1;
	While (looper <= vTotalTasks);
		vNavigationElem = DIMNM(cTaskDimension, looper);
		CellPutS(vNavigationElem, cTaskNavigationCube, vNavigationElem, cApprovalDim, cNavElemField);
		looper = looper +1;
	End;

Endif;

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
