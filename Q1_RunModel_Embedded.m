function [US_Table, UK_Table, params] = Q1_RunModel_Embedded(doCalibrate)
% Q1: Disposable income model for U.S. and U.K. demographic profiles.
% Estimates gross -> taxes -> net -> essentials -> disposable income.
%
% Usage:
%   [US, UK] = Q1_RunModel_Embedded();       % calibrated (default)
%   [US, UK] = Q1_RunModel_Embedded(false);  % uncalibrated defaults

if nargin < 1
    doCalibrate = true;
end

params    = defaultParams();
demoUS    = getDemoProfiles_US();
demoUK    = getDemoProfiles_UK();
targetsUS = getDemoTargets_US();
targetsUK = getDemoTargets_UK();

if doCalibrate
    params = calibrateUS(params, demoUS, targetsUS);
    params = calibrateUK(params, demoUK, targetsUK);
end

US_Table = buildUSTable(demoUS, params);
UK_Table = buildUKTable(demoUK, params);

fprintf('\n=========================\nUnited States (Q1)\n=========================\n');
disp(formatCurrencyTable_US(US_Table));
fprintf('\n=========================\nUnited Kingdom (Q1)\n=========================\n');
disp(formatCurrencyTable_UK(UK_Table));
end


function params = defaultParams()
params.US_payrollRate = 0.0765;
params.US_fed_brk = [0, 50000; 50000, 100000; 100000, inf];
params.US_fed_r   = [0.0, 0.0, 0.0];
params.US_fed_c   = [0.0, 0.0, 0.0];

[r1, c1] = fitAffine([45000, 48000], [3272, 3632]);
params.US_fed_r(1) = r1;
params.US_fed_c(1) = c1;
params.US_fed_r(2) = 0.097842857;
params.US_fed_c(2) = 0;
params.US_fed_r(3) = 0.148891667;
params.US_fed_c(3) = 0;

params.US_stateRegions = {'Northeast', 'Midwest', 'South', 'West'};
params.US_state_r = zeros(1, 4);
params.US_state_c = zeros(1, 4);
params.US_state_r(2) = 1114 / 45000;
params.US_state_c(2) = 0;
params.US_state_r(3) = 0;
params.US_state_c(3) = 0;
[rw, cw] = fitAffine([120000, 48000], [5606, 1605]);
params.US_state_r(4) = rw;
params.US_state_c(4) = cw;
params.US_state_r(1) = 0;
params.US_state_c(1) = 0;

params.US_ageEssentials           = struct();
params.US_ageEssentials.Under25   = 30956;
params.US_ageEssentials.Age35_44  = 67400;
params.US_ageEssentials.Age55_64  = 52152;

params.US_regionMult           = struct();
params.US_regionMult.Northeast = 1.0;
params.US_regionMult.Midwest   = 1.0;
params.US_regionMult.South     = 1.0;
params.US_regionMult.West      = 38372 / 30956;

params.UK_personalAllowance = 12570;
params.UK_basicRateLimit    = 50270;
params.UK_basicRate         = 0.20;
params.UK_higherRate        = 0.40;
params.UK_niRate            = 0.0;
params.UK_niFree            = 0.0;
params.UK_essentials_40k    = 14798;
params.UK_essentials_70k    = 13456;
end


function demoUS = getDemoProfiles_US()
demoUS = struct([]);

demoUS(1).profile = 'U.S. 23-year-old renter, Midwest, $45,000';
demoUS(1).gross   = 45000;
demoUS(1).ageKey  = 'Under25';
demoUS(1).region  = 'Midwest';
demoUS(1).retired = false;

demoUS(2).profile = 'U.S. 35-year-old homeowner, West, $120,000';
demoUS(2).gross   = 120000;
demoUS(2).ageKey  = 'Age35_44';
demoUS(2).region  = 'West';
demoUS(2).retired = false;

demoUS(3).profile = 'U.S. 60-year-old retired, South, $70,000 income';
demoUS(3).gross   = 70000;
demoUS(3).ageKey  = 'Age55_64';
demoUS(3).region  = 'South';
demoUS(3).retired = true;

demoUS(4).profile = 'U.S. Under-25 renter, West, $48,000 salary';
demoUS(4).gross   = 48000;
demoUS(4).ageKey  = 'Under25';
demoUS(4).region  = 'West';
demoUS(4).retired = false;
end


