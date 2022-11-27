function plotcov(a1,a2,b1,b2,p1,xmin,ymin,b )%a1，a2均值，b1,b2方差,p1相关系数,b坐标的长度
x=xmin:0.5:xmin+b;
y=ymin:0.5:ymin+b;
u1 = a1;          %均值
u2 = a2;        
sigma1 = b1;      %方差
sigma2 = b2;
rou = p1;     %相关系数
mu=[-1,2];
[X,Y]=meshgrid(x,y); % 产生网格数据并处理
p = 1/(2*pi*sigma1*sigma2*sqrt(1-rou*rou)).*exp(-1/(2*(1-rou^2)).*[(X-u1).*(X-u1)/(sigma1*sigma1)-2*rou*(X-u1).*(Y-u2)/(sigma1*sigma2)+(Y-u2).*(Y-u2)/(sigma2*sigma2)]);
subplot(1,2,1)
figure(1)
subplot(1,2,1)
mesh(X,Y,p)
subplot(1,2,2)
s = surf(X,Y,p);
%s.EdgeColor = 'g';
shading interp
colorbar
end

