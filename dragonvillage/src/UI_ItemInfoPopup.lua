local PARENT = UI

-------------------------------------
-- class UI_ItemInfoPopup
-------------------------------------
UI_ItemInfoPopup = class(PARENT,{
        m_itemID = 'number',
        m_itemCount = 'number',
        m_tSubData = 'table',

        m_itemType = 'string',

        m_tItemCard = 'UI_Card', -- 룬 카드 메모 갱신을 위해 추가
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemInfoPopup:init(item_id, count, t_sub_data)
    self.m_itemID = item_id
    self.m_itemCount = count
    self.m_tSubData = t_sub_data

    self.m_uiName = 'UI_ItemInfoPopup'
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

    self.m_itemType = TableItem:getItemType(self.m_itemID)

    
    -- 아이템명 출력
    if (self.m_itemType == 'rune') and self.m_tSubData then
        vars['titleLabel']:setString(self.m_tSubData['name'])
    else
        local item_name = TableItem:getItemName(self.m_itemID)
        vars['titleLabel']:setString(item_name)
    end

    local is_lockBtn_visible = (self.m_itemType == 'dragon') or (self.m_itemType == 'rune')

    if is_lockBtn_visible then
        vars['lockBtn']:setVisible(is_lockBtn_visible)

        self:setLockSprite(self.m_tSubData:getLock())
    end
    

    do -- 아이템 아이콘    
        if (self.m_itemType == 'dragon') and self.m_tSubData then
            local item_card = UI_DragonCard(self.m_tSubData)
            vars['itemNode']:addChild(item_card.root)

		elseif (self.m_itemType == 'rune') and self.m_tSubData then
            local item_card = UI_RuneCard(self.m_tSubData)
            self.m_tItemCard = item_card
            vars['itemNode']:addChild(item_card.root)
            item_card:unregisterScriptPressHandler()

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
    if (self.m_itemType == 'rune') and self.m_tSubData then
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
    if (self.m_itemType == 'rune') then
        -- 임시 룬 오브젝트를 생성 (룬 세트 설명 함수를 사용하기 위해)
        local _data = {}
        _data['rid'] = self.m_itemID
        local _struct_rune_obj = StructRuneObject(_data)
        
        -- 룬 세트 설명 출력
        vars['itemDscNode2']:setVisible(true)
        local str = _struct_rune_obj:makeRuneSetDescRichText() or ''
        vars['itemDscLabel2']:setString(str)

        if (self.m_tSubData) then
            local t_rune_data = self.m_tSubData
            local roid = t_rune_data['roid']

            self:refresh_memoLabel(roid)
        end
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

    vars['lockBtn']:registerScriptTapHandler(function() self:click_lockBtn() end)

    if (self.m_itemType == 'rune') then
        -- 룬 메모
        if (self.m_tSubData) then
            local t_rune_data = self.m_tSubData
            local rune_memo = g_runeMemoData:getMemo(t_rune_data['roid'])
            -- 메모가 있는 경우 바로 메모 창을 보여주고
            if (rune_memo ~= nil) then
                vars['useMemoBtn']:setVisible(false)
                vars['useMemoMenu']:setVisible(true)
                self:refresh_memoLabel(t_rune_data['roid'])
            -- 없는 경우에는 세트 효과창을 보여준다.
            else
                vars['useMemoBtn']:setVisible(true)
                vars['useMemoMenu']:setVisible(false)
                self:refresh_memoLabel(t_rune_data['roid'])
            end

            -- 룬 관련
            vars['useSetBtn']:registerScriptTapHandler(function() self:click_setBtn() end) -- 세트 효과 보기
            vars['useMemoBtn']:registerScriptTapHandler(function() self:click_memoBtn() end) -- 메모 보기

            vars['useMemoEditBtn']:registerScriptTapHandler(function() self:click_memoEditBtn() end)

	        -- editBox handler 등록
	        local function editBoxTextEventHandle(strEventName, pSender)
                if (strEventName == "return") then
                    local t_rune_data = self.m_tSubData
                    if (t_rune_data == nil) then
                        return
                    end
            
                    local roid = t_rune_data['roid']

			        -- 키보드 입력이 종료될 때 텍스트 검증을 한다.
                    local text = vars['useMemoEditBox']:getText()
                    local context, is_valid = g_runeMemoData:validateMemoText(text)
                    if (not is_valid) then
                        self:refresh_memoLabel(roid)
                        return
                    end

			        local function proceed_func()
                        local t_rune_data = self.m_tSubData
                        if (t_rune_data) then
			                g_runeMemoData:modifyMemo(roid, context)
			                g_runeMemoData:saveRuneMemoMap()
                            self:refresh_memoLabel(roid)
                        end
                    end

			        local function cancel_func()
                        self:refresh_memoLabel(roid)
			        end
			
			        -- 비속어 필터링
                    CheckBlockStr(context, proceed_func, cancel_func)
                end
            end
            vars['useMemoEditBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
            vars['useMemoEditBox']:setMaxLength(RUNE_MEMO_MAX_LENGTH)
        end
    end
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

-----------------------------
-- function click_setBtn
-- @brief 세트 효과 보기 버튼
-------------------------------------
function UI_ItemInfoPopup:click_setBtn()
    local vars = self.vars

    vars['useMemoMenu']:setVisible(false)
    vars['useMemoBtn']:setVisible(true)
end

-------------------------------------
-- function click_memoBtn
-- @brief 메모 보기 버튼
-------------------------------------
function UI_ItemInfoPopup:click_memoBtn()
    local vars = self.vars

    vars['useMemoMenu']:setVisible(true)
    vars['useMemoBtn']:setVisible(false)
end

-------------------------------------
-- function click_memoEditBtn
-- @brief 메모 수정 버튼
-------------------------------------
function UI_ItemInfoPopup:click_memoEditBtn()
    local vars = self.vars

    local t_rune_data = self.m_tSubData
    if (t_rune_data == nil) then
        return
    end
            
    local roid = t_rune_data['roid']
    local memo = g_runeMemoData:getMemo(roid) or ''
    
    vars['useMemoEditBox']:setText(memo)    
    vars['useMemoEditBox']:openKeyboard()
end

-------------------------------------
-- function click_lockBtn
-------------------------------------
function UI_ItemInfoPopup:click_lockBtn()
    local vars = self.vars

    if (self.m_itemType ~= 'rune') and (self.m_itemType ~= 'dragon') then 
        return 
    end

    local objectId = self.m_tSubData:getObjectId()
    local is_locked = (not self.m_tSubData:getLock())

    local function callback_function(ret)
        vars['lockSprite']:setVisible(is_locked)
    
        if (self.m_itemType == 'rune') then
            self.m_tSubData = g_runesData:getRuneObject(objectId)
        else --if (self.m_itemType == 'dragon') then
            self.m_tSubData = g_dragonsData:getDragonDataFromDoid(objectId)
        end
        
		-- 잠금 안내 팝업
		local msg = is_locked and Str('잠금되었습니다.') or Str('잠금이 해제되었습니다.')
		UIManager:toastNotificationGreen(msg)

        self.m_tItemCard:setRuneLock(self.m_tSubData:getLock())
        self:setLockSprite(self.m_tSubData:getLock())
    end

    if (self.m_itemType == 'rune') then
        local owner_oid = self.m_tSubData:getOwnerObjId()
        g_runesData:request_runesLock(objectId, owner_oid, is_locked, callback_function)
    else --if (self.m_itemType == 'dragon') then
        g_dragonsData:request_dragonLock(objectId, '', is_locked, callback_function)
    end
end

-------------------------------------
-- function refresh_memoLabel
-- @brief 메모 라벨 텍스트 refresh
-------------------------------------
function UI_ItemInfoPopup:refresh_memoLabel(roid)
    local vars = self.vars
    local str = g_runeMemoData:getMemo(roid)

    if (str ~= nil) then
        vars['useMemoLabel']:setString(str)
        vars['useMemoEditBox']:setText('')
    else
        vars['useMemoLabel']:setString(Str('메모를 입력해주세요. (최대 40자)'))
        vars['useMemoEditBox']:setText('')
    end

    -- 룬 카드에 메모 아이콘 리프레시
    local select_card = self.m_tItemCard
    if (select_card) then
        select_card:refresh_memo()
    end
end

-------------------------------------
-- function isRuneLock
-------------------------------------
function UI_ItemInfoPopup:isRuneLock()
    return self.m_tSubData:getLock()
end
-------------------------------------
-- function setLockSprite
-------------------------------------
function UI_ItemInfoPopup:setLockSprite(is_locked)
    self.vars['lockSprite']:setVisible(is_locked)
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
