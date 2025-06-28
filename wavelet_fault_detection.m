% Wavelet-Based Fault Detection - Signal Generation

% Sampling parameters
Fs = 1000;                  % Sampling frequency in Hz
t = 0:1/Fs:1;               % Time vector (1 second)

% Healthy signal (pure sine wave)
signal_clean = sin(2*pi*50*t);  

% Faulty signal: sine + noise + impulsive spike
signal_faulty = signal_clean + 0.5*randn(size(t));  
signal_faulty(500:510) = signal_faulty(500:510) + 3;  

% Plotting both signals
figure;
subplot(2,1,1);
plot(t, signal_clean, 'b');
title('Healthy Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, signal_faulty, 'r');
title('Faulty Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Select wavelet type and level
wname = 'db4';     % Daubechies 4 wavelet
level = 4;         % Decomposition level

% Decomposition of clean signal
[cC, lC] = wavedec(signal_clean, level, wname);

% Decomposition of faulty signal
[cF, lF] = wavedec(signal_faulty, level, wname);

% Plot detail coefficients (D1 to D4)
figure;
for i = 1:level
    d_clean = wrcoef('d', cC, lC, wname, i);
    d_faulty = wrcoef('d', cF, lF, wname, i);
    
    subplot(level,2,2*i-1);
    plot(d_clean);
    title(['Clean Signal - D', num2str(i)]);
    
    subplot(level,2,2*i);
    plot(d_faulty);
    title(['Faulty Signal - D', num2str(i)]);
end

% Energy calculation function
getEnergy = @(x) sum(x.^2);

% Initialize arrays
energy_clean = zeros(1, level);
energy_faulty = zeros(1, level);

% Compute energy for each level
for i = 1:level
    d_clean = wrcoef('d', cC, lC, wname, i);
    d_faulty = wrcoef('d', cF, lF, wname, i);
    
    energy_clean(i) = getEnergy(d_clean);
    energy_faulty(i) = getEnergy(d_faulty);
end

% Display table
fprintf('\nEnergy Comparison:\n');
fprintf('Level\tClean\t\tFaulty\n');
for i = 1:level
    fprintf('D%d\t%.4f\t%.4f\n', i, energy_clean(i), energy_faulty(i));
end

% Bar plot for visualization
figure;
bar([energy_clean; energy_faulty]', 'grouped');
legend('Healthy', 'Faulty');
xlabel('Wavelet Level (D1–D4)');
ylabel('Energy');
title('Wavelet Energy Comparison');