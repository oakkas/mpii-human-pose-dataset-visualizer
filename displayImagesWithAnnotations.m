clc, clear all, close all
load('mpii_human_pose_v1_u12_1.mat', 'RELEASE')

annotationImages = RELEASE.annolist;
trainingImages = RELEASE.img_train;
[parentdir,~,~]=fileparts(pwd);
baseFolder = fullfile(parentdir,'images');
%baseFolder = 'Z:\OGUZ\Study DataSets\images';
%to get a training image, loop through trainingImages and look for coded as
%1 that means annonated
for i = 1:size(trainingImages,2)
    %i
    if(trainingImages(i)==1)
        imageName = annotationImages(i).image.name;
        f = fullfile(baseFolder,imageName);
        h_fig=figure;
        image = imread(f);
        imshow(image);
        hold on
        %loop for number of rectengle annotation
        numAnnot = 0;
        positions = [];
        humansJoints = {};
        for j = 1:size(annotationImages(i).annorect,2)
           x= annotationImages(i).annorect(j).x1;
           y= annotationImages(i).annorect(j).y1;
           w = annotationImages(i).annorect(j).x2-x;
           h = annotationImages(i).annorect(j).y2-y;
           positions = [x,y,w,h;positions];
           joints=[];
           for h = 1:size(annotationImages(i).annorect(j).annopoints.point,2)
              xj= annotationImages(i).annorect(j).annopoints.point(h).x;
              yj= annotationImages(i).annorect(j).annopoints.point(h).y;
              id= annotationImages(i).annorect(j).annopoints.point(h).id;
              visible = annotationImages(i).annorect(j).annopoints.point(h).is_visible;
              if(ischar(visible))
                  visible=str2num(visible);
              end
              if(isempty(visible))
                  visible=0;
              end
              joints=[xj,yj,id,visible;joints];
           end
           humansJoints{j}=joints;
           numAnnot = numAnnot+1;
        end
        %draw rects for the number of annotations
        for k = 1 : numAnnot
           joints = humansJoints{k};
           parts = getParts(joints);
           %draw head rectengales
           %rectangle('Position', positions(k,:), 'EdgeColor','r','LineWidth',3);
           drawHeadRect(positions(k,:))
           %draw joints
           drawJoints(joints)
           %draw body parts if visible
           drawBodyParts(parts)
        end
        hold off
        %set(h_fig,'KeyPressFcn',@myfun);
        w = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter'))
        close all
    end
end
% function myfun(src,event)
%    disp(event.Key);
% end

function drawHeadRect(position)
    rectangle('Position', position, 'EdgeColor','r','LineWidth',3);
end
function drawJoints(joints)
    for g = 1:size(joints,1)
       if(joints(g,4)==1)
           plot(joints(g,1),joints(g,2),'r*', 'LineWidth', 2, 'MarkerSize', 5)
           %id - joint id (0 - r ankle, 1 - r knee, 2 - r hip, 3 - l hip, 4 - l knee, 5 - l ankle, 6 - pelvis,
           %7 - thorax, 8 - upper neck, 9 - head top, 10 - r wrist, 11 - r elbow, 12 - r shoulder, 13 - l shoulder,
           %14 - l elbow, 15 - l wrist)
       end
    end
end

function drawBodyParts(parts)
    for p = 1:size(parts,1)
       if(parts(p,5)==1)
            line([parts(p,1),parts(p,3)],[parts(p,2),parts(p,4)], 'Color','red', 'LineWidth',3)
       end
    end
