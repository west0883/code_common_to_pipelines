% ReturnMasks.m
% Sarah West
% 3/30/22

% Plots all the masks you removed with the RemoveArtifacts.m code and lets
% you return some that you might have removed by accident. 

function [masks_to_remove] = ReturnMasks(masks_to_remove, bRep)
% Inputs:
% masks -- a 3D matrix (pixels, pixels, mask #) of all the masks you drew.
% bRep -- a representative image (pixels, pixels) that you used to draw 

     % Get a colormap for qualitative data.
     mymap=[1 1 1 ; cbrewer('qual', 'Paired', size(masks_to_remove,3), 'linear')];

     % Make blank images for holding masks 
     holder=zeros(size(masks_to_remove,1), size(masks_to_remove,2));
     all_masks=zeros(size(masks_to_remove,1), size(masks_to_remove,2));
     
     % Add each mask in its own color to  holder, and also put all masks into single image.
     for i=1:size(masks_to_remove,3)
        holder(find(masks_to_remove(:,:,i)))=i; 
        all_masks(find(masks_to_remove(:,:,i)))=1;
     end
     
     % Put all masks onto bRep, keep original bRep for later.
     bRep_masked = bRep;
     bRep_masked(find(all_masks))=NaN; 
     
     % Create figure.
     figure; 
     
     % Plot masked bRep in first subplot
     subplot(1,2,1); imagesc(bRep_masked); colormap(gca,[0 0 0; parula(1000)]); 
     title('brain with masks');
     
     % Plot the mask overlays with their own colorscheme in second subplot.
     subplot(1,2,2); imagesc(holder); colormap(gca, mymap); colorbar; 
     title('mask numbers for returning');
     
     % Ask user if they want to return a mask
     user_answer1= inputdlg('Do you want to return one of these masks? 1=Y, 0=N');
     
     %Convert the user's answer into a value
     answer1=str2num(user_answer1{1});

     % While user keeps saying yes,
     while answer1 == 1 
         
         % Ask user which mask to return.
         user_answer2= inputdlg('Which mask would you like to return? Enter number.');
         
         %Convert the user's answer into a value
         answer2=str2num(user_answer2{1});

         % Remove that mask.
         masks_to_remove(:,:,answer2) = [];
         
         % **Plot remaining masks as above.**

         % Make blank images for holding masks 
         holder=zeros(size(masks_to_remove,1), size(masks_to_remove,2));
         all_masks=zeros(size(masks_to_remove,1), size(masks_to_remove,2));

         % Add each mask in its own color to  holder, and also put all masks into single image.
         for i=1:size(masks_to_remove,3)
            holder(find(masks_to_remove(:,:,i)))=i; 
            all_masks(find(masks_to_remove(:,:,i)))=1;
         end
         
         % Put all masks onto bRep, keep original bRep for later.
         bRep_masked = bRep;
         bRep_masked(find(all_masks))=NaN; 
          
         % Plot bRep in first subplot
         subplot(1,2,1); imagesc(bRep_masked); colormap(gca,[0 0 0; parula(1000)]); 
         title('brain with removed masks');

         % Plot the mask overlays with their own colorscheme in second subplot.
         subplot(1,2,2); imagesc(holder); colormap(gca, mymap); colorbar; 
         title('mask numbers for returning');
         
         % Ask user if they want to return another mask
         user_answer1= inputdlg('Do you want to return another mask? 1=Y, 0=N');
         
         %Convert the user's answer into a value
         answer1=str2num(user_answer1{1});

     end 
end