function Q2_GraphRiskDistributions
% Q2: Distribution of annual net outcomes by persona and risk tier.
% Produces per-tier histograms plus an overlay for each persona.

rng(1);
p = model_params();

for i = 1:size(p.people, 1)
    name   = p.people{i, 1};
    market = p.people{i, 2};
    DI     = p.people{i, 3};

    fprintf('\nRunning simulations for %s\n', name);

    nets = zeros(p.nTrials, 3);

    for rt = 1:3
        for t = 1:p.nTrials
            nets(t, rt) = simulate_one_year(DI, p.c0, market, rt, ...
                p.freqUS, p.freqUK, p.lambdaMap, p.betMix, p.stakeFrac, ...
                p.qStraight, p.bStraight, p.qParlay, p.bParlay, ...
                p.wProb, p.alpha100, p.alpha500);
        end

        figure;
        histogram(nets(:, rt), 50);
        title(sprintf('%s - %s Risk', name, p.riskNames{rt}));
        xlabel('Annual Net Gain/Loss');
        ylabel('Count');
        xline(mean(nets(:, rt)),   '--', 'Mean');
        xline(median(nets(:, rt)), '--', 'Median');
    end

    figure;
    hold on;
    colors = lines(3);
    for rt = 1:3
        histogram(nets(:, rt), 50, 'Normalization', 'pdf', ...
            'DisplayStyle', 'stairs', 'EdgeColor', colors(rt, :));
    end
    hold off;
    legend(p.riskNames, 'Location', 'best');
    title(sprintf('%s - All Risk Levels', name));
    xlabel('Annual Net Gain/Loss');
    ylabel('Density');
end
end
