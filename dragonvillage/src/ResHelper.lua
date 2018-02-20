ResHelper = {}

-------------------------------------
-- function getUIDragonBG
-- @brief UI에서 드래곤 속성별 배경 이미지 생성
-------------------------------------
function ResHelper:getUIDragonBG(attr, animation)
    local res

    if (attr == T_ATTR_LIST[ATTR_NONE]) then
        res = 'res/bg/ui/dragon_goodbye/dragon_goodbye.vrp'
    else
        res = string.format('res/bg/ui/dragon_bg_%s/dragon_bg_%s.vrp', attr, attr)
    end

    local animator = MakeAnimator(res)

    animation = animation or 'mini'
    animator:changeAni(animation, true)

    return animator
end

-------------------------------------
-- function makeUIAdventureChapterBG
-- @brief UI에서 사용되는 모험모드 챕터 배경
-------------------------------------
function ResHelper:makeUIAdventureChapterBG(bg_node, chapter)
    local map_script

    if (chapter == 1) then
        map_script = 'map_forest'

    elseif (chapter == 2) then
        map_script = 'map_ocean'

    elseif (chapter == 3) then
        map_script = 'map_canyon'

    elseif (chapter == 4) then
        map_script = 'map_volcano'

    elseif (chapter == 5) then
        map_script = 'map_sky_temple'

    elseif (chapter == 6) then
        map_script = 'map_dark_castle'

    else
        error('chapter : ' .. chapter)
    end
        
    local scroll_map = ScrollMap(bg_node)
    scroll_map:setBg(map_script, nil)
    scroll_map:setSpeed(-100)
    scroll_map:update(0)

    -- 배경 스크롤을 위해 스케쥴러 등록
    local function update(dt)
        scroll_map:update(dt)
    end
    bg_node:scheduleUpdateWithPriorityLua(update, 0)

    return scroll_map
end