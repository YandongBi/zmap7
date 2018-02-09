function myTab = findOrCreateTab(fig, container, title)
    % FINDORCREATETAB return handle to a specified tab. if the tab doesn't exist, it is created
    %
    % tabH = FINDORCREATETAB( FIG, CONTAINER_TAG, TITLE)
    %    FIG is a figure handle. The uitab with the Title "TITLE" will be returned only tabs
    %    belonging to this figure are returned. If the tab doesn't already exist, it will be
    %    created with the title TITLE within the container identified by the CONTAINER_TAG.
    %
    %
    myContainer=findobj(fig,'Tag',container);
    myTab=findobj(myContainer,'Title',title,'-and','Type','uitab');
    if isempty(myTab)
        myTab=uitab(myContainer, 'Title',title);
    end
end