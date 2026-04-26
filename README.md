# NonLinear Analysis on Network Traffic: Complexity Metrics and Entropy

## Project Overview

This project investigates the application of nonlinear algorithms and complexity metrics for analyzing the dynamic behavior of modern computer networks. Without relying on packet payload, this study focuses exclusively on the statistical behavior of network traffic flows, specifically analyzing the time series of transmitted packet sizes.

The primary goal is to demonstrate that nonlinear indicators accurately capture fluctuations in system complexity. This allows for the real-time distinction between different dynamic network states, such as normal stochastic "chaos" and absolute bandwidth saturation.

## Dataset Details

To evaluate the proposed algorithms, a realistic dataset was generated to capture two radically different operational states of the network:

* **Normal Phase:** Heterogeneous, mixed-use traffic (web browsing, 4K multimedia streaming, and cloud services).
* **Anomaly Phase:** Absolute bandwidth saturation, distinctly reflected by a bimodal distribution.

## 1. Mathematical Foundations & Time Discretization

The evolution of network security through information theory requires a shift from observing traffic magnitude to analyzing the stochastic nature of network interactions.

### 1.1 Shannon Entropy

Shannon Entropy analyzes the degree of uncertainty or the distribution of a phenomenon. It mathematically measures the unpredictability of a system. The equation for discrete flows (like network packets) is expressed as:

$$H(x)=-\sum_{i=1}^{n}p_{i}log_{2}p_{i}$$

Where $p_{i}$ represents the probability of occurrence of the i-th outcome.

**Algorithmic Logic (Windowing):** Calculating the entropy of the entire dataset at once would result in the loss of crucial temporal information regarding exactly when an anomaly occurred. To address this, the stream is discretized using non-overlapping windows:

$$M=\frac{N}{W}$$

To prevent overflow and ensure statistical validity, boundaries are defined dynamically:

$$end\_idx=i\times W$$
$$start\_idx=end\_idx-W+1$$

**Zero-Probability Limit:** If a packet size does not appear in a window, its probability is $p_{i}=0$. Since $log_2(0) \rightarrow -\infty$, L'Hopital's rule is applied to prove that an event with zero probability provides no information and contributes nothing to the sum:

$$\lim_{p_{i}\rightarrow0^{+}}p_{i}log_{2}p_{i}=0$$

### 1.2 Generalized Renyi Entropy & Limit Cases

Relying exclusively on Shannon Entropy leaves the network exposed to temporal blindness and low-rate attacks. Renyi entropy provides a single-parameter generalization:

$$H_{a}(X)=\frac{1}{1-a}log_{2}(\sum_{i=1}^{N}p_{i}^{a})$$

The parameter $a$ applies a non-linear distortion to the probability space:

* **Extreme Event Amplification ($a < 1$):** Small probabilities are increased, allocating disproportionate weight to the tail of the distribution, amplifying background noise.
* **Collision Entropy ($a \ge 2$):** Small probabilities are suppressed dramatically faster than larger ones. The sum relies almost entirely on high-probability events, exposing volumetric anomalies.

**Mathematical Proofs for Limit Cases:**

* **The Bridge to Shannon ($a \rightarrow 1$):** At $a=1$, the equation results in an indeterminate form. Applying L'Hopital's rule proves that it converges precisely to Shannon entropy:
  $$\lim_{a\rightarrow1}H_{a}(X)=-\sum_{i=1}^{N}p_{i}log_{b}(p_{i})$$
* **Max-Entropy / Hartley ($a \rightarrow 0$):** Disregards frequencies entirely to measure total variety ($H_o = log_b(N)$).
* **Min-Entropy ($a \rightarrow \infty$):** The limit converges to $H_{\infty}=-log_{2}(p_{max})$, evaluating the system exclusively based on the most frequent event.

## 2. Network Complexity Analysis & Feature Ensembles

To quantify the total network complexity, we calculate the joint entropy of a multidimensional feature ensemble (e.g., $G=\{f_{bytes},f_{packets},f_{iat}\}$):

$$\Psi_{a}(f_{1},...,f_{n})=\frac{1}{1-a}log_{2}(\sum_{f_{1}}\cdot\cdot\cdot\sum_{f_{m}}p(f_{1}...,f_{m})^{a})$$

### 2.1 The Subadditivity Principle (Upper Bound)

The joint entropy of multiple variables is always less than or equal to the sum of their individual marginal entropies. For two variables, this is defined as:

$$H(X,Y)\le H(X)+H(Y)$$

This bounds the system due to the existence of mutual information ($I(X;Y)=H(X)+H(Y)-H(X,Y)$), which quantifies the shared information between variables.

**The Independence Bound:** The joint entropy reaches its maximum value only when all features are stochastically independent. The aggregate sum is strictly capped by:

$$\sum_{i\le j}H(Y_{i,j}) \le c_{n}H_{2}(\overline{p})$$

This state of maximum dispersion acts as the mathematical driver of stochastic chaos. It perfectly characterizes malicious Internet Background Radiation (IBR), such as distributed scanners and worms, which rely on randomly generated values lacking protocol-driven inter-dependencies.

### 2.2 Deterministic Structure (Lower Bound)

Conversely, the lower bound is approached when perfect correlation exists between features. The uncertainty of a system decreases or remains the same when additional information is provided:

$$H(X|Y)=H(X,Y)-H(Y)$$
$$H(X|Y)\le H(X)$$

## 3. Results & Visualizations

### Shannon Entropy Distribution Over Time
During periods of network browsing, packets had many different sizes with small probabilities, yielding a high $H$ value. Conversely, during absolute saturation (Speedtest), a single packet size dominated the traffic, causing the entropy of the system to collapse.

![Network Traffic Entropy in Time](Network%20Traffic%20Entropy%20in%20Time.png)

### Renyi Entropy Analysis Across Multiple Orders
At the lowest order ($a=0.125$), the flooding event is completely masked by amplified background noise. As the order increases ($a=2$ and $a=10$), the algorithm progressively shifts its focus toward the most frequent events. Because the attack introduces a massive volume of identical packets, the probability of the dominant event skyrockets. At $a=10$, the entropy collapses entirely to a near-zero line, making the anomaly unmistakably prominent.

![Renyi Entropy on Network Traffic](Renyi%20Entropy%20on%20Network%20Traffic.png)

### Dynamic Anomaly Detection (Adaptive EWMA)
Relying on a manually pre-selected, static numerical threshold introduces a critical operational vulnerability: the system cannot adapt to evolving network loads. This advanced methodology replaces fixed limits with a dynamically calculated confidence interval, ensuring maximum sensitivity to attacks while drastically reducing false alarms in dynamic SDN environments.

![Dynamic Anomaly Detection using Renyi Entropy and Adaptive EWMA Thresholds](Dynamic%20Anomaly%20Detection%20using%20Renyi%20Entropy%20and%20Adaptive%20EWMA%20Thresholds.png)
