# DAS系统硬件详细分析：第七部分 - 高速ADC采样

## 7. 模数转换 (ADC - Analog to Digital Converter)

### 7.1 采样定理与Nyquist频率

#### 7.1.1 Nyquist-Shannon采样定理

为了不失真地恢复模拟信号，采样频率必须至少是信号最高频率的两倍：

$$f_s > 2 f_{max}$$

或者说，Nyquist频率为：
$$f_{Nyquist} = \frac{f_s}{2}$$

**物理意义**：每个完整周期至少需要2个采样点才能确定信号频率。

#### 7.1.2 DAS系统的带宽要求

在DAS系统中，信号带宽取决于：

1. **脉冲宽度的谱带宽**：
$$\Delta f \approx \frac{0.44}{\tau}$$

其中 $\tau$ 是脉冲宽度。

**示例**：对于 $\tau = 100$ ns 的脉冲
$$\Delta f \approx \frac{0.44}{100 \times 10^{-9}} = 4.4 \text{ MHz}$$

2. **振动信号频率范围**：
- 地震监测：0.1 Hz - 100 Hz
- 管道流量监测：1 Hz - 1 kHz
- 高频振动：1 kHz - 10 kHz

3. **总带宽**：
设脉冲中心频率为 $f_c$（由于混频），信号实际带宽为：
$$BW_{total} = \Delta f + f_{vibration,max}$$

**通常**，$f_c$ 在 MHz 范围（混频后的中频信号），振动信号最高频率几 kHz，所以总带宽一般在 10 MHz 以内。

**Nyquist采样率选择**：
$$f_s > 2 \times (f_c + \text{bandwidth}) > 2 \times 10 \text{ MHz} = 20 \text{ MHz}$$

推荐选择 $f_s = 50-100$ MHz（留有裕度）。

### 7.2 ADC的关键参数

#### 7.2.1 分辨率 (Resolution)

ADC将模拟信号量化为数字值。分辨率用**位数**（bits）表示：

**量化等级数**：
$$N_{levels} = 2^n$$

其中 $n$ 是位数。

**量化步长（LSB - Least Significant Bit）**：
$$\Delta V = \frac{V_{range}}{2^n}$$

其中 $V_{range}$ 是ADC的输入范围。

**示例**：对于12位ADC，输入范围0-1V
$$\Delta V = \frac{1}{2^{12}} = \frac{1}{4096} \approx 244 \text{ μV}$$

#### 7.2.2 有效位数 (ENOB - Effective Number of Bits)

实际ADC的性能会因噪声而降低，用ENOB表示：

$$ENOB = \frac{SINAD - 1.76}{6.02}$$

其中SINAD是信号与噪声及失真比（dB）。

**示例**：
- 理论12位ADC的SINAD ≈ 74 dB
- 实际可能只有 68 dB，对应 ENOB ≈ 11 位

#### 7.2.3 信号噪声比 (SNR)

ADC本身产生的量化噪声功率：

$$P_{quantization} = \frac{(\Delta V)^2}{12}$$

对于满量程正弦信号，SNR为：

$$SNR_{ADC} = \frac{3}{2} \times 2^{2n} \approx 6.02n + 1.76 \text{ dB}$$

**示例**：12位ADC
$$SNR_{ADC} = 6.02 \times 12 + 1.76 = 74 \text{ dB}$$

#### 7.2.4 信噪失真比 (SINAD)

考虑谐波失真的总体性能指标：

$$SINAD = \frac{P_{signal}}{P_{noise} + P_{distortion}}$$

通常比SNR低 3-10 dB。

### 7.3 差分非线性 (DNL) 和积分非线性 (INL)

#### 7.3.1 差分非线性 (DNL)

衡量相邻量化级之间的步长是否均匀：

$$DNL = \frac{\Delta V_{actual} - \Delta V_{ideal}}{\Delta V_{ideal}}$$

**问题**：如果某些步长缺失或过大，会导致信号失真。

#### 7.3.2 积分非线性 (INL)

衡量整个转换函数的线性程度：

$$INL = \frac{V_{actual}(i) - V_{ideal}(i)}{\Delta V_{ideal}}$$

**推荐**：DNL < ±0.5 LSB，INL < ±1 LSB

### 7.4 I/Q通道ADC配置

在DAS系统中，I和Q两个通道的信号需要同时采样。

#### 7.4.1 同步采样要求

为了准确恢复相位，I和Q采样必须严格同步：

**时间对齐误差**：
$$\Delta t < \frac{1}{10 f_{signal,max}}$$

对于 10 kHz 信号：
$$\Delta t < 10 \text{ μs}$$

#### 7.4.2 幅度与相位匹配

I和Q两路必须有相同的增益和延迟：

**增益匹配**：
$$\left|\frac{G_I}{G_Q} - 1\right| < 1\%$$

