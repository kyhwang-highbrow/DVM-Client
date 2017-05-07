plSample = {}

plSample.rmtree = function()
    local text = ' sdlkfjsdklfj dsfkjsdlkfj sdflsjdkfsd '
    print(text)
    local temp = pl.stringx.strip(text)
    print(temp)

    cclog(pl.app.platform())

    if pl.path.isdir('D:/dragonvillage/src/frameworks/dragonvillage/runtime/removetree') then
        pl.dir.rmtree('D:/dragonvillage/src/frameworks/dragonvillage/runtime/removetree')
    end

    cclog(pl.path.getatime('D:/dragonvillage/src/frameworks/dragonvillage/runtime/DragonVillage.exe'))
    cclog(pl.path.getsize('D:/dragonvillage/src/frameworks/dragonvillage/runtime/DragonVillage.exe'))

    cclog(pl.path.getsize('res/adventure_chapter_select_popup_item.ui'))


    local sertch_paths = pl.List(cc.FileUtils:getInstance():getSearchPaths())

    print(tostring(sertch_paths))

    --local ret = sertch_paths:foreach(function(path) print(path) end)

    local res = 'res/adventure_chapter_select_popup_item.ui'

    for i,v in ipairs(sertch_paths) do
        local fullpath = pl.path.join(v, res)
        if pl.path.exists(fullpath) then
            fullpath = pl.path.abspath(fullpath)
            cclog('Find!! ' .. fullpath)
            cclog(pl.path.getsize(fullpath))
            break
        end
    end
end