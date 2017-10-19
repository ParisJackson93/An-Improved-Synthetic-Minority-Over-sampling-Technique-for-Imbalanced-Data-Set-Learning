function [ QSMOTEDateSet ] = QSMOTE2_2(  trainSet,majorClassNo,minorClassNo,K )
% �h��noise ��o�� sminfSet
% �HsminfSet ����̪�K�Ӧh�ƾF�~�p�� �o�� sbmajSet
% �HsbmajSet ����̪�K�ӤּƾF�~�p�� �o�� siminSet
% ��siminSet�����p�� W �H�� �Z��  ,�åH����SEED SET
% W= �h�����O�P���+1(1�O�ۤv)/�ּ����O�P���+1
% �Z��= �h�����O�P�b��1/ �h+�� �P�b��+1+1


outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
majorClassInstanceNo=setdiff(1:rowNum,minorClassInstanceNo);  %�h�����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
majorClassInstanceCount=rowNum-minorClassInstanceCount;     %�h�����O��Ƽ�
sminfSet=[]; %���]�t�F�~�����h�����O���ּ����O���X
sbmajSet=[]; %��ɦh�����O���X
siminSet=[];
majorNeighborCountSet=zeros(1,minorClassInstanceCount);
kNeighborNo=zeros(minorClassInstanceCount,K);   %�����C�@�Ӥּ����O���̪�k�ӾF�~�s��
NeighborDist=zeros(minorClassInstanceCount,rowNum);
S=0;

Dist=zeros(rowNum,rowNum);
for i=1:rowNum
    for j=1:rowNum
        if i==j
            Dist(j)=-1;
        else
            Dist(i,j)=norm(trainSet(j,1:columnNum-1)-trainSet(i,1:columnNum-1),2);
        end
    end
end


%�w����X�C�@�Ӥּ����O��Ҫ��̪�k�ӾF�~�s��
for i=1 : minorClassInstanceCount
    dist=zeros(rowNum,1);   %�w����l��-����t�׷|�֤@�I
    %�p��X���ּ����O��Ҩ�Ҧ���ƹ�Ҫ��Z��(�ϥ�2-norm)
    for j=1:rowNum
        if j==minorClassInstanceNo(i)
            dist(j)=-1;
        else
            dist(j)=norm(trainSet(j,1:columnNum-1)-trainSet(minorClassInstanceNo(i),1:columnNum-1),2);
            if trainSet(j,columnNum)==majorClassNo
                S=S+dist(j);
            end
        end
        NeighborDist(i,j)=dist(j);
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    NeighborNo=findRank(dist,data_sorted,K+1);
    kNeighborNo(i,:)=NeighborNo(2:K+1); %�u�O���̪�k�ӾF�~ (�ư��ۤv)
    
    %�P�_�O�_�����h�����O�F�~, �������O��, �H����noise
    majorCount=0;
    for j=1 : K
        if trainSet(kNeighborNo(i,j),columnNum)~=minorClassNo
            majorCount=majorCount+1;
        end
    end
    if majorCount~=K
        sminfSet=union(sminfSet,i);
    end
end

% ��X�C�@�Ӥּ����O��Ҫ��h�����O�F�~��
for i=1 : minorClassInstanceCount
    majorNeighborCount=0;
    for j=1 : K
        if trainSet(kNeighborNo(i,j),columnNum)~=minorClassNo
            majorNeighborCount=majorNeighborCount+1;
        end
    end
    majorNeighborCountSet(i)=majorNeighborCount;
end

S_avg=S/(majorClassInstanceCount*minorClassInstanceCount);

% ���Sbmaj,��ɦh�����O
for i=1 : size(sminfSet,2)
    dist=zeros(majorClassInstanceCount,1);   %�w����l��-����t�׷|�֤@�I
    for j=1 : majorClassInstanceCount
        dist(j)=NeighborDist(sminfSet(i),majorClassInstanceNo(j));
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    majorNeighborNo=findRank(dist,data_sorted,K);
    sbmajSet=union (sbmajSet,majorNeighborNo);
end

% ���Simin,��ɤּ����O
for i=1 : size(sbmajSet,1)
    dist=zeros(size(sminfSet,2),1);   %�w����l��-����t�׷|�֤@�I
    for j=1 : size(sminfSet,2)
        dist(j)=NeighborDist(sminfSet(j),majorClassInstanceNo(sbmajSet(i)));
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    [~, minNeighborNo]=ismember(dist,data_sorted);
    siminSet=union (siminSet,sminfSet(minNeighborNo(1:(K-2))));
end



W=zeros(size(sminfSet,2),1);
DW=zeros(size(sminfSet,2),1);
for i=1 :size(siminSet,1)
    S_dist=S_avg*10000;
    majNo=0;
    for j=1:size(sbmajSet,1)
        dist=NeighborDist(siminSet(i),majorClassInstanceNo(sbmajSet(j)));
        if dist<S_dist
            S_dist=dist;
            majNo=majorClassInstanceNo(sbmajSet(j));
        end
    end
    
    majorCount=0;
    for j=1 : majorClassInstanceCount
        if Dist(majNo,majorClassInstanceNo(j))==-1
        else
            dist=Dist(majNo,majorClassInstanceNo(j));
            if dist<S_dist
                majorCount=majorCount+1;
            end
        end
    end
    
    minorCount=0;
    for j=1:minorClassInstanceCount
        if(NeighborDist(siminSet(i),minorClassInstanceNo(j))==-1)
        else
            if(NeighborDist(siminSet(i),minorClassInstanceNo(j))<S_dist )
                minorCount=minorCount+1;
            end
        end
    end
    W(i)=(majorCount+1)/(minorCount+1);
%     W(i)=majorCount/(minorCount+1);
    DW(i)=(majorCount+1)/(majorCount+minorCount+1+1); 
%     DW(i)=(minorCount+1)/(majorCount+minorCount+1); 
end

sumW=sum(W);

for i=1 : size(siminSet,1)
    you=trainSet(minorClassInstanceNo(siminSet(i)),:);
    
    S_dist=S_avg*10000;
    majNo=0;
    for j=1:size(sbmajSet,1)
        dist=NeighborDist(siminSet(i),majorClassInstanceNo(sbmajSet(j)));
        if dist<S_dist
            S_dist=dist;
            majNo=majorClassInstanceNo(sbmajSet(j));
        end
    end
    
    
    Neighbor=trainSet(majNo,:);    
    
    ratio=round((majorClassInstanceCount-size(sminfSet,2))*W(i)/sumW);
    
    temp=zeros(1,columnNum-1);
    for j=1:ratio        
        for k=1:columnNum-1
            temp(k)=(Neighbor(k)-you(k))*rand(1)*DW(i);
        end
        outDate=[you(1:columnNum-1)+temp,minorClassNo];
        outDataSet=[outDataSet;outDate];
    end
    
end

QSMOTEDateSet=[trainSet;outDataSet];




end

