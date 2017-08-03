-------------------------------------
-- class SceneAdventure
-------------------------------------
SceneAdventure = class(PerpleScene, {
        m_startStageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneAdventure:init(start_stage_id)
    -- @TODO sgkim 넘어온 stage_id가 오픈되어있는지 검증할 필요가 있음
    self.m_startStageID = start_stage_id
	
	self.m_bUseLoadingUI = false
	--self.m_loadingGuideType = 'all'
    --self.m_loadingUIDuration = 0.3
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneAdventure:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_dungeon_ready')
	
    local ui = nil

	-- self.m_bUseLoadingUI가 false라면 prepare가 동작하지 않으므로 별도로 선언
	if (not self.m_bUseLoadingUI) then
		if self.m_startStageID then
			local stage_id = self.m_startStageID
			ui = UI_AdventureSceneNew(stage_id)
            local with_friend = true
			UI_ReadyScene(stage_id, with_friend)
		else
			ui = UI_AdventureSceneNew()
		end
	end

	-- ui안에서는 close처리만 하고 close콜백으로 로비 씬을 호출
    local function func()
        local is_use_loading = false
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end

    ui:setCloseCB(func)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneAdventure:prepare()
	self:addLoading(function()
		if self.m_startStageID then
			local stage_id = self.m_startStageID
			UI_AdventureSceneNew(stage_id)
            local with_friend = true
			UI_ReadyScene(stage_id, with_friend)
		else
			UI_AdventureSceneNew()
		end
	end)
end