function demoUK = getDemoProfiles_UK()
demoUK = struct([]);
demoUK(1).profile = 'U.K. 30-year-old (London proxy), GBP 40,000 salary';
demoUK(1).gross   = 40000;
demoUK(2).profile = 'U.K. Age 30-49 (Wales), GBP 70,000 salary';
demoUK(2).gross   = 70000;
end


function targetsUS = getDemoTargets_US()
targetsUS = table( ...
    {'U.S. 23-year-old renter, Midwest, $45,000'; ...
     'U.S. 35-year-old homeowner, West, $120,000'; ...
     'U.S. 60-year-old retired, South, $70,000 income'; ...
     'U.S. Under-25 renter, West, $48,000 salary'}, ...
    [45000; 120000; 70000; 48000], ...
    [3272; 17867; 6849; 3632], ...
    [3442; 9180; 0; 3672], ...
    [1114; 5606; 0; 1605], ...
    [37172; 87347; 63151; 39092], ...
    [30956; 83578; 52152; 38372], ...
    [6216; 3769; 10999; 720], ...
    'VariableNames', {'Profile', 'Gross', 'FedIncomeTax', 'Payroll', ...
                      'State', 'Net', 'Essentials', 'Disposable'});
end


function targetsUK = getDemoTargets_UK()
targetsUK = table( ...
    {'U.K. 30-year-old (London proxy), GBP 40,000 salary'; ...
     'U.K. Age 30-49 (Wales), GBP 70,000 salary'}, ...
    [40000; 70000], ...
    [5486; 15432], ...
    [2194; 3411], ...
    [32320; 51157], ...
    [14798; 13456], ...
    [17522; 37701], ...
    'VariableNames', {'Profile', 'Gross', 'IncomeTax', 'NI', ...
                      'Net', 'Essentials', 'Disposable'});
end


function params = calibrateUS(params, demoUS, targetsUS)
mw = targetsUS.Essentials(strcmp(targetsUS.Profile, demoUS(1).profile));
w  = targetsUS.Essentials(strcmp(targetsUS.Profile, demoUS(4).profile));
params.US_regionMult.West = w / mw;
params.US_ageEssentials.Under25 = mw / params.US_regionMult.(demoUS(1).region);

e35w = targetsUS.Essentials(strcmp(targetsUS.Profile, demoUS(2).profile));
params.US_ageEssentials.Age35_44 = e35w / params.US_regionMult.(demoUS(2).region);

e55s = targetsUS.Essentials(strcmp(targetsUS.Profile, demoUS(3).profile));
params.US_ageEssentials.Age55_64 = e55s / params.US_regionMult.(demoUS(3).region);
end


function params = calibrateUK(params, demoUK, targetsUK)
S1  = demoUK(1).gross;
S2  = demoUK(2).gross;
NI1 = targetsUK.NI(1);
NI2 = targetsUK.NI(2);
[r, f] = fitNIfromTwoPoints([S1, S2], [NI1, NI2]);
params.UK_niRate = r;
params.UK_niFree = f;
params.UK_essentials_40k = targetsUK.Essentials(1);
params.UK_essentials_70k = targetsUK.Essentials(2);
end


function US_Table = buildUSTable(demoUS, params)
n = numel(demoUS);
Profile      = strings(n, 1);
Gross        = zeros(n, 1);
FedIncomeTax = zeros(n, 1);
Payroll      = zeros(n, 1);
State        = zeros(n, 1);
Net          = zeros(n, 1);
Essentials   = zeros(n, 1);
Disposable   = zeros(n, 1);

for i = 1:n
    p = demoUS(i);
    Profile(i)      = string(p.profile);
    Gross(i)        = p.gross;
    FedIncomeTax(i) = US_fedTax(p.gross, params);
    if p.retired
        Payroll(i) = 0;
        State(i)   = 0;
    else
        Payroll(i) = params.US_payrollRate * p.gross;
        State(i)   = US_stateTax(p.gross, p.region, params);
    end
    Net(i)        = p.gross - FedIncomeTax(i) - Payroll(i) - State(i);
    Essentials(i) = US_essentials(p.ageKey, p.region, params);
    Disposable(i) = Net(i) - Essentials(i);
end

