classdef nonlinear_analysis
    methods (Static)

        %function to extract as bits_per_ms
        function bits_per_ms = extract_features(time,bits)
            bits_per_ms = accumarray(time,bits);
        end

        %function to plot Network traffic
        function PLotNetwork(bits_per_ms)
            %arguments: -> traffic network dataset
            %           -> bits_per_ms by extract_features function
            close all; clc;

            x_axis = 1:length(bits_per_ms);

            figure('Name', "Network Traffic Distribution of bits/ms");
            plot(x_axis,bits_per_ms,'-r','LineWidth',0.5);
            title("NetWork's Dynamic");
            xlabel("Time (ms)");
            ylabel("Bits/ms");
            grid on;
        end

        % Shannon's Entropy of network
        function Shannon_network_entropy = Sh_Entropy(bits,window_size)
            % argument: bits (traffic_data.Length)
            %           window size -> window to seperate signal

            if nargin < 2
                window_size = 1000;
            end

            %---- block of code to comppute system's entropy ---- 

            %number of samples
            number_samples = floor(length(bits) / window_size);
            %create an 1D array with zeros for saving entropy
            Shannon_network_entropy = zeros(number_samples,1);

            for i = 1:number_samples
                
                %definition of the start and end boundaries
                end_idx = (i * window_size);
                start_idx = end_idx - window_size + 1;

                %calulate entropies for every 1000 bits
                temp_bits = bits(start_idx : end_idx);

                temp = histcounts(temp_bits,'Normalization','probability');

                %adding this line in order to avoid inf by (log2(0))
                temp = temp(temp > 0);

                %Shannon's Entropy approach
                Shannon_network_entropy(i) = -sum(temp .* log2(temp));

            end
            
            % ---- Block of code for diagrams ----
            %this block of code represents figure for Entropy
            figure('Name','Network Traffic Entropy Distribution');
            grid on;
            title("System's Entropy");
            xlabel("Entropy's Value");
            ylabel("Probability Density");

            %addind block of code to plot entropy for network
            mean_value = mean(Shannon_network_entropy);
            std_value = std(Shannon_network_entropy);

            x = linspace(mean_value - 4*std_value, mean_value + 4*std_value, 200);
            y = normpdf(x,mean_value,std_value);

            %creating histogramm for raw datas
            histogram(Shannon_network_entropy,'Normalization','pdf');
            
            %creating figure for entropy of system
            hold on;
            plot(x,y,'-w','LineWidth',2);
            hold off;

            %figure: entropy - time
            figure('Name','Network Traffic Entropy in Time');
            grid on;
            xlabel("Time");
            ylabel("System's Entropy");
            plot(Shannon_network_entropy,'-c','LineWidth',1.5);
        end

        %function to calculate Renyi Entropy | version1.0
        function Renyi_entropy = Renyi_Network_Entropy(bits,window_size,alpha_matrix)
            % arguments: bits -> bits_per_ms
            %           window_size -> window to seperate signal
            %           alpha -> Renyi's entropy parameter
            
            if nargin < 2
                window_size = 1000;
            end

            matrix_size = length(alpha_matrix);
            number_samples = floor(length(bits) / window_size);
            disp(number_samples);
            %creating 1D array to save Renyi's Entropy
            Renyi_entropy = zeros(number_samples,matrix_size); %creating a 2D array

            for i = 1:number_samples
                %creating boundaries
                end_idx = i * window_size;
                start_idx = end_idx - window_size + 1;

                %calculate entropies for every bracket of bits
                temp_bits = bits(start_idx : end_idx);

                temp = histcounts(temp_bits,'Normalization','probability');

                %adding this line in order to avoid inf
                temp = temp(temp > 0);
                
                for j = 1:length(alpha_matrix)
                    alpha = alpha_matrix(j);

                    %as we proved, when alpha tends to 1, we obtain Shannon entropy
                    if alpha == 1
                        Renyi_entropy(i,j) = -sum(temp .* log2(temp));
                    else
                        Renyi_entropy(i,j) = (1/(1 - alpha)) * log2(sum(temp .^ alpha));
                    end
                end
            end

            figure("Name","Renyi Entropy on Network Traffic");
            for k = 1:4
                grid on;
                subplot(2,2,k);
                plot(Renyi_entropy(:,k),'-c','LineWidth',1.5);
                title("Renyi Entropy (a = " + string(alpha_matrix(k)) +") ");
                xlabel("Time (ms)");
                ylabel("Renyi Entropy");
            end
        end

        %function to calculate Renyi Entropy | version2.0
        function model_output = statistic_model(Renyi_entropy)
            %argument: matrix of Renyi entropies
            
            %initialize of parameters
            w = 15; %according to paper of Renyi Entropy approach
            epsilon = 0.001; % epsilon is number between 0 and 1
            gamma = 2; %or 3 | parameter for std
            D = zeros(1,w);
            matrix_size = length(Renyi_entropy);
            beta = zeros(1,matrix_size);
            R_pred = zeros(1,matrix_size);
            A = zeros(1,matrix_size);
            C = zeros(1,matrix_size);
            F = zeros(1,matrix_size);
            upper = zeros(1,matrix_size);
            lower = zeros(1,matrix_size);

            for t=w+1: 1 :length(Renyi_entropy)
                %difference entropies of consecutive entropies
                for k = 1:w
                    m = t - w + k;
                    D(k) = abs(Renyi_entropy(m) - Renyi_entropy(m-1));
                end

                %finding min and max in D matrix for each window
                Dmin = min(D); Dmax = max(D);

                if (Dmin - Dmax) == 0
                    beta(t) = epsilon / w; % explain this in paper
                else
                    %formula for dynamically calculating β
                    beta(t) = sum((D - Dmax)/(Dmin - Dmax) + epsilon)/w;
                end
                % calculating predictable entropy
                for j = 1:w
                    R_pred(t) = R_pred(t) + beta(t) .* (1-beta(t))^(j-1) .* Renyi_entropy(t-j);
                end

                %calculatin A matrix for mean and C matrix for std
                R_wind_pred = R_pred( (t-w+1) : t);

                A(t) = mean(R_wind_pred);
                C(t) = std(R_wind_pred,1);

                %creating F matrix by multiple with gamma
                F(t) = gamma * C(t);
                upper(t) = A(t) + F(t);
                lower(t) = A(t) - F(t);
            end
            
            % valid range
            t_valid = (w+1):matrix_size;

            figure("Name","Dynamic Anomaly Detection using Renyi Entropy and Adaptive EWMA Thresholds"); 
            hold on;

            % 1. Φόντο Κανονικής Περιοχής (Απαλό, ξεκούραστο γκρι)
            fill([t_valid fliplr(t_valid)], [upper(t_valid) fliplr(lower(t_valid))], ...
                [0.88 0.89 0.91], 'EdgeColor', 'none', 'FaceAlpha', 0.6);

            % 2. Όρια (Κομψό Μπορντό/Κόκκινο με διακεκομμένη γραμμή για να μην μπερδεύεται με την εντροπία)
            plot(t_valid, upper(t_valid), 'Color', [0.75 0 0], 'LineWidth', 1.2, 'LineStyle', '--');
            plot(t_valid, lower(t_valid), 'Color', [0.75 0 0], 'LineWidth', 1.2, 'LineStyle', '--');

            % 3. Πραγματική Εντροπία (Βαθύ Μπλε για να "γράφει" καλά πάνω στο γκρι)
            plot(1:matrix_size, Renyi_entropy, 'Color', [0 0.3 0.6], 'LineWidth', 1.8);

            % Detect anomalies ONLY where bounds exist
            anomalies = false(1, matrix_size);
            anomalies(t_valid) = (Renyi_entropy(t_valid) > upper(t_valid)) | (Renyi_entropy(t_valid) < lower(t_valid));

            % 4. Anomalies (Έντονο Magenta κύκλοι - Χωρίς γραμμή σύνδεσης)
            plot(find(anomalies), Renyi_entropy(anomalies), 'o', ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceColor', [1 0 0.5], ...
                'MarkerSize', 5);

            % Καλλωπισμός Γραφήματος
            legend('Normal Region', 'Threshold Limits', '', 'Renyi Entropy (Observed)', 'Detected Anomalies', ...
                   'Location', 'northeastoutside');
            xlabel('Time Window (t)');
            ylabel('Entropy Value (H)');
            set(gca, 'GridColor', [0.8 0.8 0.8], 'FontSize', 10);
            grid on;
            hold off;

            model_output = [lower' upper'];
        end
    
    end
end