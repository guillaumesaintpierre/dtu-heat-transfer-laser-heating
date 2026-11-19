% Transient laser heating of a 316L steel plate: explicit finite volumes.
% Transcribed and reformatted from Appendix A of the DTU 41814 team report.
% The report discloses Claude assistance in preparing the original MATLAB
% appendix; see docs/CONTRIBUTIONS_AND_DISCLOSURE.md.
%
% A 5x5 nodal grid on a 4 cm x 4 cm cross section is used; unit depth.
% Cases: (1) uniform absorbed surface flux; (2) same flux plus a
% position-dependent shielding-gas convection coefficient.
%
% This copy preserves the numerical scheme in the submitted report.
% Figure output paths are organized under figures/ for GitHub use.

clear; clc; close all;

%% Geometry and grid
nx = 5; ny = 5;
lx = 0.04; ly = 0.04;  % m
nn = nx*ny;
dx = lx/(nx-1); dy = ly/(ny-1);
x = linspace(-lx/2, lx/2, nx);
y = linspace(0, ly, ny);  % positive downward

%% Constant 316L properties used in the report (approximately 446 K)
k = 16.25;           % W/(m K)
rho = 7889;          % kg/m^3
cp = 518.3;          % J/(kg K)
alpha = k/(rho*cp);  % m^2/s

%% Time integration
dt = 2; tend = 10;   % s; separate baseline run extended to 50 s
t = 0:dt:tend;
nt = numel(t);
Fo = alpha*dt/dy^2;

%% Laser and shielding gas
q = 0.35*3000/(pi*0.02^2);    % absorbed heat flux, W/m^2
Tinf = 20; Tinit = 20; Tbot = 20;  % deg C
h = @(xx) 100 + 900*exp(-log(9/2)*(xx/0.01).^2); % W/(m^2 K)
Bi = h(x)*dx/k;

%% Explicit coefficient positivity and time-step bound
Fo_lim = 1/(4 + 2*max(Bi));
fprintf('Maximum Biot number: %.3f\n',max(Bi));
fprintf('Fo = %.4f, allowable Fo <= %.4f\n',Fo,Fo_lim);
fprintf('Maximum dt with convection: %.2f s (used %.2f s)\n',Fo_lim*dy^2/alpha,dt);
assert(Fo <= Fo_lim,'Unstable explicit time step with convection.');

if ~exist('figures','dir')
    mkdir('figures');
end

%% Execute baseline and shielding-gas cases
names = {'Baseline','Shielding gas'};
Tfield = cell(1,2);
Tall = cell(1,2);
for conv = 0:1
    [A,B] = build_AB(conv,nx,ny,Fo,q,k,dx,Bi,Tinf,Tbot);
    aP = diag(A);
    aP = aP(1:(ny-1)*nx);  % exclude fixed-temperature bottom nodes
    fprintf('%s: smallest a_P = %.3f\n',names{conv+1},min(aP));
    T = run_explicit(A,B,nt,Tinit);
    if conv == 0
        A0 = A; B0 = B;
    end
    Tall{conv+1} = T;
    Tfield{conv+1} = reshape(T(:,end),nx,ny)';
end

