## General Overview
This repository contains MATLAB scripts for running an experimental task related to psychiatry in an fMRI environment. The experiment includes stimuli presentation, response recording, and synchronization with fMRI triggers. The repository is organized to facilitate running the task, managing stimuli, and configuring the experiment for different setups (e.g., different computers or fMRI centers).

## Authors and Institutions
- João Amaro, Institute of Physiology, Lisbon School of Medicine, University of Lisbon, Lisbon, Portugal
- Pedro Rocha, Institute of Physiology, Lisbon School of Medicine, University of Lisbon, Lisbon, Portugal

## TODO
- [ ] Implement configureCallback(s, "byte", 1, @myCallbackFunction);
- [ ] Implement function to check if port has data 

## Requirements
MATLAB (version R2023b or later)
PsychToolbox (version 3.0.19 or later)
fMRI-compatible computer
Joystick or button-box for response collection

## Project Structure
Below is an explanation of the key files and folders:

```
C:.
│   .gitignore                 % Standard git ignore file
│   init_experiment.m          % Script to initialize experiment parameters
│   README.md                  % This readme file
│   run_main_task.m            % Main script for running the fMRI task
│   settings_main.m            % Configuration settings for the main task
│
├───celeritas
│       celeritas.joystick.amgp % Joystick setup/configuration file
│
├───events
│       sub-test_task-sentences_events.xlsx % Event timing and stimuli-related information (BIDS-style)
│
├───legacy                     % Archive of outdated scripts (not in use anymore)
├───mainTrSynch                % Main experiment task whose entire synchronization is dependent on fMRI triggers to run
├───restingState
│       eyes_closed.m          % Script for running the resting-state session (eyes closed)
│
├───setup
│       lenovo_pc_setup.m      % Setup script for Lenovo PC environment
│       tower_computer_setup.m % Setup script for Tower computer environment
│
├───stimuli                    % Contains all stimuli used in the experiment
│   ├───active_stimuli         % Images for active task-related stimuli
│   ├───crosses                % Fixation cross images
│   ├───neutral_stimuli        % Images for neutral stimuli
│   └───stars                  % Star images for task feedback
│
├───testing                    % Scripts for simulation/testing of the experiment
│       eyes_closed_sim.m      % Simulated version of resting-state session (for testing)
│       run_main_task_sim.m    % Simulated version of the main task (for testing)
│       settings_main_sim.m    % Configuration for simulated testing of the main task
│
├───training                   % Scripts for training participants outside the scanner
│       settings_training.m    % Configuration for training task
│       training.m             % Training script (similar to main task but for practice)
│
└───utils                      % Utility scripts used throughout the project
        addResponseOptions.m   % Adds response collection options 
        drawCross.m            % Function to draw fixation cross
        drawText.m             % Function to display text
```

# Connecting to the MRI machine
1. Connect the usb-c and hdmi cables to the pc.
2. Open device manager and check the ports.
3. Connect the port in the code.

# How to Run the Experiment
1. Initial Setup
PsychToolbox: Ensure that PsychToolbox is installed and properly configured. The preferred version is 3.0.19. You can check the version with PsychtoolboxVersion.

Joystick: If using a joystick, confirm that it is properly set up using the script celeritas.joystick.amgp.

2. Configure the Experiment
Edit settings_main.m to set up experiment-specific parameters like fMRI trigger timing. Participant information is added on the main script.

3. Training
If you want to familiarize participants with the task before the scan, use the training script training.m. This script is configured with different parameters for outside-scanner practice.

4. Resting-State Task
For the resting-state scan, run eyes_closed.m. The subject should be instructed to close their eyes during this task. You may customize this script based on the duration of the scan.

5. Run the Main Task
To start the main fMRI task, use the script run_main_task.m. This script handles the presentation of stimuli and the collection of responses during the scanning session.

## Troubleshooting
Joystick issues: Ensure the joystick is connected and configured using the celeritas.joystick.amgp script.
PsychToolbox issues: If PsychToolbox fails to initialize, verify that all display settings are correct and that MATLAB has the required permissions.
Timing issues: Adjust the TR setting in settings_main.m or settings_training.m if your scanner's TR differs from the default.
Check the `init_experiment.m` script for more troubleshooting tips.


## Functioning Hardware and Software

- Lenovo PC

