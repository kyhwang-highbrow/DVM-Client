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
    })

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
            self.vars['noneSelectSprite']:setVisible(true)

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
                local rune_card_ui = UI_RuneCardOption(t_rune_data)
                rune_card_ui.root:setSwallowTouch(false)
                rune_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(t_rune_data) end)
                vars['itemNode' .. idx]:addChild(rune_card_ui.root)
                
                cca.uiReactionSlow(rune_card_ui.root, 1, 1, 1.3)
                self.m_mRuneCardUI[idx] = rune_card_ui

                -- UI_RuneCard의 press_clickBtn으로 열린 UI_ItemInfoPopup이 닫힐 때 불리는 callback function
                local function close_info_callback()
                    -- 룬이 잠금처리 되어 있을 경우 tableview에서 삭제
                    if rune_card_ui:isRuneLock() then
                        -- UI_RuneForgeCombineItem에서 제거
                        self:click_rune(rune_card_ui.m_runeData)

                        -- 좌측 UI_RuneForgeCombineTab의 m_tableView에서 제거
                        self.m_ownerUI.m_tableView:delItem(t_rune_data:getObjectId())
                        self.m_ownerUI:refresh()
                    end
                end

                rune_card_ui:setCloseInfoCallback(close_info_callback)
            end
        end
    end

    -- 룬 등록칸에 룬이 전부 등록된 경우
    if (t_rune_combine_data:isFull()) then
        vars['allSelectMenu']:setVisible(true)
        
        if (self.m_resultCard ~= nil) then
            self.m_resultCard.vars['disableSprite']:setVisible(false)
        end
    else
        vars['allSelectMenu']:setVisible(false)
        
        if (self.m_resultCard ~= nil) then
            self.m_resultCard.vars['disableSprite']:setVisible(true)
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
    result_card_ui.root:setSwallowTouch(false)
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
    local result_res = string.format('res/ui/icons/item/rune_gacha_result_card.png')
    local star_top_res = string.format('card_star_yellow_01%02d.png', success_grade)
    local star_bottom_res = string.format('card_star_yellow_01%02d.png', curr_grade)

    -- 프레임 생성
    result_card_ui:makeSprite('frameNode', frame_res)
    
    -- 획득 가능한 범주의 등급 표시
    -- 위
    result_card_ui:makeSprite('runeNumberNode', star_top_res) -- (lua_name, res, no_use_frames)
    result_card_ui.vars['runeNumberNode']:setPositionY(52) -- 하드코딩
    --result_card_ui.vars['runeNumberNode']:setScale(0.9) -- 하드코딩
    
    -- 아래
    result_card_ui:makeSprite('starNode', star_bottom_res) -- (lua_name, res, no_use_frames)
    --result_card_ui.vars['starNode']:setPositionY(-37) -- 하드코딩
    --result_card_ui.vars['starNode']:setScale(0.9) -- 하드코딩
    
    -- 룬 아이콘
    result_card_ui:makeSprite('runeNode', result_res, true) -- (lua_name, res, no_use_frames)
    result_card_ui.vars['runeNode']:setPositionY(0) -- 하드코딩
    
    -- 일단 검은 레이어 씌우고 모든 합성 재료 칸이 등록되면 벗겨주기
    local disable_res = 'card_cha_frame_disable.png'
    result_card_ui:setSpriteVisible('disableSprite', disable_res, true)

    self.vars['runeResultNode']:addChild(result_card_ui.root)
    self.vars['noneSelectSprite']:setVisible(false)
    self.m_resultCard = result_card_ui
end

-------------------------------------
-- function press_resultRuneBtn
-- @brief 합성 결과 카드 클릭할 때 
-------------------------------------
function UI_RuneForgeCombineItem:press_resultRuneBtn(curr_grade, success_grade)
    local str
    if (curr_grade == success_grade) then
        str =  Str('{@SKILL_NAME}{1}등급 룬 합성\n{@DEFAULT}랜덤한 {2}등급 룬을 얻을 수 있습니다.', curr_grade, success_grade)
    else
        str =  Str('{@SKILL_NAME}{1}등급 룬 합성\n{@DEFAULT}랜덤한 {2}~{3}등급 룬을 얻을 수 있습니다.', curr_grade, curr_grade, success_grade)
    end
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.m_resultCard.vars['clickBtn'])
end