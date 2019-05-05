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
570,budget_placeholder
571,
569,0
592,0
599,1000
560,2
Pyear
PVersion
561,2
2
2
590,2
Pyear,"2004"
PVersion,"FY 2004 Budget"
637,2
Pyear,Budget Year?
PVersion,What Version?
577,10
plan_source
plan_exchange_rates
plan_department
plan_business_unit
plan_chart_of_accounts
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
6
5
3
2
4
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
582,8
VarType=32ColType=825VarDimension=plan_reportVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_exchange_ratesVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
IgnoredInputVarName=plan_versionVarType=32ColType=1165
VarType=32ColType=825VarDimension=plan_departmentVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_business_unitVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_chart_of_accountsVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=32ColType=825VarDimension=plan_timeVarDimAction=AsIsVarElemType=NumericVarDimElemSortType=ByInputVarDimElemSortSense=ASCENDING
VarType=33ColType=826
572,111

#****GENERATED STATEMENTS START****
OldCubeLogChanges = CUBEGETLOGCHANGES('plan_Report');
CUBESETLOGCHANGES('plan_Report', 0);
#****GENERATED STATEMENTS FINISH****

Punique_id=str(NOW,10,0);

## Create a subset for the year selected##
Vmonth=1;
Vplan_time_SSN='budget_calendar'|Punique_id;
SubsetCreate('plan_time', Vplan_time_SSN);
while(Vmonth <=12);
if(Vmonth=1);
Velement='Jan-'|Pyear;
endif;
if(Vmonth=2);
Velement='Feb-'|Pyear;
endif;
if(Vmonth=3);
Velement='Mar-'|Pyear;
endif;
if(Vmonth=4);
Velement='Apr-'|Pyear;
endif;
if(Vmonth=5);
Velement='May-'|Pyear;
endif;
if(Vmonth=6);
Velement='Jun-'|Pyear;
endif;
if(Vmonth=7);
Velement='Jul-'|Pyear;
endif;
if(Vmonth=8);
Velement='Aug-'|Pyear;
endif;
if(Vmonth=9);
Velement='Sep-'|Pyear;
endif;
if(Vmonth=10);
Velement='Oct-'|Pyear;
endif;
if(Vmonth=11);
Velement='Nov-'|Pyear;
endif;
if(Vmonth=12);
Velement='Dec-'|Pyear;
endif;
SubsetElementInsert('plan_time', Vplan_time_SSN, Velement, Vmonth);
Vmonth=Vmonth+1;
end;

##create subset for given version##
Vplan_version_SSN='budget_version'|Punique_id;
SubsetCreate('plan_version', Vplan_version_SSN);
SubsetElementInsert('plan_version', Vplan_version_SSN, Pversion, 1);

##create subset for plan exchange rate##
Vplan_exchange_rate_SSN='budget_exchange_rate'|Punique_id;
SubsetCreate('plan_exchange_rates', Vplan_exchange_rate_SSN);
SubsetElementInsert('plan_exchange_rates', Vplan_exchange_rate_SSN, 'Actual', 1);

##create subset for plan_source##
Vplan_source_SSN='budget_source'|Punique_id;
SubsetCreate('plan_source', Vplan_source_SSN);
SubsetElementInsert('plan_source', Vplan_source_SSN, 'Budget', 1);

##Create temp cube view as the source of the data to load###
Vplan_budget_TVN='Plan_BudgetPlan'|Punique_id;
ViewCreate('Plan_BudgetPlan', Vplan_budget_TVN);

ViewSetSkipZeroes('Plan_BudgetPlan', Vplan_budget_TVN, 1);
ViewSetSkipCalcs('Plan_BudgetPlan', Vplan_budget_TVN, 0);
ViewSetSkipRuleValues('Plan_BudgetPlan', Vplan_budget_TVN, 0);

ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_time', Vplan_time_SSN);
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_version', Vplan_version_SSN);
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_business_unit', 'n level business unit');
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_department', 'n level departments');
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_chart_of_accounts', 'n level accounts');
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_exchange_rates', Vplan_exchange_rate_SSN);
ViewSubsetAssign('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_source', Vplan_source_SSN);

ViewColumnDimensionSet('Plan_BudgetPlan', Vplan_budget_TVN, 'plan_time', 1);

ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_version', 1);
ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_business_unit', 2);
ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_department', 3);
ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_chart_of_accounts', 4);
ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_exchange_rates', 5);
ViewRowDimensionSet('plan_budgetplan', Vplan_budget_TVN, 'plan_source', 6);

data_source_CV = Vplan_budget_TVN;



DatasourceCubeview = data_source_cv;













573,3

#****GENERATED STATEMENTS START****
#****GENERATED STATEMENTS FINISH****
574,5

#****GENERATED STATEMENTS START****
if (VALUE_IS_STRING=1, CellPutS(SVALUE,'plan_Report',plan_business_unit,plan_department,plan_chart_of_accounts,plan_exchange_rates,plan_source,plan_ti
me), CellPutN(NVALUE, 'plan_Report', plan_business_unit,plan_department,plan_chart_of_accounts,plan_exchange_rates,plan_source,plan_time));
#****GENERATED STATEMENTS FINISH****
575,14

#****GENERATED STATEMENTS START****
CUBESETLOGCHANGES('plan_Report', OldCubeLogChanges);
#****GENERATED STATEMENTS FINISH****


ViewDestroy('plan_BudgetPlan', Vplan_budget_TVN);

SubsetDestroy('plan_version', Vplan_version_SSN);
SubsetDestroy('plan_exchange_rates', Vplan_exchange_rate_SSN);
SubsetDestroy('plan_source', Vplan_source_SSN);
SubsetDestroy('plan_time', Vplan_time_SSN);


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