**相位匹配**：
$$|\phi_I - \phi_Q| < 2°$$

不匹配会产生IQ不平衡（IQ Imbalance），导致镜像信号和失真。

#### 7.4.3 双ADC配置

常用方案是两个ADC分别处理I和Q：

```
I路信号 ──→ [低通滤波] ──→ [ADC1-12bits] ──→ I数据
Q路信号 ──→ [低通滤波] ──→ [ADC2-12bits] ──→ Q数据
           ↑
    共享时钟源（同步）
```

### 7.5 混叠 (Aliasing) 防护

如果信号包含高于 Nyquist 频率的分量，会产生混叠。

#### 7.5.1 混叠效应

超过Nyquist频率的信号会被映射回低频：

$$f_{alias} = |f_{signal} - f_s|$$

**示例**：采样率 100 MHz，Nyquist频率 50 MHz
- 信号频率 55 MHz → 被映射到 45 MHz
- 信号频率 120 MHz → 被映射到 20 MHz

#### 7.5.2 反混叠滤波器 (Anti-Aliasing Filter)

在ADC前加入低通滤波器，截止频率为 Nyquist 频率：

**要求**：
- 截止频率：$f_c = 0.4 \times f_s$（保留裕度）
- 衰减斜率：≥40 dB/decade
- 滤波阶数：5-8阶

**对于 100 MHz 采��率**：
$$f_c = 0.4 \times 100 = 40 \text{ MHz}$$

推荐使用Butterworth或Chebyshev低通滤波器。

### 7.6 ADC器件选型

**应用场景**：
- 采样率：≥50 MHz（推荐100 MHz）
- 分辨率：12-14 bits
- 通道数：2（I/Q双通道）
- 低功耗、集成度高

**推荐型号**：

**选项1：中等集成度**
- **TI ADS6125**
  - 采样率：200 MSPS
  - 分辨率：14 bits
  - ENOB：≈11.5 bits
  - 双通道可用
  - 噪声：150 nV/√Hz

**选项2：高集成度（带PLL和时钟）**
- **Analog Devices AD9680**
  - 采样率：1 GSPS
  - 分辨率：14 bits
  - ENOB：≈10.5 bits @200 MHz
  - 双通道
  - 片上PLL同步

**选项3：工业级**
- **Maxim MAX19506**
  - 采样率：500 MSPS
  - 分辨率：12 bits
  - ENOB：≈10.5 bits
  - 低功耗（<500 mW）

### 7.7 采样数据率与存储

#### 7.7.1 数据速率计算

设有 $N_{samples}$ 个空间采样点（对应 $N_{samples}$ 个通道），采样率为 $f_s$，分辨率为 $n$ bits：

**总数据率**：
$$R_{data} = N_{samples} \times f_s \times n \times 2 \text{ (I+Q)}$$

**示例**：DAS系统参数
- 光纤长度：10 km
- 空间分辨率：10 m
- 采样点数：$N = 10000 / 10 = 1000$
- 采样率：$f_s = 100$ MHz
- 分辨率：12 bits

$$R_{data} = 1000 \times 100 \times 10^6 \times 12 \times 2 = 2.4 \text{ Tbps} = 300 \text{ GB/s}$$

这是一个巨大的数据量！

#### 7.7.2 数据压缩策略

必须采用在线处理和压缩：

1. **原始数据压缩**：
   - 去除直流分量和高频噪声
   - 只保留有用频段
   - 压缩比：10:1 - 100:1

2. **特征提取**：
   - 只存储相位信息（而不是原始IQ）
   - 进一步压缩 100:1

3. **空间下采样**：
   - 可能不需要 1000 个点的分辨率
   - 降采样到 100 个点
   - 压缩 10:1

**最终数据率**（经过多级压缩）：
$$R_{final} = 300 \text{ GB/s} / (100 \times 10) = 30 \text{ MB/s}$$

这才是可以存储的速率。

---

## 总结表

| 参数 | 符号 | 单位 | 推荐值 | 说明 |
|-----|------|------|--------|------|
| 采样率 | $f_s$ | MHz | 50-100 | >2倍信号带宽 |
| Nyquist频率 | $f_{Nyquist}$ | MHz | 25-50 | $f_s/2$ |
| ADC分辨率 | $n$ | bits | 12-14 | 权衡精度与速度 |
| ENOB | - | bits | >10 | 有效位数 |
| SNR | - | dB | >70 | 6.02n + 1.76 |
| SINAD | - | dB | >65 | 考虑失真 |
| DNL | - | LSB | <±0.5 | 步长均匀性 |
| INL | - | LSB | <±1 | 线性度 |
| 通道数 | - | - | 2 | I/Q双通道 |
| 反混叠截止 | $f_c$ | MHz | 0.4$f_s$ | 防混叠 |
