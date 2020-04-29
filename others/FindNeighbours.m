function [neighbourhood]=FindNeighbours(suppixel,boundaries,max_label)
neighbourhood=zeros(max_label);

neighbourx1=suppixel; neighbourx2=suppixel; neighboury1=suppixel; neighboury2=suppixel;
neighbourx1(2:end,:)=suppixel(1:end-1,:); NX1stats=regionprops(suppixel,neighbourx1,'PixelValues');
neighbourx2(1:end-1,:)=suppixel(2:end,:); NX2stats=regionprops(suppixel,neighbourx2,'PixelValues');
neighboury1(:,2:end)=suppixel(:,1:end-1); NY1stats=regionprops(suppixel,neighboury1,'PixelValues');
neighboury2(:,1:end-1)=suppixel(:,2:end); NY2stats=regionprops(suppixel,neighboury2,'PixelValues');

for label_counter=1:max_label
    neighbourhood(label_counter,[NX1stats(label_counter).PixelValues; NX2stats(label_counter).PixelValues; NY1stats(label_counter).PixelValues; NY2stats(label_counter).PixelValues])=1;
    if ismember(label_counter,boundaries)
        neighbourhood(label_counter,boundaries)=1;
    end
    neighbourhood(label_counter,label_counter)=0;
end

neighbourhood2=zeros(max_label);
for label_counter=1:max_label
    neibour1= find(neighbourhood(label_counter,:)==1);
    for i=1:length(neibour1)
        neighbourhood2(label_counter,find(neighbourhood(neibour1(i),:)==1))=2;
    end
    neighbourhood2(label_counter,label_counter)=0;
end
neighbourhood=neighbourhood+neighbourhood2;
neighbourhood(neighbourhood==3)=1;