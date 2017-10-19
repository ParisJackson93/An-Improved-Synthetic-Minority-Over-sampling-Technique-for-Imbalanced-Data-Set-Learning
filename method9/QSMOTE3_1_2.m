function [ QSMOTEDateSet ] = QSMOTE3_1_2(  trainSet,majorClassNo,minorClassNo,K )
% �C�@�Ӥּ����O ��L�̪񪺦h�����O, �H���Z����X, ���ּ����O���񪺦P�񦳦h��,�æ����@�Ӷ��X.
% ���X�ֶ��X.  (�������ۦP�����X�|�X�֦��@��)
% ���Ѧ�����ݩ���@���X���ɭ�, ����X�Ҧ��]�t����Ҫ����X, �M���ܭӼƳ̤j��,�@���ݩ�ۤv���s
% ��ɤּ����O�P�Ӹs�������͹�O

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
    dist=zeros(minorClassInstanceCount,1);   %�w����l��-����t�׷|�֤@�I
    for j=1 : minorClassInstanceCount
        dist(j)=NeighborDist(j,majorClassInstanceNo(sbmajSet(i)));
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    [~, minNeighborNo]=ismember(dist,data_sorted);
    siminSet=union (siminSet,minNeighborNo(1:K));
end



for i=1 : size(sminfSet,2)
    S_dist=S_avg*10000;
    for j=1:size(sbmajSet,1)
        dist=NeighborDist(sminfSet(i),majorClassInstanceNo(sbmajSet(j)));
        if dist<S_dist
            S_dist=dist;              
        end       
    end
       
    member=[];
    for j=1:size(sminfSet,2)
        if(NeighborDist(sminfSet(i),minorClassInstanceNo(sminfSet(j)))==-1)
        else
            if(NeighborDist(sminfSet(i),minorClassInstanceNo(sminfSet(j)))<S_dist )
                member=union(member,minorClassInstanceNo(sminfSet(j)));
            end
        end
    end
    
    if i==1
        groupInfo={[minorClassInstanceNo(sminfSet(i)),member]};
    else
        groupInfo=[groupInfo,[minorClassInstanceNo(sminfSet(i)),member]];
    end
end

hasMerge=true;
while hasMerge
    groupI=-1;
    groupJ=-1;
    hasMerge=false;
    for i=1 : size(groupInfo,2)
        for j=1 : size(groupInfo,2)
            if (i~=j) && size(groupInfo{i},2)==size(groupInfo{j},2) && all(groupInfo{i}==groupInfo{j})
                hasMerge=true;
                groupI=i;
                groupJ=j;
                break;
            end
        end
        if hasMerge
            break;
        end
    end
    
    if hasMerge
        tempGroupInfo={union(groupInfo{groupI},groupInfo{groupJ})};
        for i=1 : size(groupInfo,2)
            if i==groupI || i==groupJ
            else
                tempGroupInfo=[tempGroupInfo,groupInfo{i}];
            end
        end
        groupInfo=tempGroupInfo;
    end
end

belongClus=zeros(size(siminSet,1),1);
clusW=zeros(size(siminSet,1),1);
for i=1 : size(siminSet,1)
    if ~(any(siminSet(i)==sminfSet))
        continue;
    end
    clusterNo=[];
    W=-1;
    for j=1 :size(groupInfo,2)
        if any(minorClassInstanceNo(siminSet(i))==groupInfo{j})
            if size(groupInfo{j},2)>W
                clusterNo=j;
                W=size(groupInfo{j},2);
            elseif size(groupInfo{j},2)==W
                clusterNo=union(clusterNo,j);
            end           
        end
    end
    randClusNo=randi([1 size(clusterNo,2) ],1,1);
    belongClus(i)=clusterNo(randClusNo);
    clusW(i)=1/size(groupInfo{clusterNo(randClusNo)},2);    
end
sumClusW=sum(clusW);

W=zeros(size(siminSet,1),1);
for i=1 : size(siminSet,1)
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
    
    W(i)=majorCount/(minorCount+1);
end
sumW=sum(W);

G=majorClassInstanceCount-size(sminfSet,2);
for i=1 : size(siminSet,1)
    if ~(any(siminSet(i)==sminfSet))
        continue;
    end
    
    S_dist=S_avg*10000;
    majNo=0;
    for j=1:size(sbmajSet,1)
        dist=NeighborDist(siminSet(i),majorClassInstanceNo(sbmajSet(j)));
        if dist<S_dist
            S_dist=dist;
            majNo=majorClassInstanceNo(sbmajSet(j));
        end
    end
    
    you=trainSet(minorClassInstanceNo(siminSet(i)),:);
    
    clusCount=G*clusW(i)/sumClusW;
    ratio=clusCount*W(i)/sumW+1;
%     randsample(1:size(siminSet,1),1,true,Sw);
    temp=zeros(1,columnNum-1);
    for j=1:ratio
        Neighbor=trainSet(majNo,:);
        for k=1:columnNum-1
            temp(k)=(Neighbor(k)-you(k))*rand(1);
        end
        outDate=[you(1:columnNum-1)+temp,minorClassNo];
        outDataSet=[outDataSet;outDate];
    end   
end

QSMOTEDateSet=[trainSet;outDataSet];




end

