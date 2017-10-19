function [ SmoteDataSet ] = Smote( trainSet,minorClassNo,N,K )
% trainSet : ���i�椺�t�ץ�����ƶ�- call by value, �]����Ѽƭץ����v�T��l��
% minorClassNo : �h�����O�H�Τּ����O���s��
% N,K : N �O �ּ����O�W�[������ , K�O KNN�t��k�����̪�K�ӾF�~��

% ����SMOTE�t��k - ����

outDataSet=[];  %�ΨӸ˿�X����ƶ�
columnNum=size(trainSet,2);  %�Ҧ�feature��(�]�Aclass feature)
rowNum=size(trainSet,1); %�Ҧ���Ƶ���
minorClassInstanceNo=find(trainSet(:,columnNum)==minorClassNo); %�ּ����O��Ʀb������Ƥ����s��
minorClassInstanceCount= size(minorClassInstanceNo,1);     %�ּ����O��Ƽ�
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

% �C�@�Ӥּ����O��ҭn�H���q��K�ӾF�~��@�H�������k,�C�@�Ӥּ����O��һݰ�N�������k.
% �s���ͪ���ƹ�Ҭ��ּ����O
for i=1 : minorClassInstanceCount
    for j=1 : N
        %         rN=randsrc(1,1,1:K) %�H���qK�ӾF�~����@�ӤH(�s��)
%         rN=randperm(K);      %�]randsrc()�e��Licensing error,�ҥH�ϥΧO���覡��{
%         rN=rN(1);
        rN=randi([1 K],1,1);
        
        Neighbor=trainSet(kNeighborNo(rN),:);   %���X�F�~�����
        you=trainSet(minorClassInstanceNo(i),:);    %���ּ����O��Ҫ����
        %���椺��
        
        for k=1:columnNum-1
            temp(k)=(Neighbor(k)-you(k))*rand(1);
        end
        outDate=[you(1:columnNum-1)+temp,minorClassNo]; %�s���ͪ���ƹ�Ҽе����ּ����O
        outDataSet=[outDataSet;outDate];    %�N�s���ͪ���ƹ�ҩ�J��X�}�C��
    end
end
SmoteDataSet=[trainSet;outDataSet]; %�^�� (��X�}�C+��l���)
end

