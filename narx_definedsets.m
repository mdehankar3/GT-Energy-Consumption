clear all
close all
%Read data
data = tdfread('ATHASSOC.017.csv.out');
X1 = cell(1,length(data.Code));
Y1 = cell(1,length(data.Code));
for i = 1:length(data.Code)
        X1{1,i} = [data.Code(i);data.Area(i);data.Age(i);data.Hour(i);data.Minute(i);data.Year(i);data.Month(i);data.Date(i);data.Type(i);data.Day(i);data.Season(i)];
        Y1{1,i} = data.Record(i);
end

%%
%Define model parameters
d1 = [1:48];
d2 = [1:48];

net = narxnet(d1,d2,25);
net.divideFcn = 'divideind';
net.divideParam.trainInd = 1:70061;
net.divideParam.valInd = 70062:103463;
net.divideParam.testInd = 103464:138595;

[x,xi,ai,t] = preparets(net,X1,{},Y1);
[net trr]= train(net,x,t,xi,ai);
y = net(x,xi,ai);
perf = perform(net,t,y)
plotperf(trr)
view(net)
e = gsubtract(y,t);
rmse = sqrt(mse(e))
TS1 = size(t,2);
figure,plot(1:TS1,cell2mat(t),'b',1:TS1,cell2mat(y),'r')
