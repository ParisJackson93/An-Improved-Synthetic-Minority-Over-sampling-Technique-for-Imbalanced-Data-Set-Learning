function [ MWMOTEDateSet ] = MWMOTE( trainSet,minorClassNo,N,K1,K2,K3 )

outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
majorClassInstanceNo=setdiff(1:rowNum,minorClassInstanceNo);  %�h�����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
majorClassInstanceCount=rowNum-minorClassInstanceCount;     %�h�����O��Ƽ�
sminfSet=[]; %���]�t�F�~�����h�����O���ּ����O���X
sbmajSet=[]; %��ɦh�����O���X
siminSet=[]; %��ɤּ����O���X
CMAX=2;  %��ưѼ�
Cfth=5;  %��ưѼ�
Cp=0.05;    %��ưѼ�
kNeighborNo_K1=zeros(minorClassInstanceCount,K1);   %�����C�@�Ӥּ����O���̪�k1�ӾF�~�s��
temp=zeros(1,columnNum-1);  %���������Ȧs��(�@row��Ư�label)

%�w����X�C�@�Ӥּ����O��Ҫ��̪�k1�ӾF�~�s��-�ΨӧR��noise
for i=1 : minorClassInstanceCount
    dist=zeros(rowNum,1);   %�w����l��-����t�׷|�֤@�I
    
    %�p��X���ּ����O��Ҩ�Ҧ���ƹ�Ҫ��Z��(�ϥ�2-norm)
    for j=1:rowNum
        if j==minorClassInstanceNo(i)
            dist(j)=-1;
        else
            dist(j)=norm(trainSet(j,1:columnNum-1)-trainSet(minorClassInstanceNo(i),1:columnNum-1),2);
        end
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    NeighborNo=findRank(dist,data_sorted,K1+1);
    kNeighborNo_K1(i,:)=NeighborNo(2:K1+1); %�u�O���̪�k1�ӾF�~ (�ư��ۤv)
    
    %�P�_�O�_�����h�����O�F�~, �������O��, �H����noise
    majorCount=0;
    for j=1 : K1
        if trainSet(kNeighborNo_K1(i,j),columnNum)~=minorClassNo
            majorCount=majorCount+1;
        end
    end
    if majorCount~=K1
        sminfSet=[sminfSet,i];
    end
end


% kNeighborNo_K2=zeros(size(sminfSet,2),K2);   %�����C�@�Ӥּ����O���̪�k2�ӾF�~�s��
% ���Sbmaj,��ɦh�����O
for i=1 : size(sminfSet,2)
    dist=zeros(majorClassInstanceCount,1);   %�w����l��-����t�׷|�֤@�I
    for j=1 : majorClassInstanceCount
        dist(j)=norm(trainSet(majorClassInstanceNo(j),1:columnNum-1)-trainSet(minorClassInstanceNo(sminfSet(i)),1:columnNum-1),2);
    end
    
    data_sorted=sort(dist);    %�ƧǦ��ּ����O��Ҫ��h�����O�F�~,�ѳ̪�ƨ�̻�
    majorNeighborNo=findRank(dist,data_sorted,K2);
    
    %     kNeighborNo_K2(i,:)=majorNeighborNo(1:K2); %�O��sminfSet���̪�k2�Ӧh�����O�F�~
    sbmajSet=union (sbmajSet,majorNeighborNo(1:K2));
end

% kNeighborNo_K3=zeros(size(sbmajSet,1),K3);
% ���Simin,��ɤּ����O
% for i=1 : size(sbmajSet,1)
%     dist=zeros(minorClassInstanceCount,1);   %�w����l��-����t�׷|�֤@�I
%     for j=1 : minorClassInstanceCount
%         dist(j)=norm(trainSet(majorClassInstanceNo(sbmajSet(i)),1:columnNum-1)-trainSet(minorClassInstanceNo(j),1:columnNum-1),2);
%     end
%     
%     data_sorted=sort(dist);
%     minNeighborNo=findRank(dist,data_sorted,K3);
%     %     kNeighborNo_K3(i,:)=minNeighborNo(1:K3);
%     siminSet=union (siminSet,minNeighborNo(1:K3));
% end

% ���Simin,��ɤּ����O
for i=1 : size(sbmajSet,1)
    dist=zeros(size(sminfSet,2),1);   %�w����l��-����t�׷|�֤@�I
    for j=1 : size(sminfSet,2)
        dist(j)=norm(trainSet(majorClassInstanceNo(sbmajSet(i)),1:columnNum-1)-trainSet(minorClassInstanceNo(sminfSet(j)),1:columnNum-1),2);
    end
    data_sorted=sort(dist);  %�ƧǦ��ּ����O��Ҫ��Ҧ��F�~,�ѳ̪�ƨ�̻�
    [~, minNeighborNo]=ismember(dist,data_sorted);
    siminSet=union (siminSet,sminfSet(minNeighborNo(1:K3)));
