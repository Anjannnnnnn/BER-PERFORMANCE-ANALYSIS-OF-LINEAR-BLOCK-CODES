N=50000; %Length of data bit stream
m = randi([0 1],1,N);            %Random 0s and 1s

%Repetition Coding
c=[];
for i=1:N
 c=[c m(i) m(i) m(i) m(i) m(i)]; %Repeated symbol 3 times
end

%BPSK Mapping
x=[];
for i=1:length(c)
 if c(i)==0
 x(i)= -1;
 else
 x(i)= 1;
 end
end

r=1/5;                  %Code rate
rep = 5;                %Block size

BER_sim_HDD=[];         %Matrix declaration for Hard Decision Decoding
BER_th_C = [];          %Matrix declaration for Coded BPSK
BER_UC = [];            %Matrix declaration for Uncoded BPSK
BER_sim_SDD=[];         %Matrix declaration for Soft Decision Decoding

for EbN0dB=0:10
 EbN0=10.^(EbN0dB/10);
 sigma = sqrt(1/(2*r*EbN0));        %Noise Standard deviation
 n = sigma.*randn(1,length(x));     %Random Noise(AWGN) with adjusted variance
 y=x+n;                             %Received symbol = Transmitted + Noise

 c_cap=(y>0);                       %If y is positive, c_cap=1, otherwise c_cap=0

  m_cap_HDD=[];                     % Hard Decision Coding (decision of a bit is not dependent on other bits)
  m_cap_SDD=[];                     %Soft Decision Coding (Dependent on neighbouring bits)

  % Hard Decision Coding
 for j=1:(length(c_cap)/rep)
 code_HDD = c_cap((j-1)*rep+1:j*rep); %Storing one block of symbols in single variable (3 bits)
 if sum(code_HDD)>=3
 code1=1;
 else
 code1=0;
 end
 m_cap_HDD = [m_cap_HDD code1];

 %Soft Decision Coding
 code_SDD=y((j-1)*rep+1:j*rep);
 if sum(code_SDD)>0
 code2=1;
 else
 code2=0;
 end
 m_cap_SDD=[m_cap_SDD code2];
 end

noe_HDD = sum(m~=m_cap_HDD);                %Number of Errors HDD
ber_sim_HDD = noe_HDD/N;
BER_sim_HDD=[BER_sim_HDD ber_sim_HDD];     %Appending the BER values in an array


noe_SDD= sum(m~=m_cap_SDD);                %Number of Errors SDD
ber_sim_SDD = noe_SDD/N;
BER_sim_SDD=[BER_sim_SDD ber_sim_SDD];     %Appending the BER values in an array


p = qfunc(sqrt(2*r*EbN0));                              %Single bit Probability of Error in Coded BPSK
ber_th_q= 5*(p^4)*(1-p) + p^5+ 10*(1-(p^2))*(p^3);      %3-bit Error + 4-bit Error
BER_th_C = [BER_th_C ber_th_q];                         %Theoretical BER for Coded BPSK
BER_UC = [BER_UC 0.5*erfc(sqrt(EbN0))];                 %BER for Uncoded BPSK
end

EbN0dB = 0:10;
semilogy(EbN0dB,BER_sim_HDD,'r*-',EbN0dB,BER_th_C,'b--',EbN0dB,BER_UC,'go-',EbN0dB,BER_sim_SDD,'b^-');
title("BER Analysis of (5,1) Repetition Code");
xlabel('Eb/N0(dB)');
ylabel('BER');
grid on;
legend("Simulated HDD","Theoretical","Uncoded","Simulated SDD");
axis([min(EbN0dB) max(EbN0dB) 10^-4 10^0]);
