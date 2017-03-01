-------------------------------------
-- class ServerData_Adventure
-------------------------------------
ServerData_Adventure = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Adventure:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToAdventureScene
-------------------------------------
function ServerData_Adventure:goToAdventureScene(stage_id)
    local scene = SceneAdventure(stage_id)
    scene:runScene()
end