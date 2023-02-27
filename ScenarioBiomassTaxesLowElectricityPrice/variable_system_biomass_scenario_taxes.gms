Option  Optcr=0.1;
Option Reslim=100000;
$offDigit

Sets
T       'hours of the year'
/T0001*T8760/

G       'generation technology index'
/G01*G12/
*G1 = WtE CHP       
*G2 = WtE HOB       
*G3 = Biomass (Wood chips) CHP       
*G4 = Biomass (wood chips) HOB       
*G5 = pulverized coal fired, supercritical steam process        
*G6 = gas turbine single - cycle        
*G7 = gas turbine combined cycle        
*G8 = district heaitng boiler, gas fired        
*G9 = heat Pump (10 MW airsource heat pump)        
*G10 = electric boiler
*G11 = Biomass (straw) CHP
*G12 = Biomass (straw) HOP

F       'fuel index'
/F1*F6/
*needs to be made more specific
*F1 = Gas
*F2 = Coal & Peat
*F3 = Non-renewable waste
*F4 = Biomass&biofuels (wood chips)
*F5 = Electricity (needs to be changed is the average right now)
*F6 = Biomass (straw)

K       'community index'
/K01*K10/

D       'Data center types'
/D1*D3/
*D1 = small data center
*D2 = medium data center
*D3 large data center

P       'production sent from '
/P01*P13/

*subsets

CHP_G_no_WtE(G)
/G03,G05,G06,G07/
HOP_G_no_WtE(G)
/G04,G08/
CHP_G_WtE_try(G)
/G01/
HOP_G_WtE_try(G)
/G02/
Demand_new(G)
/G03,G04,G05,G06,G07,G08,G09,G10,G11,G12/

CHP_G(G)
/G01,G03,G05,G06,G07,G11/
CHP_back_pressure_G(G)
/G01,G06,G11/
CHP_extraction_G(G)
/G03,G05,G07/
*see how this will be implemented regarding cost!!!!
HOP_G(G)
/G02,G04,G08,G12/
Heat_pumps_G(G)
/G09/
Not_CHP_electric_G(G)
/G01,G03,G05,G06,G07/

WtE_CHP(G)
/G01/
Bio_CHP(G)
/G03/
Bio_Straw_CHP(G)
/G11/
Coal_CHP(G)
/G05/
Simple_Gas_CHP(G)
/G06/
Combined_Gas_CHP(G)
/G07/
WtE_CHP_fuel(F)
/F1,F2,F4,F5,F6/
Bio_CHP_fuel(F)
/F1,F2,F3,F5,F6/
Bio_Straw_CHP_fuel(F)
/F1,F2,F3,F4,F5/
Coal_CHP_fuel(F)
/F1,F3,F4,F5,F6/
Simple_Gas_CHP_fuel(F)
/F2,F3,F4,F5,F6/
Combined_Gas_CHP_fuel(F)
/F2,F3,F4,F5,F6/

WtE_HOP(G)
/G02/
Bio_HOP(G)
/G04/
Bio_Straw_HOP(G)
/G12/
District_Gas_HOP(G)
/G08/
Electric_HOP(G)
/G10/
WtE_HOP_fuel(F)
/F1,F2,F4,F5,F6/
Bio_HOP_fuel(F)
/F1,F2,F3,F5,F6/
Bio_Straw_HOP_fuel(F)
/F1,F2,F3,F4,F5/
District_Gas_HOP_fuel(F)
/F2,F3,F4,F5,F6/
*this one might need to change!!!!
Electric_HOP_fuel(F)
/F1,F2,F3,F4,F6/


;

SCALARS
M           'Big number'
/1000/

Market_setter_G   'the amount of heat produced and sold/stored in all technologies needs to equate at all times to 0'
/0/
Market_setter_D   'the amount of heat produced and sold/stored in all technologies needs to equate at all times to 0'
/0/

SOC_inital      'inital storage in latent storage tank is 0'
/0/

T_charge_rate   'percentage of discharge that can be done in one hour of LTS'
/0.2/

T_discharge_rate 'percentage of cahrge that can be done in one hour of LTS'
/0.2/

n_T             'round trip efficiency of LTS'
/0.88/
;


Table Demands(T,K)     2 dimensional table

$onDelim
$include municipality_demands(3).csv
$offDelim


Table Loss_Coefficient(G,K)     2 dimensional table

$onDelim
$include loss_coefficient_generator.csv
$offDelim
;

