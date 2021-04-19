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

UI_DmgateStageItem = class(PARENT, {
    m_data = 'table',
    m_targetData = 'table', -- 난이도가 나뉠 경우 여러 테이블 중 현재 적용중인 테이블 정보 혹은 id

    m_stageID = 'number',   -- stage button의 현재 id

    m_stageStatus = 'number',

    m_currDiffIndex = 'number', -- 현재 해당하는 난이도에 따른 m_data의 index 값



    -- Nodes in ui
    m_stageBtn = 'UIC_Button',                -- 스테이지 버튼
    m_lockVisual = 'AnimatorVrp',              -- 잠금 VRP
    m_bgVisual = 'AnimatorVrp',                -- 보스 배경 VRP
    m_stageNameText = 'UIC_LabelTTF',           -- 하단 스테이지 이름 텍스트
    m_stageLevelText = 'UIC_LabelTTF',          -- 상단 
    m_originStageLevelText = 'UIC_LabelTTF',    -- 상단 

    m_stageDiffLabel = 'UIC_LabelTTF',


    m_rewardBtn = 'UIC_Button',
    m_rewardVisual = 'AnimatorVrp',

    m_rewardLabel = 'UIC_LabelTTF',
    m_originRewardText = 'string',
})


-------------------------------------
-- function init
-- @brief virtual function of UI
-------------------------------------
function UI_DmgateStageItem:init(data) 
    local vars = self:load('dmgate_scene_item_top.ui')

    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @brief virtual function of UI
-------------------------------------
function UI_DmgateStageItem:initUI() 
    local stage_index = g_dmgateData:getStageID(self.m_stageID)
    self.m_stageLevelText:setString(Str(self.m_originStageLevelText, stage_index))

    self.m_stageNameText:setString(g_dmgateData:getStageName(self.m_stageID))
end


-------------------------------------
-- function initButton
-- @brief virtual function of UI
-------------------------------------
function UI_DmgateStageItem:initButton() 
    self.m_rewardBtn:registerScriptTapHandler(function() self:click_rewardBtn() end)
end


-------------------------------------
-- function refresh
-- @brief virtual function of UI
-------------------------------------
function UI_DmgateStageItem:refresh() 
    --self.root:setOpacity(0)
    
    --cca.reserveFunc(self.root, 0.1, function() self.root:runAction(cc.FadeIn:create(1)) end)
    self:refreshBackgroundVRP()

    self:refreshLockVRP()
    self:refreshRewardVRP()
end



-------------------------------------
-- function initMember
-- @brief virtual function of UI
-------------------------------------
function UI_DmgateStageItem:initMember(data) 
    local vars = self.vars
    self.m_data = data

    -- 언락된 난이도가 있으면 고정
    for key, data in pairs(self.m_data) do
        
        -- TODO : checkInUnlockList를 부를시 내용을 nil 처리 하기에 임시적으로 직접 리스트를 부름.
        if g_dmgateData.m_unlockStageList[tonumber(data['stage_id'])] then 
            self.m_currDiffIndex = key
        end
    end
    -- 언락된 난이도가 없으면 현재 도전 가능한 최고 난이도 설정
    if self.m_currDiffIndex == nil then
        self.m_currDiffIndex = g_dmgateData:getCurrDiffInList(self.m_data)
        -- 난이도가 0인경우 index를 위해 1로 고정
        -- TODO : 윗 라인에 or 1 을 하면 되지 않음?
        if(self.m_currDiffIndex == 0) then self.m_currDiffIndex = 1 end
    end

    self.m_targetData = self.m_data[self.m_currDiffIndex]


    -- update member data depend on the clear status of stage
    self.m_stageID = self.m_targetData['stage_id']
    self.m_stageStatus =  g_dmgateData:getStageStatus(self.m_stageID)


    -- Nodes in .ui file
    self.m_stageBtn = vars['stageBtn']
    self.m_lockVisual = vars['lockVisual']
    self.m_bgVisual = vars['bgVisual']
    self.m_stageNameText = vars['stageLabel']
    self.m_stageLevelText = vars['stageLevelLabel']
    self.m_originStageLevelText = self.m_stageLevelText:getString()


    self.m_stageDiffLabel = vars['stageDiffLabel']
    self.m_stageDiffLabel:setVisible(false)

    self.m_rewardBtn = vars['rewardBtn']
    self.m_rewardVisual = vars['rewardVisual']   
    self.m_rewardLabel = vars['rewardLabel']
    self.m_originRewardText = self.m_rewardLabel:getString()
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  TEMP (NEED TO REFACTORING)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////\


