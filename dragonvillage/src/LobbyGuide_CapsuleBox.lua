local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_CapsuleBox
-------------------------------------
LobbyGuide_CapsuleBox = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_CapsuleBox:init()
end

-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_CapsuleBox:startCustomGuide()
    g_capsuleBoxData:openCapsuleBoxUI(true)
end

return LobbyGuide_CapsuleBox