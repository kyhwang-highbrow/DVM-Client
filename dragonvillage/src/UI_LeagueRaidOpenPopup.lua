-------------------------------------
-- class UI_LeagueRaidRankItem
-------------------------------------
UI_LeagueRaidOpenPopup = class(UI,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidOpenPopup:init(owner_ui)
    local vars = self:load('league_raid_season_open_popup.ui')

    self.m_uiName = 'UI_LeagueRaidOpenPopup'
    UIManager:open(self, UIManager.POPUP)
    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidOpenPopup:initUI()
    local vars = self.vars
    local stage_id, season = g_leagueRaidData:getStageIdAndSeason()
    local is_boss_stage, monster_id = g_stageData:isBossStage(stage_id)

    if (vars['seasonLabel']) then vars['seasonLabel']:setString(Str('SEASON {1}', season)) end
 
    -- 몬스터
    do

        local res =  TableMonster():getMonsterRes(monster_id)
        local attr = TableMonster():getValue(monster_id, 'attr')

        local animator = AnimatorHelper:makeMonsterAnimator(res, attr)
        animator:changeAni('idle', true)
        vars['bossNode']:addChild(animator.m_node)

        -- 도굴꾼 싸이즈 임시로 0.5 미래에는 몬스터 스케일 조정 가능하게 뭔가 조치를 취해야 한다
        if (monster_id == 138001) then
            animator.m_node:setScale(0.5)
        end
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidOpenPopup:initButton()
    local vars = self.vars

    if (vars['closeBtn']) then vars['closeBtn']:registerScriptTapHandler(function() self:close() end) end
    if (vars['joinBtn']) then vars['joinBtn']:registerScriptTapHandler(function() self:close() UINavigator:goTo('league_raid') end) end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidOpenPopup:refresh()
end

