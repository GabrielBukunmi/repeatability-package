function [] = pl(sol)

fontsz = 14;

figure1 = figure('Color',[1 1 1],'units','normalized','outerposition',[0 0 1 1]);

subplot1 = subplot(3,4,1,'Parent',figure1);
hold(subplot1,'on');  
plot(sol.Time,sol.Solution(1,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{1}$','Interpreter','latex');
box(subplot1,'on');
hold(subplot1,'off');
set(subplot1,'FontSize',fontsz);

subplot2 = subplot(3,4,2,'Parent',figure1);
hold(subplot2,'on');  
plot(sol.Time,sol.Solution(2,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{2}$','Interpreter','latex');
box(subplot2,'on');
hold(subplot2,'off');
set(subplot2,'FontSize',fontsz);

subplot3 = subplot(3,4,3,'Parent',figure1);
hold(subplot3,'on');  
plot(sol.Time,sol.Solution(3,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{3}$','Interpreter','latex');
box(subplot3,'on');
hold(subplot3,'off');
set(subplot3,'FontSize',fontsz);

subplot4 = subplot(3,4,4,'Parent',figure1);
hold(subplot4,'on');  
plot(sol.Time,sol.Solution(4,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{4}$','Interpreter','latex');
box(subplot4,'on');
hold(subplot4,'off');
set(subplot4,'FontSize',fontsz);

subplot5 = subplot(3,4,5,'Parent',figure1);
hold(subplot5,'on');  
plot(sol.Time,sol.Solution(5,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{5}$','Interpreter','latex');
box(subplot5,'on');
hold(subplot5,'off');
set(subplot5,'FontSize',fontsz);

subplot6 = subplot(3,4,6,'Parent',figure1);
hold(subplot6,'on');  
plot(sol.Time,sol.Solution(6,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{6}$','Interpreter','latex');
box(subplot6,'on');
hold(subplot6,'off');
set(subplot6,'FontSize',fontsz);

subplot7 = subplot(3,4,7,'Parent',figure1);
hold(subplot7,'on');  
plot(sol.Time,sol.Solution(7,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{7}$','Interpreter','latex');
box(subplot7,'on');
hold(subplot7,'off');
set(subplot7,'FontSize',fontsz);

subplot8 = subplot(3,4,8,'Parent',figure1);
hold(subplot8,'on');  
plot(sol.Time,sol.Solution(8,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{8}$','Interpreter','latex');
box(subplot8,'on');
hold(subplot8,'off');
set(subplot8,'FontSize',fontsz);

subplot9 = subplot(3,4,9,'Parent',figure1);
hold(subplot9,'on');  
plot(sol.Time,sol.Solution(9,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{9}$','Interpreter','latex');
box(subplot9,'on');
hold(subplot9,'off');
set(subplot9,'FontSize',fontsz);

subplot10 = subplot(3,4,10,'Parent',figure1);
hold(subplot10,'on');  
plot(sol.Time,sol.Solution(10,:),'LineWidth',2); 
xlabel('time (s)'); 
ylabel('$x_{10}$','Interpreter','latex');
box(subplot10,'on');
hold(subplot10,'off');
set(subplot10,'FontSize',fontsz);