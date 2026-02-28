# DAS系统硬件详细分析：第三部分 - 脉冲调制

## 3. 脉冲调制 (Pulse Modulation: AOM/EOM)

### 3.1 调制的目的

在DAS系统中，脉冲调制用于：
1. **产生脉冲光** - 确定光信号在光纤中的位置
2. **时间编码** - 实现空间分辨率
3. **信号恢复** - 增强信噪比

### 3.2 物理原理

#### 3.2.1 声光调制器 (AOM - Acousto-Optic Modulator)

**基本原理**：
- 利用超声波在光学介质中产生的周期性折射率变化
- 入射光在折射率栅栏中发生衍射

**衍射方程（Bragg条件）**：
$$2 d \sin\theta = m\lambda$$

其中：
- $d$ = 声波波长（由超声频率决定）
- $\theta$ = Bragg角
- $m$ = 衍射阶数（通常取m=1）
- $\lambda$ = 光波长

**输出光强的调制**：
$$I_{out}(t) = I_0 \sin^2\left(\frac{\pi \nu_{RF}(t) t}{2}\right)$$

其中：
- $I_0$ = 输入光强
- $\nu_{RF}(t)$ = RF驱动频率（时变）

#### 3.2.2 电光调制器 (EOM - Electro-Optic Modulator)

**基于Pockels效应**：
光通过电光晶体时，晶体的折射率随外加电场变化：

$$n = n_0 - \frac{1}{2}n_0^3 r E$$

其中：
- $n_0$ = 零场时的折射率
- $r$ = 电光系数
- $E$ = 外加电场强度

**相位调制**：
$$\phi(t) = \frac{\pi V(t)}{2V_\pi}$$

其中：
- $V(t)$ = 外加电压（时变信号）
- $V_\pi$ = 使相位改变$`\pi`$的半波电压

**振幅调制（通过偏振器）**：
$$I_{out}(t) = I_0 \sin^2\left(\frac{\pi V(t)}{2V_\pi}\right)$$

### 3.3 脉冲参数设计

#### 3.3.1 脉冲宽度与空间分辨率

脉冲在光纤中传播的距离：
$$\Delta z = \frac{c \cdot \tau}{2 n_{eff}}$$

其中：
- $c$ = 光速（$`3 \times 10^8`$ m/s）
- $\tau$ = 脉冲宽度（时间）
- $n_{eff}$ = 光纤有效折射率（≈1.468）

**空间分辨率**：
$$\delta z = \Delta z = \frac{c \cdot \tau}{2 n_{eff}}$$

**示例计算**：
- 若 $\tau = 100$ ns，则 $\delta z = \frac{3 \times 10^8 \times 100 \times 10^{-9}}{2 \times 1.468} \approx 10.2$ m
- 若 $\tau = 10$ ns，则 $\delta z \approx 1.02$ m  
- 若 $\tau = 1$ ns，则 $\delta z \approx 0.102$ m

#### 3.3.2 脉冲重复频率与光纤长度的关系

为避免回波叠加，脉冲往返时间应小于脉冲重复周期：

$$T_{rep} > \frac{2 L n_{eff}}{c}$$

其中：
- $`T_{rep}`$ = 脉冲重复周期
- $`L`$ = 光纤传感长度

**脉冲重复频率**：
$$f_{rep} = \frac{1}{T_{rep}} < \frac{c}{2 L n_{eff}}$$

**示例**：对于 $L = 10$ km 的光纤
$$f_{rep} < \frac{3 \times 10^8}{2 \times 10^4 \times 1.468} \approx 10.2 \text{ kHz}$$

推荐选择 $f_{rep} = 5$ kHz（保留余量）

#### 3.3.3 占空比 (Duty Cycle)

$$DC = \frac{\tau}{T_{rep}} \times 100\%$$

通常 DC = 1-10% 是合理范围

