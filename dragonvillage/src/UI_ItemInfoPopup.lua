local PARENT = UI

-------------------------------------
-- class UI_ItemInfoPopup
-------------------------------------
UI_ItemInfoPopup = class(PARENT,{
        m_itemID = 'number',
        m_itemCount = 'number',
        m_tSubData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemInfoPopup:init(item_id, count, t_sub_data)
    self.m_itemID = item_id
    self.m_itemCount = count
    self.m_tSubData = t_sub_data

    local vars = self:load('item_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ItemInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ItemInfoPopup:initUI()
    local vars = self.vars

    local type = TableItem:getItemType(self.m_itemID)

    
    -- 아이템명 출력
    if (type == 'rune') and self.m_tSubData then
        vars['titleLabel']:setString(self.m_tSubData['name'])
    else
        
        local item_name = TableItem:getItemName(self.m_itemID)
        vars['titleLabel']:setString(item_name)
    end
    

    do -- 아이템 아이콘    
        if (type == 'dragon') and self.m_tSubData then
            local item_card = UI_DragonCard(self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)

		elseif (type == 'rune') and self.m_tSubData then
            local item_card = UI_RuneCard(self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)

            -- 만약 장착 중인 룬인 경우 장착한 드래곤 카드 추가
            if (self.m_tSubData['owner_doid'] ~= nil) then
                local doid = self.m_tSubData['owner_doid']
                local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
                local dragon_card = UI_DragonCard(dragon_obj)
                vars['dragonNode']:addChild(dragon_card.root)
                vars['dragonNode']:setVisible(true)
            end

        else
            local item_card = UI_ItemCard(self.m_itemID, self.m_itemCount, self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)
            item_card:unregisterScriptPressHandler()
        end
    end

    -- 아이템 설명
    local desc = ''
    if (type == 'rune') and self.m_tSubData then
        -- 룬일 경우
        local t_rune_data = self.m_tSubData
        
        -- 옵션 라벨 UI를 로드한다
        local opt_label = t_rune_data:getOptionLabel()
        self.vars['runeDscNode']:addChild(opt_label.root)
        self.vars['runeDscNode']:setVisible(true)
        
        -- 해당 UI를 옵션정보로 채운다 
        t_rune_data:setOptionLabel(opt_label, 'use', nil) -- param : ui, label_format, target_level
    else
        desc = TableItem():getValue(self.m_itemID, 't_desc')
    end
    vars['itemDscLabel']:setString(Str(desc))

    -- 룬 세트 옵션 설명
    if (type == 'rune') then
        -- 임시 룬 오브젝트를 생성 (룬 세트 설명 함수를 사용하기 위해)
        local _data = {}
        _data['rid'] = self.m_itemID
        local _struct_rune_obj = StructRuneObject(_data)
        
        -- 룬 세트 설명 출력
        vars['itemDscNode2']:setVisible(true)
        local str = _struct_rune_obj:makeRuneSetDescRichText() or ''
        vars['itemDscLabel2']:setString(str)
    end

    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)

    -- 획득 장소가 없다면 버튼을 꺼버린다.
    local l_region = UI_AcquisitionRegionInformation:makeRegionList(self.m_itemID)
    if (table.count(l_region) == 0) then
        vars['locationBtn']:setVisible(false)
        vars['okBtn']:setVisible(true)
    end
end

-------------------------------------
-- function showItemInfoPopupOkBtn
-- @brief 특정 경우 (우편함에서 받았을 경우)
--        "획득 장소"버튼은 끄고 "확인"버튼만 띄우도록 처리
-------------------------------------
function UI_ItemInfoPopup:showItemInfoPopupOkBtn()
    local vars = self.vars

    if vars['locationBtn'] then
        vars['locationBtn']:setVisible(false)
    end

    if vars['okBtn'] then
        vars['okBtn']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['locationBtn']:registerScriptTapHandler(function() self:click_locationBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ItemInfoPopup:refresh()
end

-------------------------------------
-- function click_locationBtn
-------------------------------------
function UI_ItemInfoPopup:click_locationBtn()
    local item_id = self.m_itemID
    UI_AcquisitionRegionInformation:create(item_id)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ItemInfoPopup:click_okBtn()
    self:close()
end







function MakeSimpleRewarPopup(title_str, item_id, count, t_sub_data)
    local ui = UI_ItemInfoPopup(item_id, count, t_sub_data)
    ui.vars['titleLabel']:setString(title_str)
    ui.vars['locationBtn']:setVisible(false)
    ui.vars['closeBtn']:setPositionX(0)
    return ui
end

--@CHECK
UI:checkCompileError(UI_ItemInfoPopup)