US_Table = table(Profile, Gross, FedIncomeTax, Payroll, State, ...
                 Net, Essentials, Disposable);
end


function UK_Table = buildUKTable(demoUK, params)
n = numel(demoUK);
Profile    = strings(n, 1);
Gross      = zeros(n, 1);
IncomeTax  = zeros(n, 1);
NI         = zeros(n, 1);
Net        = zeros(n, 1);
Essentials = zeros(n, 1);
Disposable = zeros(n, 1);

for i = 1:n
    p = demoUK(i);
    Profile(i)   = string(p.profile);
    Gross(i)     = p.gross;
    IncomeTax(i) = UK_incomeTax(p.gross, params);
    NI(i)        = UK_NI(p.gross, params);
    Net(i)       = p.gross - IncomeTax(i) - NI(i);

    if p.gross == 40000
        Essentials(i) = params.UK_essentials_40k;
    elseif p.gross == 70000
        Essentials(i) = params.UK_essentials_70k;
    else
        Essentials(i) = interp1([40000, 70000], ...
            [params.UK_essentials_40k, params.UK_essentials_70k], ...
            p.gross, 'linear', 'extrap');
    end
    Disposable(i) = Net(i) - Essentials(i);
end

UK_Table = table(Profile, Gross, IncomeTax, NI, Net, Essentials, Disposable);
end


function tax = US_fedTax(S, params)
tax = 0;
for b = 1:size(params.US_fed_brk, 1)
    lo = params.US_fed_brk(b, 1);
    hi = params.US_fed_brk(b, 2);
    if S >= lo && S < hi
        tax = params.US_fed_r(b) * S + params.US_fed_c(b);
        return;
    end
end
tax = params.US_fed_r(end) * S + params.US_fed_c(end);
end


function st = US_stateTax(S, region, params)
idx = find(strcmpi(params.US_stateRegions, region), 1);
if isempty(idx)
    st = 0;
    return;
end
st = params.US_state_r(idx) * S + params.US_state_c(idx);
end


function E = US_essentials(ageKey, region, params)
base = params.US_ageEssentials.(ageKey);
mult = params.US_regionMult.(region);
E = base * mult;
end


function tax = UK_incomeTax(S, params)
taxable = max(0, S - params.UK_personalAllowance);
if taxable <= 0
    tax = 0;
    return;
end
basicBand     = params.UK_basicRateLimit - params.UK_personalAllowance;
basicTaxable  = min(taxable, basicBand);
higherTaxable = max(0, taxable - basicTaxable);
tax = params.UK_basicRate * basicTaxable + params.UK_higherRate * higherTaxable;
end


function ni = UK_NI(S, params)
ni = 0;
if S > params.UK_niFree
    ni = params.UK_niRate * (S - params.UK_niFree);
end
end


function T = formatCurrencyTable_US(T)
T.Gross        = addDollar(T.Gross);
T.FedIncomeTax = addDollar(T.FedIncomeTax);
T.Payroll      = addDollar(T.Payroll);
T.State        = addDollar(T.State);
T.Net          = addDollar(T.Net);
T.Essentials   = addDollar(T.Essentials);
T.Disposable   = addDollar(T.Disposable);
end


function T = formatCurrencyTable_UK(T)
T.Gross      = addPound(T.Gross);
T.IncomeTax  = addPound(T.IncomeTax);
T.NI         = addPound(T.NI);
T.Net        = addPound(T.Net);
T.Essentials = addPound(T.Essentials);
T.Disposable = addPound(T.Disposable);
end


function out = addDollar(x)
out = arrayfun(@(v) sprintf('$%s', formatWithCommas(v)), x, 'UniformOutput', false);
end


function out = addPound(x)
out = arrayfun(@(v) sprintf('GBP %s', formatWithCommas(v)), x, 'UniformOutput', false);
end


function s = formatWithCommas(v)
s = regexprep(sprintf('%.0f', v), '(?<=\d)(?=(\d{3})+$)', ',');
end


function [r, c] = fitAffine(x, y)
r = (y(2) - y(1)) / (x(2) - x(1));
c = y(1) - r * x(1);
end


function [niRate, niFree] = fitNIfromTwoPoints(S, NI)
r = (NI(2) - NI(1)) / (S(2) - S(1));
f = S(1) - NI(1) / r;
niRate = r;
niFree = f;
end