*Hardware:*
```
Host Name:                 LAPTOP-N37ECEH3
OS Name:                   Microsoft Windows 11 Home
OS Version:                10.0.22631 N/A Build 22631
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Workstation
OS Build Type:             Multiprocessor Free
Registered Owner:          SpikeUrban
Registered Organization:   N/A
Product ID:                00342-21901-78821-AAOEM
Original Install Date:     8/25/2023, 5:42:36 AM
System Boot Time:          9/17/2024, 11:21:21 AM
System Manufacturer:       LENOVO
System Model:              82XW
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: Intel64 Family 6 Model 186 Stepping 2 GenuineIntel ~2400 Mhz
BIOS Version:              LENOVO LZCN30WW, 6/15/2023
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             en-us;English (United States)
Input Locale:              pt;Portuguese (Portugal)
Time Zone:                 (UTC+00:00) Dublin, Edinburgh, Lisbon, London
Total Physical Memory:     16,108 MB
Available Physical Memory: 1,192 MB
Virtual Memory: Max Size:  29,932 MB
Virtual Memory: Available: 10,780 MB
Virtual Memory: In Use:    19,152 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    WORKGROUP
Logon Server:              \\LAPTOP-N37ECEH3
Hotfix(s):                 5 Hotfix(s) Installed.
                           [01]: KB5042099
                           [02]: KB5012170
                           [03]: KB5027397
                           [04]: KB5043076
                           [05]: KB5043937
Network Card(s):           3 NIC(s) Installed.
                           [01]: Realtek PCIe GbE Family Controller
                                 Connection Name: Ethernet
                                 Status:          Media disconnected
                           [02]: Bluetooth Device (Personal Area Network)
                                 Connection Name: Bluetooth Network Connection
                                 Status:          Media disconnected
                           [03]: Realtek RTL8852BE WiFi 6 802.11ax PCIe Adapter
                                 Connection Name: Wi-Fi
                                 DHCP Enabled:    Yes
                                 DHCP Server:     10.20.0.1
                                 IP address(es)
                                 [01]: 10.20.8.180
                                 [02]: fe80::221e:8e6a:c989:f2db
Hyper-V Requirements:      A hypervisor has been detected. Features required for Hyper-V will not be displayed.
```
*Software:*
```
-----------------------------------------------------------------------------------------------------
MATLAB Version: 23.2.0.2515942 (R2023b) Update 7
MATLAB License Number: 41137037
Operating System: Microsoft Windows 11 Home Version 10.0 (Build 22631)
Java Version: Java 1.8.0_202-b08 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 23.2        (R2023b)   
Simulink                                              Version 23.2        (R2023b)   
5G Toolbox                                            Version 23.2        (R2023b)   
AUTOSAR Blockset                                      Version 23.2        (R2023b)   
Aerospace Blockset                                    Version 23.2        (R2023b)   
Aerospace Toolbox                                     Version 23.2        (R2023b)   
Antenna Toolbox                                       Version 23.2        (R2023b)   
Audio Toolbox                                         Version 23.2        (R2023b)   
Automated Driving Toolbox                             Version 23.2        (R2023b)   
Bioinformatics Toolbox                                Version 23.2        (R2023b)   
Bluetooth Toolbox                                     Version 23.2        (R2023b)   
C2000 Microcontroller Blockset                        Version 23.2        (R2023b)   
Communications Toolbox                                Version 23.2        (R2023b)   
Computer Vision Toolbox                               Version 23.2        (R2023b)   
Control System Toolbox                                Version 23.2        (R2023b)   
Curve Fitting Toolbox                                 Version 23.2        (R2023b)   
DDS Blockset                                          Version 23.2        (R2023b)   
DSP HDL Toolbox                                       Version 23.2        (R2023b)   
DSP System Toolbox                                    Version 23.2        (R2023b)   
Data Acquisition Toolbox                              Version 23.2        (R2023b)   
Database Toolbox                                      Version 23.2        (R2023b)   
Datafeed Toolbox                                      Version 23.2        (R2023b)   
DatapixxToolbox                                       Version 0.9,        Aug        
Deep Learning HDL Toolbox                             Version 23.2        (R2023b)   
Deep Learning Toolbox                                 Version 23.2        (R2023b)   
EEGLAB Toolbox to process EEG data                    Version -           see        
EEGLAB Toolbox to process EEG data                    Version -           see        
Econometrics Toolbox                                  Version 23.2        (R2023b)   
Embedded Coder                                        Version 23.2        (R2023b)   
Filter Design HDL Coder                               Version 23.2        (R2023b)   
Financial Instruments Toolbox                         Version 23.2        (R2023b)   
Financial Toolbox                                     Version 23.2        (R2023b)   
Fixed-Point Designer                                  Version 23.2        (R2023b)   
Fuzzy Logic Toolbox                                   Version 23.2        (R2023b)   
GPU Coder                                             Version 23.2        (R2023b)   
Global Optimization Toolbox                           Version 23.2        (R2023b)   
HDL Coder                                             Version 23.2        (R2023b)   
HDL Verifier                                          Version 23.2        (R2023b)   
Image Acquisition Toolbox                             Version 23.2        (R2023b)   
Image Processing Toolbox                              Version 23.2        (R2023b)   
Industrial Communication Toolbox                      Version 23.2        (R2023b)   
Instrument Control Toolbox                            Version 23.2        (R2023b)   
LTE Toolbox                                           Version 23.2        (R2023b)   
Lidar Toolbox                                         Version 23.2        (R2023b)   
MATLAB Coder                                          Version 23.2        (R2023b)   
MATLAB Compiler                                       Version 23.2        (R2023b)   
MATLAB Compiler SDK                                   Version 23.2        (R2023b)   
MATLAB Report Generator                               Version 23.2        (R2023b)   
MATLAB Test                                           Version 23.2        (R2023b)   
Mapping Toolbox                                       Version 23.2        (R2023b)   
Medical Imaging Toolbox                               Version 23.2        (R2023b)   
Mixed-Signal Blockset                                 Version 23.2        (R2023b)   
Model Predictive Control Toolbox                      Version 23.2        (R2023b)   
Model-Based Calibration Toolbox                       Version 23.2        (R2023b)   
Motor Control Blockset                                Version 23.2        (R2023b)   
Navigation Toolbox                                    Version 23.2        (R2023b)   
Optimization Toolbox                                  Version 23.2        (R2023b)   
Parallel Computing Toolbox                            Version 23.2        (R2023b)   
Partial Differential Equation Toolbox                 Version 23.2        (R2023b)   
Phased Array System Toolbox                           Version 23.2        (R2023b)   
Powertrain Blockset                                   Version 23.2        (R2023b)   
Predictive Maintenance Toolbox                        Version 23.2        (R2023b)   
Psychtoolbox                                          Version 3.0.19      17 February
Psychtoolbox                                          Version 3.0.19      17 February
RF Blockset                                           Version 23.2        (R2023b)   
RF PCB Toolbox                                        Version 23.2        (R2023b)   
RF Toolbox                                            Version 23.2        (R2023b)   
ROS Toolbox                                           Version 23.2        (R2023b)   
Radar Toolbox                                         Version 23.2        (R2023b)   
Reinforcement Learning Toolbox                        Version 23.2        (R2023b)   
Requirements Toolbox                                  Version 23.2        (R2023b)   
Risk Management Toolbox                               Version 23.2        (R2023b)   
Robotics System Toolbox                               Version 23.2        (R2023b)   
Robust Control Toolbox                                Version 23.2        (R2023b)   
Satellite Communications Toolbox                      Version 23.2        (R2023b)   
Sensor Fusion and Tracking Toolbox                    Version 23.2        (R2023b)   
SerDes Toolbox                                        Version 23.2        (R2023b)   
Signal Integrity Toolbox                              Version 23.2        (R2023b)   
Signal Processing Toolbox                             Version 23.2        (R2023b)   
SimBiology                                            Version 23.2        (R2023b)   
SimEvents                                             Version 23.2        (R2023b)   
Simscape                                              Version 23.2        (R2023b)   
Simscape Battery                                      Version 23.2        (R2023b)   
Simscape Driveline                                    Version 23.2        (R2023b)   
Simscape Electrical                                   Version 23.2        (R2023b)   
Simscape Fluids                                       Version 23.2        (R2023b)   
Simscape Multibody                                    Version 23.2        (R2023b)   
Simulink 3D Animation                                 Version 23.2        (R2023b)   
Simulink Check                                        Version 23.2        (R2023b)   
Simulink Code Inspector                               Version 23.2        (R2023b)   
Simulink Coder                                        Version 23.2        (R2023b)   
Simulink Compiler                                     Version 23.2        (R2023b)   
Simulink Control Design                               Version 23.2        (R2023b)   
Simulink Coverage                                     Version 23.2        (R2023b)   
Simulink Design Optimization                          Version 23.2        (R2023b)   
Simulink Design Verifier                              Version 23.2        (R2023b)   
Simulink Desktop Real-Time                            Version 23.2        (R2023b)   
Simulink Fault Analyzer                               Version 23.2        (R2023b)   
Simulink PLC Coder                                    Version 23.2        (R2023b)   
Simulink Real-Time                                    Version 23.2        (R2023b)   
Simulink Report Generator                             Version 23.2        (R2023b)   
Simulink Test                                         Version 23.2        (R2023b)   
SoC Blockset                                          Version 23.2        (R2023b)   
Spreadsheet Link                                      Version 23.2        (R2023b)   
Stateflow                                             Version 23.2        (R2023b)   
Statistical Parametric Mapping                        Version 7771        (SPM12)    
Statistics and Machine Learning Toolbox               Version 23.2        (R2023b)   
Symbolic Math Toolbox                                 Version 23.2        (R2023b)   
System Composer                                       Version 23.2        (R2023b)   
System Identification Toolbox                         Version 23.2        (R2023b)   
Text Analytics Toolbox                                Version 23.2        (R2023b)   
UAV Toolbox                                           Version 23.2        (R2023b)   
Vehicle Dynamics Blockset                             Version 23.2        (R2023b)   
Vehicle Network Toolbox                               Version 23.2        (R2023b)   
Vision HDL Toolbox                                    Version 23.2        (R2023b)   
WLAN Toolbox                                          Version 23.2        (R2023b)   
Wavelet Toolbox                                       Version 23.2        (R2023b)   
Wireless HDL Toolbox                                  Version 23.2        (R2023b)   
Wireless Testbench                                    Version 23.2        (R2023b)   
```
```
PsychtoolboxVersion:     '3.0.19 - Flavor: Manual Install, 13-Feb-2024 12:07:36'
```

