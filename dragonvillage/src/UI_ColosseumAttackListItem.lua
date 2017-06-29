local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumAttackListItem
-------------------------------------
UI_ColosseumAttackListItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumAttackListItem:init(struct_user_info_colosseum)
    local vars = self:load('colosseum_scene_atk_item.ui')
    vars['listMenu']:setSwallowTouch(false)

    local info = struct_user_info_colosseum

    -- 대표 드래곤 아이콘
    local icon = info:getLeaderDragonCard()
    if icon then
        icon.root:setSwallowTouch(false)
        icon.vars['clickBtn']:registerScriptTapHandler(function() UI_UserInfoMini(info) end)
        vars['profileNode']:addChild(icon.root)
    end

    --[[
    do -- 테이머로 표시
        local tamer_type = TableTamer:getTamerType(info.m_tamerID) or 'goni'
        local icon = IconHelper:getTamerProfileIcon(tamer_type)
        if icon then
            vars['profileNode']:addChild(icon)
        end
    end
    --]]
   
    -- 유저 정보
    local str = Str('레벨{1} {2}', info.m_lv, info.m_nickname)
    vars['userLabel']:setString(str)

    -- 전투력 표시
    local combat_power = info:getDeckCombatPower()
    vars['powerLabel']:setString(Str('전튜력 : {1}', comma_value(combat_power)))

    -- 점수 표시
    vars['scoreLabel']:setString(Str('{1}점', info.m_rp))

    -- 드래곤 리스트
    local t_deck_dragon_list = info:getDeck_dragonList()
    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. i]:addChild(icon.root)
    end

    -- 선택 (공격 버튼)
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_ColosseumAttackListItem:click_selectBtn()
    UI_ColosseumReady()
end