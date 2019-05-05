601,100
602,"}tp_reset_views"
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
572,42

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

vAppCube = '}tp_application_cubes';
vCubesDim = '}Cubes';
vClientsDim = '}Clients';
vTotalCubes = DIMSIZ(vCubesDim);

looper =1;
While (looper <= vTotalCubes);
	vCube = DIMNM(vCubesDim, looper);
	IF (SUBST(vCube, 1,1) @<> '}');
		vCubeType = CellGetS(vAppCube, pAppId, vCube);
		IF (vCubeType @= 'A' % vCubeType @= 'Y');
			vTotalClients = DIMSIZ(vClientsDim);
			vClientLooper = 1;
			While (vClientLooper <= vTotalClients);
				vClient = DIMNM(vClientsDim, vClientLooper);
				vReturnValue = ExecuteProcess('}tp_reset_view_by_cube_user', 'pExecutionId', pExecutionId,
					'pAppId', pAppId, 'pCube', vCube, 'pUser', vClient);
				If (vReturnValue <> ProcessExitNormal());
					ProcessError;
				EndIf;
				vClientLooper = vClientLooper +1;
			End;
		Endif;
	Endif;
	looper = looper +1;
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
