
    function [ gradI ] = CalGrad( Igray )
    
            sigma = 2;
            w = 4*sigma;
            x=-w:1:w; %filter window width

            s1sq = sigma.^2;
            smoothfilter = (1./(sqrt(2*pi)*sigma)) .* exp(-(x.^2 )./(2*s1sq));
            differfilter = (-x./(sqrt(2*pi)*sigma)) .* exp(-(x.^2 )./(2*s1sq));
            smoothfilter = smoothfilter/sum(smoothfilter);
            differfilter = differfilter/sum(abs(differfilter));

            %compute DOG responses along the x and y directions respectively.       
            smoothIx=filter2(smoothfilter,Igray,'valid');
            smoothIx=padarray(smoothIx,[0 w],'replicate','both');
            gradIy=filter2(differfilter',smoothIx,'valid');
            gradIy=padarray(gradIy,[w 0],'replicate','both');
             
            smoothIy=filter2(smoothfilter',Igray,'valid');
            smoothIy=padarray(smoothIy,[w 0],'replicate','both');
            gradIx=filter2(differfilter,smoothIy,'valid');
            gradIx=padarray(gradIx,[0 w],'replicate','both');      

            gradI=(gradIx.^2+gradIy.^2).^0.5;
            %gradI=uint8(mat2gray(gradI)*255);
                 
    end
