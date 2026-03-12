function Network_Chaos
    try
        load trafficData.mat
        fprintf("Traffic dataset has been loaded correctly");
    catch
        error("Dataset has not been loaded. Process has been terminated");
    end

    time_ms = traffic_data.Time * 1000; 
    bits = traffic_data.Length * 8;
    time = round(time_ms/1000 - min(time_ms/1000) + 1); % using div by 1000, in order to have a more visuable plot

    %calculate bits/ms 
    fprintf("\n Compute timestring Bits/ms...");
    bits_per_ms = nonlinear_analysis.extract_features(time,bits);
    
    % ---- Starting non_Linear analysin on network traffic
    
    fprintf("\n Starting non-linear Analysis on network traffic...")

    fprintf("\n Calculate system's Entropy by Renyi's approach...");
    Renyi_entropy = nonlinear_analysis.Renyi_Network_Entropy(bits,3000,0.125); %third argument is alpha
end