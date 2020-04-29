    % ----------------------------------------------------------------
    % function ImageCrop
    % input:  Img .....Input image
    % output: hsum.....total cropped margin pixels in y direction
    %         wsum.....total cropped margin pixels in x direction  
    %         I........Cropped image
    % this function removes the image's photo frames, such as the black margin in 0_11_11852.jpg in MSRA1000.
    % ----------------------------------------------------------------

    function [ hsum, wsum, I] = ImageCrop( Img )
           
        I=Img;       
        crop=10;%default margin width for all images
        hsum=0; wsum=0;    
        range=100;
        I = I((crop+1):(end-crop),(crop+1):(end-crop),:);
        [CannyMap , ~] = edge(rgb2gray(I),'sobel');
        [Height, Width, Channel] = size(I);
        range=round(min([Height/3 Width/3 range]));
        %find margin positions
        CannyW=sum(CannyMap);
        PosWL=find(CannyW(1:range)>Height*0.6, 1, 'last' );
        PosWR=find(CannyW((end-range+1):end)>Height*0.6, 1, 'first' );

        CannyH=sum(CannyMap,2);
        PosHU=find(CannyH(1:range)>Width*0.6, 1, 'last' ); 
        PosHD=find(CannyH((end-range+1):end)>Width*0.6, 1, 'first' );

        %margin width of image in horizontal and vertical direction
        PosW=max([PosWL range-PosWR+1]);
        PosH=max([PosHU range-PosHD+1]);

        %if detected margin positions are asymmetric, set margin width to zero.
        if isempty(PosW)||isempty(abs(PosWL-(range-PosWR+1))>5)||abs(PosWL-(range-PosWR+1))>5
           PosW=0;
        end

        if isempty(PosH)||isempty(abs(PosHU-(range-PosHD+1))>5)||abs(PosHU-(range-PosHD+1))>5
            PosH=0;
        end

        hsum=hsum+PosH;
        wsum=wsum+PosW;

        %cropping
        CropI=zeros(Height-2*PosH, Width-2*PosW, Channel);
        CropI(:,:,1)=I(PosH+1:Height-PosH,PosW+1:Width-PosW,1);
        CropI(:,:,2)=I(PosH+1:Height-PosH,PosW+1:Width-PosW,2);
        CropI(:,:,3)=I(PosH+1:Height-PosH,PosW+1:Width-PosW,3);
        CropI=uint8(CropI);
        I=CropI;

        hsum=hsum+crop;
        wsum=wsum+crop;
            
    end

