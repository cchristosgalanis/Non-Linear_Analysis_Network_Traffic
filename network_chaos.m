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

    %plot for network traffic
    fprintf("\n Plotting Network Traffic...");
    nonlinear_analysis.PLotNetwork(bits_per_ms);

    % ---- Starting non_Linear analysin on network traffic
    
    fprintf("\n Starting non-linear Analysis on network traffic...")

    fprintf("\n Calculate system's Entropy by Shannon's approach...");
    network_entropy = nonlinear_analysis.Sh_Entropy(bits);
end