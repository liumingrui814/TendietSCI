#### ICP (iterative closest point) 迭代最邻近法

ICP完成的事情我们已经是了然于心的，在这篇推导中，使用$P_s$作为新一帧的点云，$P_t$作为原有的点云，目标是找到$R,t$使得$P_s(source)$配准到$P_t(target)$, 使得配准误差最小，即：
$$
R*,t* = \arg \min_{R,t} \frac{1}{|P_s|}\sum_{i=1}^{|P_s|}||p_t^i - (R.p^i_s+t)||^2
$$

##### 推导ICP的最优平移

对$loss$函数对平移量进行求导，与复合函数求导同理得：

$\begin{align} \frac{\partial L}{\partial t} = \sum_{i=1}^{|P_s|}2(R.p_s^i+t-p_t^i) = 2|P_s|t+2R\sum_{i=1}^{|P_s|}p_s^i - 2\sum_{i=1}^{|P_s|}p_t^i = 0 \end{align}$

$\begin{align} t = \frac{1}{|P_s|}\sum_{i=1}^{|P_s|} p_t^i -R\frac{1}{|P_s|}\sum_{i=1}^{|P_s|}p_s^i \end{align}$,可以看到这是两个质心，质心用符号$\bar{p_t},\bar{p_s}$表示，即$t = \bar{p_t}-R\bar{p_s}$, 对于每个$R$, 都能计算出一个对应的$t$使得上述损失函数最小。

##### 推导ICP的最优旋转

在推导最优旋转时需要先消除最优平移的影响以简便计算，即找到一个平移量，在这个平移量条件下计算最优旋转，也就可以用于指代最优旋转。为了简便，不妨将两个点云$P_s,P_t$在平移上的量消除（即全部换到质心坐标系）。

令点$\hat{p}_s^i = p_s^i - \bar{p}_s^i,\hat{p}_t^i = p_t^i - \bar{p}_t^i$, 则最邻近的损失变为
$$
Loss(R) = \sum_{i=1}^{|P_s|}||R.\hat{p}_s^i-\hat{p}_t^i||^2
$$
结合向量模的化简方法（注意标量的转置就是标量本身这一向量级别的性质）

$\begin{align} Loss(R) &= \sum_{i=1}^{|P_s|}(R.\hat{p}_s^i-\hat{p}_t^i)^T(R.\hat{p}_s^i-\hat{p}_t^i) =   ||\hat{p}_h^i||^2 + ||\hat{p}_t^i||^2 - 2(\hat{p}_t^i)^TR\hat{p}_s^i \end{align}$

则等价于求解$\begin{align} Loss(R) = \arg \min_{R} -\sum_{i=1}^{||P_s||}2(\hat{p}_t^i)^TR\hat{p}_s^i = \arg \max_{R} \sum_{i=1}^{||P_s||}2(\hat{p}_t^i)^TR\hat{p}_s^i\end{align}$,

结合线性代数的知识以及一直以来的工程习惯，考虑将上面的式子用整个点云$P_s,P_t$来描述。对于一组数据，标准来说都是需要在列方向上延拓，即$\begin{align} P_s = [p_{s1},p_{s2},...,p_{sN}]_{(3\times N)}\end{align}$,  因此将上面的求和式用$P_s,P_t$就是：
$$
\begin{align} 
\arg \max_{R} \sum_{i=1}^{||P_s||}2(\hat{p}_t^i)^TR\hat{p}_s^i = 
\arg \max_R \space trace(
\begin{bmatrix}\hat{p}_t^{1T} \\  \hat{p}_t^{2T} \\ ... \\\hat{p}_t^{NT}\end{bmatrix}.
R
.[\hat{p}_s^1,\hat{p}_s^2,...,\hat{p}_s^N]) = trace([\hat{p}_t^{iT}R\hat{p}_s^j]_{(N\times N)})
\end{align}
$$
即$\arg \max_R \space trace(P_t^T R P_s) = \arg \max_R \space trace(RP_sP_t^T )$, 此时的$P_sP_t^T$是个$3\times3$的矩阵，对其进行奇异值分解（SVD分解，即$P_sP_t^T=P\Gamma Q^T$, 结合SVD的性质可知P，Q均正交，即上述式子变为求$\arg \max_R \space trace(\Gamma. Q^TRP)$,$\Gamma$是奇异值的对角矩阵，另外三个正交矩阵整合成一个正交矩阵$M_{ij}=[m_{ij}]_{3\times 3}$

由于单位矩阵的每个元素绝对值都不大于1，且奇异值均为正（$A^TA$形式的对称矩阵是半正定的），则可知当$M=E_{(3\times 3)}$时能够取得上式的最大值，即$Q^TRP=E_{(3\times 3)},R=QP^T$

上述的讨论却并不是完善的，此时仍然存在两种情况：

①$||QP^T||=1$,这就是标准的旋转矩阵

②$||QP^T||=-1$,此时说明$||M||=-1$,上述使得$M=E$的情况不可能存在，此时使得$\Gamma M$最大的$M=\begin{bmatrix}1& 0& 0\\ 0 & 1& 0\\0&0&-1 \end{bmatrix}$（要求$\Gamma$的奇异值要从大到小排）

因此结合上述两种情况，$R = QMP^T=Q\begin{bmatrix}1& 0& 0\\ 0 & 1& 0\\0&0&|QP^T| \end{bmatrix}P^T$,即ICP得到的最优的旋转矩阵。

