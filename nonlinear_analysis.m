classdef nonlinear_analysis
    methods (Static)
        function bits_per_ms = extract_features(time,bits)
            bits_per_ms = accumarray(time,bits);
        end


        function PLotNetwork(bits_per_ms)
            %arguments: -> traffic network dataset
            %           -> bits_per_ms by extract_features function
            close all; clc;

            x_axis = 1:length(bits_per_ms);

            figure;
            plot(x_axis,bits_per_ms,'-r','LineWidth',0.5);
            title("NetWork's Dynamic");
            xlabel("Time (ms)");
            ylabel("Bits/ms");
            grid on;
        end

        % Shanno's Entropy of network
        function network_entropy = Sh_Entropy(bits)
            % argument: bits (traffic_data.Length)

            %---- block of code to comppute system's entropy ----
            window_size = 1000; % set a window size 

            %number of samples
            number_samples = floor(length(bits) / window_size);
            %have a different amount of packets
            samples = size(number_samples,1);
            %create an 1D array with zeros for saving entropy
            network_entropy = zeros(samples,1);

            for i = 1:number_samples
                if i == 1
                    end_idx = window_size;
                end
                
                start_idx = end_idx - window_size + 1;
                end_idx = (i * window_size) + 1;

                %calulate entropies for every 1000 bits
                temp_bits = bits(start_idx : end_idx);

                temp = histcounts(temp_bits,'Normalization','probability');

                %adding this line in order to avoid inf by (log2(0))
                temp = temp(temp > 0);

                %Shannon's Entropy approach
                network_entropy(i) = -sum(temp .* log2(temp));

            end
            
            % ---- Block of code for diagrams ----
            %this block of code represents figure for Entropy
            figure('Name','Network Traffic Entropy Distribution');
            grid on;
            title("System's Entropy");
            xlabel("Entropy's Value");
            ylabel("Probability Density");

            %addind block of code to plot entropy for network
            mean_value = mean(network_entropy);
            std_value = std(network_entropy);

            x = linspace(mean_value - 4*std_value, mean_value + 4*std_value, 100);
            y = normpdf(x,mean_value,std_value);

            %creating histogramm for raw datas
            histogram(network_entropy,'Normalization','pdf');
            
            %creating figure for entropy of system
            hold on;
            plot(x,y,'-w','LineWidth',2);
            hold off;

            %figure: entropy - time
            figure('Name','Network Traffic Entropy in Time');
            grid on;
            xlabel("Time");
            ylabel("System's Entropy");
            plot(network_entropy,'-b','LineWidth',1.5);
        end
    
    end
end