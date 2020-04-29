function ALL_DIST=DistFind(lab_seg_vals,max_label,valScale)
% ALL_DIST=zeros(max_label,max_label);
% for label_counter=1:max_label   
%     distance_all=sum((lab_seg_vals(label_counter:end,:)-lab_seg_vals(label_counter,:)).^2,2);
%     ALL_DIST(label_counter:end,label_counter)=1./(0.00001+distance_all);
%     ALL_DIST(label_counter,label_counter:end)=1./(0.00001+distance_all);
% end
ALL_DIST=zeros(max_label,max_label);
for label_counter=1:max_label   
    distance_all=sqrt(sum((lab_seg_vals(label_counter:end,:)-lab_seg_vals(label_counter,:)).^2,2));
    ALL_DIST(label_counter:end,label_counter)=distance_all;
    ALL_DIST(label_counter,label_counter:end)=distance_all;
end
ALL_DIST=mapminmax(ALL_DIST(:).',0,1);
ALL_DIST=reshape(ALL_DIST,max_label,max_label);
ALL_DIST=exp(-valScale.*ALL_DIST);
