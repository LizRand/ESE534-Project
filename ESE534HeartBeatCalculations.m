%       Import files
% Note: file path will have to be changed for every measurement as they are
% recorded in a different txt file every time
filename = 'C:/Users/eliza/PyCharmProjects/10-1-7.txt';
raw = readtable(filename, 'FileType', 'text', 'Delimiter', ',');

%       Pulling out the data
x = raw{:,1};  % x measurements are first in recorded data
y = raw{:,2};  % y measurements are second in recorded data
z = raw{:,3};  % z measurements are third in recorded data

%       Sampling rate
fs = 65; % Freq is 65 Hz which was given to us by PhD - based on code written for extraction of data
t = (0:length(x)-1)/fs; % Finding time vector for FFT - don't have period but have fs

%       DC Offset Removal 
% Subtracting the mean from each signal will remove the DC offset
x0 = x - mean(x);
y0 = y - mean(y);
z0 = z - mean(z);

%       Bandpass Filter Definitions
% The range of BPM for an average human is 60 - 100 BPM
low_bpm = 60;
high_bpm = 100;
% Conversion to Hz - able to use in bandpass filter now
low_hz = low_bpm * 0.01666667;
high_hz = high_bpm * 0.01666667;

% Note: for bandpass function to be operational, Signal Processing Add-On
% needs to be installed
x_f = bandpass(x0, [low_hz high_hz], fs);
y_f = bandpass(y0, [low_hz high_hz], fs);
z_f = bandpass(z0, [low_hz high_hz], fs);

%       ECG Machine Measurements
% ECG machine measures heartrate by voltage (magnitude) vs time, so mag
% will need to be calculated post-bandpass filter

volt_mag = sqrt(x_f.^2 + y_f.^2 + z_f.^2);

%       Cleaning up some noise
% Average BPM range is from 60-100 which is 1-0.6 beats per second, so need
% to choose something <0.6s so that the heartbeats are still seperate
smooth_window_sec = 0.2;   % chose 0.2s 
smooth_N = max(3, round(smooth_window_sec*fs)); % Converts secs to # of samples
volt_mag_smooth = movmean(volt_mag, smooth_N);  % moving mean of voltage_mag for # of samples

%       FFT Measurements
% Frequency-domain values calculate the absolute or relative amount of
% signal energy. This is important to be able to tell the HRV

N = length(volt_mag_smooth);
f = (0:N-1)*(fs/N);
MAG_FFT = abs(fft(volt_mag_smooth));

%       Plotting Graphs
% ECG Graph
figure;
plot(t, x_f, 'r'); hold on;
plot(t, y_f, 'g');
plot(t, z_f, 'b');
plot(t, volt_mag_smooth, 'k', 'LineWidth', 1.4);
title('Heartbeat-Band Filtered XYZ + Magnitude');
xlabel('Time (s)');
ylabel('Filtered Amplitude');
legend('X filtered','Y filtered','Z filtered','Magnitude');
grid on;

% FFT Graph
figure;
plot(f, MAG_FFT);
xlim([0 5]);  % heartbeats are 0–3 Hz
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('FFT – Detect Heartbeat Frequency');
grid on;