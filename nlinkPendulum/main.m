%%%MAIN
%%%derives rhs function, calls ode45 to solve, plots, energy, animation,
clc; clear all; close all;

%nlinkderive()
p.N=2; p.g = 9.81;
for i = 1:p.N
    p.d(i) = 0.5;
    p.L(i) = 1;
    p.m(i) = 0.1;
    p.Ig(i) = p.m(i)*p.L(i)^2*(1/12);
end

%%% INITIALIZE INITIAL CONDITIONS
z0 = [];
z0(1:p.N) = (pi/2)*ones(1,length(p.N));
z0(p.N+1:p.N*2) = (0)*ones(1,length(p.N));
z0 = [pi/2; pi/2; 0.01; 0];
tspan = [0,5];
options=odeset('abstol',1e-6,'reltol',1e-6);

%solving, plotting, and animation 2 ways: sinmple rhs and DAE
[tarray, zarray] = ode45(@(t,z) nlinkrhs(t,z,p),tspan,z0,options);

figure()
plot(tarray,zarray(:,1),tarray,zarray(:,2),tarray,zarray(:,3),tarray,zarray(:,4));
xlabel('time (s)'); ylabel('theta (rad)')
legend('theta1', 'theta2','theta3', 'theta4')
title('n-link pendulum')

%tail end of link1
x1 = p.L(1)*cos(zarray(:,1)); y1 = p.L(2)*sin(zarray(:,1)); 
%tail end of link2
x2 = x1 + p.L(2).*cos(zarray(:,2)); y2 = y1 + p.L(2).*sin(zarray(:,2));

anim_doublepend(x1,x2,y1,y2,tarray)

function zdot = nlinkrhs(t,z,p)
    disp(t)
    % Eom are M*thetaddots = b;
%     th1 = z(1);
%     th2 = z(2);
%     th3 = z(3);
%     th4 = z(4);
%     th1dot = z(5);
%     th2dot = z(6);
%     th3dot = z(7);
%     th4dot = z(8);

    ths = sym('th',[1 p.N],'real');
    ths(1:p.N) = z(1:p.N);
    thdots = sym('thdot',[1 p.N],'real');
    thdots(1:p.N) = z(p.N+1:p.N*2);
    

%     thdots = mat2cell(thdots,1,ones(1,numel(thdots)));
%     M_L = tryM(thdots{:}); %PROBLEM HERE, WHAT VARS
%     b_L = tryR();

%     M_L = tryM(Ig1,Ig2,L1,d1,d2,m1,m2,th1,th2,thdot1,thdot2);
%     b_L = tryR(Ig1,Ig2,L1,d1,d2,g,m1,m2,th1,th2,thdot1,thdot2);
      %M_L = tryM([p.Ig],[p.L],[p.d],[p.m],[ths],[thdots]);
      M_L = tryM(p.Ig(1),p.Ig(2),p.L(1),p.d(1),p.d(2),p.m(1),p.m(2),ths(1),ths(2),thdots(1),thdots(2));
      %b_L = tryR(9.81,[p.Ig],[p.L],[p.d],[p.m],[ths],[thdots]);
      b_L = tryR(p.Ig(1),p.Ig(2),p.L(1),p.d(1),p.d(2),p.m(1),p.m(2),ths(1),ths(2),thdots(1),thdots(2));
    
    % Eom are M*thetaddots = b;
    %@(I1,I2,L1,d1,d2,m1,m2,th1,th2)
    %M_L = M_L_fun(IG1,IG2,ell1,d1,d2,m1,m2,th1,th2);
    %@(L1,d1,d2,g,m1,m2,th1,th2,th1dot,th2dot)
    %b_L = b_L_fun(ell1,d1,d2,g,m1,m2,th1,th2,th1dot,th2dot);
    
    thddots = M_L\b_L;
    thddotsd = [];
    for i = 1:p.N
        thddotsd(i) = double(thddots(i));
    end
    thdotsd = [];
    for i = 1:p.N
        thdotsd(i) = double(thdots(i));
    end
    
%     th1ddot = double(thddots(1));
%     th2ddot = double(thddots(2));
%     th3ddot = double(thddots(3));
%     th4ddot = double(thddots(4));
    
    zdot = [thdotsd(:);thddotsd(:)] ; 
end

function anim_doublepend(x1,x2,y1,y2,tarray)
    figure()

    plot(0,0,'+','MarkerSize',20,'LineWidth',20)  %Origin
    axis([-3 3 -3 3])
        xlabel('x motion (m)')
        ylabel('y motion (m)')
    hold on

    % Plot tail ends of links at time = 0; 
    link1end = plot(x1(1),y1(1), '.', 'MarkerSize',50);
    link2end = plot(x2(1),y2(1), '.', 'MarkerSize',50);
    link1 = plot([0,x1(1)],[0,y1(1)],'-','LineWidth', 4); 
    link2 = plot([x1(1),x2(1)],[y1(1),y2(1)],'-','LineWidth', 4);
    %Animation loop
    for t = 2:length(tarray) 
        linkx1= x1(t); linky1 = y1(t);
        linkx2= x2(t); linky2 = y2(t);

        %update end positions
        link1end.XData = linkx1;
        link1end.YData = linky1;
        link2end.XData = linkx2;
        link2end.YData = linky2;

        link1.XData = [0,linkx1];
        link1.YData = [0,linky1];
        link2.XData = [linkx1,linkx2];
        link2.YData = [linky1,linky2];

        drawnow
    end
    legend('Origin','link1tail','link2tail','link1','link2')
end