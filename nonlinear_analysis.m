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
            epsilon = random(0,1); % epsilon is number between 0 and 1
            gamma = 2; %or 3 | parameter for std
            D = zeros(1,w);
            matrix_size = length(Renyi_entropy);
            beta = zeros(1,matrix_size);

            for t=w+1: 1 :length(Renyi_entropy)
                %difference entropies of consecutive entropies
                for k = 1:w
                    m = t - w + k;
                    D(k) = abs(Renyi_entropy(m) - Renyi_entropy(m-1));
                end

                %finding min and max in D matrix for each window
                Dmin = min(D); Dmax = max(D);

                if (Dmin - Dmax) == 0
                    beta(t) = 0;
                else
                    %formula for dynamically calculating β
                    beta(t) = sum((D - Dmax)/(Dmin - Dmax) + epsilon)/w;
                end
            end
        end
    
    end
end