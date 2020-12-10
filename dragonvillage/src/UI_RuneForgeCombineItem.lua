local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RuneForgeCombineItem
-------------------------------------
UI_RuneForgeCombineItem = class(PARENT,{
        m_ownerUI = 'UI_RuneForgeCombineTab',
        ---------------------------------
        m_runeCombineData = 'StructRuneCombine',
        m_mRuneCardUI = 'map', -- 현재 생성되어있는 룬 카드 UI, map[index] = UI_RuneCard
        m_resultCard = 'UI_ItemCard',
        m_resultEffect = 'visual',
    })

-- 가능한 등급이 1~2라면 key : 12
UI_RuneForgeCombineItem.result_info_text = {
    ['12'] = Str('{@SKILL_NAME}1등급 룬 합성\n{@DEFAULT}1~2등급 룬을 얻을 수 있습니다.'),
    ['23'] = Str('{@SKILL_NAME}2등급 룬 합성\n{@DEFAULT}2~3등급 룬을 얻을 수 있습니다.'),
    ['34'] = Str('{@SKILL_NAME}3등급 룬 합성\n{@DEFAULT}3~4등급 룬을 얻을 수 있습니다.'),
    ['45'] = Str('{@SKILL_NAME}4등급 룬 합성\n{@DEFAULT}4~5등급 룬을 얻을 수 있습니다.'),
    ['56'] = Str('{@SKILL_NAME}5등급 룬 합성\n{@DEFAULT}5~6등급 룬을 얻을 수 있습니다.'),
    ['67'] = Str('{@SKILL_NAME}6등급 룬 합성\n{@DEFAULT}6~7등급 룬을 얻을 수 있습니다.'),
    ['77'] = Str('{@SKILL_NAME}7등급 룬 합성\n{@DEFAULT}7등급 룬을 얻을 수 있습니다.'),
}

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineItem:init(owner_ui, struct_rune_combine)
    local vars = self:load('rune_forge_combine_item.ui')
    
    self.m_ownerUI = owner_ui
    self.m_runeCombineData = struct_rune_combine
    self.m_mRuneCardUI = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeCombineItem:initUI()
    local vars = self.vars
    
    vars['runeResultNode']:setVisible(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeCombineItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeCombineItem:refresh()
    local vars = self.vars

    local t_rune_combine_data = self.m_runeCombineData
    local grade = t_rune_combine_data.m_grade

    -- 합성 정보에 등록된 룬이 없는 경우
    if (grade == nil) then
        if (self.m_resultCard ~= nil) then
            self.m_resultCard = nil
            vars['runeResultNode']:removeAllChildren()
        end

    -- 결과 룬 카드를 생성하지 않은 경우
    else
        if (grade ~= nil) then
            self:makeResultRuneCard()
        end
    end

    
    -- 각 룬 등록칸에 룬 카드 생성하기
    for idx = 1, RUNE_COMBINE_REQUIRE do
        local is_blank_index = t_rune_combine_data:isBlankIndex(idx)
        
        if (is_blank_index) then
           vars['itemNode' .. idx]:removeAllChildren() -- 제거
           self.m_mRuneCardUI[idx] = nil

        else
            if (self.m_mRuneCardUI[idx] == nil) then -- 룬 정보가 있는데 UI 카드가 없던 경우생성
                local t_rune_data = t_rune_combine_data:getRuneDataFromIndex(idx)
                local rune_card_ui = UI_RuneCard(t_rune_data)
                rune_card_ui.root:setSwallowTouch(false)
                rune_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(t_rune_data) end)
                vars['itemNode' .. idx]:addChild(rune_card_ui.root)
                
                cca.uiReactionSlow(rune_card_ui.root, 1, 1, 1.3)
                self.m_mRuneCardUI[idx] = rune_card_ui
            end
        end
    end

    -- 룬 등록칸에 룬이 전부 등록된 경우
    if (t_rune_combine_data:isFull()) then
        vars['allSelectMenu']:setVisible(true)
        
        if (self.m_resultCard ~= nil) then
            self.m_resultCard.vars['disableSprite']:setVisible(false)
        end
        if (self.m_resultEffect ~= nil) then
            self.m_resultEffect:setVisible(true)
        end
    else
        vars['allSelectMenu']:setVisible(false)
        
        if (self.m_resultCard ~= nil) then
            self.m_resultCard.vars['disableSprite']:setVisible(true)
        end
        if (self.m_resultEffect ~= nil) then
            self.m_resultEffect:setVisible(false)
        end
    end
