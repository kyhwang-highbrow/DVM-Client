local PARENT = UI

local MIN_NICK = 2
local MAX_NICK = 10

-------------------------------------
-- class UI_StartTamerSelect
-------------------------------------
UI_StartTamerSelect = class(PARENT,{
        m_mStartTamerInfo = 'map',
        m_tamerRadioButton = 'UIC_RadioButton',

        m_nSelIdx = 'number',
        m_tamerItemList = 'list',
        m_cbSelectTamer = 'function',

        -- 사전등록 닉네임
        m_preOccupancyCode = 'string',
        m_preOccupancyNick = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_StartTamerSelect:init(select_callback)
    local vars = self:load('tamer_select.ui')
    UIManager:open(self, UIManager.SCENE)

    SoundMgr:playBGM('bgm_title')
    SoundMgr.m_bStopPreload = true

    self.m_nSelIdx = 1
    self.m_mStartTamerInfo = g_startTamerData:getData()
    self.m_cbSelectTamer = select_callback

    -- 씬 전환 효과
    self:sceneFadeInAction()

	self:initUI()
    self:initButton()
    self:initEditBox()
    self:initSpine()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StartTamerSelect:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StartTamerSelect:initButton()
    local vars = self.vars
    local tamer_info = self.m_mStartTamerInfo

    self.m_tamerItemList = {}
    local tamer_table = TableTamer()
    for idx, v in ipairs(tamer_info) do
        local t_tamer = tamer_table:get(v['tamer_id'])
        local new = true
        local tamer_item = UI_TamerManageItem(t_tamer, new)
		tamer_item.vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn(tamer_item, idx) end)
        vars['profileNode' .. idx]:addChild(tamer_item.root)

        if idx == self.m_nSelIdx then tamer_item:selectTamer(true) end
        table.insert(self.m_tamerItemList, tamer_item)
    end

    vars['couponBtn']:registerScriptTapHandler(function() self:click_nicknameCouponBtn() end)
    vars['createBtn']:registerScriptTapHandler(function() self:click_createBtn() end)
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_StartTamerSelect:initEditBox()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            local editbox = pSender
            local str = editbox:getText()
			local len = uc_len(str)

            local is_name = true
            if (len < MIN_NICK) or (len > MAX_NICK) or (not IsValidText(str, is_name)) then
                editbox:setText('')

                local msg = Str('닉네임은 한글, 영어, 숫자를 사용하여 최소{1}자부터 최대 {2}자까지 생성할 수 있습니다. \n \n 특수문자, 한자, 비속어는 사용할 수 없으며, 중간에 띄어쓰기를 할 수 없습니다.', MIN_NICK, MAX_NICK)
                MakeSimplePopup(POPUP_TYPE.OK, msg)
                return
            end
        end
    end

    vars['editBox']:setMaxLength(MAX_NICK)
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function initSpine
-- @brief 미리 스파인 모두 생성 (캐싱)
-------------------------------------
function UI_StartTamerSelect:initSpine()
    local tamer_info = self.m_mStartTamerInfo
    for idx = #tamer_info, 1, -1 do
        self.m_nSelIdx = idx
        self:showTamerInfo()
    end
end

-------------------------------------
-- function showTamerInfo
-------------------------------------
function UI_StartTamerSelect:showTamerInfo()
    local vars = self.vars
    local tamer_info = self.m_mStartTamerInfo

    local idx = self.m_nSelIdx
    local tid = tamer_info[idx]['tamer_id']

    -- 3마리 보여줄지 1마리 보여줄지 미정 (현재는 1마리만)
    local did = tamer_info[idx]['dragon_ids'][1]

    self:setDragonAni(did)
    self:setTamerAni(tid)
    self:setSkillIcon(tid)
end


-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_StartTamerSelect:click_tamerBtn(tamer_item, idx)
    if self.m_nSelIdx == idx then return end
    for _i, v in ipairs(self.m_tamerItemList) do
        if _i == idx then 
            v:selectTamer(true)
        else
            v:selectTamer(false)
        end
    end
    self.m_nSelIdx = idx
    self:showTamerInfo()
end

-------------------------------------
-- function setDragonAni
-------------------------------------
function UI_StartTamerSelect:setDragonAni(did)
    local vars = self.vars
    local ani_dragon = AnimatorHelper:makeDragonAnimator_usingDid(did)
    vars['dragonNode']:removeAllChildren()
	vars['dragonNode']:addChild(ani_dragon.m_node)
end

-------------------------------------
-- function setTamerAni
-------------------------------------
function UI_StartTamerSelect:setTamerAni(tid)
    local vars = self.vars
    local t_tamer = TableTamer():get(tid)
    local ani_tamer = AnimatorHelper:makeTamerAnimator(t_tamer['res'])
    vars['tamerNode']:removeAllChildren()
	vars['tamerNode']:addChild(ani_tamer.m_node)

    vars['tamerLabel']:setString(t_tamer['t_name'])
    vars['infoLabel']:setString(t_tamer['t_desc'])
end

-------------------------------------
-- function setSkillIcon
-------------------------------------
function UI_StartTamerSelect:setSkillIcon(tid)
    local vars = self.vars
    local t_tamer = TableTamer():get(tid)
	local skill_mgr = MakeTamerSkillManager(t_tamer)
	local l_skill_icon = skill_mgr:getDragonSkillIconList_NoLv()

	for i = 1, 3 do 
		local skill_icon = l_skill_icon[i]
		if (skill_icon) then
			vars['skillNode' .. i]:removeAllChildren()
			vars['skillNode' .. i]:addChild(skill_icon.root)
		end
	end
end

-------------------------------------
-- function click_nicknameCouponBtn
-- @brief 사전 등록 닉네임
-------------------------------------
function UI_StartTamerSelect:click_nicknameCouponBtn()
    local ui = UI_CouponPopupPreOccupancyNick()

    local function close_cb()
        if (ui.m_couponCode and ui.m_retNick) then
            self.m_preOccupancyCode = ui.m_couponCode
            self.m_preOccupancyNick = ui.m_retNick
            self.vars['editBox']:setText(self.m_preOccupancyNick)
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_createBtn
-- @brief 계정 생성
-------------------------------------
function UI_StartTamerSelect:click_createBtn()
    local vars = self.vars
    local tamer_info = self.m_mStartTamerInfo
    local idx = self.m_nSelIdx
    local user_type = tamer_info[idx]['user_type']
    local nick = vars['editBox']:getText()

    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('사용 할 닉네임을 입력하세요.'))
        return
    end

    -- 사전등록 닉네임을 받아놓고 닉네임을 변경한 경우 code를 nil처리
    if (self.m_preOccupancyCode) and (nick ~= self.m_preOccupancyNick) then
        self.m_preOccupancyCode = nil
    end

    local finish_cb = self.m_cbSelectTamer
    g_startTamerData:request_createAccount(user_type, self.m_preOccupancyCode, nick, finish_cb)
end