end
function parts = getParts(joints)
    %body parts: Rleg=Rankle0-Rknee1, Lleg=Lankle5-Lknee4, Rthigh = Rknee1-Rhip2, Lthigh = Lknee4-Lhip3, body=upper
    %neck8- pelvis6, Rneck8-Rshoulder12, Lneck8-Lshoulder13, Rupper arm = %Rshoulder12-Relbow11, Lupper arm = Lshoulder13-Relbow14,
    %Rlower arm = Relbow11-Rwrist10, Llower arm = Lelbow14-Lwrist15 
    parts=[];
    jointIds = joints(:,3);
    XY = joints(:,1:2);
    visibility=joints(:,4);
    %check for right leg
    if(ismember(0,jointIds) && ismember(1,jointIds))
        rAnkleIndex = find(jointIds==0);
        rkneeIndex = find(jointIds==1);
        rAnkleXY =  XY(rAnkleIndex(1),:);
        rKneeXY =  XY(rkneeIndex(1),:);
        parts = [horzcat(rAnkleXY,rKneeXY, visibility(rAnkleIndex(1))*visibility(rkneeIndex(1)));parts];
    end
    %check for left leg
    if(ismember(5,jointIds) && ismember(4,jointIds))
        lAnkleIndex = find(jointIds==5);
        lkneeIndex = find(jointIds==4);
        lAnkleXY =  XY(lAnkleIndex(1),:);
        lKneeXY =  XY(lkneeIndex(1),:);
        parts = [horzcat(lAnkleXY,lKneeXY, visibility(lAnkleIndex(1))*visibility(lkneeIndex(1)));parts];
    end
    %check for right thigh
    if(ismember(1,jointIds) && ismember(2,jointIds))
        rHipIndex = find(jointIds==2);
        rkneeIndex = find(jointIds==1);
        rHipXY =  XY(rHipIndex(1),:);
        rKneeXY =  XY(rkneeIndex(1),:);
        parts = [horzcat(rKneeXY,rHipXY,visibility(rHipIndex(1))*visibility(rkneeIndex(1)));parts];
    end
    %check for left thigh
    if(ismember(3,jointIds) && ismember(4,jointIds))
        lHipIndex = find(jointIds==3);
        lkneeIndex = find(jointIds==4);
        lHipXY =  XY(lHipIndex(1),:);
        lKneeXY =  XY(lkneeIndex(1),:);
        parts = [horzcat(lKneeXY,lHipXY,visibility(lHipIndex(1))*visibility(lkneeIndex(1)));parts];
    end
    %check for body
    if(ismember(8,jointIds) && ismember(6,jointIds))
        UpperNeckIndex = find(jointIds==8);
        PelvisIndex = find(jointIds==6);
        UpperNeckXY =  XY(UpperNeckIndex(1),:);
        PelvisXY =  XY(PelvisIndex(1),:);
        parts = [horzcat(UpperNeckXY,PelvisXY,visibility(PelvisIndex(1))*visibility(UpperNeckIndex(1)));parts];
    end
    
    %check for right neck-shoulder
    if(ismember(8,jointIds) && ismember(12,jointIds))
        neckIndex = find(jointIds==8);
        rShoulderIndex = find(jointIds==12);
        neckXY =  XY(neckIndex(1),:);
        rShoulderXY =  XY(rShoulderIndex(1),:);
        parts = [horzcat(neckXY,rShoulderXY,visibility(neckIndex(1))*visibility(rShoulderIndex(1)));parts];
    end
    %check for left neck-shoulder
    if(ismember(8,jointIds) && ismember(13,jointIds))
        neckIndex = find(jointIds==8);
        lShoulderIndex = find(jointIds==13);
        neckXY =  XY(neckIndex(1),:);
        lShoulderXY =  XY(lShoulderIndex(1),:);
        parts = [horzcat(neckXY,lShoulderXY,visibility(neckIndex(1))*visibility(lShoulderIndex(1)));parts];
    end
    
    %check for right upper arm
    if(ismember(11,jointIds) && ismember(12,jointIds))
        rElbowIndex = find(jointIds==11);
        rShoulderIndex = find(jointIds==12);
        rElbowXY =  XY(rElbowIndex(1),:);
        rShoulderXY =  XY(rShoulderIndex(1),:);
        parts = [horzcat(rElbowXY,rShoulderXY,visibility(rElbowIndex(1))*visibility(rShoulderIndex(1)));parts];
    end
    %check for left upper arm
    if(ismember(13,jointIds) && ismember(14,jointIds))
        lElbowIndex = find(jointIds==14);
        lShoulderIndex = find(jointIds==13);
        lElbowXY =  XY(lElbowIndex(1),:);
        lShoulderXY =  XY(lShoulderIndex(1),:);
        parts = [horzcat(lElbowXY,lShoulderXY,visibility(lElbowIndex(1))*visibility(lShoulderIndex(1)));parts];
    end
        %check for right lower arm
    if(ismember(11,jointIds) && ismember(10,jointIds))
        rElbowIndex = find(jointIds==11);
        rWristIndex = find(jointIds==10);
        rElbowXY =  XY(rElbowIndex(1),:);
        rWristXY =  XY(rWristIndex(1),:);
        parts = [horzcat(rElbowXY,rWristXY,visibility(rElbowIndex(1))*visibility(rWristIndex(1)));parts];
    end
    %check for left lower arm
    if(ismember(14,jointIds) && ismember(15,jointIds))
        lElbowIndex = find(jointIds==14);
        lWristIndex = find(jointIds==15);
        lElbowXY =  XY(lElbowIndex(1),:);
        lWristXY =  XY(lWristIndex(1),:);
        parts = [horzcat(lElbowXY,lWristXY,visibility(lElbowIndex(1))*visibility(lWristIndex(1)));parts];
    end
end