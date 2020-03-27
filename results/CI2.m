function [Median, LowNotch, HiNotch] = CI2(in)

correct = tinv(0.975,size(in,1)-1)/1.96;

pct      = prctile(in,[25 50 75]);
Median   = pct(2,:);
LowNotch = pct(2,:)-1.57*correct*2*(pct(2,:)-pct(1,:))/sqrt(size(in,1));
HiNotch  = pct(2,:)+1.57*correct*2*(pct(3,:)-pct(2,:))/sqrt(size(in,1));



% 
% for n = 1 : size(in,2)
%     
%     if HiNotch(n) > pct(3,n)
%         HiNotch(n) = pct(3,n);
%     end
%     if LowNotch(n) < pct(1,n)
%         LowNotch(n) = pct(1,n);
%     end
% end
