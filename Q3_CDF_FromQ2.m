function Results = Q3_CDF_FromQ2
% Q3: Empirical CDFs of annual net outcome and foregone wealth.
% Translates one-year gambling losses into a 20-year compounded
% opportunity cost and reports it as a Wealth Impact Ratio.

rng(1);
p = model_params();

rows = {};

for i = 1:size(p.people, 1)
    persona = p.people{i, 1};
    market  = p.people{i, 2};
    DI      = p.people{i, 3};

    for rt = 1:3
        G = zeros(p.nTrials, 1);
        for t = 1:p.nTrials
            G(t) = simulate_one_year(DI, p.c0, market, rt, ...
                p.freqUS, p.freqUK, p.lambdaMap, p.betMix, p.stakeFrac, ...
                p.qStraight, p.bStraight, p.qParlay, p.bParlay, ...
                p.wProb, p.alpha100, p.alpha500);
        end

        Q3 = q3_foregone_metrics(DI, G, p.r, p.Y);
        P_FW_gt = arrayfun(@(x) mean(Q3.FW > x), p.FW_thresholds);

        rows(end+1, :) = {persona, market, p.riskNames{rt}, DI, ...
            Q3.MeanNet, Q3.MedianNet, Q3.P_win, ...
            Q3.MedianLoss, Q3.P90Loss, ...
            Q3.MedianFW, Q3.P90FW, ...
            Q3.MedianWIR, Q3.P90WIR, ...
            P_FW_gt(1), P_FW_gt(2), P_FW_gt(3), P_FW_gt(4)}; %#ok<AGROW>

        figure;
        [fG, xG] = ecdf(Q3.G);
        plot(xG, fG, 'LineWidth', 1.5);
        grid on;
        title(sprintf('%s (%s Risk): CDF of Annual Net Outcome', ...
            persona, p.riskNames{rt}));
        xlabel('G_{1y} (annual net gain/loss)');
        ylabel('CDF: P(G <= x)', 'Interpreter', 'none');
        xline(0, '--', 'G=0');

        figure;
        [fF, xF] = ecdf(Q3.FW);
        plot(xF, fF, 'LineWidth', 1.5);
        grid on;
        title(sprintf('%s (%s Risk): CDF of Foregone Wealth (r=%.0f%%, Y=%d)', ...
            persona, p.riskNames{rt}, 100 * p.r, p.Y));
        xlabel('FW = max(0,-G_{1y})*(1+r)^Y');
        ylabel('CDF: P(FW <= x)', 'Interpreter', 'none');
    end
end

Results = cell2table(rows, 'VariableNames', ...
    {'Persona', 'Market', 'RiskTier', 'DI', ...
     'MeanNet', 'MedianNet', 'P_Win', ...
     'MedianLoss', 'P90Loss', ...
     'MedianFW', 'P90FW', ...
     'MedianWIR', 'P90WIR', ...
     'P_FW_gt_100', 'P_FW_gt_250', 'P_FW_gt_500', 'P_FW_gt_1000'});

disp(Results);
end
