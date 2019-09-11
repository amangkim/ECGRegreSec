%amgecgeval_demo

clear all
amgecgeval_dataset;

w = slicetime;
st = sampletime;

d = eval;
ac_st=eval_mean_sampletime;
ac_w=eval_mean_slice; %Sample Slice mean

eval_mode_sampletime = mode(eval,2); %Sample Time mean
eval_mode_slice=mode(eval,1); %Sample Slice mean

ac_st2 = eval_mode_sampletime;
ac_w2 = eval_mode_slice;

[max_ac_w idx_ac_w] = max (ac_w)
[max_ac_st idx_ac_st] = max (ac_st)

%[max_ac_w2 idx_ac_w] = max (ac_w2);
%[max_ac_st2 idx_ac_st] = max (ac_st2);

x = w;
y = ac_w*100;

x2 = st;
y2 = ac_st*100;

figure
subplot(2,1,1)
hold on
title('Slicing Time vs. Accuracy');
xlabel('Slicing Time [sec]');
ylabel('Accuracy [%]');
grid on
ax = gca;
ax.YLim = [60 95];
b=bar(x,y);
b.FaceColor = 'flat';
b.CData(idx_ac_w,:)=[0.025 0 0.025];
hold off

subplot(2,1,2)
hold on
title('Sampling Time vs. Accuracy');
xlabel('Sampling Time [sec]');
ylabel('Accuracy [%]');
grid on
ax = gca;
ax.YLim = [70 95];
b=bar(x2,y2);
b.FaceColor = 'flat';
b.CData(idx_ac_st,:)=[0.025 0 0.025];
hold off


figure
hold on
title('Slicing Time vs. Accuracy');
xlabel('Slicing Time [sec]');
ylabel('Accuracy [%]');
grid on
ax = gca;
ax.YLim = [60 95];
b=bar(x,y);
b.FaceColor = 'flat';
b.CData(idx_ac_w,:)=[0.025 0 0.025];
hold off

figure
hold on
title('Sampling Time vs. Accuracy');
xlabel('Sampling Time [sec]');
ylabel('Accuracy [%]');
grid on
ax = gca;
ax.YLim = [70 95];
b=bar(x2,y2);
b.FaceColor = 'flat';
b.CData(idx_ac_st,:)=[0.025 0 0.025];
hold off
