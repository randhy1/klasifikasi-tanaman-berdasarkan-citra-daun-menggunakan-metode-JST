clc; clear; close all; warning off all;

nama_folder = 'data latih';
nama_file = dir(fullfile(nama_folder,'*.jpg'));
jumlah_file = numel(nama_file);

area = zeros(1,jumlah_file);
perimeter = zeros(1,jumlah_file);
metric = zeros(1,jumlah_file);
eccentricity = zeros(1,jumlah_file);

% pengolahan citra terhadap seluruh file
for n = 1 : jumlah_file
    % membaca file citra rgb
    I = imread(fullfile(nama_folder, nama_file(n).name));
    %figure,imshow(I);
        
    % Gryscale 
    G = rgb2gray(I);
    %figure, imshow(G);
    
    K = imbinarize(G,0.45);
    %figure, imshow(K);
    
    % melakukan operasi komplemen
    L = imcomplement(K);
    %figure, imshow(L);
    
    % melakukan croping
    C = imcrop(L, [1 1 1200 1400]);
    %figure, imshow(C);
    
    % melakukan operasi morfologi
    % 1. closing
    str = strel('disk',5);
    M = imclose(C,str);
    %figure, imshow(M);
    
    % 2. filling holse
    N = imfill(M, 'holes'); 
    %figure, imshow(N);
    
    % 3. area opening
    O = bwareaopen(N, 5000);
    %figure, imshow(O);
    
    % ekstrasi ciri (bentuk)
    stats = regionprops(O,'Area','Perimeter', 'Eccentricity');
    area(n) = stats.Area;
    perimeter(n) = stats.Perimeter;
    metric(n) = 4*pi*area(n)/(perimeter(n)^2);
    eccentricity(n) = stats.Eccentricity;
end

% menysun variabel input
input = [metric;eccentricity];
% menyusun variabel target
target = zeros(1,jumlah_file);
target(1:100) = 1;
target(101:200) = 2;

% membagun arsitektur jst
rng('default');
net = newff(input,target,[10 5],{'logsig','logsig'}, 'trainlm');
% melakukan pelatihan jaringan
net = train(net,input,target); 
% membaca nilai keluaran janringan
output = round(sim(net,input));

% akurasi
[m,n]= find(output==target);
akurasi = sum(m)/jumlah_file *100;

save net net

