var a1 >= 0;
var a2 >= 0;
var a3 >= 0;

var b1 >= 0;
var b2 >= 0;
var b3 >= 0;

var c1 >= 0;
var c2 >= 0;
var c3 >= 0;

var d1 >= 0;
var d2 >= 0;
var d3 >= 0;

subject to a_max : a1 + a2 + a3 <= 400;
subject to b_max : b1 + b2 + b3 <= 100;
subject to c_max : c1 + c2 + c3 <= 150;
subject to d_max : d1 + d2 + d3 <= 500;

subject to m_1_max : 12*a1 + 20*b1 + 15 * c1 + 15 * d1 <= 60;
subject to m_2_max : 6*a1 + 10*b1 + 12 * c1 + 30 * d1 <= 60;
subject to m_3_max : 10*a1 + 15*b1 + 20 * c1 + 60 * d1 <= 60;


solve;

data;

end;