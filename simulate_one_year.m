function net = simulate_one_year(DI, c0, market, riskTier, ...
    freqUS, freqUK, lambdaMap, betMix, stakeFrac, ...
    qS, bS, qP, bP, wProb, alpha100, alpha500)
% SIMULATE_ONE_YEAR  One 52-week sportsbook account trajectory.
%
% Draws a betting-frequency category from the market-specific
% distribution, then simulates weekly Poisson-distributed bet counts
% with risk-tier-dependent stake sizing and straight/parlay mix.
% Withdrawal behaviour is drawn once per account from wProb.
%
% Returns net annual gain/loss relative to the starting bankroll.

B0     = c0 * DI;   % starting bankroll
B      = B0;        % current bankroll
Wtotal = 0;         % cumulative withdrawals

if strcmpi(market, 'US')
    cat = randsample(1:8, 1, true, freqUS);
else
    cat = randsample(1:8, 1, true, freqUK);
end
lambda = lambdaMap(cat);

wType = randsample(1:4, 1, true, wProb);

pStraight = betMix(riskTier, 1);
pParlay   = betMix(riskTier, 2);  %#ok<NASGU> % implied by 1 - pStraight

for week = 1:52
    nBets = poissrnd(lambda);

    for j = 1:nBets
        if B <= 0
            break;
        end
        s = stakeFrac(riskTier) * B;
        s = min(s, B);

        if rand < pStraight
            if rand < qS
                B = B + bS * s;
            else
                B = B - s;
            end
        else
            if rand < qP
                B = B + bP * s;
            else
                B = B - s;
            end
        end
    end

    % Withdrawal rules, evaluated weekly against cumulative gain
    gain = B - B0;
    if wType == 1
        if gain >= 500
            w = alpha500 * gain;
            w = max(w, 0);
            w = min(w, B);
            B = B - w;
            Wtotal = Wtotal + w;
        end
    elseif wType == 2
        if gain >= 100
            w = alpha100 * gain;
            w = max(w, 0);
            w = min(w, B);
            B = B - w;
            Wtotal = Wtotal + w;
        end
    end
end

net = (B + Wtotal) - B0;
end
