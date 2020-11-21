-------------------------------------
-- class LevelupDirector_GameResult
-------------------------------------
LevelupDirector_GameResult = class({
        m_lvLabel = 'cc.LabelTTF',
        m_expLabel = 'cc.LabelTTF',
        m_maxIcon = 'cc.Sprite',
        m_expGauge = 'cc.Progress',
        m_levelUpVrp = 'cc.AzVRP',

        m_levelupDirector = 'LevelupDirector',

        m_cbFirstLevelup = 'function',
        m_cbAniFinish = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function LevelupDirector_GameResult:init(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp)
    self.m_lvLabel = lv_label
    self.m_expLabel = exp_label
    self.m_maxIcon = max_icon
    self.m_expGauge = exp_gauge
    self.m_levelUpVrp = level_up_vrp
end

-------------------------------------
-- function initLevelupDirector
-------------------------------------
function LevelupDirector_GameResult:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade, rlv, mlv)
    local l_max_exp = nil
    local max_lv = nil
	local rlv = rlv or 0
	local mlv = mlv or 0

    -- LevelupDirector 생성
    self.m_levelupDirector = LevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade)

    -- Update 콜백 등록
    self.m_levelupDirector.m_cbUpdate = function(lv, exp, percentage)
        local lv_str
        if (mlv > 0) then
            lv_str = string.format('{@white}Lv.%d {@light_green}+%d{@light_blue}+%d', lv, rlv, mlv)
		elseif (rlv > 0) then
			lv_str = string.format('{@white}Lv.%d {@light_green}+%d', lv, rlv)
		else
			lv_str = string.format('Lv.%d', lv)
		end
        self.m_lvLabel:setString(lv_str)

        local exp_str = string.format('%.2f %%', percentage)
        self.m_expLabel:setString(exp_str)

        self.m_expGauge:setPercentage(percentage)
    end

    -- LevelUp 콜백 등록
    self.m_levelupDirector.m_cbLevelUp = function()
        self.m_levelUpVrp:setVisible(true)
        self.m_levelUpVrp:setVisual('group', 'level_up')
        self.m_levelUpVrp:registerScriptLoopHandler(function()
            self.m_levelUpVrp:setVisual('group', 'level_up_idle')
            self.m_levelUpVrp:setRepeat(true)
        end)

        -- 최초 레벨업 콜백
        if (self.m_cbFirstLevelup) then
            self.m_cbFirstLevelup()
            self.m_cbFirstLevelup = nil
        end
    end

    -- MaxLevel 콜백 등록
    self.m_levelupDirector.m_cbMaxLevel = function()
        self.m_maxIcon:setVisible(true)
        self.m_expLabel:setString('MAX')
    end
end

-------------------------------------
-- function start
-------------------------------------
function LevelupDirector_GameResult:start(duration)
    local duration = duration or 2
    local from = 0
    local to = self.m_levelupDirector.m_totalAddExp

    local function tween_cb(value, node)
        self.m_levelupDirector:update(value, node)
    end

    local tween_action = cc.ActionTweenForLua:create(duration, from, to, tween_cb)
    local callback = cc.CallFunc:create(function()
		if (self.m_cbAniFinish) then
            self.m_cbAniFinish()
            self.m_cbAniFinish = nil
        end
	end)

    local action = cc.Sequence:create(tween_action, callback)

    self.m_lvLabel:stopAllActions()
    self.m_lvLabel:runAction(action)
end

-------------------------------------
-- function stop
-------------------------------------
function LevelupDirector_GameResult:stop(force)
    self.m_lvLabel:stopAllActions()

    local value = self.m_levelupDirector.m_totalAddExp
    local node = self.m_lvLabel
    self.m_levelupDirector:update(value, node, force)
end