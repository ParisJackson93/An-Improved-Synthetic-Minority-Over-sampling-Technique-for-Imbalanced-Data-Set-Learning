function [ QSMOTEDateSet ] = QSMOTE3_1_1(  trainSet,majorClassNo,minorClassNo,K )
% �h��noise ��o�� sminfSet
% �HsminfSet ����̪�K�Ӧh�ƾF�~�p�� �o�� sbmajSet
% �HsbmajSet ����̪�K�ӤּƾF�~�p�� �o�� siminSet
% �C�@�Ӥּ����O(sminfSet) ��L�̪񪺦h�����O, �H���Z����X, ���ּ����O���񪺦P�񦳦h��,�æ����@�Ӷ��X.
% �Y���X�P���X���ۦP����,�h�X�֦����X.
% ��SMOTE���ּͤ����O- �]���P�s���I���ͤ����i��O���~��- ���F�PQSMOTE3�����
% �v���� �s���ƪ��˼�
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
    majorNeighborNo=findRank(dist,data_sorted,(K-2));
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

G=majorClassInstanceCount-minorClassInstanceCount;
sumc=0;

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
            if (i~=j) && any(ismember(groupInfo{i},groupInfo{j}))
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

sumWeight=zeros(size(siminSet,1),0);
sumGroup=0;
for i=1 : size(siminSet,1)
    
    you=trainSet(minorClassInstanceNo(siminSet(i)),:);
    
    clusterNo=-1;
    for j=1 :size(groupInfo,2)
        if any(minorClassInstanceNo(siminSet(i))==groupInfo{j})
            clusterNo=j;
            break;
        end
    end
	sumGroup=sumGroup+(1/size(groupInfo{clusterNo},2));
	sumWeight(i)=(1/size(groupInfo{clusterNo},2));
end

for i=1 : size(siminSet,1)
    
    you=trainSet(minorClassInstanceNo(siminSet(i)),:);
    
	ratio=round((majorClassInstanceCount-size(sminfSet,2))*sumWeight(i)/sumGroup);
    
    temp=zeros(1,columnNum-1);
    for j=1:ratio
        randNo=randi([1 K],1,1);
        Neighbor=trainSet(kNeighborNo(siminSet(i),randNo),:);
        for k=1:columnNum-1
            temp(k)=(Neighbor(k)-you(k))*rand(1);
        end
        outDate=[you(1:columnNum-1)+temp,minorClassNo];
        outDataSet=[outDataSet;outDate];
    end   
end
QSMOTEDateSet=[trainSet;outDataSet];




end