end



%�p��Ҧ���Cf��
Cf=zeros(size(siminSet,1),size(sbmajSet,1));
for i=1 : size(siminSet,1)
    for j=1 : size(sbmajSet,1)
        dn=norm(trainSet(majorClassInstanceNo(sbmajSet(j)),1:columnNum-1)-trainSet(minorClassInstanceNo(siminSet(i)),1:columnNum-1),2)/columnNum;
        x=1/dn;
        if x<=Cfth
            Cf(i,j)=x/Cfth*CMAX;
        else
            Cf(i,j)=1*CMAX;
        end
    end
end

%�p��Ҧ���Iw��
Iw=zeros(size(Cf,1),size(Cf,2));
for i=1 : size(siminSet,1)
    for j=1 : size(sbmajSet,1)
        Iw(i,j)=Cf(i,j)*Cf(i,j)/sum(Cf(i,:));
    end
end

%��XSw��
Sw=zeros(size(siminSet,1),1);
for i=1 : size(siminSet,1)
    Sw(i)=sum(Iw(i,:));
end

%Clustering �ϰ�
% A=[1,2,3]
% B=[4,5]
% C={A,B}
% C{2}(1) ->  4
minorInstanceArray=zeros(minorClassInstanceCount,minorClassInstanceCount);
for i=1 : minorClassInstanceCount
    for j=1 : minorClassInstanceCount
        if i==j
            minorInstanceArray(i,j)=-1;
        else
            minorInstanceArray(i,j)=norm(trainSet(minorClassInstanceNo(i),1:columnNum-1)-trainSet(minorClassInstanceNo(j),1:columnNum-1),2);
        end
    end
end

for i=1 : minorClassInstanceCount
    if i==1
        groupInfo={[i]};
    else
        groupInfo=[groupInfo,[i]];
    end    
end
closeDis=0;
davg=0;
for i=1 : size(sminfSet,2)
    for j=1: size(sminfSet,2)
        if i~=j
            davg=davg+minorInstanceArray(sminfSet(i),sminfSet(j));
        end
    end
end
davg=davg/(2*size(sminfSet,2));
Th=davg*Cp;
while size(groupInfo,2)>1
    %     disArray=zeros(size(groupInfo,2),size(groupInfo,2));
    
    minAvgDistGroup=100000000;
    pairI=-1;
    pairJ=-1;
    for i=1 : size(groupInfo,2)
        for j=1 : size(groupInfo,2)
            if i==j
                %                 disArray(i,j)=-1;
            else
                sumDistGroup=0;
                for k=1 : size(groupInfo{i},2)
                    for l=1 : size(groupInfo{j},2)
                        if groupInfo{i}(k)~=groupInfo{j}(l)
                            sumDistGroup=sumDistGroup+minorInstanceArray(groupInfo{i}(k),groupInfo{j}(l));
                        end
                    end
                end
                avgDistGroup=sumDistGroup/(size(groupInfo{i},2)*size(groupInfo{j},2));
                %                 disArray(i,j)=avgDistGroup;
                if avgDistGroup<minAvgDistGroup
                    pairI=i;
                    pairJ=j;
                    minAvgDistGroup=avgDistGroup;
                end
            end
        end
    end
    
    closeDis=minAvgDistGroup;
    
    if closeDis > Th
        break;
    end
    
    tempGroupInfo={union(groupInfo{pairI},groupInfo{pairJ})};
    for i=1 : size(groupInfo,2)
        if i==pairI || i==pairJ
        else
            tempGroupInfo=[tempGroupInfo,groupInfo{i}];
        end
    end
    groupInfo=tempGroupInfo;
end

%Clustering

instanceCount=0;
while instanceCount<N
    SampleNo=randsample(1:size(siminSet,1),1,true,Sw);
    you=trainSet(minorClassInstanceNo(siminSet(SampleNo)),:);
    
    clusterNo=-1;
    for i=1 :size(groupInfo,2)
        if any(minorClassInstanceNo(siminSet(SampleNo))==minorClassInstanceNo(groupInfo{i}))
            clusterNo=i;
            break;
        end
    end
    
    randNo=randi([1 size(groupInfo{clusterNo},2) ],1,1);
    Neighbor=trainSet(groupInfo{clusterNo}(randNo),:);
    
    %���椺��
    for k=1:columnNum-1
        temp(k)=(Neighbor(k)-you(k))*rand(1);
    end
    outDate=[you(1:columnNum-1)+temp,minorClassNo]; %�s���ͪ���ƹ�Ҽе����ּ����O
    outDataSet=[outDataSet;outDate];    %�N�s���ͪ���ƹ�ҩ�J��X�}�C��    
    instanceCount=instanceCount+1;
end

MWMOTEDateSet=[trainSet;outDataSet];




end

