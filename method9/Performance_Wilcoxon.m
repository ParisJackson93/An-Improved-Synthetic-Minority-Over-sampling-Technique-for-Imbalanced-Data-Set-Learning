function [  ] = Performance_Wilcoxon( yourFunction,yourFunctionName,outTextFileName )

%  dbstop if error %�p�G�����Dmatlab�|���b�X��������A�åB�O�s�Ҧ������ܼ�-������
tic  %�X��}�l�˼�

trainFile={'abalone9-18.mat','Btissue.mat','ecoli1.mat'...
    ,'pima.mat','vehicle1.mat'...
    ,'yeast.mat','segment0.mat'...
    ,'wisconsin.mat','appendicitis.mat','bupa.mat','heart.mat'...
    ,'haberman.mat','glass0.mat','new-thyroid1.mat','ecoli3.mat','vehicle3.mat','wdbc.mat'...
    ,'cleveland-0_vs_4.mat','page-blocks0.mat','Robot.mat'};
% trainFile={'vehicle1','pima.mat'};
%%�]�w��ƶ��Ҧb�ڥؿ�
path='./data/';
%%�]�wK-FOLD����
KFold=5;
%%�]�w�F�~��
KNighbor=5;
%�����k�W��-��X��
method={yourFunctionName,'B-SMOTE','ADAYSN','MSMOTE','MWMOTE','SMOTE'};
%�˩w�����k��
alpha=0.1; 
%��k��
methodCount=size(method,2);;

%KNN totoal index
KNN_Accurecy=zeros(methodCount,size(trainFile,2));
KNN_TP=zeros(methodCount,size(trainFile,2));
KNN_FP=zeros(methodCount,size(trainFile,2));
KNN_Precision=zeros(methodCount,size(trainFile,2));
KNN_AUC=zeros(methodCount,size(trainFile,2));
KNN_G_mean=zeros(methodCount,size(trainFile,2));
KNN_F_measure=zeros(methodCount,size(trainFile,2));

%DT totoal index
DT_Accurecy=zeros(methodCount,size(trainFile,2));
DT_TP=zeros(methodCount,size(trainFile,2));
DT_FP=zeros(methodCount,size(trainFile,2));
DT_Precision=zeros(methodCount,size(trainFile,2));
DT_AUC=zeros(methodCount,size(trainFile,2));
DT_G_mean=zeros(methodCount,size(trainFile,2));
DT_F_measure=zeros(methodCount,size(trainFile,2));

%SVM totoal index
SVM_Accurecy=zeros(methodCount,size(trainFile,2));
SVM_TP=zeros(methodCount,size(trainFile,2));
SVM_FP=zeros(methodCount,size(trainFile,2));
SVM_Precision=zeros(methodCount,size(trainFile,2));
SVM_AUC=zeros(methodCount,size(trainFile,2));
SVM_G_mean=zeros(methodCount,size(trainFile,2));
SVM_F_measure=zeros(methodCount,size(trainFile,2));

%NaiveB totoal index
NaiveB_Accurecy=zeros(methodCount,size(trainFile,2));
NaiveB_TP=zeros(methodCount,size(trainFile,2));
NaiveB_FP=zeros(methodCount,size(trainFile,2));
NaiveB_Precision=zeros(methodCount,size(trainFile,2));
NaiveB_AUC=zeros(methodCount,size(trainFile,2));
NaiveB_G_mean=zeros(methodCount,size(trainFile,2));
NaiveB_F_measure=zeros(methodCount,size(trainFile,2));

%logisticR totoal index
logisticR_Accurecy=zeros(methodCount,size(trainFile,2));
logisticR_TP=zeros(methodCount,size(trainFile,2));
logisticR_FP=zeros(methodCount,size(trainFile,2));
logisticR_Precision=zeros(methodCount,size(trainFile,2));
logisticR_AUC=zeros(methodCount,size(trainFile,2));
logisticR_G_mean=zeros(methodCount,size(trainFile,2));
logisticR_F_measure=zeros(methodCount,size(trainFile,2));


