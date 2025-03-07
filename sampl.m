  case VS_OUTPUT_HEART_BREATHING_RATES
                                                          % Extract BPM value and raw heart sound waveform
                   [extractedValue, byteVecIdx] = getVitalSignsDemoHeartBreathingRate(bytevec_cp, byteVecIdx);
                    heartRateBPM = extractedValue(1);
                    heartSoundSignal = double(extractedValue(2:end)); % Ensure double type
                    
                    % Sampling frequency
                    fs = 5000;  % Sampling frequency (Hz)
                    lowCut = 20;  % Lower cutoff frequency (Hz)
                    highCut = 150; % Upper cutoff frequency (Hz)
                    
                    % Design a bandpass Butterworth filter
                    [b, a] = butter(4, [lowCut highCut] / (fs / 2), 'bandpass');
                    
                    % Persistent buffer to store heart sound data
                    persistent heartSoundBuffer;
                    bufferSize = fs * 4; % Store 4 seconds of data
                    
                    if isempty(heartSoundBuffer)
                        heartSoundBuffer = [];
                    end
                    
                    % Flush old data from buffer to prevent ghost plotting
                    heartSoundBuffer = [];
                    
                    % Create figure for live plotting
                    figure;
                    hPlot = plot(nan, nan, 'r', 'LineWidth', 1.5); % Initialize red plot
                    xlabel('Time [s]');
                    ylabel('Amplitude');
                    title('Live Heart Sound Signal');
                    grid on;
                    xlim([0, 4]); % Show 4 seconds of data
                    ylim([-0.2, 0.2]); % Adjust dynamically
                    hold on;
                    
                    % Live processing loop
                    while true
                        % Simulate receiving sensor data (Replace this with actual sensor input)
                        [heartRateBPM, heartSoundSignal] = getVitalSignsData();
                    
                        % Ensure signal is double type
                        heartSoundSignal = double(heartSoundSignal);
                    
                        % Append new data to buffer
                        heartSoundBuffer = [heartSoundBuffer; heartSoundSignal];
                    
                        % Keep only the latest 4 seconds of data
                        if length(heartSoundBuffer) > bufferSize
                            heartSoundBuffer = heartSoundBuffer(end-bufferSize+1:end);
                        end
                    
                        % Process only if we have enough data
                        if length(heartSoundBuffer) >= 500  % Update plot every 500 samples
                            % Apply bandpass filter
                            filteredSound = filtfilt(b, a, heartSoundBuffer);
                    
                            % Apply moving average smoothing (window size 10)
                            smoothedSound = movmean(filteredSound, 10);
                    
                            % Normalize the signal
                            smoothedSound = smoothedSound / max(abs(smoothedSound));
                    
                            % Update plot
                            timeAxis = (1:length(smoothedSound)) / fs;
                            set(hPlot, 'XData', timeAxis, 'YData', smoothedSound);
                            ylim([-1, 1]);  % Adjust y-limits dynamically
                    
                            drawnow;
                        else
                            disp(['Waiting for more data... Collected: ', num2str(length(heartSoundBuffer))]);
                        end
                    
                        % Simulated delay to mimic real-time acquisition
                        pause(0.1);
                    end
