601,100
562,"CHARACTERDELIMITED"
586,".\data_load\actuals_load\2003Actual.csv"
585,".\data_load\actuals_load\2003Actual.csv"
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
589,","
568,""""
570,
571,
569,1
592,0
599,1000
560,2
PStartDate
PEndDate
561,2
2
2
590,2
PStartDate,"01/01/2003"
PEndDate,"12/31/2003"
637,2
PStartDate,Actual Start Date?
PEndDate,Actual End Date?
577,5
V1
Dept
BU
Account
local
578,5
2
2
2
2
1
579,5
1
2
3
4
5
580,5
0
0
0
0
0
581,5
0
0
0
0
0
582,9
VarType=32ColType=827
VarType=32ColType=825VarDimension=plan_departmentVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_business_unitVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_chart_of_accountsVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=33ColType=827
VarName=V6VarType=32ColType=825VarFormula=V6='actual';:VarFormulaDestination=BOTHVarDimension=plan_reportVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=V7VarType=32ColType=825VarFormula=V7='Actual';:VarFormulaDestination=BOTHVarDimension=plan_exchange_ratesVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=V8VarType=32ColType=825VarFormula=## Get Year:Vdatelength=Long(V1);:If(Vdatelength=9);:Vyear=subst(V1,6,4);:else;:Vyear=subst(V1,7,4);:endif;:## Find Month:FindMonth=SCAN('/', V1);:If(Findmonth=2);:Vmonth=subst(V1,1,1);:else;:Vmonth=subst(V1,1,2);:endif;:If(Vmonth@='1');:Xmonth='Jan-';:endif;:If(Vmonth@='2');:Xmonth='Feb-';:endif;:If(Vmonth@='3');:Xmonth='Mar-';:endif;:If(Vmonth@='4');:Xmonth='Apr-';:endif;:If(Vmonth@='5');:Xmonth='May-';:endif;:If(Vmonth@='6');:Xmonth='Jun-';:endif;:	\
If(Vmonth@='7');:Xmonth='Jul-';:endif;:If(Vmonth@='8');:Xmonth='Aug-';:endif;:If(Vmonth@='9');:Xmonth='Sep-';:endif;:If(Vmonth@='10');:Xmonth='Oct-';:endif;:If(Vmonth@='11');:Xmonth='Nov-';:endif;:If(Vmonth@='12');:Xmonth='Dec-';:endif;:V8=Xmonth|Vyear;:VarFormulaDestination=BOTHVarDimension=plan_timeVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=V9VarType=33ColType=827VarFormula=## Get Year:Vdatelength=Long(V1);:If(Vdatelength=9);:Vyear=subst(V1,6,4);:Xyear=subst(V1,8,2);:else;:Vyear=subst(V1,7,4);:Xyear=subst(V1,9,2);:endif;:## Find Month:FindMonth=SCAN('/', V1);:If(Findmonth=2);:Vmonth=subst(V1,1,1);:Xmonth='0'|Vmonth;:else;:Vmonth=subst(V1,1,2);:Xmonth=Vmonth;:endif;:## Find Day:Vcheck1=subst(V1,4,1);:If(Vcheck1@='/');:Xday='0'|subst(V1,3,1);:endif;:Vcheck2=subst(V1,6,1);:If(Vcheck2@='/');:Xday=subst(V1,4,2);:endif;:Vcheck	\
3=subst(V1,5,1);:If(Vcheck3@='/');:Xcheck=SCAN('/', V1);:If(Xcheck=2);:Xday=subst(V1,3,2);:else;:Xday='0'|subst(V1,4,1);:endif;:endif;:VDate=Xyear|'-'|Xmonth|'-'|Xday;:V9=dayno(Vdate);:VarFormulaDestination=BOTH
572,28

#****GENERATED STATEMENTS START****
OldCubeLogChanges = CUBEGETLOGCHANGES('plan_Report');
CUBESETLOGCHANGES('plan_Report', 0);
#****GENERATED STATEMENTS FINISH****

#PStartDate
## Get Start Date (YY-MM-DD)
VStartYear=subst(PstartDate,9,2);
VStartMonth=subst(PstartDate,1,2);
VStartDay=subst(PstartDate,4,2);

VStartDate=(VstartYear|'-'|VstartMonth|'-'|VstartDay);
ZStartDate=DAYNO(VstartDate);

#PEndDate
## Get End Date (YY-MM-DD)
VEndYear=subst(PEndDate,9,2);
VEndMonth=subst(PEndDate,1,2);
VEndDay=subst(PEndDate,4,2);

VEndDate=(VEndYear|'-'|VEndMonth|'-'|VEndDay);
ZEndDate=DAYNO(VEndDate);





573,94

#****GENERATED STATEMENTS START****
V6='actual';
V7='Actual';
## Get Year
Vdatelength=Long(V1);
If(Vdatelength=9);
Vyear=subst(V1,6,4);
else;
Vyear=subst(V1,7,4);
endif;
## Find Month
FindMonth=SCAN('/', V1);
If(Findmonth=2);
Vmonth=subst(V1,1,1);
else;
Vmonth=subst(V1,1,2);
endif;
If(Vmonth@='1');
Xmonth='Jan-';
endif;
If(Vmonth@='2');
Xmonth='Feb-';
endif;
If(Vmonth@='3');
Xmonth='Mar-';
endif;
If(Vmonth@='4');
Xmonth='Apr-';
endif;
If(Vmonth@='5');
Xmonth='May-';
endif;
If(Vmonth@='6');
Xmonth='Jun-';
endif;
If(Vmonth@='7');
Xmonth='Jul-';
endif;
If(Vmonth@='8');
Xmonth='Aug-';
endif;
If(Vmonth@='9');
Xmonth='Sep-';
endif;
If(Vmonth@='10');
Xmonth='Oct-';
endif;
If(Vmonth@='11');
Xmonth='Nov-';
endif;
If(Vmonth@='12');
Xmonth='Dec-';
endif;
V8=Xmonth|Vyear;
## Get Year
Vdatelength=Long(V1);
If(Vdatelength=9);
Vyear=subst(V1,6,4);
Xyear=subst(V1,8,2);
else;
Vyear=subst(V1,7,4);
Xyear=subst(V1,9,2);
endif;
## Find Month
FindMonth=SCAN('/', V1);
If(Findmonth=2);
Vmonth=subst(V1,1,1);
Xmonth='0'|Vmonth;
else;
Vmonth=subst(V1,1,2);
Xmonth=Vmonth;
endif;
## Find Day
Vcheck1=subst(V1,4,1);
If(Vcheck1@='/');
Xday='0'|subst(V1,3,1);
endif;
Vcheck2=subst(V1,6,1);
If(Vcheck2@='/');
Xday=subst(V1,4,2);
endif;
Vcheck3=subst(V1,5,1);
If(Vcheck3@='/');
Xcheck=SCAN('/', V1);
If(Xcheck=2);
Xday=subst(V1,3,2);
else;
Xday='0'|subst(V1,4,1);
endif;
endif;
VDate=Xyear|'-'|Xmonth|'-'|Xday;
V9=dayno(Vdate);
#****GENERATED STATEMENTS FINISH****
574,99

#****GENERATED STATEMENTS START****
V6='actual';
V7='Actual';
## Get Year
Vdatelength=Long(V1);
If(Vdatelength=9);
Vyear=subst(V1,6,4);
else;
Vyear=subst(V1,7,4);
endif;
## Find Month
FindMonth=SCAN('/', V1);
If(Findmonth=2);
Vmonth=subst(V1,1,1);
else;
Vmonth=subst(V1,1,2);
endif;
If(Vmonth@='1');
Xmonth='Jan-';
endif;
If(Vmonth@='2');
Xmonth='Feb-';
endif;
If(Vmonth@='3');
Xmonth='Mar-';
endif;
If(Vmonth@='4');
Xmonth='Apr-';
endif;
If(Vmonth@='5');
Xmonth='May-';
endif;
If(Vmonth@='6');
Xmonth='Jun-';
endif;
If(Vmonth@='7');
Xmonth='Jul-';
endif;
If(Vmonth@='8');
Xmonth='Aug-';
endif;
If(Vmonth@='9');
Xmonth='Sep-';
endif;
If(Vmonth@='10');
Xmonth='Oct-';
endif;
If(Vmonth@='11');
Xmonth='Nov-';
endif;
If(Vmonth@='12');
Xmonth='Dec-';
endif;
V8=Xmonth|Vyear;
## Get Year
Vdatelength=Long(V1);
If(Vdatelength=9);
Vyear=subst(V1,6,4);
Xyear=subst(V1,8,2);
else;
Vyear=subst(V1,7,4);
Xyear=subst(V1,9,2);
endif;
## Find Month
FindMonth=SCAN('/', V1);
If(Findmonth=2);
Vmonth=subst(V1,1,1);
Xmonth='0'|Vmonth;
else;
Vmonth=subst(V1,1,2);
Xmonth=Vmonth;
endif;
## Find Day
Vcheck1=subst(V1,4,1);
If(Vcheck1@='/');
Xday='0'|subst(V1,3,1);
endif;
Vcheck2=subst(V1,6,1);
If(Vcheck2@='/');
Xday=subst(V1,4,2);
endif;
Vcheck3=subst(V1,5,1);
If(Vcheck3@='/');
Xcheck=SCAN('/', V1);
If(Xcheck=2);
Xday=subst(V1,3,2);
else;
Xday='0'|subst(V1,4,1);
endif;
endif;
VDate=Xyear|'-'|Xmonth|'-'|Xday;
V9=dayno(Vdate);
#****GENERATED STATEMENTS FINISH****

IF(V9>=ZStartDate & V9<=ZEndDate);
CellPutN(local,'plan_Report',BU,Dept,Account,V7,V6,V8);
#Asciioutput('c:\temp\aabbcc.txt',BU,Dept,Account,V7,V6,V8);
endif;
575,3
#****GENERATED STATEMENTS START****
CUBESETLOGCHANGES('plan_Report', OldCubeLogChanges);
#****GENERATED STATEMENTS FINISH****
576,CubeAction=1500DataAction=1503CubeName=plan_ReportCubeLogChanges=0
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
