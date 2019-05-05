601,100
562,"NULL"
586,
585,
564,
565,"e7_rjao:JKTHY4<2<vuvL6Q^y8VssQjQ0:d=]u;T6KD6;Vj[nW8iLGotLgWoadl7QgT<y1Ix^s?X0u8Y;SnepPXx<`ESoRn`G\8W[Yn[k8Mma_AcCNGgwIH`aIj?eMlUghHf26Z9uYfHgl^C]H:@enQrYWI>kPzhVuI06LPPXq?mVEpYA<rku70t;6NGYIoYX8MtMg:c"
559,0
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
560,1
pLanguage
561,1
2
590,1
pLanguage,"English"
637,1
pLanguage,Language (German
577,0
578,0
579,0
580,0
581,0
582,0
572,59

#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****

#
# Loop through all dimensions skipping system dimensions
#
vDimCount = DIMSIZ('}dimensions');

vDimIndex = 1;

while (vDimIndex <= vDimCount);
vDim = DIMNM('}dimensions', vDimIndex);

if (SUBST(vDim, 1, 1) @<> '}');

#
# Test to see if an attribute cube exists for the current dimension
#
vAttrDim = '}ElementAttributes_' | vDim;
vTest = TABDIM(vAttrDim,1);
if (vTest @<> '');

#
# Loop through all attributes in the dimension looking for attributes that have a matching language attribute
# _ENGLISH or _GERMAN or _FRENCH
#
vAttrCount = DIMSIZ(vAttrDim);
vAttrIndex = 1;
while (vAttrIndex <= vAttrCount);
vAttr = DIMNM(vAttrDim,  vAttrIndex);

vFromAttr = vAttr | '_' | pLanguage;
vFromExists = DIMIX(vAttrDim, vFromAttr);
if (vFromExists > 0);

#
# Loop through all elements in the dimension moving the attribute value from the language to the main
#
vEleCount = DIMSIZ(vDim);
vEleIndex = 1;
while (vEleIndex <= vEleCount);
vEle = DIMNM(vDim, vEleIndex);

ATTRPUTS(ATTRS(vDim, vEle, vFromAttr), vDim, vEle, vAttr);
vEleIndex = vEleIndex + 1;
end;

endif;

vAttrIndex = vAttrIndex + 1;
end;

endif;

endif;

vDimIndex = vDimIndex + 1;
end;
573,3

#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****
574,3

#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****
575,31

#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****

LastIndx=DIMSIZ('plan_chart_of_accounts');
IndxCount=1;

While(IndxCount <= LastIndx);
VElement=DIMNM('plan_chart_of_accounts', IndxCount);

## Get The Account Attribute value
VAttValue=ATTRS('plan_chart_of_accounts', VElement, 'FormatGroup');

IF(VAttValue@<>'');

## Check that the Attribute Value Exist as an element in the plan format;
IF(DIMIX('plan_format_template',VAttValue)>0);

VNewValue=ATTRS('plan_format_template',VAttValue,'FormatGroup');


IF(VNewValue @<> '');
AttrPutS(VNewValue, 'plan_chart_of_accounts', VElement, 'FormatGroup');
ENDIF;
endif;
endif;

IndxCount=IndxCount+1;

end;

576,CubeAction=1511DataAction=1503CubeLogChanges=0
638,1
804,0
1217,0
900,
901,
902,
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
