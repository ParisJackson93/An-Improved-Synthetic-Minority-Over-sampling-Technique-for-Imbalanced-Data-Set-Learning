function [ Borderline_SMOTEDataSet ] = Borderline_SMOTE( trainSet,minorClassNo,K )

outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
kNeighborNo=zeros(minorClassInstanceCount,K);   %�����C�@�Ӥּ����O���̪�k�ӾF�~�s��
DangerSet=[];   %�M�I��,�ΨӦs��s�y�������ؤl�H�Ψ�h�ƾF�~�Ӽ�
temp=zeros(1,columnNum-1);  %���������Ȧs��(�@row��Ư�label)


%�w����X�C�@�Ӥּ����O��Ҫ��̪�k�ӾF�~�s��
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
    NeighborNo=findRank(dist,data_sorted,K+1);
    kNeighborNo(i,:)=NeighborNo(2:K+1); %�u�O���̪�k�ӾF�~ (�ư��ۤv)
end

%�N��ɦ����[�J�M�I��.
for i=1 : minorClassInstanceCount
    majorNeighborCount=0;
    for j=1 : K
        if trainSet(kNeighborNo(i,j),columnNum)~=minorClassNo
            majorNeighborCount=majorNeighborCount+1;
        end
    end
    if majorNeighborCount>=(K/2) && majorNeighborCount<K
        DangerSet=[DangerSet;i];
    end
end

% �ϥΦM�I���X��������������
for i=1 : size(DangerSet,1)
    minorKNeighborNo=[];
    %�P�_���M�I���X���������@�ӾF�~�O�ּ����O
    for j=1 : K
        if trainSet(kNeighborNo(DangerSet(i),j),columnNum)==minorClassNo
            minorKNeighborNo=[minorKNeighborNo,j];
        end
    end
    s=size(minorKNeighborNo,2);
    for q=1 : s
        Neighbor=trainSet(kNeighborNo(DangerSet(i),minorKNeighborNo(q)),:);
        you=trainSet(minorClassInstanceNo(DangerSet(i)),:);
        for k=1:columnNum-1
            temp(k)=(Neighbor(k)-you(k))*rand(1);
        end
        outDate=[you(1:columnNum-1)+temp,minorClassNo]; %�s���ͪ���ƹ�Ҽе����ּ����O
        outDataSet=[outDataSet;outDate];    %�N�s���ͪ���ƹ�ҩ�J��X�}�C��
    end
end

Borderline_SMOTEDataSet=[trainSet;outDataSet]; %�^�� (��X�}�C+��l���)
end

