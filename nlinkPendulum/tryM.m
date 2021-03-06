function M_L = tryM(Ig1,Ig2,L1,d1,d2,m1,m2,th1,th2,thdot1,thdot2)
%TRYM
%    M_L = TRYM(IG1,IG2,L1,D1,D2,M1,M2,TH1,TH2,THDOT1,THDOT2)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    07-Feb-2021 20:22:42

t2 = Ig1.*thdot1;
t3 = Ig2.*thdot2;
t4 = L1.^2;
t5 = d1.^2;
t6 = d2.^2;
t7 = thdot1.^2;
t8 = thdot2.^2;
t9 = -th2;
t10 = m1.*t5.*thdot1;
t11 = m2.*t6.*thdot2;
t12 = t9+th1;
t13 = m2.*t4.*thdot1;
t15 = (t2.*thdot1)./2.0;
t16 = (t3.*thdot2)./2.0;
t17 = (m2.*t4.*t7)./2.0;
t18 = (m1.*t5.*t7)./2.0;
t19 = (m2.*t6.*t8)./2.0;
t14 = cos(t12);
t20 = L1.*d2.*m2.*t14.*thdot1;
t21 = L1.*d2.*m2.*t14.*thdot2;
t22 = t20.*thdot2;
t23 = t3+t11+t20;
t24 = t2+t10+t13+t21;
t25 = t15+t16+t17+t18+t19+t22;
t26 = dirac(t25);
t27 = sign(t25);
t28 = L1.*d2.*m2.*t14.*t27;
t29 = t23.*t24.*t26.*2.0;
t30 = t28+t29;
M_L = reshape([t24.^2.*t26.*2.0+t27.*(Ig1+m1.*t5+m2.*t4),t30,t30,t23.^2.*t26.*2.0+t27.*(Ig2+m2.*t6)],[2,2]);
