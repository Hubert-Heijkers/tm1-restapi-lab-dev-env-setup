601,100
602,"}tp_util_insert_value_into_cube"
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
pCube
pValue
pElem1
pElem2
pElem3
pElem4
561,6
2
2
2
2
2
2
590,6
pCube,"None"
pValue,"None"
pElem1,""
pElem2,""
pElem3,""
pElem4,""
637,6
pCube,""
pValue,""
pElem1,""
pElem2,""
pElem3,""
pElem4,""
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,237


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


#*** Calculate dimension count
cDim1 = '';
cDim2 = '';
cDim3 = '';
cDim4 = '';

vIndex = 1;
While (vIndex <> 0);
	vDim = TABDIM(pCube, vIndex);
	
	If (vIndex = 1);
		cDim1 = vDim;
	ElseIf (vIndex = 2);
		cDim2 = vDim;
	ElseIf (vIndex = 3);
		cDim3 = vDim;
	ElseIf (vIndex = 4);
		cDim4 = vDim;
	EndIf;
	
	If (vDim @<> '');
		vIndex = vIndex + 1;
	Else;
		cDimCount = vIndex - 1;
		vIndex = 0;
	EndIf;
End;


#*** Check elements
If (cDimCount = 2);
	If (pElem1 @= '' % pElem2 @= '');
		ProcessError;
	EndIf;
ElseIf (cDimCount = 3);
	If (pElem1 @= '' % pElem2 @= '' % pElem3 @= '');
		ProcessError;
	EndIf;
ElseIf (cDimCount = 4);
	If (pElem1 @= '' % pElem2 @= '' % pElem3 @= '' % pElem4 @= '');
		ProcessError;
	EndIf;
Else;
	ProcessError;
EndIf;


#*** If element is '?', the element is a wild card and it means any element.
If (cDimCount = 2);	
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0);
		If (DTYPE(cDim2, pElem2) @= 'S');
			CellPutS(pValue, pCube, pElem1, pElem2);
		Else;
			CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2);
		EndIf;
	EndIf;
	
	If (pElem1 @= '?' & DIMIX(cDim2, pElem2) <> 0);
		vDimSize = DIMSIZ(cDim1);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim1, vIndex);
			
			If (DTYPE(cDim2, pElem2) @= 'S');
				CellPutS(pValue, pCube, vElem, pElem2);
			Else;
				CellPutN(StringToNumber(pValue), pCube, vElem, pElem2);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & pElem2 @= '?');
		vDimSize = DIMSIZ(cDim2);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim2, vIndex);
			
			If (DTYPE(cDim2, vElem) @= 'S');
				CellPutS(pValue, pCube, pElem1, vElem);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, vElem);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
ElseIf (cDimCount = 3);
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0 & DIMIX(cDim3, pElem3) <> 0);
		If (DTYPE(cDim3, pElem3) @= 'S');
			CellPutS(pValue, pCube, pElem1, pElem2, pElem3);
		Else;
			CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2, pElem3);
		EndIf;
	EndIf;
	
	If (pElem1 @= '?' & DIMIX(cDim2, pElem2) <> 0 & DIMIX(cDim3, pElem3) <> 0);
		vDimSize = DIMSIZ(cDim1);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim1, vIndex);
			
			If (DTYPE(cDim3, pElem3) @= 'S');
				CellPutS(pValue, pCube, vElem, pElem2, pElem3);
			Else;
				CellPutN(StringToNumber(pValue), pCube, vElem, pElem2, pElem3);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & pElem2 @= '?' & DIMIX(cDim3, pElem3) <> 0);
		vDimSize = DIMSIZ(cDim2);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim2, vIndex);
			
			If (DTYPE(cDim3, pElem3) @= 'S');
				CellPutS(pValue, pCube, pElem1, vElem, pElem3);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, vElem, pElem3);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0 & pElem3 @= '?');
		vDimSize = DIMSIZ(cDim3);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim3, vIndex);
			
			If (DTYPE(cDim3, vElem) @= 'S');
				CellPutS(pValue, pCube, pElem1, pElem2, vElem);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2, vElem);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
ElseIf (cDimCount = 4);
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0 & DIMIX(cDim3, pElem3) <> 0 & DIMIX(cDim4, pElem4) <> 0);
		If (DTYPE(cDim4, pElem4) @= 'S');
			CellPutS(pValue, pCube, pElem1, pElem2, pElem3, pElem4);
		Else;
			CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2, pElem3, pElem4);
		EndIf;
	EndIf;
	
	If (pElem1 @= '?' & DIMIX(cDim2, pElem2) <> 0 & DIMIX(cDim3, pElem3) <> 0 & DIMIX(cDim4, pElem4) <> 0);
		vDimSize = DIMSIZ(cDim1);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim1, vIndex);
			
			If (DTYPE(cDim4, pElem4) @= 'S');
				CellPutS(pValue, pCube, vElem, pElem2, pElem3, pElem4);
			Else;
				CellPutN(StringToNumber(pValue), pCube, vElem, pElem2, pElem3, pElem4);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & pElem2 @= '?' & DIMIX(cDim3, pElem3) <> 0 & DIMIX(cDim4, pElem4) <> 0);
		vDimSize = DIMSIZ(cDim2);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim2, vIndex);
			
			If (DTYPE(cDim4, pElem4) @= 'S');
				CellPutS(pValue, pCube, pElem1, vElem, pElem3, pElem4);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, vElem, pElem3, pElem4);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0 & pElem3 @= '?' & DIMIX(cDim4, pElem4) <> 0);
		vDimSize = DIMSIZ(cDim3);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim3, vIndex);
			
			If (DTYPE(cDim4, pElem4) @= 'S');
				CellPutS(pValue, pCube, pElem1, pElem2, vElem, pElem4);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2, vElem, pElem4);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
	
	If (DIMIX(cDim1, pElem1) <> 0 & DIMIX(cDim2, pElem2) <> 0 & DIMIX(cDim3, pElem3) <> 0 & pElem4 @= '?');
		vDimSize = DIMSIZ(cDim4);
		vIndex = 1;
		while (vIndex <= vDimSize);
			vElem = DIMNM(cDim4, vIndex);
			
			If (DTYPE(cDim4, vElem) @= 'S');
				CellPutS(pValue, pCube, pElem1, pElem2, pElem3, vElem);
			Else;
				CellPutN(StringToNumber(pValue), pCube, pElem1, pElem2, pElem3, vElem);
			EndIf;
			
			vIndex = vIndex + 1;
		End;
	EndIf;
Else;
	ProcessError;
EndIf;

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
