%% Succolarity Index Computing
%Author: Amirhossein Samavi ( amirhosseinsamavi79@gmail.com )
%change image path in line 8
%change box sizes based on your image size in line 26
%for test the code by random binary matrix you can uncomment line 10,25 and
%comment line 9,26
function dq = SI (Ipath)
%% prepare image
I=imread('type your own image address');
I=im2bw(I,0.4);
%I = round(rand(8,16));I = [0,0,0,0;0,1,1,1;0,1,0,0;0,0,0,0]
I=-I+1; % crack : 1
dir = 't2b';
%% handle other direction by rotating
if dir == 'b2t'
    I = flip(I);
elseif dir == 'l2r'
    I = rot90(I,3)
elseif dir == 'r2l'
    I = rot90(I,1);
end

%% Define box sizes
[rows,cols] = size(I)
maxBoxSize = gcd(rows, cols);
%boxSizes = [maxBoxSize/4];
boxSizes = [maxBoxSize/2, maxBoxSize/4, maxBoxSize/8, maxBoxSize/16, maxBoxSize/32, maxBoxSize/64, maxBoxSize/128, maxBoxSize/256, maxBoxSize/512];

%% Close the other three directions
zerosCol = zeros(rows,1);
zerosRow = zeros(1, cols+2);
I = [zerosCol,I,zerosCol];
I = [I;zerosRow];
[newRowNum,newColNum] = size(I);

%% Create one matrix
M = ones(newRowNum,newColNum); % 1: holes (black) 0: obstacle

%% Step 0: find first row that have 0
startRow = 1;
for i=1:newRowNum
    if I(i,:) == 0 
        startRow = startRow +1 
    else
        break
    end
end

%% Step1: 1 replace by 0 from top to bottom
for j=1:newColNum
    for i=startRow:newRowNum
        if I(i,j) == 0
            break
        else 
            M(i,j) = 0;
        end
    end
end

%% Step2: Check the ability to move left, right and down as long as possible  
preSum = sum(sum(M));
nextSum = 0;
while nextSum ~= preSum
    preSum = nextSum;
    for i=startRow:newRowNum
        for j=1:newColNum
            if M(i,j) == 0
                %check right
                if I(i,j+1) == 1 
                    M(i,j+1) = 0;
                end
                %check left
                if I(i,j-1) == 1 
                    M(i,j-1) = 0;
                end
            end
        end
    end
    for j=1:newColNum
        for i=startRow+1:newRowNum
            if M(i,j) == 0
                %check top
                if I(i-1,j) == 1 
                    M(i-1,j) = 0;
                end
                %check bottom
                if I(i+1,j) == 1 
                    M(i+1,j) = 0;
                end
            end
        end
    end
    nextSum = sum(sum(M));
end

%% Remove extra border in order : last row, first col and last col
M(end,:) = [];
M(:,1) = [];
M(:,end) = [];
M=-M+1; 

%% Compute succolarity (OP and PR)
len = length(boxSizes);
%In OP matrix col shows each boxSize
OP = double(zeros(rows/min(boxSizes),len));
%pressure (PR)
PR = double(zeros(rows/min(boxSizes),len));
%Denominator = assume all boxes are completely black  
dm = zeros(rows/min(boxSizes),len);
for k=1:len
    boxOPs = [];
    boxSize = boxSizes(k);
    bnx = rows/boxSize;
    bny = cols/boxSize;
    for i=1:bnx
        for j=1:bny
            boxOPs(i,j) = sum(sum(M((i-1)*boxSize+1:i*boxSize,(j-1)*boxSize+1:j*boxSize)))/boxSize^2;
        end
        PR(i,k) = (boxSize/2) + (i-1)*boxSize;
        dm(i,k) = PR(i,k)*bny;
    end
    %Sum of boxes OP that have same pressure
    sumOP = sum(boxOPs,2);
    OP(1:length(sumOP),k) = sumOP;
end

%% Result
%The numerator
numerator = sum(PR.*OP);
%The denominator 
denominator = sum(dm);
%succolarity index
result = (numerator./denominator)*10^6
boxSizes
plot(boxSizes,result,'r-x');hold on
xlabel('box sizes','FontSize',14);
ylabel('succolarity index','FontSize',14);
