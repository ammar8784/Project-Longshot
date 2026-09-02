function Q3 = q3_foregone_metrics(DI, G, r, Y)
% Q3_FOREGONE_METRICS  Convert annual net outcomes into foregone wealth.
%
%   DI  disposable income for the persona
%   G   vector of annual net gain/loss draws
%   r   annual compounding rate (e.g. 0.06)
%   Y   horizon in years (e.g. 20)
%
% FW  = losses compounded forward at r over Y years
% WIR = Wealth Impact Ratio, foregone wealth as a multiple of DI

if DI <= 0
    error("DI must be > 0. Got DI=%g", DI);
end

G   = G(:);
L   = max(0, -G);
FW  = L * (1 + r)^Y;
WIR = FW / DI;

Q3.P_win      = mean(G > 0);
Q3.MeanNet    = mean(G);
Q3.MedianNet  = median(G);
Q3.MedianLoss = median(L);
Q3.P90Loss    = prctile(L, 90);
Q3.MedianFW   = median(FW);
Q3.P90FW      = prctile(FW, 90);
Q3.MedianWIR  = median(WIR);
Q3.P90WIR     = prctile(WIR, 90);

Q3.G   = G;
Q3.L   = L;
Q3.FW  = FW;
Q3.WIR = WIR;
end