Table Losses_DC(D,K)
$onDelim
$include  Losses_DC.csv
$offDelim
;

Table COP_HP_DC(T,D)     2 dimensional table

$onDelim
$include  COP_data_center.csv
$offDelim
;

PARAMETERS
size(D)
/
$onDelim
$include  size.csv
$offDelim
/

COP_HP_industrial(T)
/
$onDelim
$include  COP_HP_industry.csv
$offDelim
/

tax_revenue(G)
/
$onDelim
$include  tax_revenue.csv
$offDelim
/

Thermal_Efficiency(G)     'effciencies of the given generation technology'
/
$onDelim
$include thermalefficiencies.csv
$offDelim
/

Capacities(G)   'set of capacities of generation technology (MW_el & MW_th)'
/
$ondelim
$include    municipality_biomass_capacities.csv
$offdelim
/

Capacities_fuel(G)   'set of capacities of generation technology (MW_el)'
/
$ondelim
$include    fuel_capacities.csv
$offdelim
/

*is in MW per hour
Max_fuel_consumption_per_hour(G)
/
$ondelim
$include    maximum_fuel_consumption.csv
$offdelim
/
*double check all the units and make them into MW from GJ
fuel_price(F) 'fuel prices unit assumed needs to be determined (Euro/GJ)'
/
$ondelim
$include    fuel_prices.csv
$offdelim
/

fuel_emission_equ(F) 'emission equivalence by fuel typ (kg(CO2)/MWh(not sure about unit))'
/
$ondelim
$include    CO2_emissions_fuel.csv
$offdelim
/

*not sure about what the energy equivalnce is, id assume its MWh(th)
fuel_energy(F)      'energy content in fuel typ (MWh(not sure)/kg)'
/
$ondelim
$include    Fuel_energy_content.csv
$offdelim
/

*needs work some units are in el some in th!!!
OM_fixed(G)        'set of fixed operation and maintance cost of tech (Euro/MW/year), needs work units are some in el some in th!!!!'
/
$ondelim
$include    fixed_V&O_cost.csv
$offdelim
/

OM_nominal(G)        'set of nominal operation and maintance cost of tech (Euro/MW)'
/
$ondelim
$include    nominal_investment.csv
$offdelim
/

OM_nominal_fuel(G)        'set of nominal operation and maintance cost of tech (Euro/MW)'
/
$ondelim
$include    nominal_inv_cost_fuel_input.csv
$offdelim
/

OM_variable(G)        'set of variable operation and maintance cost of tech (Euro/MWh)'
/
$ondelim
$include    variable_O&M.csv
$offdelim
/

OM_fuel_usage(G)        'set of fuel usage operation and maintance cost of tech (Euro/MWh)'
/
$ondelim
$include    variable_O&M_fuel.csv
$offdelim
/

eday(T)    'Electricity day-ahead price (EUR/MWh)'
/
$ondelim
$include    day_ahead_el_price.csv
$offdelim
/

ecarbon(T)    'carbon equivalent emission of electricity consumption from grid in that time step (kg(Co2)/MWh)'
/
$ondelim
$include    carbon_average.csv
$offdelim
/

c_b(G)        'back-pressure coefficient (electricity divided by heat)'
/
$ondelim
$include    back_pressure_coefficient_Cb.csv
$offdelim
/

c_v(G)        'loss of electric generation per unit of heat generated at fixed fuel input, assumed constant'
/
$ondelim
$include    loss_electricity_generation_coefficient_Cv.csv
$offdelim
/

*data center costs

OM_fixed_DC(D)        'set of fixed operation and maintance cost of tech (Euro/MW/year)'
/
$ondelim
$include    fixed_V&O_DC.csv
$offdelim
/

OM_nominal_DC(D)        'set of nominal operation and maintance cost of tech (Euro/MW)'
/
$ondelim
$include    nominal_investment_DC.csv
$offdelim
/

OM_variable_DC(D)        'set of variable operation and maintance cost of tech (Euro/MWh)'
/
$ondelim
$include    variable_O&M_DC.csv
$offdelim
/

OM_nominal_infrastruture_DC(D)        'set of nominal operation and maintance cost of tech (Euro)'
/
$ondelim
$include    Investment_cost_DC.csv
$offdelim
/

OM_variable_infrastruture_DC(D)        'set of nominal operation and maintance cost of tech (Euro)'
/
$ondelim
$include    variable_investment_cost_infrastructure_DC.csv
$offdelim
/

Waste_heat(T)
/
$ondelim
$include    waste_heat_variable(2).csv
$offdelim
/

