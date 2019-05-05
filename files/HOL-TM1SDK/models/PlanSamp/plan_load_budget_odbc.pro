601,100
562,"ODBC"
586,"Plan_load_data"
585,"Plan_load_data"
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
select * from plan_load_budgets
567,","
588,"."
589,","
568,""""
570,
571,
569,1
592,0
599,1000
560,3
PVersion
PStartDate
PEndDate
561,3
2
2
2
590,3
PVersion,"FY 2003 Budget"
PStartDate,"Jan-2003"
PEndDate,"Dec-2003"
637,3
PVersion,Which Version?
PStartDate,Budget Start Date?
PEndDate,Budget End Date?
577,5
plan_date
plan_department
plan_business_unit
plan_acount
plan_value
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
582,12
VarType=32ColType=827
VarType=32ColType=825VarDimension=plan_departmentVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=827
VarType=32ColType=825VarDimension=plan_chart_of_accountsVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=33ColType=827
VarName=V7VarType=32ColType=825VarFormula=V7='Local';:VarFormulaDestination=BOTHVarDimension=plan_exchange_ratesVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=V8VarType=32ColType=825VarFormula=V8='Input';:VarFormulaDestination=BOTHVarDimension=plan_sourceVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=VMonthVarType=33ColType=827VarFormula=DateMonth=subst(plan_date,6,2);:If(DateMonth@='01');:YMonth=1;:ZMonth='Jan';:endif;:If(DateMonth@='02');:YMonth=2;:Zmonth='Feb';:endif;:If(DateMonth@='03');:YMonth=3;:Zmonth='Mar';:endif;:If(DateMonth@='04');:YMonth=4;:Zmonth='Apr';:endif;:If(DateMonth@='05');:YMonth=5;:Zmonth='May';:endif;:If(DateMonth@='06');:YMonth=6;:Zmonth='Jun';:endif;:If(DateMonth@='07');:YMonth=7;:ZMonth='Jul';:endif;:If(DateMonth@='08');:YMonth=8;:Zmonth='Aug';:endif;:If(	\
DateMonth@='09');:YMonth=9;:ZMonth='Sep';:endif;:If(DateMonth@='10');:YMonth=10;:Zmonth='Oct';:endif;:If(DateMonth@='11');:YMonth=11;:Zmonth='Nov';:endif;:If(DateMonth@='12');:YMonth=12;:ZMonth='Dec';:endif;:VMonth=Ymonth;:VarFormulaDestination=BOTH
VarName=VYearVarType=33ColType=827VarFormula=VYear=Numbr(subst(plan_date,1,4));:VarFormulaDestination=BOTH
VarName=LoadDateVarType=32ColType=825VarFormula=LoadDate=Zmonth|'-'|str(Vyear,4,0);:VarFormulaDestination=BOTHVarDimension=plan_timeVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=VersionVarType=32ColType=825VarFormula=Version='Test';:VarFormulaDestination=BOTHVarDimension=plan_versionVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=V12VarType=32ColType=825VarFormula=V12=TRIM(str(NUMBR(plan_business_unit),10,0));:#V12=NumberToString(StringToNumber(plan_business_unit));:VarFormulaDestination=BOTHVarDimension=plan_business_unitVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
572,88

#****GENERATED STATEMENTS START****
OldCubeLogChanges = CUBEGETLOGCHANGES('plan_BudgetPlan');
CUBESETLOGCHANGES('plan_BudgetPlan', 0);
#****GENERATED STATEMENTS FINISH****

DatasourceASCIIThousandSeparator='';

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

573,60

#****GENERATED STATEMENTS START****
V7='Local';
V8='Input';
DateMonth=subst(plan_date,6,2);
If(DateMonth@='01');
YMonth=1;
ZMonth='Jan';
endif;
If(DateMonth@='02');
YMonth=2;
Zmonth='Feb';
endif;
If(DateMonth@='03');
YMonth=3;
Zmonth='Mar';
endif;
If(DateMonth@='04');
YMonth=4;
Zmonth='Apr';
endif;
If(DateMonth@='05');
YMonth=5;
Zmonth='May';
endif;
If(DateMonth@='06');
YMonth=6;
Zmonth='Jun';
endif;
If(DateMonth@='07');
YMonth=7;
ZMonth='Jul';
endif;
If(DateMonth@='08');
YMonth=8;
Zmonth='Aug';
endif;
If(DateMonth@='09');
YMonth=9;
ZMonth='Sep';
endif;
If(DateMonth@='10');
YMonth=10;
Zmonth='Oct';
endif;
If(DateMonth@='11');
YMonth=11;
Zmonth='Nov';
endif;
If(DateMonth@='12');
YMonth=12;
ZMonth='Dec';
endif;
VMonth=Ymonth;
VYear=Numbr(subst(plan_date,1,4));
LoadDate=Zmonth|'-'|str(Vyear,4,0);
Version='Test';
V12=TRIM(str(NUMBR(plan_business_unit),10,0));
#V12=NumberToString(StringToNumber(plan_business_unit));
#****GENERATED STATEMENTS FINISH****
574,75

#****GENERATED STATEMENTS START****
V7='Local';
V8='Input';
DateMonth=subst(plan_date,6,2);
If(DateMonth@='01');
YMonth=1;
ZMonth='Jan';
endif;
If(DateMonth@='02');
YMonth=2;
Zmonth='Feb';
endif;
If(DateMonth@='03');
YMonth=3;
Zmonth='Mar';
endif;
If(DateMonth@='04');
YMonth=4;
Zmonth='Apr';
endif;
If(DateMonth@='05');
YMonth=5;
Zmonth='May';
endif;
If(DateMonth@='06');
YMonth=6;
Zmonth='Jun';
endif;
If(DateMonth@='07');
YMonth=7;
ZMonth='Jul';
endif;
If(DateMonth@='08');
YMonth=8;
Zmonth='Aug';
endif;
If(DateMonth@='09');
YMonth=9;
ZMonth='Sep';
endif;
If(DateMonth@='10');
YMonth=10;
Zmonth='Oct';
endif;
If(DateMonth@='11');
YMonth=11;
Zmonth='Nov';
endif;
If(DateMonth@='12');
YMonth=12;
ZMonth='Dec';
endif;
VMonth=Ymonth;
VYear=Numbr(subst(plan_date,1,4));
LoadDate=Zmonth|'-'|str(Vyear,4,0);
Version='Test';
V12=TRIM(str(NUMBR(plan_business_unit),10,0));
#V12=NumberToString(StringToNumber(plan_business_unit));
#****GENERATED STATEMENTS FINISH****

IF(Vyear >= VstartYear & Vyear <= VEndYear);

IF(Vmonth >= Xstartmonth & Vmonth <= Xendmonth);


VPlanDept=TRIM(STR(NUMBR(plan_department),10,0));
VPlanAccount=TRIM(STR(NUMBR(plan_acount),10,0));

#Asciioutput('c:\temp\aaa.txt',PVersion,V12,plan_department,VPlanAccount,V7,V8,LoadDate);
CellPutN(0,'plan_BudgetPlan',PVersion,V12,VPlanDept,VPlanAccount,V7,V8,LoadDate);
CellPutN(plan_value,'plan_BudgetPlan',PVersion,V12,VPlanDept,VPlanAccount,V7,V8,LoadDate);

endif;
endif;
575,4

#****GENERATED STATEMENTS START****
CUBESETLOGCHANGES('plan_BudgetPlan', OldCubeLogChanges);
#****GENERATED STATEMENTS FINISH****
576,CubeAction=1500DataAction=1503CubeName=plan_BudgetPlanCubeLogChanges=0
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
