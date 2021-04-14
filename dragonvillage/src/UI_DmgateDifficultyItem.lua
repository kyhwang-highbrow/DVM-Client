local PARENT = class(UI, ITableViewCell:getCloneTable())

-- ['level']=2;
-- ['dm_id']=3010000;
-- ['reset_unlock']=0;
-- ['condition_stage_id']=3012201;
-- ['start_date']=20213115;
-- ['reset_reward']=1;
-- ['end_date']=29211231;
-- ['type']=2;
-- ['item']='700901;10';
-- ['stage_id']=3012202;
-- ['grade']=2;

----------------------------------------------------------------------
-- class UI_DmgateDifficultyItem
----------------------------------------------------------------------
UI_DmgateDifficultyItem = class(PARENT, {
    m_data = 'table',

    m_stageId = 'number',
    m_currDifficultyLevel = 'number',


    -- nodes in ui file
    m_selectedBtn = 'UIC_Button',
    m_stageLabel = 'UIC_LabelTTF',

    m_lockSprite = 'Animator', -- 자물쇠
    m_completeSprite = 'Animator', -- 스테이지 클리어
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:init(data)
    local vars = self:load('dmgate_scene_stage_item.ui')
    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initMember(data)
    local vars = self.vars

    self.m_data = data
    
    self:setStageID(self.m_data['stage_id'])

    -- nodes in ui file
    self.m_selectedBtn = vars['selectedBtn']
    self.m_stageLabel = vars['stageLabel']
    self.m_lockSprite = vars['lockSprite']
    self.m_completeSprite = vars['completeSprite']
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initUI()
    self.m_stageLabel:setString(g_dmgateData:getStageDiffText(self.m_stageId))
    self.m_stageLabel:setTextColor(g_dmgateData:getStageDiffTextColor(self.m_stageId))
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:initButton()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:refresh()
    if g_dmgateData:isStageCleared(self.m_stageId) then
        self.m_completeSprite:setVisible(true)
    else
        self.m_completeSprite:setVisible(false)
    end

    self:refreshLockSprite()
end

----------------------------------------------------------------------
-- function refreshLockSprite
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:refreshLockSprite()
    local isStageOpened = g_dmgateData:isStageOpened(self.m_stageId) and g_dmgateData:checkStageTime(self.m_stageId)

    self.m_lockSprite:setVisible(not isStageOpened)
    self.m_selectedBtn:setEnabled(isStageOpened)
end

-------------------------------------------------------------
---------
-- function set
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:getStageID()
    return self.m_stageId
end

----------------------------------------------------------------------
-- function set
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:setStageID(stage_id)
    self.m_stageId = stage_id
    self.m_currDifficultyLevel = g_dmgateData:getDifficultyID(self.m_stageId)
end


----------------------------------------------------------------------
-- function is
----------------------------------------------------------------------
function UI_DmgateDifficultyItem:isStageLocked()
    return not self.m_lockSprite:isVisible()
end