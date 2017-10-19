function [ ADAYSNDataSet ] = ADAYSN( trainSet,minorClassNo,K )

outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
majorClassInstanceCount=rowNum-minorClassInstanceCount;      %�h�����O��Ƽ�
kNeighborNo=zeros(minorClassInstanceCount,K);   %�����C�@�Ӥּ����O���̪�k�ӾF�~�s��
majorNeighborCountSet=zeros(1,minorClassInstanceCount);
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

G=majorClassInstanceCount-minorClassInstanceCount;
for i=1 : minorClassInstanceCount
    you=trainSet(minorClassInstanceNo(i),:);
    
    for j=1:(majorNeighborCountSet(i)*G/sum(majorNeighborCountSet))
        minorKNeighborNo=[]; %�F�~�s��-�M�s�ּ����O
        for k=1 : K
            if trainSet(kNeighborNo(i,k),columnNum)==minorClassNo
                minorKNeighborNo=[minorKNeighborNo,k];
            end
        end
        if size(minorKNeighborNo,2)==0  %�S���ּ����O�F�~      
        else
            rN=randi([1 size(minorKNeighborNo,2)],1,1);        
            Neighbor=trainSet( kNeighborNo(i,minorKNeighborNo(rN)),:); %���X�F�~�����
            
            for k=1:columnNum-1
                temp(k)=(Neighbor(k)-you(k))*rand(1);
            end
            outDate=[you(1:columnNum-1)+temp,minorClassNo]; %�s���ͪ���ƹ�Ҽе����ּ����O
            outDataSet=[outDataSet;outDate];    %�N�s���ͪ���ƹ�ҩ�J��X�}�C��            
        end         
    end        
end

ADAYSNDataSet=[trainSet;outDataSet];
end


% randsample(1:2,100,true,[p1 p2 p3 p4 p5 p6])
