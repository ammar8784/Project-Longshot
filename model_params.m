function p = model_params()
% MODEL_PARAMS  Shared simulation parameters for Q2 and Q3.
% Single source of truth so the two scripts cannot drift apart.

p.nTrials = 3000;

% Sportsbook economics
holdStraight = 0.05;    % house edge, straight bets
holdParlay   = 0.15;    % house edge, parlays
p.bStraight  = 0.909;   % net decimal payout, straight
p.bParlay    = 3.0;     % net decimal payout, parlay
p.qStraight  = (1 - holdStraight) / (1 + p.bStraight);  % win prob, straight
p.qParlay    = (1 - holdParlay)  / (1 + p.bParlay);     % win prob, parlay

% Risk tiers: low / medium / high
p.stakeFrac = [0.01 0.02 0.04];      % stake as fraction of bankroll
p.betMix    = [0.90 0.10;            % [straight, parlay] share
               0.75 0.25;
               0.60 0.40];
p.riskNames = {'Low', 'Medium', 'High'};

% Bankroll as a fraction of disposable income
p.c0 = 0.05;

% Betting-frequency category distributions and weekly Poisson rates
p.freqUS    = [0.08 0.15 0.11 0.19 0.19 0.13 0.08 0.06];
p.freqUK    = [0.11 0.23 0.17 0.21 0.18 0.10 0.06 0.04];
p.lambdaMap = [0.0 0.2 0.25 0.75 1.5 3.5 6.0 10.0];

% Withdrawal behaviour types
p.wProb     = [0.23 0.50 0.20 0.05] / sum([0.23 0.50 0.20 0.05]);
p.alpha100  = 0.50;
p.alpha500  = 0.80;

% Personas: {name, market, disposable income} -- DI values come from Q1
p.people = { ...
    'US 23 renter Midwest',  'US', 6216; ...
    'US 35 homeowner West',  'US', 3769; ...
    'US 60 retired South',   'US', 10999; ...
    'UK 30 London',          'UK', 17522; ...
    'UK Wales 30-49',        'UK', 37701};

% Foregone-wealth assumptions
p.r  = 0.06;   % annual compounding rate
p.Y  = 20;     % horizon, years
p.FW_thresholds = [100, 250, 500, 1000];
end
