# DAS系统硬件详细分析：第十部分 - Gauge Length差分

## 10. Gauge Length 差分

### 10.1 概念介绍

**Gauge Length** 是指用来计算应变或振动的参考长度。在DAS系统中，不是简单地使用两个相邻采样点的相位差，而是使用特定长度（Gauge Length）内的相位变化。

#### 10.1.1 定义

设光纤上距离起点 $z$ 处、长度为 $\Delta z_{GL}$ 的光纤段的相位为：

$$\phi_k(t) = \phi(z_k, t)$$

其中 $z_k = k \cdot \Delta z_{spatial}$，$`k = 0, 1, 2, ..., N-1`$

**Gauge Length应变估计**：
$$\varepsilon_{GL}(z, t) = \frac{1}{L_{GL}} [\phi(z + L_{GL}/2, t) - \phi(z - L_{GL}/2, t)]$$

或者更简单的形式（两个采样点）：
$$\Delta\phi(z, t) = \phi(z + \Delta z, t) - \phi(z, t)$$

### 10.2 Gauge Length的选择

#### 10.2.1 空间分辨率与Gauge Length的权衡

**空间分辨率**由脉冲宽度决定（已在第三部分讨论）：
$$\delta z_{pulse} = \frac{c \tau}{2 n_{eff}} \approx 10 \text{ m}$$

**Gauge Length**通常应该是脉冲宽度的整数倍：
$$L_{GL} = M \times \delta z_{pulse}$$

其中 $M = 1, 2, 4, 8, ...$

**影响**：
- $L_{GL}$ 越小 → 空间分辨率越高，但噪声越大
- $L_{GL}$ 越大 → 噪声越小，但空间分辨率降低

#### 10.2.2 典型Gauge Length选择

| 应用场景 | 推荐 $L_{GL}$ | 说明 |
|---------|----------|------|
| 高精度应变监测 | 10-50 m | 对应1-5个脉冲宽度 |
| 管道监测 | 50-100 m | 常规应用 |
| 地震勘探 | 100-500 m | 需要更好的信噪比 |
| 长距离监测 | 500-1000 m | 极端低信噪比 |

#### 10.2.3 Gauge Length与信噪比的关系

假设噪声与长度的平方根反比：

$$SNR \propto \sqrt{L_{GL}}$$

或者说，Gauge Length增加4倍，SNR提高2倍（6 dB）。

**数学表达式**：
$$SNR_{GL} = SNR_{0} \times \sqrt{\frac{L_{GL}}{L_0}}$$

其中 $SNR_0$ 是参考Gauge Length $L_0$ 时的SNR。

### 10.3 差分计算方法

#### 10.3.1 一阶差分（单个Gauge Length）

**最简单的情况**：使用相邻两个采样点

$$\Delta\phi_k(t) = \phi_k(t) - \phi_{k-1}(t)$$

这对应的应变（假设线性应变分布）：
$$\varepsilon_k(t) = \frac{\Delta\phi_k(t)}{2\pi} \times \frac{\lambda}{p_e L_{GL}}$$

其中 $L_{GL}$ 是两个采样点之间的距离。

#### 10.3.2 多个Gauge Length的组合

可以使用多个不同长度的差分来提高抗噪性或获得多尺度信息。

**两个不同长度**：
- 短Gauge Length ($L_{GL,s}$)：高空间分辨率，高噪声
- 长Gauge Length ($L_{GL,l}$)：低噪声，低空间分辨率

**加权组合**：
$$\Delta\phi_{combined}(t) = w_s \Delta\phi_s(t) + w_l \Delta\phi_l(t)$$

其中权重 $w_s + w_l = 1$

#### 10.3.3 有限差分滤波

使用FIR滤波器实现Gauge Length差分：

**中心差分（二阶精度）**：
$$\Delta\phi_k = \frac{\phi_{k+1} - \phi_{k-1}}{2}$$

**前向差分**：
$$\Delta\phi_k = \phi_{k+1} - \phi_k$$

**后向差分**：
$$\Delta\phi_k = \phi_k - \phi_{k-1}$$

**高阶差分**（减少量化噪声）：
$$\Delta\phi_k = \frac{-\phi_{k+2} + 8\phi_{k+1} - 8\phi_{k-1} + \phi_{k-2}}{12}$$

这是四阶精度的中心差分。

### 10.4 噪声放大与滤波

#### 10.4.1 差分噪声放大

相位差分会放大高频噪声：

**原始相位噪声的功率谱**：
$$S_\phi(f)$$

**差分后的噪声功率谱**：
$$S_{\Delta\phi}(f) = |1 - e^{j2\pi f T}|^2 S_\phi(f) = 4\sin^2(\pi f T) S_\phi(f)$$

其中 $T$ 是采样周期。

**在高频处**，噪声被放大 $\approx (2\pi f)^2$ 倍！

#### 10.4.2 高通滤波特性