Fuel_taxes(F)
/
$ondelim
$include    fuel_taxes.csv
$offdelim
/

CO2_taxes(F)
/
$ondelim
$include    CO2_taxes.csv
$offdelim
/
;

Binary Variable
data(D)
;

Variable       
Z              'total cost of system'
C_g(G,T)      'producer bidding price'
C_d(D,T)      'cost of heat porduction by that data center in that hour'
CO2_G                'CO2 emissions from the heat generation'
CO2_D
cost_HP(G,T)
cost_HP_DC(D,T)
cost_HP_DC(D,T)
cost_EL(G,T)
C_inv_g(G)
C_inv_DC(D)
C_T_G(G)
C_T_D(D)
*T_charge(T)   'amount charged in time period t'
*T_discharge(T) 'amount discharged in time period t'
*SOC_T(T)      'amount stored in tank in time period t'

;

Positive Variables
py(G,T,K)
px(G,T,K)

x_g(G,T)            'heat production of individual producers'
x_d(D,T)            'heat produced in data centers'
x_f(G,F,T)          'type fuel quantity used for heat generation in that tech'
y_g(G,K,T)          'amount sold from generator g to community k in time step t'
y_d(D,K,T)
e_g(G,T)            'electricty exported to grid at time period t by generation tech G'
z_g(D)              'Capacity invested in data centers to recover surplus heat(MW)'
e(D,T)              'electricty taken from the grid for data centers (Mwh)'
e_IH(G,T)           ''
e_EL(G,T)           'electricty taken from grid to supply the electric boiler'
*T_charge(T)
*T_discharge(T)
*SOC_T(T)
Fuel_CO2_Taxes(G)
g_c(G)
;

e_g.fx(G,T)$(not CHP_G(G)) = 0;

py.fx(G,T,K)$(not HOP_G_WtE_try(G)) = 0;
px.fx(G,T,K)$(not CHP_G_WtE_try(G)) = 0;

x_f.fx(G,F,T)$(WtE_CHP(G) and WtE_CHP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Bio_CHP(G) and Bio_CHP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Bio_Straw_CHP(G) and Bio_Straw_CHP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Coal_CHP(G) and Coal_CHP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Simple_Gas_CHP(G) and Simple_Gas_CHP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Combined_Gas_CHP(G) and Combined_Gas_CHP_fuel(F)) = 0;

x_f.fx(G,F,T)$(WtE_HOP(G) and WtE_HOP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Bio_HOP(G) and Bio_HOP_fuel(F)) = 0;
x_f.fx(G,F,T)$(Bio_Straw_HOP(G) and Bio_Straw_HOP_fuel(F)) = 0;
x_f.fx(G,F,T)$(District_Gas_HOP(G) and District_Gas_HOP_fuel(F)) = 0;
*this one might need changing
*x_f.fx(G,F,T)$(Electric_HOP(G) and Electric_HOP_fuel(F)) = 0;

Equations

*objective function
Cost_of_system            'returns the overall cost of the system'
Cost_heat_production(G,T)
Cost_heat_production_DC(D,T)

Market_balance_G(T,G)
Market_balance_D(T,D)

Upper_bound_not_CHP(G,T)
Upper_bound_electric_CHP(G,T)
Upper_bound_CHP(G,T)
Upper_bound_extraction_CHP(G,T)
Lower_bound_extraction_CHP(G,T)
Production_equation_back_pressure_CHP(G,T)

Heating_demand(K,T)
Heat_production_equation(G,T)
Emissions_G(G,T)
Emissions_D(D,T)
*Waste_limit(G,F,T)  

Heat_production_HP_DC(T,D)
Heat_production_HP_industrial(G,T)
Cost_HP_equ(G,T)
Cost_HP_equ_DC(T,D)
Limit_heat_production_HP_DC(T,D)

Investment_cost(G)
Investment_cost_DC(D)
Total_cost_of_G(G)
Total_cost_of_DC(D)

Force(D)

Heat_production_EL(G,T)
Cost_EL_equ(G,T)

Taxes(G)

upper_bound_capacities(G)

Waste_CHP_limit(G,T)
Waste_HOP_limit(G,T)
;
Waste_CHP_limit(G,T).. x_g(G,T)$(WtE_CHP(G)) =e= (Capacities(G)/c_v(G))$(WtE_CHP(G));
Waste_HOP_limit(G,T).. x_g(G,T)$(WtE_HOP(G)) =e= (Capacities(G))$(WtE_HOP(G));

