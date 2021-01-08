local PARENT = UI

-------------------------------------
-- class UI_UserLevelUp
-------------------------------------
UI_UserLevelUp = class(PARENT,{
        m_levelup_data = 'map',
    })

local AUTO_CLOSE_TIME = 3
local OPEN_CONTENT_TIME = 2.5

-------------------------------------
-- function init
-------------------------------------
function UI_UserLevelUp:init(t_levelup_data)
    local vars = self:load('user_levelup.ui')
    self.m_levelup_data = t_levelup_data
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserLevelUp')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserLevelUp:initUI()
    local vars = self.vars
    local t_levelup_data = self.m_levelup_data
    local prev_lv = t_levelup_data['prev_lv']
    local curr_lv = t_levelup_data['curr_lv']

    -- @adjust 
    do
        local check_lv_list = {15, 12, 10, 8, 6, 4}
        for _, lv in ipairs(check_lv_list) do
            if (curr_lv >= lv) then
                local key = Adjust.EVENT['TAMER_LV_'..tostring(lv)]
                if (key) then
                    Adjust:trackEvent(key)
                end                
                break
            end
        end
    end

    -- 레벨 
    do
        local label = cc.Label:createWithBMFont('res/font/level_font.fnt', '')
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setAdditionalKerning(0)
        vars['levelNode']:addChild(label)
        label:setString(tostring(curr_lv))

        cca.stampShakeAction(label)
    end

    -- 활동력
    do
        local numbering_time = 0.3
        local before_label = vars['beforeLabel']
        before_label = NumberLabel(before_label, 0, numbering_time)

        local after_label = vars['afterLabel']
        after_label = NumberLabel(after_label, 0, numbering_time)

        local bonus_label = vars['bonusLabel']
        bonus_label = NumberLabel(bonus_label, 0, numbering_time)

        local reward_label = vars['rewardLabel']
        reward_label = NumberLabel(reward_label, 0, numbering_time)

        local table_exp_tamer = TABLE:get('exp_tamer')
        local prev_stamina = table_exp_tamer[prev_lv]['max_stamina']
        local curr_stamina = table_exp_tamer[curr_lv]['max_stamina']

        -- 스태미나 선물
        local st_gift = TableUserLevel():getStaminaGift(prev_lv, curr_lv)

        before_label:setNumber(prev_stamina)
        after_label:setNumber(curr_stamina)
        reward_label:setNumber(st_gift)

        -- 증가분인지 회복량인지 미정. 혹은 삭제 될 수 있음
        local add_stamina = curr_stamina - prev_stamina
        bonus_label:setNumber(add_stamina)
    end

    -- 컨텐츠 오픈 팝업
    local function open_content_popup(content_type)
        UI_ContentOpenPopup(content_type)
    end

    -- 연속전투, 컨텐츠 오픈 체크 액션
    do
        local delay1 = cc.DelayTime:create(0.5)
	    local check_open = cc.CallFunc:create(function()
            for lv = prev_lv + 1, curr_lv do
                local content_type = g_contentLockData:getOpenContentNameWithLv(lv)
                if (content_type) then
                    open_content_popup(content_type)
                    break
                end
            end
	    end)

        local delay2 = cc.DelayTime:create(AUTO_CLOSE_TIME)
        local check_auto = cc.CallFunc:create(function()
            -- 연속전투일 경우에는 자동으로 닫힘
            if (g_autoPlaySetting:isAutoPlay()) then
		        self:close()
            end
	    end)

		--cca.runAction(self.root, cc.Sequence:create(delay1, check_open, delay2, check_auto))
	    cca.runAction(self.root, cc.Sequence:create(delay2, check_auto))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserLevelUp:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserLevelUp:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_UserLevelUp:click_okBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_UserLevelUp)
