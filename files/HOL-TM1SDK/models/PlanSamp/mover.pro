601,100
562,"VIEW"
586,"plan_BudgetPlan"
585,"plan_BudgetPlan"
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
570,mover
571,
569,0
592,0
599,1000
560,0
561,0
590,0
637,0
577,10
plan_business_unit
plan_department
plan_chart_of_accounts
plan_exchange_rates
plan_source
plan_time
Value
NVALUE
SVALUE
VALUE_IS_STRING
578,10
2
2
2
2
2
2
1
1
2
1
579,10
2
3
4
5
6
7
8
0
0
0
580,10
0
0
0
0
0
0
0
0
0
0
581,10
0
0
0
0
0
0
0
0
0
0
582,10
IgnoredInputVarName=plan_versionVarType=32ColType=1165
VarType=32ColType=825VarDimension=plan_business_unitVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_departmentVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_chart_of_accountsVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_exchange_ratesVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_sourceVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=827
VarType=33ColType=826
VarName=vMonthVarType=32ColType=825VarFormula=vMonth=subst(plan_time, 1, 7) | '3';:VarFormulaDestination=DATAVarDimension=plan_timeVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarName=vVersionVarType=32ColType=825VarFormula=vVersion='FY 2003 Budget';:VarFormulaDestination=DATAVarDimension=plan_versionVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
572,4
#****GENERATED STATEMENTS START****
OldCubeLogChanges = CUBEGETLOGCHANGES('plan_BudgetPlan');
CUBESETLOGCHANGES('plan_BudgetPlan', 0);
#****GENERATED STATEMENTS FINISH****
573,2
#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****
574,7
#****GENERATED STATEMENTS START****
vMonth=subst(plan_time, 1, 7) | '3';
vVersion='FY 2003 Budget';
if (VALUE_IS_STRING=1, CellPutS(SVALUE,'plan_BudgetPlan',vVersion,plan_business_unit,plan_department,plan_chart_of_accounts,plan_exchange_rates,plan_s
ource,vMonth), CellPutN(NVALUE, 'plan_BudgetPlan', vVersion,plan_business_unit,plan_department,plan_chart_of_accounts,plan_exchange_rates,plan_source,
vMonth));
#****GENERATED STATEMENTS FINISH****
575,3
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
