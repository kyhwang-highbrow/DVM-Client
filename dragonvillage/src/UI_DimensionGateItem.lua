local PARENT = class(UI, ITableViewCell:getCloneTable())

-- {
--     ['level']=5;
--     ['dm_id']=3010000;
--     ['reset_unlock']=0;
--     ['condition_stage_id']=3012104;
--     ['start_date']=20213115;
--     ['reset_reward']=1;
--     ['end_date']=29211231;
--     ['type']=2;
--     ['item']='700901;10';
--     ['stage_id']=3012105;
--     ['grade']=1;
-- };
-- };
-- {
-- {
--     ['level']=5;
--     ['dm_id']=3010000;
--     ['reset_unlock']=0;
--     ['condition_stage_id']=3012204;
--     ['start_date']=20213115;
--     ['reset_reward']=1;
--     ['end_date']=29211231;
--     ['type']=2;
--     ['item']='700901;10';
--     ['stage_id']=3012205;
--     ['grade']=2;
-- };
-- };
-- {
-- {
--     ['level']=5;
--     ['dm_id']=3010000;
--     ['reset_unlock']=0;
--     ['condition_stage_id']=3012304;
--     ['start_date']=20213115;
--     ['reset_reward']=1;
--     ['end_date']=29211231;
--     ['type']=2;
--     ['item']='700901;10';
--     ['stage_id']=3012305;
--     ['grade']=3;
-- };

UI_DimensionGateItem = class(PARENT, {
    m_data = '',
    m_targetData = '', -- 난이도가 나뉠 경우 여러 테이블 중 현재 적용중인 테이블 정보 혹은 id

    m_stageID = 'number',
    m_mode = 'number',      --
    m_chapter = 'number',   -- 

    m_hasDifficulty = 'boolean',
    m_currDifficultyLevel = 'number',



    -- Nodes in ui
    m_stageBtn = '',
    m_lockVisual = '',
    m_bgVisual = '',
    m_stageNameText = '',
    m_stageLevelText = '',
    m_originStageLevelText = '',

    
    m_entireStar = '',
    m_starSprites = '',


    m_rewardBtn = '',
    m_rewardVisual = '',
})


-------------------------------------
-- function init
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:init(data) 
    local vars = self:load('dmgate_scene_item_top.ui')

    self:initMember(data)

    -- 1. 마누사냐 다른 용 모드냐

    -- 2. 챕터가 하위층이냐 상위층이냐

    -- 3. 스테이지가 몇번이냐(bgVisual)

    -- 4. 스테이지가 열려있냐 안열려있냐

    -- 5. 스테이지 난이도가 무엇이냐

    -- 6. 스테이지 보상을 받았냐 안받았냐

    
    





    self:initUI()
end

-------------------------------------
-- function initUI
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:initUI() 
    local stage_id = g_dimensionGateData:getStageID(self.m_stageID)
    self.m_stageLevelText:setString(Str(self.m_originStageLevelText, stage_id))

    self:setStarSprites()
    self:setBackgroundVRP()
    --self:setLockVRP()
end


-------------------------------------
-- function initButton
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:initButton() end


-------------------------------------
-- function refresh
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:refresh() 
    self.root:setOpacity(0)
    self.root:runAction(cc.FadeIn:create(1))
end



-------------------------------------
-- function initMember
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:initMember(data) 
    local vars = self.vars

    self.m_data = data

    self.m_hasDifficulty = (#data > 0)
    self.m_currDifficultyLevel = g_dimensionGateData:getMaxDifficultyInList(DIMENSION_GATE_MANUS, self.m_data)

    if self.m_hasDifficulty then
        self.m_targetData = self.m_data[self.m_currDifficultyLevel]
    else
        self.m_targetData = self.m_data
    end
    -- update member data depend on the clear status of stage
    self.m_stageID = self.m_targetData['stage_id']
    self.m_mode = g_dimensionGateData:getModeID(self.m_stageID)
    self.m_chapter = g_dimensionGateData:getChapterID(self.m_stageID)


    -- Nodes in .ui file
    self.m_stageBtn = vars['stageBtn']
    self.m_lockVisual = vars['lockVisual']
    self.m_bgVisual = vars['bgVisual']
    self.m_stageNameText = vars['stageLabel']
    self.m_stageLevelText = vars['stageLevelLabel']
    self.m_originStageLevelText = self.m_stageLevelText:getString()

    self.m_entireStar = vars['starMenu']
    self.m_starSprites = {}
    table.insert(self.m_starSprites, vars['starSprite1'])
    table.insert(self.m_starSprites, vars['starSprite2'])
    table.insert(self.m_starSprites, vars['starSprite3'])

    self.m_rewardBtn = vars['rewardBtn']
    self.m_rewardVisual = vars['rewardVisual']   

end





function UI_DimensionGateItem:setLockVisual(isLocked)

end

function UI_DimensionGateItem:setRewardVisual()

end

function UI_DimensionGateItem:setDifficulty(diff_level)

end




function GetNameContainsString(target, str)
    if #target > 0 then

    else

    end
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  TEMP (NEED TO REFACTORING)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////\
function UI_DimensionGateItem:setStarSprites()
    -- 레벨이 있는가?
    if self.m_hasDifficulty == false then
        self.m_entireStar:setVisible(false)
        return
    end

    -- 현재 난이도가 몇인가?
    local level = self.m_currDifficultyLevel
    for index, starSprite in pairs(self.m_starSprites) do
        if index <= level then
            starSprite:setVisible(true)
        else
            starSprite:setVisible(false)
        end
    end

    -- 클리어 했는가?
end


function UI_DimensionGateItem:setBackgroundVRP()
    local stage_id = g_dimensionGateData:getStageID(self.m_stageID)
    self.m_bgVisual:changeAni('dmgate_0' .. tostring(stage_id))
end

function UI_DimensionGateItem:setLockVRP()
    -- is it locked ?
    if g_dimensionGateData:isStageOpen(self.m_mode, self.m_stageID) ==  false then
        self.m_lockVisual:setVisible(true)
        self.m_lockVisual:changeAni('dmgate_lock')
        self.m_stageBtn:setEnabled(false)
    else -- opened
        self.m_lockVisual:setVisible(true)
        self.m_lockVisual:changeAni('dmgate_unlock')
        self.m_stageBtn:setEnabled(true)
    end
end



function UI_DimensionGateItem:setRewardVRP()

end