- Tower Computer
```
Host Name:                 DESKTOP-UJUVJ70
OS Name:                   Microsoft Windows 10 Education
OS Version:                10.0.19045 N/A Build 19045
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Workstation
OS Build Type:             Multiprocessor Free
Registered Owner:          Windows User
Registered Organization:   
Product ID:                00328-00205-96228-AA809
Original Install Date:     25/10/2021, 17:08:40
System Boot Time:          06/09/2024, 03:55:31
System Manufacturer:       Micro-Star International Co., Ltd.
System Model:              MS-7B48
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: Intel64 Family 6 Model 158 Stepping 10 GenuineIntel ~3696 Mhz
BIOS Version:              American Megatrends Inc. 2.20, 27/10/2017
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume2
System Locale:             en-us;English (United States)
Input Locale:              pt;Portuguese (Portugal)
Time Zone:                 (UTC+00:00) Dublin, Edinburgh, Lisbon, London
Total Physical Memory:     32 728 MB
Available Physical Memory: 15 827 MB
Virtual Memory: Max Size:  37 592 MB
Virtual Memory: Available: 16 436 MB
Virtual Memory: In Use:    21 156 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    WORKGROUP
Logon Server:              \\DESKTOP-UJUVJ70
Hotfix(s):                 32 Hotfix(s) Installed.
                           [01]: KB5042097
                           [02]: KB5030841
                           [03]: KB4562830
                           [04]: KB5003791
                           [05]: KB5011048
                           [06]: KB5012170
                           [07]: KB5015684
                           [08]: KB5043064
                           [09]: KB5006753
                           [10]: KB5007273
                           [11]: KB5011352
                           [12]: KB5011651
                           [13]: KB5014032
                           [14]: KB5014035
                           [15]: KB5014671
                           [16]: KB5015895
                           [17]: KB5016705
                           [18]: KB5018506
                           [19]: KB5020372
                           [20]: KB5022924
                           [21]: KB5023794
                           [22]: KB5025315
                           [23]: KB5028318
                           [24]: KB5029709
                           [25]: KB5031539
                           [26]: KB5036447
                           [27]: KB5037018
                           [28]: KB5037995
                           [29]: KB5039336
                           [30]: KB5041579
                           [31]: KB5043935
                           [32]: KB5005699
Network Card(s):           3 NIC(s) Installed.
                           [01]: Realtek PCIe GbE Family Controller
                                 Connection Name: Ethernet
                                 DHCP Enabled:    Yes
                                 DHCP Server:     10.105.4.4
                                 IP address(es)
                                 [01]: 10.105.150.66
                                 [02]: fe80::c1f7:ca5b:ed4c:7ad1
                           [02]: Bluetooth Device (Personal Area Network)
                                 Connection Name: Bluetooth Network Connection 3
                                 Status:          Media disconnected
                           [03]: TP-Link Wireless N PCI Express Adapter
                                 Connection Name: Wi-Fi 3
                                 Status:          Media disconnected
Hyper-V Requirements:      VM Monitor Mode Extensions: Yes
                           Virtualization Enabled In Firmware: Yes
                           Second Level Address Translation: Yes
                           Data Execution Prevention Available: Yes
```
```
MATLAB Version: 24.1.0.2628055 (R2024a) Update 4
MATLAB License Number: 41137037
Operating System: Microsoft Windows 10 Education Version 10.0 (Build 19045)
Java Version: Java 1.8.0_202-b08 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 24.1        (R2024a)                
Simulink                                              Version 24.1        (R2024a)                
5G Toolbox                                            Version 24.1        (R2024a)                
AUTOSAR Blockset                                      Version 24.1        (R2024a)                
Aerospace Blockset                                    Version 24.1        (R2024a)                
Aerospace Toolbox                                     Version 24.1        (R2024a)                
Antenna Toolbox                                       Version 24.1        (R2024a)                
Audio Toolbox                                         Version 24.1        (R2024a)                
Automated Driving Toolbox                             Version 24.1        (R2024a)                
Bioinformatics Toolbox                                Version 24.1        (R2024a)                
Bluetooth Toolbox                                     Version 24.1        (R2024a)                
C2000 Microcontroller Blockset                        Version 24.1        (R2024a)                
Communications Toolbox                                Version 24.1        (R2024a)                
Computer Vision Toolbox                               Version 24.1        (R2024a)                
Control System Toolbox                                Version 24.1        (R2024a)                
Curve Fitting Toolbox                                 Version 24.1        (R2024a)                
DDS Blockset                                          Version 24.1        (R2024a)                
DSP HDL Toolbox                                       Version 24.1        (R2024a)                
DSP System Toolbox                                    Version 24.1        (R2024a)                
Data Acquisition Toolbox                              Version 24.1        (R2024a)                
Database Toolbox                                      Version 24.1        (R2024a)                
Datafeed Toolbox                                      Version 24.1        (R2024a)                
DatapixxToolbox                                       Version 0.9,        Aug                     
Deep Learning HDL Toolbox                             Version 24.1        (R2024a)                
Deep Learning Toolbox                                 Version 24.1        (R2024a)                
EEGLAB Toolbox to process EEG data                    Version -           see                     
EEGLAB Toolbox to process EEG data                    Version -           see                     
Econometrics Toolbox                                  Version 24.1        (R2024a)                
Embedded Coder                                        Version 24.1        (R2024a)                
FieldTrip                                             Version unknown     www.fieldtriptoolbox.org
Filter Design HDL Coder                               Version 24.1        (R2024a)                
Financial Instruments Toolbox                         Version 24.1        (R2024a)                
Financial Toolbox                                     Version 24.1        (R2024a)                
Fixed-Point Designer                                  Version 24.1        (R2024a)                
Fuzzy Logic Toolbox                                   Version 24.1        (R2024a)                
GPU Coder                                             Version 24.1        (R2024a)                
Global Optimization Toolbox                           Version 24.1        (R2024a)                
HDL Coder                                             Version 24.1        (R2024a)                
HDL Verifier                                          Version 24.1        (R2024a)                
Image Acquisition Toolbox                             Version 24.1        (R2024a)                
Image Processing Toolbox                              Version 24.1        (R2024a)                
Industrial Communication Toolbox                      Version 24.1        (R2024a)                
Instrument Control Toolbox                            Version 24.1        (R2024a)                
LTE Toolbox                                           Version 24.1        (R2024a)                
Lidar Toolbox                                         Version 24.1        (R2024a)                
MATLAB Coder                                          Version 24.1        (R2024a)                
MATLAB Compiler                                       Version 24.1        (R2024a)                
MATLAB Compiler SDK                                   Version 24.1        (R2024a)                
MATLAB Report Generator                               Version 24.1        (R2024a)                
MATLAB Test                                           Version 24.1        (R2024a)                
Mapping Toolbox                                       Version 24.1        (R2024a)                
Medical Imaging Toolbox                               Version 24.1        (R2024a)                
Mixed-Signal Blockset                                 Version 24.1        (R2024a)                
Model Predictive Control Toolbox                      Version 24.1        (R2024a)                
Model-Based Calibration Toolbox                       Version 24.1        (R2024a)                
Motor Control Blockset                                Version 24.1        (R2024a)                
Navigation Toolbox                                    Version 24.1        (R2024a)                
Optimization Toolbox                                  Version 24.1        (R2024a)                
Parallel Computing Toolbox                            Version 24.1        (R2024a)                
Partial Differential Equation Toolbox                 Version 24.1        (R2024a)                
Phased Array System Toolbox                           Version 24.1        (R2024a)                
Powertrain Blockset                                   Version 24.1        (R2024a)                
Predictive Maintenance Toolbox                        Version 24.1        (R2024a)                
Psychtoolbox                                          Version 3.0.18      13 October              
RF Blockset                                           Version 24.1        (R2024a)                
RF PCB Toolbox                                        Version 24.1        (R2024a)                
RF Toolbox                                            Version 24.1        (R2024a)                
ROS Toolbox                                           Version 24.1        (R2024a)                
Radar Toolbox                                         Version 24.1        (R2024a)                
Reinforcement Learning Toolbox                        Version 24.1        (R2024a)                
Requirements Toolbox                                  Version 24.1        (R2024a)                
Risk Management Toolbox                               Version 24.1        (R2024a)                
Robotics System Toolbox                               Version 24.1        (R2024a)                
Robust Control Toolbox                                Version 24.1        (R2024a)                
Satellite Communications Toolbox                      Version 24.1        (R2024a)                
Sensor Fusion and Tracking Toolbox                    Version 24.1        (R2024a)                
SerDes Toolbox                                        Version 24.1        (R2024a)                
Signal Integrity Toolbox                              Version 24.1        (R2024a)                
Signal Processing Toolbox                             Version 24.1        (R2024a)                
SimBiology                                            Version 24.1        (R2024a)                
SimEvents                                             Version 24.1        (R2024a)                
Simscape                                              Version 24.1        (R2024a)                
Simscape Battery                                      Version 24.1        (R2024a)                
Simscape Driveline                                    Version 24.1        (R2024a)                
Simscape Electrical                                   Version 24.1        (R2024a)                
Simscape Fluids                                       Version 24.1        (R2024a)                
Simscape Multibody                                    Version 24.1        (R2024a)                
Simulink 3D Animation                                 Version 24.1        (R2024a)                
Simulink Check                                        Version 24.1        (R2024a)                
Simulink Code Inspector                               Version 24.1        (R2024a)                
Simulink Coder                                        Version 24.1        (R2024a)                
Simulink Compiler                                     Version 24.1        (R2024a)                
Simulink Control Design                               Version 24.1        (R2024a)                
Simulink Coverage                                     Version 24.1        (R2024a)                
Simulink Design Optimization                          Version 24.1        (R2024a)                
Simulink Design Verifier                              Version 24.1        (R2024a)                
Simulink Desktop Real-Time                            Version 24.1        (R2024a)                
Simulink Fault Analyzer                               Version 24.1        (R2024a)                
Simulink PLC Coder                                    Version 24.1        (R2024a)                
Simulink Real-Time                                    Version 24.1        (R2024a)                
Simulink Report Generator                             Version 24.1        (R2024a)                
Simulink Test                                         Version 24.1        (R2024a)                
SoC Blockset                                          Version 24.1        (R2024a)                
Spreadsheet Link                                      Version 24.1        (R2024a)                
Stateflow                                             Version 24.1        (R2024a)                
Statistics and Machine Learning Toolbox               Version 24.1        (R2024a)                
Symbolic Math Toolbox                                 Version 24.1        (R2024a)                
System Composer                                       Version 24.1        (R2024a)                
System Identification Toolbox                         Version 24.1        (R2024a)                
Text Analytics Toolbox                                Version 24.1        (R2024a)                
UAV Toolbox                                           Version 24.1        (R2024a)                
Vehicle Dynamics Blockset                             Version 24.1        (R2024a)                
Vehicle Network Toolbox                               Version 24.1        (R2024a)                
Vision HDL Toolbox                                    Version 24.1        (R2024a)                
WLAN Toolbox                                          Version 24.1        (R2024a)                
Wavelet Toolbox                                       Version 24.1        (R2024a)                
Wireless HDL Toolbox                                  Version 24.1        (R2024a)                
Wireless Testbench                                    Version 24.1        (R2024a)                
ans =
    '3.0.18 - Flavor: beta - Corresponds to SVN Revision 12862
     For more info visit:
     https://github.com/Psychtoolbox-3/Psychtoolbox-3'
```