for fileIndex=1 : size(trainFile,2)
    
    %Ū�����
    totalData=load([path  trainFile{fileIndex}]);
    totalData=totalData.X;
    
    
    %�U�C��for - �R���ܲ��ƤӤp��feature
    delNo=[];
    spiltMinorCount=floor(size(find(totalData(:,size(totalData,2))==1),1)/KFold);
    spiltMajorCount=floor((size(totalData,1)-size(find(totalData(:,size(totalData,2))==1),1))/KFold);
    for kfoldIndex=1 : KFold
        testMajorDataNo=1+(kfoldIndex-1)*spiltMajorCount:kfoldIndex*spiltMajorCount;
        testMinorDataNo=1+(kfoldIndex-1)*spiltMinorCount:kfoldIndex*spiltMinorCount;
        minorClassInstanceNo=find(totalData(:,size(totalData,2))==1);
        majorClassInstanceNo=setdiff(1:size(totalData,1),minorClassInstanceNo);
        testDataNo=union(minorClassInstanceNo(testMinorDataNo),majorClassInstanceNo(testMajorDataNo));
        trainDataNo=setdiff(1:size(totalData,1),testDataNo);
        testData=totalData(testDataNo,:);
        trainData=totalData(trainDataNo,:);
        for i=1:size(totalData,2)-1
            if var(trainData(trainData(:,size(totalData,2))==1,i))<=0.0001
                delNo=union(delNo,i);
            end
        end
    end
    totalData(:,delNo)=[];
    
    %�o�즹�V�m���������
    instanceNum=size(totalData,1);
    featureNum=size(totalData,2);
    [majorClassNo,minorClassNo]=recognizeMajorClassAndOtherClass(totalData);
    minorInstanceNum=size(find(totalData(:,featureNum)==minorClassNo),1);
    majorInstanceNum=instanceNum-minorInstanceNum;
    classRatio=majorInstanceNum/minorInstanceNum;
        
    %KNN�p����Ъ�l��
    ACK=zeros(methodCount,KFold);
    TK=zeros(methodCount,KFold);
    FPK=zeros(methodCount,KFold);
    PK=zeros(methodCount,KFold);
    AK=zeros(methodCount,KFold);
    GK=zeros(methodCount,KFold);
    FK=zeros(methodCount,KFold);
    
    %     decisionTree �p����Ъ�l��
    ACT=zeros(methodCount,KFold);
    TT=zeros(methodCount,KFold);
    FPT=zeros(methodCount,KFold);
    PT=zeros(methodCount,KFold);
    AT=zeros(methodCount,KFold);
    GT=zeros(methodCount,KFold);
    FT=zeros(methodCount,KFold);    
    
    %     SVM �p����Ъ�l��
    ACS=zeros(methodCount,KFold);
    TS=zeros(methodCount,KFold);
    FPS=zeros(methodCount,KFold);
    PS=zeros(methodCount,KFold);
    AS=zeros(methodCount,KFold);
    GS=zeros(methodCount,KFold);
    FS=zeros(methodCount,KFold);
    
    %     NAVIE �p����Ъ�l��
    ACN=zeros(methodCount,KFold);
    TN=zeros(methodCount,KFold);
    FPN=zeros(methodCount,KFold);
    PN=zeros(methodCount,KFold);
    AN=zeros(methodCount,KFold);
    GN=zeros(methodCount,KFold);
    FN=zeros(methodCount,KFold);
    
    %     logisit �p����Ъ�l��
    ACL=zeros(methodCount,KFold);
    TL=zeros(methodCount,KFold);
    FPL=zeros(methodCount,KFold);
    PL=zeros(methodCount,KFold);
    AL=zeros(methodCount,KFold);
    GL=zeros(methodCount,KFold);
    FL=zeros(methodCount,KFold);
    
    spiltMinorCount=floor(minorInstanceNum/KFold);
    spiltMajorCount=floor(majorInstanceNum/KFold);
    for kfoldIndex=1 : KFold
        %�ּ����O��ƩM�h�Ƹ�Ƥ��O���� KFold��   �̾�FOld�ƱN�ּƥH�Φh�ƲզX���@��Fold  (�קK��������K-fold ����FOLD�S���ּ����O)
        disp([trainFile{fileIndex} num2str(kfoldIndex)]);
        testMinorDataNo=1+(kfoldIndex-1)*spiltMinorCount:kfoldIndex*spiltMinorCount;
        testMajorDataNo=1+(kfoldIndex-1)*spiltMajorCount:kfoldIndex*spiltMajorCount;
        minorClassInstanceNo=find(totalData(:,featureNum)==minorClassNo);
        majorClassInstanceNo=setdiff(1:instanceNum,minorClassInstanceNo);  %�h�����O��Ʀb������Ƥ����s��
        
        %�o��testSet�H��trainSet
        testDataNo=union(minorClassInstanceNo(testMinorDataNo),majorClassInstanceNo(testMajorDataNo));
        trainDataNo=setdiff(1:instanceNum,testDataNo);
        testData=totalData(testDataNo,:);
        trainData=totalData(trainDataNo,:);
        
        %             �o�����]�w���Ѽ�
        minorClassSetSize=size(find(trainData(:,featureNum)==minorClassNo),1); %�ּ����O���ƶq
        majorClassSetSize=size(trainDataNo,2)-minorClassSetSize;
        makeAmount=majorClassSetSize-minorClassSetSize;
        radio=round(majorClassSetSize/minorClassSetSize);
        %SMOTE����k�]�w��1 �N��|�s�y�@�����ּ����O�� - �ڧƱ�o�Ǥ�k�ܤ֯���s�y�@��...���Ǹ�ƶ�        %�u��1.5��-2�����������O��
        if radio>=2              
            radio=radio-1;   
        end
        
        %����match�Ӥ�k�H�Φb��������
        for match=1 : methodCount            
            switch match                
                case {1}
                    yourDataSet=yourFunction(trainData,majorClassNo,minorClassNo,KNighbor);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(yourDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(yourDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(yourDataSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(yourDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(yourDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    
                case {2}
                    Borderline_SMOTEDataSet=Borderline_SMOTE(trainData,minorClassNo,KNighbor);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(Borderline_SMOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(Borderline_SMOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(Borderline_SMOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(Borderline_SMOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(Borderline_SMOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    
                case {3}
                    ADAYSNDataSet=ADAYSN(trainData,minorClassNo,KNighbor);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(ADAYSNDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(ADAYSNDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(ADAYSNDataSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(ADAYSNDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(ADAYSNDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    
                case {4}
                    MSNOTEDataSet=MSNOTE(trainData,minorClassNo,radio,KNighbor);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(MSNOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(MSNOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(MSNOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(MSNOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(MSNOTEDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    
                case {5}
                    MWMOTEDateSet=MWMOTE(trainData,minorClassNo,makeAmount,5,3,3);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(MWMOTEDateSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(MWMOTEDateSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(MWMOTEDateSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(MWMOTEDateSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(MWMOTEDateSet,testData,majorClassNo,minorClassNo,featureNum);
                    
                case {6}
                    SmoteDataSet=Smote(trainData,minorClassNo,radio,KNighbor);
                    [tempknnAccurecy,tempknnTPK,tempknnFP,tempknnPrecision,tempknnAUC,tempknnG_mean,tempknnF_measure]=KnnA(SmoteDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempTreeAccurecy,tempTreeTP,tempTreeFP,tempTreePrecision,tempTreeAUC,tempTreeG_mean,tempTreeF_measure]=decTree(SmoteDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempSVMAccurecy,tempSVMTPK,tempSVMFP,tempSVMPrecision,tempSVMAUC,tempSVMG_mean,tempSVMF_measure]=Svm(SmoteDataSet,testData,majorClassNo,minorClassNo,featureNum);                    
                    [tempNBAccurecy,tempNBTP,tempNBFP,tempNBPrecision,tempNBAUC,tempNBG_mean,tempNBF_measure]=naiveBayes(SmoteDataSet,testData,majorClassNo,minorClassNo,featureNum);
                    [tempLogRAccurecy,tempLogRTP,tempLogRFP,tempLogRPrecision,tempLogRAUC,tempLogRG_mean,tempLogRF_measure]=logistic(SmoteDataSet,testData,majorClassNo,minorClassNo,featureNum);
            end
            
            %     KNN �p�����
            ACK(match,kfoldIndex)=tempknnAccurecy;
            TK(match,kfoldIndex)=tempknnTPK;
            FPK(match,kfoldIndex)=tempknnFP;
            PK(match,kfoldIndex)=tempknnPrecision;
            AK(match,kfoldIndex)=tempknnAUC;
            GK(match,kfoldIndex)=tempknnG_mean;
            FK(match,kfoldIndex)=tempknnF_measure;
            
             %     DT �p�����
            ACT(match,kfoldIndex)=tempTreeAccurecy;
            TT(match,kfoldIndex)=tempTreeTP;
            FPT(match,kfoldIndex)=tempTreeFP;
            PT(match,kfoldIndex)=tempTreePrecision;
            AT(match,kfoldIndex)=tempTreeAUC;
            GT(match,kfoldIndex)=tempTreeG_mean;
            FT(match,kfoldIndex)=tempTreeF_measure;
            
            %     SVM �p�����
            ACS(match,kfoldIndex)=tempSVMAccurecy;
            TS(match,kfoldIndex)=tempSVMTPK;
            FPS(match,kfoldIndex)=tempSVMFP;
            PS(match,kfoldIndex)=tempSVMPrecision;
            AS(match,kfoldIndex)=tempSVMAUC;
            GS(match,kfoldIndex)=tempSVMG_mean;
            FS(match,kfoldIndex)=tempSVMF_measure;
            tempSVMAccurecy=0;
            tempSVMTPK=0;
            tempSVMFP=0;
            tempSVMPrecision=0;
            tempSVMAUC=0;
            tempSVMG_mean=0;
            tempSVMF_measure=0;
            
            %     NAVIE �p�����
            ACN(match,kfoldIndex)=tempNBAccurecy;
            TN(match,kfoldIndex)=tempNBTP;
            FPN(match,kfoldIndex)=tempNBFP;
            PN(match,kfoldIndex)=tempNBPrecision;
            AN(match,kfoldIndex)=tempNBAUC;
            GN(match,kfoldIndex)=tempNBG_mean;
            FN(match,kfoldIndex)=tempNBF_measure;
            
            %     logisit �p�����
            ACL(match,kfoldIndex)=tempLogRAccurecy;
            TL(match,kfoldIndex)=tempLogRTP;
            FPL(match,kfoldIndex)=tempLogRFP;
            PL(match,kfoldIndex)=tempLogRPrecision;
            AL(match,kfoldIndex)=tempLogRAUC;
            GL(match,kfoldIndex)=tempLogRG_mean;
            FL(match,kfoldIndex)=tempLogRF_measure;
        end
    end
    
    %�D�XK-fold������
    scoreK=zeros(methodCount,7);
    scoreT=zeros(methodCount,7);
    scoreSVM=zeros(methodCount,7);
    scoreNB=zeros(methodCount,7);
    scoreLR=zeros(methodCount,7);
    for i=1:methodCount
        for j=1:7
            switch j
                case {1}
                    scoreK(i,j)=mean(ACK(i,:));
                    scoreT(i,j)=mean(ACT(i,:));
                    scoreSVM(i,j)=mean(ACS(i,:));
                    scoreNB(i,j)=mean(ACN(i,:));
                    scoreLR(i,j)=mean(ACL(i,:));
                case {2}
                    scoreK(i,j)=mean(TK(i,:));
                    scoreT(i,j)=mean(TT(i,:));
                    scoreSVM(i,j)=mean(TS(i,:));
                    scoreNB(i,j)=mean(TN(i,:));
                    scoreLR(i,j)=mean(TL(i,:));
                case {3}
                    scoreK(i,j)=mean(FPK(i,:));
                    scoreT(i,j)=mean(FPT(i,:));
                    scoreSVM(i,j)=mean(FPS(i,:));
                    scoreNB(i,j)=mean(FPN(i,:));
                    scoreLR(i,j)=mean(FPL(i,:));
                case {4}
                    scoreK(i,j)=mean(PK(i,:));
                    scoreT(i,j)=mean(PT(i,:));
                    scoreSVM(i,j)=mean(PS(i,:));
                    scoreNB(i,j)=mean(PN(i,:));
                    scoreLR(i,j)=mean(PL(i,:));
                case {5}
                    scoreK(i,j)=mean(AK(i,:));
                    scoreT(i,j)=mean(AT(i,:));
                    scoreSVM(i,j)=mean(AS(i,:));
                    scoreNB(i,j)=mean(AN(i,:));
                    scoreLR(i,j)=mean(AL(i,:));
                case {6}
                    scoreK(i,j)=mean(GK(i,:));
                    scoreT(i,j)=mean(GT(i,:));
                    scoreSVM(i,j)=mean(GS(i,:));
                    scoreNB(i,j)=mean(GN(i,:));
                    scoreLR(i,j)=mean(GL(i,:));
                case {7}
                    scoreK(i,j)=mean(FK(i,:));
                    scoreT(i,j)=mean(FT(i,:));
                    scoreSVM(i,j)=mean(FS(i,:));
                    scoreNB(i,j)=mean(FN(i,:));
                    scoreLR(i,j)=mean(FL(i,:));
            end
        end
    end
    
    %�������� �U�Ӹ�ƶ����į��{    
    fileID=fopen(strcat(trainFile{fileIndex},'-',outTextFileName,'.txt'),'w');
    nbytes = fprintf(fileID,'%f\n',classRatio);
    nbytes = fprintf(fileID,'%d\t',delNo);
    nbytes = fprintf(fileID,'\n');
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','AUC','AUC','AUC','AUC','AUC');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,5));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,5));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,5));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,5));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,5));
        
        KNN_AUC(i,fileIndex)=scoreK(i,5);
        DT_AUC(i,fileIndex)=scoreT(i,5);
        SVM_AUC(i,fileIndex)=scoreSVM(i,5);
        NaiveB_AUC(i,fileIndex)=scoreNB(i,5);
        logisticR_AUC(i,fileIndex)=scoreLR(i,5);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','average','average','average','average','average');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,1));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,1));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,1));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,1));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,1));
        
        KNN_Accurecy(i,fileIndex)=scoreK(i,1);
        DT_Accurecy(i,fileIndex)=scoreT(i,1);
        SVM_Accurecy(i,fileIndex)=scoreSVM(i,1);
        NaiveB_Accurecy(i,fileIndex)=scoreNB(i,1);
        logisticR_Accurecy(i,fileIndex)=scoreLR(i,1);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','TP','TP','TP','TP','TP');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,2));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,2));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,2));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,2));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,2));
        
        KNN_TP(i,fileIndex)=scoreK(i,2);
        DT_TP(i,fileIndex)=scoreT(i,2);
        SVM_TP(i,fileIndex)=scoreSVM(i,2);
        NaiveB_TP(i,fileIndex)=scoreNB(i,2);
        logisticR_TP(i,fileIndex)=scoreLR(i,2);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','FP','FP','FP','FP','FP');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,3));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,3));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,3));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,3));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,3));
        
        KNN_FP(i,fileIndex)=scoreK(i,3);
        DT_FP(i,fileIndex)=scoreT(i,3);
        SVM_FP(i,fileIndex)=scoreSVM(i,3);
        NaiveB_FP(i,fileIndex)=scoreNB(i,3);
        logisticR_FP(i,fileIndex)=scoreLR(i,3);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','Precision','Precision','Precision','Precision','Precision');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,4));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,4));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,4));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,4));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,4));
        
        KNN_Precision(i,fileIndex)=scoreK(i,4);
        DT_Precision(i,fileIndex)=scoreT(i,4);
        SVM_Precision(i,fileIndex)=scoreSVM(i,4);
        NaiveB_Precision(i,fileIndex)=scoreNB(i,4);
        logisticR_Precision(i,fileIndex)=scoreLR(i,4);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','G_mean','G_mean','G_mean','G_mean','G_mean');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,6));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,6));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,6));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,6));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,6));
        
        KNN_G_mean(i,fileIndex)=scoreK(i,6);
        DT_G_mean(i,fileIndex)=scoreT(i,6);
        SVM_G_mean(i,fileIndex)=scoreSVM(i,6);
        NaiveB_G_mean(i,fileIndex)=scoreNB(i,6);
        logisticR_G_mean(i,fileIndex)=scoreLR(i,6);
    end
    
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataSet','Method','F_measure','F_measure','F_measure','F_measure','F_measure');
    for i=1 : methodCount
        fprintf(fileID,'%s\t%s\t',trainFile{fileIndex},method{i});
        nbytes = fprintf(fileID,'%f\t',scoreK(i,7));
        nbytes = fprintf(fileID,'%f\t',scoreT(i,7));
        nbytes = fprintf(fileID,'%f\t',scoreSVM(i,7));
        nbytes = fprintf(fileID,'%f\t',scoreNB(i,7));
        nbytes = fprintf(fileID,'%f\n',scoreLR(i,7));
        
        KNN_F_measure(i,fileIndex)=scoreK(i,7);
        DT_F_measure(i,fileIndex)=scoreT(i,7);
        SVM_F_measure(i,fileIndex)=scoreSVM(i,7);
        NaiveB_F_measure(i,fileIndex)=scoreNB(i,7);
        logisticR_F_measure(i,fileIndex)=scoreLR(i,7);
    end
    fclose(fileID);
    
    
    
end


indexName={'Accurecy','TP','FP','Precision','AUC','G-mean','F-measure'}; %�ϥ�index�W��


% % Wilcoxon signed rank test  

%�}��
fileID=fopen(strcat(outTextFileName, '_Wilcoxon signed rank test.txt'),'w');

%�p��U�ӫ��Ъ� P-Value  �˩w���G 
for index_choice=1:7
    fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
    fprintf(fileID,'\t%s\t%s\t%s\t%s\t%s\t%s\n','Method','P_Value','P_Value','P_Value','P_Value','P_Value');
    for Competitor_choice=2:methodCount
        switch index_choice
            case {1}
                %                 Accurecy
                [p1,h1]=signrank(KNN_Accurecy(1,:),KNN_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_Accurecy(1,:),DT_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_Accurecy(1,:),SVM_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_Accurecy(1,:),NaiveB_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_Accurecy(1,:),logisticR_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_Accurecy(1,:),KNN_Accurecy(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_Accurecy(1,:),DT_Accurecy(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_Accurecy(1,:),SVM_Accurecy(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_Accurecy(1,:),NaiveB_Accurecy(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_Accurecy(1,:),logisticR_Accurecy(Competitor_choice,:),'tail','left','alpha', alpha);
                
            case {2}
                %                 TP
                [p1,h1]=signrank(KNN_TP(1,:),KNN_TP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_TP(1,:),DT_TP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_TP(1,:),SVM_TP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_TP(1,:),NaiveB_TP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_TP(1,:),logisticR_TP(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_TP(1,:),KNN_TP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_TP(1,:),DT_TP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_TP(1,:),SVM_TP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_TP(1,:),NaiveB_TP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_TP(1,:),logisticR_TP(Competitor_choice,:),'tail','left','alpha', alpha);
            case {3}
                %                 FP
                [p1,h1]=signrank(KNN_FP(1,:),KNN_FP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p2,h2]=signrank(DT_FP(1,:),DT_FP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p3,h3]=signrank(SVM_FP(1,:),SVM_FP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p4,h4]=signrank(NaiveB_FP(1,:),NaiveB_FP(Competitor_choice,:),'tail','left','alpha', alpha);
                [p5,h5]=signrank(logisticR_FP(1,:),logisticR_FP(Competitor_choice,:),'tail','left','alpha', alpha);
                
                [p11,h11] =signrank(KNN_FP(1,:),KNN_FP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p22,h22] =signrank(DT_FP(1,:),DT_FP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p33,h33] =signrank(SVM_FP(1,:),SVM_FP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p44,h44] =signrank(NaiveB_FP(1,:),NaiveB_FP(Competitor_choice,:),'tail','right','alpha', alpha);
                [p55,h55] =signrank(logisticR_FP(1,:),logisticR_FP(Competitor_choice,:),'tail','right','alpha', alpha);
                
            case {4}
                %                 Precision
                [p1,h1]=signrank(KNN_Precision(1,:),KNN_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_Precision(1,:),DT_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_Precision(1,:),SVM_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_Precision(1,:),NaiveB_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_Precision(1,:),logisticR_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_Precision(1,:),KNN_Precision(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_Precision(1,:),DT_Precision(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_Precision(1,:),SVM_Precision(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_Precision(1,:),NaiveB_Precision(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_Precision(1,:),logisticR_Precision(Competitor_choice,:),'tail','left','alpha', alpha);
            case {5}
                %                 AUC
                [p1,h1]=signrank(KNN_AUC(1,:),KNN_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_AUC(1,:),DT_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_AUC(1,:),SVM_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_AUC(1,:),NaiveB_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_AUC(1,:),logisticR_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_AUC(1,:),KNN_AUC(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_AUC(1,:),DT_AUC(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_AUC(1,:),SVM_AUC(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_AUC(1,:),NaiveB_AUC(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_AUC(1,:),logisticR_AUC(Competitor_choice,:),'tail','left','alpha', alpha);
            case {6}
                %                 G_mean
                [p1,h1]=signrank(KNN_G_mean(1,:),KNN_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_G_mean(1,:),DT_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_G_mean(1,:),SVM_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_G_mean(1,:),NaiveB_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_G_mean(1,:),logisticR_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_G_mean(1,:),KNN_G_mean(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_G_mean(1,:),DT_G_mean(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_G_mean(1,:),SVM_G_mean(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_G_mean(1,:),NaiveB_G_mean(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_G_mean(1,:),logisticR_G_mean(Competitor_choice,:),'tail','left','alpha', alpha);
                
            case {7}
                %                 F_measure
                [p1,h1]=signrank(KNN_F_measure(1,:),KNN_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
                [p2,h2]=signrank(DT_F_measure(1,:),DT_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
                [p3,h3]=signrank(SVM_F_measure(1,:),SVM_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
                [p4,h4]=signrank(NaiveB_F_measure(1,:),NaiveB_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
                [p5,h5]=signrank(logisticR_F_measure(1,:),logisticR_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
                
                [p11,h11] =signrank(KNN_F_measure(1,:),KNN_F_measure(Competitor_choice,:),'tail','left','alpha', alpha);
                [p22,h22] =signrank(DT_F_measure(1,:),DT_F_measure(Competitor_choice,:),'tail','left','alpha', alpha);
                [p33,h33] =signrank(SVM_F_measure(1,:),SVM_F_measure(Competitor_choice,:),'tail','left','alpha', alpha);
                [p44,h44] =signrank(NaiveB_F_measure(1,:),NaiveB_F_measure(Competitor_choice,:),'tail','left','alpha', alpha);
                [p55,h55] =signrank(logisticR_F_measure(1,:),logisticR_F_measure(Competitor_choice,:),'tail','left','alpha', alpha);
        end
        
        %�̾��˩w���G�M�w��X  �����-���[*
        fprintf(fileID,'%s\t%s\t',indexName{index_choice},method{Competitor_choice});
        for class_choice=1:5
            switch class_choice
                case {1}
                    if h1==1
                        sign='*';
                    else
                        sign='';
                    end
                    if h11==1
                        sign1='*';
                    else
                        sign1='';
                    end
                    fprintf(fileID,'%s%f/%s%f\t',sign,p1,sign1,p11);
                case {2}
                    if h2==1
                        sign='*';
                    else
                        sign='';
                    end
                    if h22==1
                        sign1='*';
                    else
                        sign1='';
                    end
                    fprintf(fileID,'%s%f/%s%f\t',sign,p2,sign1,p22);
                case {3}
                    if h3==1
                        sign='*';
                    else
                        sign='';
                    end
                    if h33==1
                        sign1='*';
                    else
                        sign1='';
                    end
                    fprintf(fileID,'%s%f/%s%f\t',sign,p3,sign1,p33);
                case {4}
                    if h4==1
                        sign='*';
                    else
                        sign='';
                    end
                    if h44==1
                        sign1='*';
                    else
                        sign1='';
                    end
                    fprintf(fileID,'%s%f/%s%f\t',sign,p4,sign1,p44);
                case {5}
                    if h5==1
                        sign='*';
                    else
                        sign='';
                    end
                    if h55==1
                        sign1='*';
                    else
                        sign1='';
                    end
                    fprintf(fileID,'%s%f/%s%f\t\n',sign,p5,sign1,p55);
            end
        end
    end
    fprintf(fileID,'\n');
end
fclose(fileID);


% % �U�����Цb�Ҧ���ƶ���Ĺ���`�@count��
% method={'QSMOTE','B-SMOTE','ADAYSN','MSMOTE','MWMOTE','SMOTE'};
% indexName={'Accurecy','TP','FP','Precision','AUC','G-mean','F-measure'};
% fileID=fopen('count.txt','w');
% for index_choice=1:7
%     for Competitor_choice=2:methodCount
%         switch index_choice
%             case {1}
%                 %                 Accurecy
%                 
%                 c1=length(find(KNN_Accurecy(1,:)-KNN_Accurecy(Competitor_choice,:)>0));
%                 c2=length(find(DT_Accurecy(1,:)-DT_Accurecy(Competitor_choice,:)>0));
%                 c3=length(find(SVM_Accurecy(1,:)-SVM_Accurecy(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_Accurecy(1,:)-NaiveB_Accurecy(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_Accurecy(1,:)-logisticR_Accurecy(Competitor_choice,:)>0));
%                 
%             case {2}
%                 %                 TP
%                 c1=length(find(KNN_TP(1,:)-KNN_TP(Competitor_choice,:)>0));
%                 c2=length(find(DT_TP(1,:)-DT_TP(Competitor_choice,:)>0));
%                 c3=length(find(SVM_TP(1,:)-SVM_TP(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_TP(1,:)-NaiveB_TP(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_TP(1,:)-logisticR_TP(Competitor_choice,:)>0));
%             case {3}
%                 %                 FP
%                 c1=length(find(KNN_FP(1,:)-KNN_FP(Competitor_choice,:)<0));
%                 c2=length(find(DT_FP(1,:)-DT_FP(Competitor_choice,:)<0));
%                 c3=length(find(SVM_FP(1,:)-SVM_FP(Competitor_choice,:)<0));
%                 c4=length(find(NaiveB_FP(1,:)-NaiveB_FP(Competitor_choice,:)<0));
%                 c5=length(find(logisticR_FP(1,:)-logisticR_FP(Competitor_choice,:)<0));
%             case {4}
%                 %                 Precision
%                 c1=length(find(KNN_Precision(1,:)-KNN_Precision(Competitor_choice,:)>0));
%                 c2=length(find(DT_Precision(1,:)-DT_Precision(Competitor_choice,:)>0));
%                 c3=length(find(SVM_Precision(1,:)-SVM_Precision(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_Precision(1,:)-NaiveB_Precision(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_Precision(1,:)-logisticR_Precision(Competitor_choice,:)>0));
%             case {5}
%                 %                 AUC
%                 c1=length(find(KNN_AUC(1,:)-KNN_AUC(Competitor_choice,:)>0));
%                 c2=length(find(DT_AUC(1,:)-DT_AUC(Competitor_choice,:)>0));
%                 c3=length(find(SVM_AUC(1,:)-SVM_AUC(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_AUC(1,:)-NaiveB_AUC(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_AUC(1,:)-logisticR_AUC(Competitor_choice,:)>0));
%             case {6}
%                 %                 G_mean
%                 c1=length(find(KNN_G_mean(1,:)-KNN_G_mean(Competitor_choice,:)>0));
%                 c2=length(find(DT_G_mean(1,:)-DT_G_mean(Competitor_choice,:)>0));
%                 c3=length(find(SVM_G_mean(1,:)-SVM_G_mean(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_G_mean(1,:)-NaiveB_G_mean(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_G_mean(1,:)-logisticR_G_mean(Competitor_choice,:)>0));
%                 
%             case {7}
%                 %                 F_measure
%                 c1=length(find(KNN_F_measure(1,:)-KNN_F_measure(Competitor_choice,:)>0));
%                 c2=length(find(DT_F_measure(1,:)-DT_F_measure(Competitor_choice,:)>0));
%                 c3=length(find(SVM_F_measure(1,:)-SVM_F_measure(Competitor_choice,:)>0));
%                 c4=length(find(NaiveB_F_measure(1,:)-NaiveB_F_measure(Competitor_choice,:)>0));
%                 c5=length(find(logisticR_F_measure(1,:)-logisticR_F_measure(Competitor_choice,:)>0));
%         end
%         
%         fprintf(fileID,'%s\t%s\t',indexName{index_choice},method{Competitor_choice});
%         for class_choice=1:5
%             switch class_choice
%                 case {1}
%                     fprintf(fileID,'%d\t',c1);
%                 case {2}
%                     fprintf(fileID,'%d\t',c2);
%                 case {3}
%                     fprintf(fileID,'%d\t',c3);
%                 case {4}
%                     fprintf(fileID,'%d\t',c4);
%                 case {5}
%                     fprintf(fileID,'%d\t\n',c5);
%             end
%         end
%     end
%     fprintf(fileID,'\n');
% end
% fclose(fileID);


% % Wilcoxon rank sum test
% alpha=0.1;
% method={'QSMOTE','B-SMOTE','ADAYSN','MSMOTE','MWMOTE','SMOTE'};
% indexName={'Accurecy','TP','FP','Precision','AUC','G-mean','F-measure'};
% fileID=fopen('Wilcoxon rank sum test.txt','w');
% for index_choice=1:7
%     fprintf(fileID,'\t\t%s\t%s\t%s\t%s\t%s\n','KNN','DT','SVM','NaiveB','LogitR');
%     fprintf(fileID,'\t%s\t%s\t%s\t%s\t%s\t%s\n','Method','P_Value','P_Value','P_Value','P_Value','P_Value');
%     for Competitor_choice=2:6
%         switch index_choice
%             case {1}
%                 %                 Accurecy
%                 [p1,h1]=ranksum(KNN_Accurecy(1,:),KNN_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_Accurecy(1,:),DT_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_Accurecy(1,:),SVM_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_Accurecy(1,:),NaiveB_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_Accurecy(1,:),logisticR_Accurecy(Competitor_choice,:),'tail','right','alpha', alpha);
%
%             case {2}
%                 %                 TP
%                 [p1,h1]=ranksum(KNN_TP(1,:),KNN_TP(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_TP(1,:),DT_TP(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_TP(1,:),SVM_TP(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_TP(1,:),NaiveB_TP(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_TP(1,:),logisticR_TP(Competitor_choice,:),'tail','right','alpha', alpha);
%             case {3}
%                 %                 FP
%                 [p1,h1]=ranksum(KNN_FP(1,:),KNN_FP(Competitor_choice,:),'tail','left','alpha', alpha);
%                 [p2,h2]=ranksum(DT_FP(1,:),DT_FP(Competitor_choice,:),'tail','left','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_FP(1,:),SVM_FP(Competitor_choice,:),'tail','left','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_FP(1,:),NaiveB_FP(Competitor_choice,:),'tail','left','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_FP(1,:),logisticR_FP(Competitor_choice,:),'tail','left','alpha', alpha);
%             case {4}
%                 %                 Precision
%                 [p1,h1]=ranksum(KNN_Precision(1,:),KNN_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_Precision(1,:),DT_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_Precision(1,:),SVM_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_Precision(1,:),NaiveB_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_Precision(1,:),logisticR_Precision(Competitor_choice,:),'tail','right','alpha', alpha);
%             case {5}
%                 %                 AUC
%                 [p1,h1]=ranksum(KNN_AUC(1,:),KNN_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_AUC(1,:),DT_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_AUC(1,:),SVM_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_AUC(1,:),NaiveB_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_AUC(1,:),logisticR_AUC(Competitor_choice,:),'tail','right','alpha', alpha);
%             case {6}
%                 %                 G_mean
%                 [p1,h1]=ranksum(KNN_G_mean(1,:),KNN_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_G_mean(1,:),DT_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_G_mean(1,:),SVM_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_G_mean(1,:),NaiveB_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_G_mean(1,:),logisticR_G_mean(Competitor_choice,:),'tail','right','alpha', alpha);
%
%             case {7}
%                 %                 F_measure
%                 [p1,h1]=ranksum(KNN_F_measure(1,:),KNN_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p2,h2]=ranksum(DT_F_measure(1,:),DT_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p3,h3]=ranksum(SVM_F_measure(1,:),SVM_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p4,h4]=ranksum(NaiveB_F_measure(1,:),NaiveB_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
%                 [p5,h5]=ranksum(logisticR_F_measure(1,:),logisticR_F_measure(Competitor_choice,:),'tail','right','alpha', alpha);
%         end
%         fprintf(fileID,'%s\t%s\t',indexName{index_choice},method{Competitor_choice});
%         for class_choice=1:5
%             switch class_choice
%                 case {1}
%                     if h1==1
%                         sign='*';
%                     else
%                         sign='';
%                     end
%                     fprintf(fileID,'%s%f\t',sign,p1);
%                 case {2}
%                     if h2==1
%                         sign='*';
%                     else
%                         sign='';
%                     end
%                     fprintf(fileID,'%s%f\t',sign,p2);
%                 case {3}
%                     if h3==1
%                         sign='*';
%                     else
%                         sign='';
%                     end
%                     fprintf(fileID,'%s%f\t',sign,p3);
%                 case {4}
%                     if h4==1
%                         sign='*';
%                     else
%                         sign='';
%                     end
%                     fprintf(fileID,'%s%f\t',sign,p4);
%                 case {5}
%                     if h5==1
%                         sign='*';
%                     else
%                         sign='';
%                     end
%                     fprintf(fileID,'%s%f\t\n',sign,p5);
%             end
%         end
%     end
%     fprintf(fileID,'\n');
% end
% fclose(fileID);





toc  %��X�{������ɶ�

end

