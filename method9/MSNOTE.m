function [ MSNOTEDataSet ] = MSNOTE( trainSet,minorClassNo,N,K )

outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
minorClassInstanceType=zeros(minorClassInstanceCount,1);    %�ּ����O��ƪ�����-noise/borider/safe
kNeighborNo=zeros(minorClassInstanceCount,K);   %�����C�@�Ӥּ����O���̪�k�ӾF�~�s��
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

%�w����X�C�@�Ӥּ����O������
for i=1 : minorClassInstanceCount
    majorKNeighborCount=0;
    for j=1 : K
        if trainSet(kNeighborNo(i,j),columnNum)~=minorClassNo
            majorKNeighborCount=majorKNeighborCount+1;
        end
    end
    
    if majorKNeighborCount==K
        minorClassInstanceType(i)=1; %noise
    elseif majorKNeighborCount==0
        minorClassInstanceType(i)=2; %safe
    else
        minorClassInstanceType(i)=3; %boundary
    end
end

for i=1 : minorClassInstanceCount
    if minorClassInstanceType(i)~=1
        for j=1 : N
            if minorClassInstanceType(i)==2
                rN=randi([1 K],1,1);
                Neighbor=trainSet(kNeighborNo(rN),:);   %���X�F�~�����
            elseif minorClassInstanceType(i)==3
                Neighbor=trainSet(kNeighborNo(1),:);   %���X�̪�F�~�����
            end
            
            you=trainSet(minorClassInstanceNo(i),:);    %���ּ����O��Ҫ����
            %���椺��
            for k=1:columnNum-1
                temp(k)=(Neighbor(k)-you(k))*rand(1);
            end
            outDate=[you(1:columnNum-1)+temp,minorClassNo]; %�s���ͪ���ƹ�Ҽе����ּ����O
            outDataSet=[outDataSet;outDate];    %�N�s���ͪ���ƹ�ҩ�J��X�}�C��
        end
    end
end

MSNOTEDataSet=[trainSet;outDataSet]; %�^�� (��X�}�C+��l���)

end

