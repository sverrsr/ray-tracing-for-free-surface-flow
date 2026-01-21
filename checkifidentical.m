clear all;

% Paths to folders
folderA = "//tsclient/E/DNS/re2500_we10/test/traced/re2500_we10_raytraced_D3.00pi";;
folderB = "//tsclient/E/DNS/re2500_we10/test/traced3pi";

index = 10;

% Get and sort MAT files
filesA = dir(fullfile(folderA, '*.mat'));
filesB = dir(fullfile(folderB, '*.mat'));

[~, ia] = sort({filesA.name});
[~, ib] = sort({filesB.name});

filesA = filesA(ia);
filesB = filesB(ib);


A = load(fullfile(folderA, filesA(index).name));
B = load(fullfile(folderB, filesB(index).name));

% Extract screen    
screenA = cropimg2(finalPP_simple(A.screen.image));
screenB = cropimg2(finalPP_simple(B.screen.image));


% Plot side by side
figure();

subplot(1,3,1)
imshow(screenA)
axis image off
colorbar
title('Folder A')

subplot(1,3,2)
imagesc(screenB)
axis image off
colorbar
title('Folder B')

subplot(1,3,3)
imagesc(screenA - screenB)
axis image off
colorbar
title('Difference (A - B)')

colormap(gray)







