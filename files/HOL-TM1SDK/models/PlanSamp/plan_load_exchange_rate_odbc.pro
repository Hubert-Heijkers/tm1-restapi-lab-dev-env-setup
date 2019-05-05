601,100
562,"ODBC"
586,"plan_load_data"
585,"plan_load_data"
564,"admin"
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
566,1
select * from plan_load_exchange_rates
567,","
588,"."
589,","
568,""""
570,
571,
569,0
592,0
599,1000
560,2
PStartDate
PEndDate
561,2
2
2
590,2
PStartDate,"Jan-2003"
PEndDate,"Dec-2004"
637,2
PStartDate,Start Period?
PEndDate,End Period?
577,4
V1
V2
V3
V4
578,4
2
2
2
1
579,4
1
2
3
4
580,4
0
0
0
0
581,4
0
0
0
0
582,6
VarType=32ColType=825VarDimension=plan_currencyVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_exchange_ratesVarDimAction=AsIsVarElemType=StringVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_timeVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=33ColType=827
VarName=VMonthVarType=33ColType=827VarFormula=DateMonth=subst(V3,1,3);:If(DateMonth@='Jan');:YMonth=1;:endif;:If(DateMonth@='Feb');:YMonth=2;:endif;:If(DateMonth@='Mar');:YMonth=3;:endif;:If(DateMonth@='Apr');:YMonth=4;:endif;:If(DateMonth@='May');:YMonth=5;:endif;:If(DateMonth@='Jun');:YMonth=6;:endif;:If(DateMonth@='Jul');:YMonth=7;:endif;:If(DateMonth@='Aug');:YMonth=8;:endif;:If(DateMonth@='Sep');:YMonth=9;:endif;:If(DateMonth@='Oct');:YMonth=10;:endif;:If(DateMonth@='Nov');:YMonth=11;:en	\
dif;:If(DateMonth@='Dec');:YMonth=12;:endif;:VMonth=Ymonth;:VarFormulaDestination=BOTH
VarName=VYearVarType=33ColType=827VarFormula=VYear=Numbr(subst(V3,5,4));:VarFormulaDestination=BOTH
572,86

#****GENERATED STATEMENTS START****
OldCubeLogChanges = CUBEGETLOGCHANGES('plan_ExchangeRate');
CUBESETLOGCHANGES('plan_ExchangeRate', 0);
#****GENERATED STATEMENTS FINISH****


#PStartDate
VStartMonth=subst(PStartDate,1,3);
VstartYear=NUMBR(subst(PStartDate,5,4));
If(Vstartmonth@='Jan');
XStartmonth=1;
endif;
If(Vstartmonth@='Feb');
XStartmonth=2;
endif;
If(Vstartmonth@='Mar');
XStartmonth=3;
endif;
If(Vstartmonth@='Apr');
XStartmonth=4;
endif;
If(Vstartmonth@='May');
XStartmonth=5;
endif;
If(Vstartmonth@='Jun');
XStartmonth=6;
endif;
If(Vstartmonth@='Jul');
XStartmonth=7;
endif;
If(Vstartmonth@='Aug');
XStartmonth=8;
endif;
If(Vstartmonth@='Sep');
XStartmonth=9;
endif;
If(Vstartmonth@='Oct');
XStartmonth=10;
endif;
If(Vstartmonth@='Nov');
XStartmonth=11;
endif;
If(Vstartmonth@='Dec');
XStartmonth=12;
endif;

#PEndDate
VEndMonth=subst(PEndDate,1,3);
VEndYear=NUMBR(subst(PEndDate,5,4));
If(VEndMonth@='Jan');
XEndMonth=1;
endif;
If(VEndMonth@='Feb');
XEndMonth=2;
endif;
If(VEndMonth@='Mar');
XEndMonth=3;
endif;
If(VEndMonth@='Apr');
XEndMonth=4;
endif;
If(VEndMonth@='May');
XEndMonth=5;
endif;
If(VEndMonth@='Jun');
XEndMonth=6;
endif;
If(VEndMonth@='Jul');
XEndMonth=7;
endif;
If(VEndMonth@='Aug');
XEndMonth=8;
endif;
If(VEndMonth@='Sep');
XEndMonth=9;
endif;
If(VEndMonth@='Oct');
XEndMonth=10;
endif;
If(VEndMonth@='Nov');
XEndMonth=11;
endif;
If(VEndMonth@='Dec');
XEndMonth=12;
endif;
573,42

#****GENERATED STATEMENTS START****
DateMonth=subst(V3,1,3);
If(DateMonth@='Jan');
YMonth=1;
endif;
If(DateMonth@='Feb');
YMonth=2;
endif;
If(DateMonth@='Mar');
YMonth=3;
endif;
If(DateMonth@='Apr');
YMonth=4;
endif;
If(DateMonth@='May');
YMonth=5;
endif;
If(DateMonth@='Jun');
YMonth=6;
endif;
If(DateMonth@='Jul');
YMonth=7;
endif;
If(DateMonth@='Aug');
YMonth=8;
endif;
If(DateMonth@='Sep');
YMonth=9;
endif;
If(DateMonth@='Oct');
YMonth=10;
endif;
If(DateMonth@='Nov');
YMonth=11;
endif;
If(DateMonth@='Dec');
YMonth=12;
endif;
VMonth=Ymonth;
VYear=Numbr(subst(V3,5,4));
#****GENERATED STATEMENTS FINISH****
574,59

#****GENERATED STATEMENTS START****
DateMonth=subst(V3,1,3);
If(DateMonth@='Jan');
YMonth=1;
endif;
If(DateMonth@='Feb');
YMonth=2;
endif;
If(DateMonth@='Mar');
YMonth=3;
endif;
If(DateMonth@='Apr');
YMonth=4;
endif;
If(DateMonth@='May');
YMonth=5;
endif;
If(DateMonth@='Jun');
YMonth=6;
endif;
If(DateMonth@='Jul');
YMonth=7;
endif;
If(DateMonth@='Aug');
YMonth=8;
endif;
If(DateMonth@='Sep');
YMonth=9;
endif;
If(DateMonth@='Oct');
YMonth=10;
endif;
If(DateMonth@='Nov');
YMonth=11;
endif;
If(DateMonth@='Dec');
YMonth=12;
endif;
VMonth=Ymonth;
VYear=Numbr(subst(V3,5,4));
#****GENERATED STATEMENTS FINISH****


If(VYear >= VstartYear & VYear <= VEndYear);

If(VMonth >= Xstartmonth & Vmonth <= Xendmonth);

if(V2@<>'local');

if(V1@<>'USD');

CellPutN(0,'plan_ExchangeRate',V1,V2,V3);
CellPutN(V4,'plan_ExchangeRate',V1,V2,V3);

endif;
endif;
endif;
endif;
575,5

#****GENERATED STATEMENTS START****
CUBESETLOGCHANGES('plan_ExchangeRate', OldCubeLogChanges);
#****GENERATED STATEMENTS FINISH****

576,CubeAction=1500DataAction=1503CubeName=plan_ExchangeRateCubeLogChanges=0
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
