function [ Major,Minor ] = recognizeMajorClassAndOtherClass( Data )
% ��{��Ƥ����h�Ƥּ����O  �æ^�Ǩ����O���X
% ��J: ���   ��X: �h�����O�H�Τּ����O���s��
%  �ثe�ȹ�@ 2class
    columnNumber= size(Data,2);
    rowNumber = size(Data,1);
    
    maxClass= max(Data(:,columnNumber));%���D���O���X�� �̤j�Ʀr
    minClass= min(Data(:,columnNumber));%���D���O���X�� �̤p�Ʀr
    majorCount=-1000000;
    minorCount=1000000;
    major=0;
    minor=0;
    tempCount=0;
    
    for i=minClass : maxClass
        tempCount=sum(Data(:,columnNumber)==i);
        if tempCount < minorCount
            minor=i;
            minorCount=tempCount;
        end
        
        if tempCount > majorCount
            major=i;
            majorCount=tempCount;
        end
    end
    Major=major;
    Minor=minor;

end