end

-------------------------------------
-- function click_rune
-- @brief 룬 선택
-------------------------------------
function UI_RuneForgeCombineItem:click_rune(data)
    local owner_ui = self.m_ownerUI
    owner_ui:click_rune(data)
end

-------------------------------------
-- function makeResultRuneCard
-- @brief 합성 시 결과로 나오는 룬을 알려주는 카드 생성
-------------------------------------
function UI_RuneForgeCombineItem:makeResultRuneCard()
    -- 현재 합성 정보로 얻을 수 있는 등급의 범위
    local curr_grade = self.m_runeCombineData.m_grade
    local success_grade = math_min(curr_grade + 1, 7)
    
    -- 룬 카드 생성
    local result_card_ui = UI_Card()
    result_card_ui.ui_res = 'card_rune.ui'
    result_card_ui:getUIInfo()
    
    local btn = result_card_ui.vars['clickBtn']

    if (not btn) then
        btn = cc.MenuItemImage:create()
        btn:setDockPoint(CENTER_POINT)
        btn:setAnchorPoint(CENTER_POINT)
        btn:setContentSize(150, 150)
    
        result_card_ui.vars['clickBtn'] = UIC_Button(btn)
        result_card_ui.root:addChild(btn, -1)

	    btn:registerScriptTapHandler(function() self:press_resultRuneBtn(curr_grade, success_grade) end)
    end

    local frame_res = 'card_rune_frame_none.png'
    local result_res = string.format('res/ui/icons/rune/set_all_%02d.png', success_grade)
    local star_res
    if (curr_grade == success_grade) then
        star_res = string.format('res/ui/icons/rune/star_%d.png', curr_grade)
    else
        star_res = string.format('res/ui/icons/rune/star_%d%d.png', curr_grade, success_grade)
    end

    -- 프레임 생성
    result_card_ui:makeSprite('frameNode', frame_res)
    
    -- 획득 가능한 범주의 등급 표시
    result_card_ui:makeSprite('starNode', star_res, true) -- (lua_name, res, no_use_frames)
    result_card_ui.vars['starNode']:setPositionY(-45) -- 하드코딩
    
    -- 얻을 수 있는 등급 중 좋은 등급의 룬 아이콘
    result_card_ui:makeSprite('runeNode', result_res, true) -- (lua_name, res, no_use_frames)
    result_card_ui.vars['runeNode']:setPositionY(20) -- 하드코딩
    
    -- 높은 등급을 획득할 수 있는 경우 효과 나타내기
	if (success_grade >= 7) then
		local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
		rarity_effect:changeAni('summon_hero', true)
		rarity_effect:setScale(1.7)
		result_card_ui.root:addChild(rarity_effect.m_node)
        self.m_resultEffect = rarity_effect
    else
        self.m_resultEffect = nil
	end
    
    -- 일단 검은 레이어 씌우고 모든 합성 재료 칸이 등록되면 벗겨주기
    local disable_res = 'card_cha_frame_disable.png'
    result_card_ui:setSpriteVisible('disableSprite', disable_res, true)

    self.vars['runeResultNode']:addChild(result_card_ui.root)
    self.m_resultCard = result_card_ui
end

-------------------------------------
-- function press_resultRuneBtn
-- @brief 합성 결과 카드 클릭할 때 
-------------------------------------
function UI_RuneForgeCombineItem:press_resultRuneBtn(curr_grade, success_grade)
    local str_key = tostring(curr_grade) .. tostring(success_grade)
    local str = UI_RuneForgeCombineItem.result_info_text[str_key]
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.m_resultCard.vars['clickBtn'])
end