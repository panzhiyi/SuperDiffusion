function weights=makeweights2(edges,vals,valScale)
valDistances=sqrt(sum((vals(edges(:,1),:)-vals(edges(:,2),:)).^2,2));
valDistances=valDistances.*edges(:,3);
valDistances=(valDistances-min(valDistances))/(max(valDistances)-min(valDistances));%Normalize to [0,1]
weights=exp(-valScale*valDistances);
