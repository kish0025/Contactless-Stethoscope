function processVitalSigns(bytevec_cp, VS_OUTPUT_HEART_BREATHING_RATES)
    global phaseDataBuffer lastProcessTime figHandle1 lastValidHeartRate;
    
    try
        % Initialize if needed
        initializeGlobals();
        
        % Process incoming data
        if nargin > 0 && ~isempty(bytevec_cp)
            byteVecIdx = 0;
            samplingRate = 1000;
            
            switch VS_OUTPUT_HEART_BREATHING_RATES
                case VS_OUTPUT_HEART_BREATHING_RATES
                    [extractedValue, byteVecIdx] = getVitalSignsDemoHeartBreathingRate(bytevec_cp, byteVecIdx);
                    
                    if ~isempty(extractedValue)
                        % Process in smaller chunks to improve responsiveness
                        chunkSize = 500;
                        for i = 1:chunkSize:length(extractedValue)
                            endIdx = min(i + chunkSize - 1, length(extractedValue));
                            chunk = extractedValue(i:endIdx);
                            
                            % Process the chunk
                            processedSignal = processHeartSounds(chunk, samplingRate);
                            
                            % Only accumulate if signal is valid
                            if ~all(processedSignal == 0)
                                if isempty(phaseDataBuffer)
                                    phaseDataBuffer = processedSignal;
                                else
                                    phaseDataBuffer = [phaseDataBuffer; processedSignal];
                                end
                                
                                % Maintain buffer size
                                bufferMaxLength = samplingRate * 4;
                                if length(phaseDataBuffer) > bufferMaxLength
                                    phaseDataBuffer = phaseDataBuffer(end-bufferMaxLength+1:end);
                                end
                            end
                        end
                        
                        % Update visualization at controlled rate
                        currentTime = now;
                        if length(phaseDataBuffer) >= samplingRate && ...
                           (isempty(lastProcessTime) || (currentTime - lastProcessTime) * 24 * 3600 >= 1/30)
                            
                            updateVisualization(phaseDataBuffer, samplingRate);
                            lastProcessTime = currentTime;
                        end
                    end
            end
        end
        
    catch ME
        fprintf('Error in processVitalSigns: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  File: %s, Line: %d, Function: %s\n', ...
                    ME.stack(k).file, ME.stack(k).line, ME.stack(k).name);
        end
    end
return