Cost_of_system..            Z =e= sum((D), C_T_D(D)) + sum((G), C_T_G(G)) - sum(T, sum(G, e_g(G,T))*(eday(T))) + sum(T,sum(G,sum(K, py(G,T,K)))*100) + sum(T,sum(G, sum(K, px(G,T,K)))*100);

upper_bound_capacities(G)..     g_c(G) =l= Capacities(G);
*+ sum(F, OM_fuel_usage(G)*x_f(G,F,T)*fuel_energy(F)) 
Cost_heat_production(G,T).. C_g(G,T) =e= (sum(F, x_f(G,F,T)*fuel_price(F)*fuel_energy(F)) + OM_variable(G)*x_g(G,T) + sum(F, x_f(G,F,T)*fuel_energy(F)*Fuel_taxes(F) + x_f(G,F,T)*fuel_energy(F)*CO2_taxes(F)))$(HOP_G(G)) + (OM_variable(G)*e_g(G,T) + sum(F, x_f(G,F,T)*fuel_energy(F)*Fuel_taxes(F) + x_f(G,F,T)*fuel_energy(F)*CO2_taxes(F)))$(CHP_G(G)) +  (cost_HP(G,T))$(Heat_pumps_G(G)) + cost_EL(G,T)$Electric_HOP(G);
Cost_heat_production_DC(D,T).. C_d(D,T) =e= cost_HP_DC(D,T);
Taxes(G)..                      Fuel_CO2_Taxes(G) =e= sum(T, sum(F, x_f(G,F,T)*fuel_energy(F)*Fuel_taxes(F) + x_f(G,F,T)*fuel_energy(F)*CO2_taxes(F))) + sum(T, (e_EL(G,T)*0.536912752)$Electric_HOP(G) + (e_IH(G,T)*0.536912752)$Heat_pumps_G(G));

*+ sum(F, OM_fuel_usage(G)*x_f(G,F,T)*fuel_energy(F)) 
Total_cost_of_G(G)..            C_T_G(G) =e= sum(T, (sum(F, x_f(G,F,T)*fuel_price(F)*fuel_energy(F)) + OM_variable(G)*x_g(G,T) + sum(F, x_f(G,F,T)*fuel_energy(F)*Fuel_taxes(F) + x_f(G,F,T)*fuel_energy(F)*CO2_taxes(F)))$(HOP_G(G)) + (OM_variable(G)*e_g(G,T) + sum(F, x_f(G,F,T)*fuel_energy(F)*Fuel_taxes(F) + x_f(G,F,T)*fuel_energy(F)*CO2_taxes(F)))$(CHP_G(G)) + (cost_HP(G,T))$(Heat_pumps_G(G)) + cost_EL(G,T)$Electric_HOP(G)) + OM_fixed(G)*g_c(G)+ OM_nominal(G)*g_c(G); 

*
Total_cost_of_DC(D)..           C_T_D(D) =e= sum(T, OM_variable_DC(D)*x_d(D,T) + e(D,T)*eday(T) + OM_variable_infrastruture_DC(D)*x_d(D,T) + e(D,T)*0.536912752) + OM_fixed_DC(D)*(sum(T,Waste_heat(T))/8760)*(sum(T,COP_HP_DC(T,D))/8760)*z_g(D) + ((OM_nominal_DC(D)))*(sum(T,Waste_heat(T))/8760)*(sum(T,COP_HP_DC(T,D))/8760)*z_g(D) + (OM_nominal_infrastruture_DC(D)*data(D)) - (sum(G, tax_revenue(G))/3)*(z_g(D)/100);


Investment_cost(G)..        C_inv_g(G) =e= OM_fixed(G)*g_c(G) + OM_nominal(G)*g_c(G);
Investment_cost_DC(D)..        C_inv_DC(D) =e= OM_fixed_DC(D)*(sum(T,Waste_heat(T))/8760)*(sum(T,COP_HP_DC(T,D))/8760)*z_g(D) + OM_nominal_DC(D)*(sum(T,Waste_heat(T))/8760)*(sum(T,COP_HP_DC(T,D))/8760)*z_g(D) + OM_nominal_infrastruture_DC(D)*data(D); 

Market_balance_G(T,G)..     Market_setter_G =e=  x_g(G,T) - sum(K,y_g(G,K,T));
Market_balance_D(T,D)..     Market_setter_D =e=  x_d(D,T) - sum(K,y_d(D,K,T));

