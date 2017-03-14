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
function LevelupDirector_GameResult:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade)
    local l_max_exp = nil

    -- 타입에 따른 테이블 얻어옴
    if (type == 'tamer') then
        l_max_exp = LevelupDirector:getTamerExpList()
    elseif (type == 'dragon') then
        l_max_exp = LevelupDirector:getDragonExpList(grade)
    else
        error('type : ' .. type)
    end

    -- LevelupDirector 생성
    self.m_levelupDirector = LevelupDirector(src_lv, src_exp, dest_lv, dest_exp, l_max_exp)

    -- Update 콜백 등록
    self.m_levelupDirector.m_cbUpdate = function(lv, exp, percentage)
        local lv_str = Str('Lv.{1}', lv)
        self.m_lvLabel:setString(lv_str)

        local exp_str = Str('{1} %', percentage)
        self.m_expLabel:setString(exp_str)

        self.m_expGauge:setPercentage(percentage)
    end

    -- LevelUp 콜백 등록
    self.m_levelupDirector.m_cbLevelUp = function()
        SoundMgr:playEffect('EFFECT', 'dragon_levelup')
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

    self.m_lvLabel:stopAllActions()
    self.m_lvLabel:runAction(tween_action)
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