**示例**：$`\tau = 100`$ ns，$`f_{rep} = 5`$ kHz
$$T_{rep} = \frac{1}{5000} = 200 \mu s = 2 \times 10^{-4} \text{ s}$$
$$DC = \frac{100 \times 10^{-9}}{2 \times 10^{-4}} = 5 \times 10^{-4} = 0.05\% $$

### 3.4 AOM与EOM的比较

| 特性 | AOM | EOM |
|------|-----|-----|
| 调制速率 | <200 MHz | >10 GHz |
| 响应时间 | 微秒级 | 纳秒级 |
| 功率消耗 | 1-5 W | <1 W |
| 衍射效率 | 60-80% | 95%+ |
| 成本 | 低 | 中等 |
| 适用场景 | 低频脉冲 | 高频脉冲 |
| 热效应 | 明显 | 小 |
| 频带 | <200 MHz | >10 GHz |

### 3.5 DAS系统中的选择

**应用场景参数**：
- 光纤长度：$`L = 10`$ km
- 目标空间分辨率：$`\delta z = 10`$ m
- 目标时间分辨率：1 kHz

**步骤1：计算脉冲宽度**
$$\tau = \frac{2 n_{eff} \cdot \delta z}{c} = \frac{2 \times 1.468 \times 10}{3 \times 10^8} \approx 98 \text{ ns} \rightarrow \text{取} 100 \text{ ns}$$

**步骤2：计算脉冲重复频率**
$$f_{rep} < \frac{c}{2 L n_{eff}} = \frac{3 \times 10^8}{2 \times 10^4 \times 1.468} \approx 10.2 \text{ kHz}$$
→ 选择 $f_{rep} = 5$ kHz

**步骤3：选择调制器类型**
- 脉冲宽度：100 ns（相对较宽）
- 重复频率：5 kHz（相对低频）
- 推荐：**AOM**（成本低，易于集成）

**步骤4：器件选型**

**推荐AOM型号**：
- **Brimrose TEM-100-1550**
  - 工作波长：1550 nm
  - 衍射效率：>70%
  - 最大调制频率：100 MHz
  - 中心频率：100 MHz
  - RF功率：5 W

或者：
- **AA Electronics AAOM-110-1550**
  - 工作波长：1550 nm
  - 中心频率：110 MHz
  - RF驱动功率：<3 W

**推荐EOM型号**（如需更高速率）：
- **Photonwares PM-EOM-1550**
  - 工作波长：1550 nm
  - 半波电压：5-7 V
  - 调制带宽：>10 GHz

### 3.6 调制功率预算

**AOM的损耗**：

衍射效率（Diffraction Efficiency）：
$$\eta_{diff} = \sin^2\left(\frac{\pi \nu_{RF} M}{2}\right)$$

其中 $M$ 是一个与设备设计相关的参数。

通常 $\eta_{diff} \approx 0.7$ (70%)

**输出功率**：
$$P_{out} = P_{in} \times \eta_{diff} = 50 \text{ mW} \times 0.7 = 35 \text{ mW}$$

### 3.7 控制信号设计

**脉冲驱动信号示例**：

```
时间轴 (μs)
0     50    100   150   200
|-----|-----|-----|-----|
|脉冲 |    |脉冲 |    |  周期：200 μs (频率：5 kHz)
 100ns      100ns       脉冲宽度：100 ns
              占空比：0.05%
```

**RF信号**（用于驱动AOM）：
- 中心频率：100 MHz
- 功率：3-5 W
- 调制包络：100 ns 脉冲，5 kHz 重复

---

## 总结表

| 参数 | 符号 | 单位 | 计算值 | 说明 |
|-----|------|------|--------|------|
| 脉冲宽度 | $\tau$ | ns | 100 | 决定空间分辨率 |
| 空间分辨率 | $\delta z$ | m | 10 | 相邻两个可分辨点 |
| 脉冲重复频率 | $f_{rep}$ | kHz | 5 | <10.2 kHz |
| 占空比 | DC | % | 0.05 | $\tau/T_{rep}$ |
| AOM效率 | $\eta_{diff}$ | % | 70 | 输出功率 = 35 mW |
