# Physical-Layer-Security-

# **Advanced Communication Systems Security Project**

## **Overview**
This project explores the implementation and analysis of secure communication techniques at the physical layer. Developed as part of a semester-long course at the University of the Aegean, it combines theoretical concepts with practical coding to enhance data transmission reliability and secrecy in the presence of noise and potential eavesdroppers.

## **Objectives**
- Investigate the entropy and mutual information in message sources.
- Implement and evaluate error detection and correction techniques.
- Simulate modulation schemes and analyze their performance over noisy channels.
- Optimize security using advanced multi-antenna techniques like beamforming and artificial noise.

---

## **Key Components**

### 1. **Entropy and Source Encoding**
- **Objective**: Analyze the randomness of a binary message source and introduce controlled randomness for secure encoding.
- **Tasks**:
  - Calculated the entropy of a uniformly distributed binary source.
  - Designed a random encoding scheme extending the bit size, evaluated through entropy and conditional entropy calculations.

---

### 2. **Error Detection and Correction**
- **Error Detection**:
  - Implemented **Cyclic Redundancy Check (CRC)** using polynomial division (CRC-24 standard).
  - Automated CRC integration for message blocks, appending redundancy bits for validation.
- **Error Correction**:
  - Applied **Hamming codes** for encoding and decoding messages, ensuring correction of single-bit errors.
  - Simulated error rates to evaluate Hamming code performance.

---

### 3. **Modulation and Signal Transmission**
- **64-QAM Modulation**:
  - Developed Python and MATLAB scripts for modulating messages using 64-QAM, a high-efficiency modulation scheme.
  - Simulated transmission over an **Additive White Gaussian Noise (AWGN)** channel.
- **Superposition Coding**:
  - Implemented layered message encoding to improve channel capacity and manage multi-user scenarios.

---

### 4. **Channel Simulation and Secrecy Analysis**
- Modeled two communication channels: one between the transmitter (Alice) and receiver (Bob) and a second with an eavesdropper (Eve).
- **Signal-to-Noise Ratio (SNR)** adjustments simulated real-world scenarios:
  - Explored secrecy trade-offs between Bob and Eve by analyzing **Packet Error Rates (PER)** for varying SNR values.
  - Identified thresholds for secure communication where Eve's PER > 98% while maintaining low PER for Bob.

---

### 5. **Advanced Multi-Antenna Techniques**
- Simulated multi-antenna setups with **3 transmit and 3 receive antennas**.
- Compared and implemented two strategies:
  - **Beamforming** for focusing signal energy towards the receiver.
  - **Artificial Noise Injection** to disrupt potential eavesdroppers.
- Calculated secrecy capacity enhancements using **Singular Value Decomposition (SVD)**.

---

### 6. **Coding and Decoding Pipelines**
- **Encoding**:
  - Integrated CRC and Hamming coding into a streamlined pipeline for redundancy and error correction.
  - Optimized block encoding for secure transmission over noisy channels.
- **Decoding**:
  - Developed QAM demodulation and bit-by-bit decoding algorithms.
  - Implemented error correction using Hamming decoding and verified message integrity with CRC.

---

### 7. **Secrecy Capacity Analysis**
- Simulated a high-noise channel to estimate **secrecy capacity** by comparing Bob's and Eve's channels.
- Proposed techniques to achieve secure transmission, balancing reliability for Bob and obfuscation for Eve.

---

## **Technologies and Tools**
- **Languages**: Python, MATLAB, C++
- **Mathematical Techniques**: Entropy analysis, QAM modulation/demodulation, polynomial division, SVD
- **Simulation Tools**: MATLAB Signal Processing Toolbox, Python libraries for statistical simulations

---

## **How to Use**
1. **Setup**:
   - Install required libraries: Python (`numpy`, `matplotlib`), MATLAB Signal Processing Toolbox.
   - Clone the repository and navigate to the relevant script directories.
2. **Run Simulations**:
   - Follow instructions in the README files of each module to execute simulations for entropy, CRC, Hamming coding, QAM modulation, and secrecy analysis.
3. **Results**:
   - Visualize simulation outputs, such as PER vs. SNR graphs and encoded/decoded message statistics.

---

## **Outcomes**
- Demonstrated secure data transmission techniques under noisy conditions.
- Optimized communication strategies for real-world applications in wireless and secure networks.
- Highlighted the importance of redundancy, coding, and channel-specific optimizations for secure physical layer communications.


