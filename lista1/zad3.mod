set Oils;

#Liczba ton ropy B1
var b1 >= 0;
#B1 na domowe paliwo
var b1_home >= 0;
#B1 na ciezie paliwo
var b1_heavy >= 0;
#B1 do destylacji w krakowaniu
var b1_distill_crack >= 0;
#B1 destlat na ciezkie paliwo
var b1_distill_heavy >= 0;
#Liczba ton ropy b2
var b2 >= 0;
#B2 na domowe paliwo
var b2_home >= 0;
#B2 na ciezie paliwo
var b2_heavy >= 0;
#B2 do destylacji w krakowaniu
var b2_distill_crack >= 0;
#B2 destlat na ciezkie paliwo
var b2_distill_heavy >= 0;

#Przeliczniki otrzymywanej benzyny w wyniku destylacji ropy
param petrol{Oils} >= 0;
#Przeliczniki otrzymywanego oleju w wyniku destylacji ropy
param oil{Oils} >= 0;
#Przeliczniki otrzymywanego destylatu w wyniku destylacji ropy
param distill{Oils} >= 0;
#Przeliczniki otrzymywanych resztek w wyniku destylacji ropy
param leftovers{Oils} >= 0;
#Ceny ropy za tonę
param price{Oils} >= 0;

#Sekcja przelicznikow operacji destylacji/krakowania
param petrol_crack >= 0;
param oil_crack >= 0;
param leftovers_crack >= 0;
param distill_oil_cost >= 0;
param distill_crack_cost >= 0;

#Sekcja przeliczników dotyczących minimalnej liczby wyprodukowanych paliw
param min_engine >= 0;
param min_home >= 0;
param min_heavy >= 0;

#Sekcja przeliczników dotyczących zawartości siarki
param sulphur_home >= 0;
param sulphur_b1 >= 0;
param sulphur_b2 >= 0;
param sulphur_b1_crack >= 0;
param sulphur_b2_crack >= 0;

#Minimalizacja funkcji celu, czyli kosztow przetworzenia
minimize cost_func : (price['B1'] + distill_oil_cost) * b1 + (price['B2'] + distill_oil_cost) * b2 + distill_crack_cost * b1_distill_crack + distill_crack_cost * b2_distill_crack ;

#Ograniczenie dotyczące liczby wyprodukowanego paliwa silnikowego
subject to engine : petrol['B1'] * b1 + petrol['B2'] * b2 + petrol_crack * b1_distill_crack + petrol_crack * b2_distill_crack >= min_engine ;
#Ograniczenie dotyczące liczby wyprodukowanego domowego paliwa
subject to home : b1_home + b2_home + oil_crack * b1_distill_crack + oil_crack * b2_distill_crack >= min_home ;
#Ograniczenie dotyczące liczby wyprodukowanego ciężkiego paliwa
subject to heavy : b1_heavy + b1_distill_heavy + distill['B1'] * b1 + b2_heavy + b2_distill_heavy + distill['B2'] * b2 + leftovers_crack * b1_distill_crack + leftovers_crack * b2_distill_crack >= min_heavy ;
#Ograniczenie odnośnie ilości oleju dla B1
subject to b1_oil : b1_home + b1_heavy == oil['B1'] * b1 ;
#Ograniczenie odnośnie ilości oleju dla B2
subject to b2_oil : b2_home + b2_heavy == oil['B2'] * b2 ;
#Ograniczenie odnośnie ilości destylatu dla B1
subject to b1_distill : b1_distill_crack + b1_distill_heavy == distill['B1'] * b1 ;
#Ograniczenie odnośnie ilości destylatu dla B2
subject to b2_distill : b2_distill_crack + b2_distill_heavy == distill['B2'] * b2 ;

#Ograniczenia dotyczące zawartości siarki
subject to limit : sulphur_b1 * b1_home + sulphur_b1_crack * b1_distill_crack * oil_crack + sulphur_b2  * b2_home + sulphur_b2_crack * b2_distill_crack * oil_crack <= (b1_home + b2_home + b1_distill_crack * oil_crack + b2_distill_crack * oil_crack) * sulphur_home;


solve;

display cost_func ;

data;
set Oils := B1 B2;

param petrol := 
    B1  0.15
    B2  0.1;

param oil :=
    B1  0.4
    B2  0.35;

param distill :=
    B1  0.15
    B2  0.2 ;

param leftovers :=
    B1 0.15
    B2 0.25 ;

param price :=
    B1 1300
    B2 1500 ;


param petrol_crack := 0.5 ;
param oil_crack := 0.2 ;
param leftovers_crack := 0.06 ;

param distill_oil_cost := 10 ;
param distill_crack_cost := 20 ;

param min_engine := 200000 ;
param min_home := 400000 ;
param min_heavy := 250000 ;

param sulphur_home := 0.005;
param sulphur_b1 := 0.002;
param sulphur_b2 := 0.012;
param sulphur_b1_crack := 0.003;
param sulphur_b2_crack := 0.025;

end;