Upper_bound_not_CHP(G,T)..      (x_g(G,T))$(not CHP_G(G)) =l= (g_c(G))$(not CHP_G(G));
Upper_bound_electric_CHP(G,T)..      (e_g(G,T))$(CHP_G(G)) =l= (g_c(G))$(CHP_G(G));
Upper_bound_CHP(G,T)..      (x_g(G,T))$(CHP_G(G)) =l= (g_c(G)/c_v(G))$(CHP_G(G));

Lower_bound_extraction_CHP(G,T)..  (e_g(G,T))$CHP_extraction_G(G) =g= ((c_b(G)*x_g(G,T)))$CHP_extraction_G(G);
Upper_bound_extraction_CHP(G,T)..  (e_g(G,T))$CHP_extraction_G(G) =l= (g_c(G) - (c_v(G)*x_g(G,T)))$CHP_extraction_G(G);
Production_equation_back_pressure_CHP(G,T).. (e_g(G,T))$CHP_back_pressure_G(G) =e= ((c_b(G)*x_g(G,T)))$CHP_back_pressure_G(G);

Heating_demand(K,T).. sum(G, (y_g(G,K,T)*(1-Loss_Coefficient(G,K)))$Demand_new(G)) + sum(G, (y_g(G,K,T)*(1-Loss_Coefficient(G,K)) - py(G,T,K))$HOP_G_WtE_try(G)) + sum(G, (y_g(G,K,T)*(1-Loss_Coefficient(G,K)) - px(G,T,K))$CHP_G_WtE_try(G)) + sum(D, y_d(D,K,T)*(1-Losses_DC(D,K))) =e= Demands(T,K);

Heat_production_equation(G,T).. x_g(G,T) =e= sum(F, (x_f(G,F,T)*fuel_energy(F)*Thermal_Efficiency(G))$HOP_G(G)) + sum(F, (x_f(G,F,T)*fuel_energy(F)*Thermal_Efficiency(G) - (e_g(G,T)/c_v(G)))$CHP_G(G)) + (x_g(G,T))$Heat_pumps_G(G) + x_g(G,T)$Electric_HOP(G);

Emissions_G(G,T).. CO2_G(G,T) =e= sum(F, x_f(G,F,T)*fuel_emission_equ(F)*fuel_energy(F)) + (e_IH(G,T)*ecarbon(T))$Heat_pumps_G(G) + (e_EL(G,T)*ecarbon(T))$Electric_HOP(G);
Emissions_D(D,T).. CO2_D(D,T) =e= e(D,T)*ecarbon(T);

Force(D).. z_g(D) =l= 100*data(D);
*Lower_limit(D).. z_g(D) =g= 1*data(D);

Heat_production_HP_DC(T,D).. x_d(D,T) =e= e(D,T)*COP_HP_DC(T,D);
Limit_heat_production_HP_DC(T,D)..  x_d(D,T) =l= (Waste_heat(T)*z_g(D))/(1-(1/COP_HP_DC(T,D)));
Heat_production_HP_industrial(G,T).. x_g(G,T)$Heat_pumps_G(G) =e= (COP_HP_industrial(T)*e_IH(G,T))$Heat_pumps_G(G);
Cost_HP_equ(G,T)..  (cost_HP(G,T))$(Heat_pumps_G(G)) =e= (e_IH(G,T)*eday(T) + OM_variable(G)*x_g(G,T) + e_IH(G,T)*0.536912752)$(Heat_pumps_G(G));
Cost_HP_equ_DC(T,D).. cost_HP_DC(D,T) =e= e(D,T)*eday(T) + OM_variable_DC(D)*e(D,T) + e(D,T)*0.536912752;

Heat_production_EL(G,T)..  x_g(G,T)$Electric_HOP(G) =e= (Thermal_Efficiency(G)*e_EL(G,T))$Electric_HOP(G);
Cost_EL_equ(G,T)..              cost_EL(G,T)$Electric_HOP(G)  =e=  (e_EL(G,T)*eday(T) + OM_variable(G)*x_g(G,T) + e_EL(G,T)*0.536912752)$Electric_HOP(G);

Model
District_heating_system_variable  'All components'
/all/
;

Solve District_heating_system_variable using MIP minimizing Z;
display Z.l;
*try writing it without the direction of the file
execute_unload 'output_file.gdx';
execute 'gdxdump output_file format=csv output=Generator_heat.csv   symb=y_g';
execute 'gdxdump output_file format=csv output=DC_heat.csv   symb=y_d';