差分本质上是一个高通滤波器：

**频率响应**：
$$H(f) = 1 - e^{j2\pi f T} \approx j 2\pi f T$$

所以差分会去除直流和低频趋势，但放大高频噪声。

**解决方案**：
1. **先滤波后差分**：用低通滤波器→再进行差分
2. **结合低通和高通**：带通滤波
3. **自适应滤波**：根据信号特性调整滤波参数

#### 10.4.3 Savitzky-Golay滤波（平滑微分）

结合平滑和微分，避免纯差分的噪声放大。

**方法**：
1. 在滑动窗口内拟合多项式
2. 使用多项式的导数作为微分结果

**优点**：
- 保留高频信号
- 有效抑制噪声
- 无相位失真（线性相位）

**例子**（5点Savitzky-Golay，一阶导数）：
$$\Delta\phi_k = \frac{-2\phi_{k-2} - \phi_{k-1} + \phi_{k+1} + 2\phi_{k+2}}{10}$$

### 10.5 多通道Gauge Length处理

在实际DAS系统中，有许多沿光纤分布的采样通道。

#### 10.5.1 空间矩阵形式

设有 $N$ 个采样点，时间上有 $M$ 个采样：

$$\Phi = \begin{bmatrix} \phi_1(t_1) & \phi_1(t_2) & \cdots & \phi_1(t_M) \\ \phi_2(t_1) & \phi_2(t_2) & \cdots & \phi_2(t_M) \\ \vdots & \vdots & \ddots & \vdots \\ \phi_N(t_1) & \phi_N(t_2) & \cdots & \phi_N(t_M) \end{bmatrix}$$

**差分操作**（沿空间方向）：
$$\Delta\Phi = D \times \Phi$$

其中 $D$ 是差分矩阵：
$`D = \begin{bmatrix} 1 & -1 & 0 & \cdots & 0 \\ 0 & 1 & -1 & \cdots & 0 \\ \vdots & \vdots & \ddots & \ddots & \vdots \\ 0 & 0 & \cdots & 1 & -1 \end{bmatrix}`$

### 10.6 应变计算

#### 10.6.1 从相位差到应变

光纤应变与相位变化的关系：

$$\varepsilon = \frac{\Delta\phi / (2\pi)}{\Delta n_{eff} + \Delta \rho}$$

其中：
- $\Delta n_{eff}$ 是有效折射率的变化
- $\Delta \rho$ 是应变光学效应

**简化形式**（对于1550 nm光纤）：
$$\varepsilon = \frac{\Delta\phi}{2\pi \times 2.1}$$

或者用微应变（μstrain）表示：
$$\varepsilon [\mu\text{strain}] = \frac{\Delta\phi [rad]}{2\pi} \times 476 \text{ μstrain/rad}$$

**示例**：
- $\Delta\phi = 0.1$ rad
- $\varepsilon = 0.1/(2\pi) \times 476 \approx 7.6$ μstrain

#### 10.6.2 振动速度计算

应变随时间的变化给出应变速率，这与振动相关：

$$\dot{\varepsilon}(z, t) = \frac{d\varepsilon}{dt} = \frac{1}{2\pi \times 2.1} \times \frac{d\Delta\phi}{dt}$$

对于某些应用（如地震监测），还需要通过积分得到位移：

$$u(z, t) = \int_0^t v(z, \tau) d\tau$$

其中 $v$ 是振动速度。

### 10.7 多尺度Gauge Length处理

#### 10.7.1 拉普拉斯金字塔

建立多个不同Gauge Length的层级：

1. **第0层**：原始相位 $\phi_0(z,t) = \phi(z,t)$
2. **第1层**：相位差 $\Delta\phi_1(z,t) = \phi_0(z+\Delta z,t) - \phi_0(z,t)$
3. **第2层**：二阶差 $\Delta\phi_2(z,t) = \Delta\phi_1(z+2\Delta z,t) - \Delta\phi_1(z,t)$
4. **等等**

每一层代表不同尺度的信息：
- 低层（小Gauge Length）：高频信息
- 高层（大Gauge Length）：低频信息

#### 10.7.2 小波变换方法

使用连续小波变换提取多尺度信息：

$$W(z, s) = \int \phi(\xi) \psi\left(\frac{\xi - z}{s}\right) d\xi$$

其中 $s$ 是尺度参数，对应Gauge Length。

---

## 总结表

| 参数 | 符号 | 单位 | 推荐值 | 说明 |
|-----|------|------|--------|------|
| Gauge Length | $L_{GL}$ | m | 10-500 | 取决于应用 |
| 相位差 | $\Delta\phi$ | rad | <π | 需要合理展开 |
| 应变灵敏度 | - | μstrain/rad | 476 | 1550 nm光纤 |
| 平滑窗口 | $2w+1$ | points | 5-21 | Savitzky-Golay |
| 多尺度层数 | L | - | 3-5 | 金字塔方法 |
