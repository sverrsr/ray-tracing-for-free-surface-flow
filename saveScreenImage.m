function saveScreenImage(screen, filename)
    % saveScreenImage saves screen.image as a PNG file
    %
    % Inputs:
    %   screen   - struct or object with field/property "image"
    %   filename - output file name, e.g. "output.png"

    % if ~isfield(screen, 'image')
    %     error('screen does not contain an image field');
    % end

    %img = screen.image;
    img = screen.screen.image;

    img = imadjust(mat2gray(img));

    % Ensure filename ends with .png
    if ~endsWith(filename, '.png')
        filename = filename + ".png";
    end

    imwrite(img, filename);

    % PDF
    [p, n] = fileparts(filename);
    pdfname = fullfile(p, n + ".pdf");
    
    fig = figure('Visible','off', ...
                 'Units','pixels', ...
                 'Position',[100 100 size(img,2) size(img,1)]);
    
    ax = axes(fig, 'Units','pixels', 'Position',[1 1 size(img,2) size(img,1)]);
    imshow(img, 'InitialMagnification', 'fit', 'Interpolation','nearest');
    axis off
    
    set(fig, 'PaperPositionMode','auto');
    
    print(fig, pdfname, '-dpdf', '-r0');  % -r0 = keep native resolution
    close(fig)
end