%% Semi-infinite analytical comparison at 10 and 20 seconds
for tv = [10 20]
    Tv = run_explicit(A0,B0,tv/dt + 1,Tinit);
    numeric = reshape(Tv(:,end),nx,ny)';
    analytical = analytical_semifinite(y,tv,q,k,alpha,Tinit);
    fprintf('\nt = %.0f s\n y(cm)  Analytical(C)  FVM(C)  Error(K)\n',tv);
    fprintf('%6.1f  %12.2f  %7.2f  %+8.2f\n', ...
        [100*y(:),analytical(:),numeric(:,3),numeric(:,3)-analytical(:)]');
end

%% Uniformity across x in the baseline case
R = reshape(Tall{1},nx,ny,nt);
spread = max(max(R,[],1)-min(R,[],1),[],3);
fprintf('\nMaximum x-spread by depth row (K): ');
fprintf('%.3e ',spread);
fprintf('\n');

%% Shielding-gas convection coefficient
xx = linspace(-0.02,0.02,400);
figure;
plot(xx*100,h(xx),'LineWidth',1.5); hold on;
plot(x*100,h(x),'o','MarkerSize',6);
xlabel('x (cm)'); ylabel('h (W/(m^2 K))');
legend('h(x)','Grid nodes','Location','best'); grid on;
saveas(gcf,fullfile('figures','h_of_x_matlab.png'));

%% Temperature fields at 10 s with common colour limits
cl = [min([Tfield{1}(:);Tfield{2}(:)]), ...
      max([Tfield{1}(:);Tfield{2}(:)])];
figure;
for i = 1:2
    subplot(1,2,i);
    contourf(x*100,y*100,Tfield{i},linspace(cl(1),cl(2),21));
    set(gca,'YDir','reverse'); caxis(cl); axis equal tight;
    xlabel('x (cm)'); ylabel('y (cm)'); title(names{i});
end
colorbar('Position',[0.93 0.2 0.02 0.6]);
saveas(gcf,fullfile('figures','contours_10s_baseline_vs_gas.png'));

%% Comparison of temperature vs depth at 10 s
figure;
plot(y*100,Tfield{1}(:,3),'o-', ...
     y*100,Tfield{2}(:,3),'s-', ...
     y*100,Tfield{2}(:,1),'s--');
xlabel('y (cm)'); ylabel('T (deg C)');
legend('Baseline','Shielding gas: centre','Shielding gas: edge', ...
       'Location','best'); grid on;
saveas(gcf,fullfile('figures','Centerline_10s.png'));

%% Baseline at 50 s (part j in the assignment)
tend50 = 50;
assert(mod(tend50,dt)==0,'50 s must be divisible by dt.');
T50 = run_explicit(A0,B0,tend50/dt + 1,Tinit);
field50 = reshape(T50(:,end),nx,ny)';
Tana50 = analytical_semifinite(y,tend50,q,k,alpha,Tinit);
fprintf('\nBaseline at 50 s\n y(cm)  FVM(C)  Analytical(C)  Difference(K)\n');
fprintf('%6.1f  %7.2f  %13.2f  %+12.2f\n', ...
        [100*y(:),field50(:,3),Tana50(:),field50(:,3)-Tana50(:)]');

figure;
yfine = linspace(0,ly,300);
plot(yfine*100,analytical_semifinite(yfine,tend50,q,k,alpha,Tinit), ...
     '-','LineWidth',1.5); hold on;
plot(y*100,field50(:,3),'o--','LineWidth',1.2);
xlabel('y (cm)'); ylabel('T (deg C)');
legend('Semi-infinite analytical','Explicit FVM (5 nodes)', ...
       'Location','best'); title('Baseline at t = 50 s'); grid on;
saveas(gcf,fullfile('figures','comparison_50s.png'));

fprintf('\nSurface temperatures at 10s: baseline %.1f C, gas centre %.1f C\n', ...
        Tfield{1}(1,3),Tfield{2}(1,3));

%% Local functions (MATLAB R2016b or newer)
function [A,B] = build_AB(conv,nx,ny,Fo,q,k,dx,Bi,Tinf,Tbot)
    % Index order: node i + (j-1)*nx, with top row j=1.
    A = zeros(nx*ny);
    B = zeros(nx*ny,1);
    for j = 1:ny
        for i = 1:nx
            node = i + (j-1)*nx;
            if j == ny
                B(node) = Tbot;               % bottom Dirichlet row
            elseif j == 1
                c = conv*Bi(i);
                A(node,node) = 1 - 4*Fo - 2*Fo*c;
                if i == 1
                    A(node,node+1) = 2*Fo;
                elseif i == nx
                    A(node,node-1) = 2*Fo;
                else
                    A(node,node-1) = Fo;
                    A(node,node+1) = Fo;
                end
                A(node,node+nx) = 2*Fo;
                B(node) = 2*Fo*(q*dx/k + c*Tinf);
            elseif i == 1
                A(node,node) = 1 - 4*Fo;
                A(node,node+1) = 2*Fo;
                A(node,node+nx) = Fo;
                A(node,node-nx) = Fo;
            elseif i == nx
                A(node,node) = 1 - 4*Fo;
                A(node,node-1) = 2*Fo;
                A(node,node+nx) = Fo;
                A(node,node-nx) = Fo;
            else
                A(node,node) = 1 - 4*Fo;
                A(node,node-1) = Fo;
                A(node,node+1) = Fo;
                A(node,node+nx) = Fo;
                A(node,node-nx) = Fo;
            end
        end
    end
end

function T = run_explicit(A,B,nt,Tinit)
    T = zeros(numel(B),nt);
    T(:,1) = Tinit;
    for m = 2:nt
        T(:,m) = A*T(:,m-1) + B;
    end
end

function T = analytical_semifinite(y,t,q,k,alpha,Tinit)
    % Semi-infinite solid with constant surface heat flux.
    eta = y./(2*sqrt(alpha*t));
    T = Tinit + (2*q/k)*sqrt(alpha*t/pi).*exp(-eta.^2) ...
        - (q.*y/k).*erfc(eta);
end
