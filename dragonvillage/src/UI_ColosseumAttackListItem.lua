local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ColosseumAttackListItem
-------------------------------------
UI_ColosseumAttackListItem = class(PARENT,{
        m_structUserInfoColosseum = 'StructUserInfoColosseum',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumAttackListItem:init(struct_user_info_colosseum)
    self.m_structUserInfoColosseum = struct_user_info_colosseum

    local vars = self:load('colosseum_scene_atk_item.ui')
    vars['listMenu']:setSwallowTouch(false)

    local info = struct_user_info_colosseum

    -- 대표 드래곤 아이콘
    local icon = info:getLeaderDragonCard()
    if icon then
        icon.root:setSwallowTouch(false)
        vars['profileNode']:addChild(icon.root)

        icon.vars['clickBtn']:registerScriptTapHandler(function() 
			local is_visit = true
			UI_UserInfoDetailPopup:open(struct_user_info_colosseum, is_visit, nil)
		end)
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
    local combat_power = info:getDefDeckCombatPower()
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    -- 점수 표시
    vars['scoreLabel']:setString(Str('{1}점', comma_value(info.m_rp)))

    -- 드래곤 리스트
    local t_deck_dragon_list = info:getDefDeck_dragonList()
    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. i]:addChild(icon.root)
    end

    -- 선택 (공격 버튼)
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)

    do-- 상태 정리
        vars['selectBtn']:setVisible((info.m_matchResult == -1) or (info.m_matchResult == 0))
        vars['winNode']:setVisible((info.m_matchResult == 1))
        vars['loseNode']:setVisible((info.m_matchResult == 0))
    end

    -- 공통의 정보
    self:initRankInfo(vars, info)   
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_ColosseumAttackListItem:click_selectBtn()
    g_colosseumData.m_matchUserID = self.m_structUserInfoColosseum.m_uid
    UI_ColosseumReady()
end