----------------------------------------------------------------------
-- function setBackgroundVRP
----------------------------------------------------------------------
function UI_DmgateStageItem:refreshBackgroundVRP()
    local stage_id = g_dmgateData:getStageID(self.m_stageID)
    self.m_bgVisual:changeAni('dmgate_0' .. tostring(stage_id))
end

----------------------------------------------------------------------
-- function setLockVRP
----------------------------------------------------------------------
function UI_DmgateStageItem:refreshLockVRP()
    -- is it locked ?
    if (g_dmgateData:isStageOpened(self.m_stageID) == false)
        or (g_dmgateData:checkStageTime(self.m_stageID) == false) then

        self.m_lockVisual:setVisible(true)
        self.m_lockVisual:changeAni('dmgate_lock')
        self.m_stageBtn:setEnabled(false)
    
        -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()     
        --     self.m_lockVisual:setVisible(true)
        --     self.m_lockVisual:changeAni('dmgate_lock')
        --     self.m_stageBtn:setEnabled(false)
        -- end)))
    
    else -- opened
        if g_dmgateData:checkInUnlockList(self.m_stageID) then
            self.m_lockVisual:setVisible(true)
            self.m_lockVisual:changeAni('dmgate_lock')
            self.m_lockVisual:addAniHandler(function() self.m_lockVisual:changeAni('dmgate_unlock', false) end)
        end
    end
end

----------------------------------------------------------------------
-- function setRewardVRP
----------------------------------------------------------------------
function UI_DmgateStageItem:refreshRewardVRP() 
   
    local status = 0
    local stage_id
    local rewardNum = 0
    for key, data in pairs(self.m_data) do
        stage_id = data['stage_id']

        if g_dmgateData:isStageOpened(stage_id) then
            if g_dmgateData:hasStageReward(stage_id) then 
                status = g_dmgateData:getStageStatus(stage_id)
            end
            
            if g_dmgateData:isStageCleared(stage_id) then
                rewardNum = rewardNum + 1
            end
        else break end
    end

    if (status == 0) and (rewardNum == #self.m_data) then
        status = 2
    end


    self.m_rewardVisual:changeAni('dmgate_box_' .. tostring(status), true)

    self.m_stageStatus = status

    if #self.m_data > 1 then
        self.m_rewardLabel:setString(Str(self.m_originRewardText, rewardNum, #self.m_data))
    else
        self.m_rewardLabel:setVisible(false)
    end
end


----------------------------------------------------------------------
-- function click_rewardBtn
----------------------------------------------------------------------
function UI_DmgateStageItem:click_rewardBtn()
    if(self.m_stageStatus == 1) then 
        local function finish_cb(ret)
            if(ret['added_items']) then
                g_serverData:receiveReward(ret)
                self:refresh()
            else
                UIManager:toastNotificationRed('수령할 수 있는 아이템이 없습니다.')
            end
            
        end

        g_dmgateData:request_reward(self.m_stageID, finish_cb)
    else
        UI_DmgateRewardBtnPopup(self.m_data)
    end
end


----------------------------------------------------------------------
-- function getStageID
----------------------------------------------------------------------
function UI_DmgateStageItem:getStageID()
    return self.m_stageID
end

----------------------------------------------------------------------
-- function set
----------------------------------------------------------------------
function UI_DmgateStageItem:setStageID(stage_id)
    -- TODO (YOUNGJIN) : MAKE ERROR CONDITION FOR SAFETY
    self.m_currDiffIndex = g_dmgateData:getDifficultyID(stage_id)
    if (self.m_currDiffIndex == 0) then self.m_currDiffIndex = 1 end
    
    self.m_targetData = self.m_data[self.m_currDiffIndex]

    -- update member data depend on the clear status of stage
    self.m_stageID = self.m_targetData['stage_id']
    self.m_stageStatus =  g_dmgateData:getStageStatus(self.m_stageID)
end