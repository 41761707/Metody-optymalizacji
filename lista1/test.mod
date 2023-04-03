var b1 >= 0;
var b1_oil_home >= 0;
var b1_oil_heavy >= 0;
var b1_dist_crack >= 0;
var b1_dist_heavy >= 0;
var b2 >= 0;
var b2_oil_home >= 0;
var b2_oil_heavy >= 0;
var b2_dist_crack >= 0;
var b2_dist_heavy >= 0;

minimize cost: 1310*b1 + 1510*b2 + 20*b1_dist_crack + 20*b2_dist_crack;

s.t. petrol: 
    0.15*b1 + 0.1*b2 + 0.5*b1_dist_crack + 0.5*b2_dist_crack >= 200000;
s.t. home: 
    b1_oil_home + b2_oil_home + 0.2*b1_dist_crack + 0.2*b2_dist_crack >= 400000;
s.t. heavy: 
    b1_oil_heavy + b1_dist_heavy + 0.15*b1 + b2_oil_heavy + b2_dist_heavy + 0.25*b2 + 0.06*b1_dist_crack + 0.06*b2_dist_crack >= 250000;

s.t. b1_oil: b1_oil_home + b1_oil_heavy == 0.4*b1;
s.t. b2_oil: b2_oil_home + b2_oil_heavy == 0.35*b2;
s.t. b1_dist: b1_dist_crack + b1_dist_heavy == 0.15*b1;
s.t. b2_dist: b2_dist_crack + b2_dist_heavy == 0.2*b2;

s.t. limits: 
    0.002 * b1_oil_home + 0.003 * b1_dist_crack * 0.2 + 0.012 * b2_oil_home + 0.025 * b2_dist_crack * 0.2 <= (b1_oil_home + b2_oil_home + b1_dist_crack*0.2 + b2_dist_crack*0.2)*0.005;

solve;

display cost;

end;