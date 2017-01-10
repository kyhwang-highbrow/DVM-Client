local t_module = {
    'Cocos2d',
    'Cocos2dConstants',
    'lib/net',
    'lib/class',
    'lib/utils',
    'lib/StringUtils',
    'lib/Translate',
    'lib/scheduler',
    'lib/SocketTCP',
    'lib/math',
    'lib/Radian',
    'uilib/UIManager',
    'uilib/UI',
    'uilib/UILoader',
    'uilib/TableView',
    'uilib/Notification',
    'perpleLib/StringUtils',
    'perpleLib/sn',
    'perpleLib/crand',
    'perpleLib/PerpleScene',
    'perpleLib/PerpleScene',
    'fixed_constant',
    'Constant',
    'ConstantForArt',
	'ConstantIngame',
    'ConstantDragonEvolution',
    'ConstantDragonGrade',
    'ConstantAttribute',
    'ConstantString',
    'SoundMgr',
    'SoundMgrController',
    'SoundMgrProtected',
    'PatchData',
    'PatchCore',

    -- Util
    'Action',
    'TimeLib',
    'Table',
    'TableClass',
    'ResPreloadHelper',
    'ResPreloadMgr',
    'RichLabel',
    'NumberLabel',
    'LevelupDirector',
    'LevelupDirector_GameResult',
    'MapManager',
    'ServerData',
    'ServerData_User',
    'ServerData_Dragons',
    'ServerData_Deck',
    'ServerData_Staminas',
    'ServerData_NestDungeon',
    'ServerData_Stage',
    'ServerData_LobbyUserList',
    'ServerData_AutoPlaySetting',
    'UserData',
    'DropHelper',
    'DragonAutoSetHelper',
    'DragonSkillManager',
    'DragonSkillIndivisualInfo',
    'SumRandom',
    'ValidationAssistant',
    'Counter',
    'Stopwatch',
    'Camera',
    'CameraTouchHandler',
    'Camera_Lobby',
    'CameraTouchHandler_Lobby',
    'Camera_LobbySwipe',
    'ValidationDragon',
    'TableViewExtension',
    'StatusEffectHelper',
    'AreaOfEffectHelper',
    'ShaderCache',
    'DragonSortManager',
    'SimplePrimitivesDraw',

    -- Table
    'TableStageDesc',
    'TableDragon',
    'TableMonster',
    'TableDragonSkill',
    'TableFriendship',
    'TableFruit',
    'TableUserLevel',
    'TableDragonTrainInfo',
    'TableDragonTrainStatus',
    'TableDrop',

    -- Interface
    'IEventDispatcher',
    'IStateHelper',
    'ITopUserInfo_EventListener',
    'ITabUI',

    -- Scene
    'SceneCommon',
    'SceneLogo',
    'ScenePatch',
    'SceneTitle',
    'SceneLobby',
    'SceneDV',
    'SceneGame',
    'SceneAdventure',
    'SceneNestDungeon',

    -- Phys
	'PhysWorld',
    'PhysObject',

	-- Animator
    'Animator',
    'AnimatorPng',
    'AnimatorSpine',
    'AnimatorVrp',

	-- Entity GameWorld
    'Entity',
    'GameWorld',
    'GameWorld_Touch',
    'GameWorld_Formation',
    'GameWorld_Unit',
    'GameState',
    'GameState_NestDungeon',
    'GameState_NestDungeon_Dragon',
    'GameState_NestDungeon_Nightmare',
    'GameState_NestDungeon_Tree',
    'GameState_Colosseum',
    'GameAuto',
    'GameFever',
    'GameCamera',
    'GameTimeScale',
	'ShakeManager',
    
	-- TAMER
	'TamerSpeechSystem',
    'TamerSkillSystem',
    'TamerSkillCut',
	'TamerSkillManager',

    -- MAP
    'ScrollMap',
    'ScrollMapLayer',
    'AnimationMap',
    	
	-- MISSILE
	'Missile',
    'MissileBoomerang',
    'MissileCurve',
    'MissileDrop',
    'MissileDropGuid',
    'MissileDropRandom',
    'MissileDropTarget',
    'MissileDropZigzag',
    'MissileGuid',
    'MissileGuidTarget',
    'MissileTarget',
    'MissileZigzag',
    'MissileEffecter',
    'MissileLua',
    'MissileBounce',
    'MissileFix',
    'require_MissileLua',
    'LaserMissile',

	-- CHARACTER
	'Character',
    'CharacterEvent',
    'CharacterState',
    'CharacterSkill',
    'CharacterStateDelegate',
    'Dragon',
    'Monster',
    'MonsterLua_Boss',
    'Monster_GiantDragon',
    'Monster_Tree',
	'Monster_WorldOrderMachine',
    'require_EnemyLua',
    'EnemyMovement',
    'MissileFactory',
    'MissileLauncher',
    
	-- COMMON MISSILE (공통탄)
	'CommonMissile',
	'CommonMissile_Straight',
	'CommonMissile_Cruise',
	'CommonMissile_Shotgun',
	'CommonMissile_Release',
	'CommonMissile_High',
	'CommonMissile_Bounce',

	-- STATUS EFFECT
	'StatusEffect',
    'StatusEffect_Trigger',
	'StatusEffect_Trigger_Release',
    'StatusEffect_PassiveSpatter',
	'StatusEffect_CheckWorld',
	'StatusEffect_Heal',
	'StatusEffect_DotDmg',
	'StatusEffect_addAttack',
    'StatusEffect_Protection',
	'StatusEffect_Silence',
	
	'StatusEffectIcon',

	-- EFFECT
	'EffectLink',
	'EffectHeal',
    'EffectBezierLink',
    'EffectLinearDot',
    
	-- SKILL HELPER
	'SkillHitEffectDirector',

    -- SKILL    
	'Skill',
	'SkillRay',
    'SkillLaser',
	'SkillLaser_Lightning',
	'SkillChainLightning',
	'SkillThrowBuff',
	'SkillProtection',
    'SkillGuardian',
    'SkillHealSingle',
    'SkillHealAround',
    'SkillShield',
    'SkillAttributeAmor',
    'SkillMeleeHack',
	'SkillMeleeHack_Specific',
    'SkillHealingWind',
    'SkillCrash',
    'SkillLeafBlade',
    'SkillSummon',
	'SkillDispelMagic',
    'SkillSpatter',
	'SkillAoERound',
	'SkillLeap',
	'SkillExplosion',
	'SkillConicAtk',
	'SkillConicAtk_Spread',
	'SkillRolling',
	'SkillAddAttack',
	'SkillCounterAttack',
	'SkillSpiderWeb',
	'SkillBurst',
	'SkillFieldCheck',

    -- SKILL INDICATOR
    'SkillIndicatorMgr',
    'SkillIndicator',
    'SkillIndicator_Laser',
    'SkillIndicator_Range',
    'SkillIndicator_Target',
    'SkillIndicator_HealingWind',
    'SkillIndicator_Crash',
    'SkillIndicator_LeafBlade',
	'SkillIndicator_AoERound',
	'SkillIndicator_Conic',
	'SkillIndicator_ConicSpread',
    
	-- BUFF
	'Buff',
    'Buff_Protection',
    
	-- TAMER SPECAIL SKILL
	'TamerSpecialSkillCombination',

	'WaveMgr',
    'DynamicWave',
    'ActivityCarrier',

    -- UIC (UI Component)
    'UIC_Node',
    'UIC_Button',
    'UIC_CheckBox',
    'UIC_ClippingNode',
    'UIC_TableView',
    'UIC_TableViewCell',
    'UIC_TableViewTD',
    'UIC_RadioButton',

	-- UI
    'UI_BlockPopup',
    'UI_Network',
    'UI_NetworkLoading',
    'UI_TitleScene',
    'UI_TitleSceneLoading',
    'UI_LobbyNew',
    'UI_LobbyOld',
    'UI_Lobby',
    'LobbyMapSpotMgr',
    'LobbyMap',
    'LobbyCharacter',
    'LobbyTamer',
    'LobbyTamerBot',
    'LobbyDragon',
    'LobbyShadow',
    'LobbyUserStatusUI',
    'LobbyItemBox',
    'UI_Game',
    'UI_GameResultNew',
    'UI_GameResult_NestDungeon',
    'UI_GamePause',
    'UI_GamePause_NestDungeon',
    'UI_GameDebug',
	'UI_GameDebug_RealTime',
    'UI_ReadyScene',
    'UI_ReadyScene_Deck',
    'UI_AdventureSceneNew',
    'UI_AdventureChapterSelectPopup',
    'UI_AdventureChapterButton',
    'UI_AdventureStageButton',
    'UI_AdventureFirstRewardPopup',
    'UI_AdventureStageInfo',
    'UI_IngameUnitInfo',
    'UI_IngameDragonInfo',
    'UI_IngameBossInfo',
    'UI_Popup',
    'UI_SimplePopup',
    'UI_SimpleDragonInfoPopup',
    'UI_DragonDetailPopup',
    'UI_Tooltip',
	'UI_Tooltip_Indicator',
    'UI_TopUserInfo',
    'UI_ShopPopup',
    'UI_ItemCard',
    'UI_ProductButton',
    'UI_SkillCard',
    'UI_DragonSkillCard',
    'UI_Tooltip_Skill',
    'UI_DragonGachaResult',
    'UI_GuidePopup',
    'UI_NestDungeonScene',
    'UI_NestDungeonListItem',
    'UI_NestDungeonStageListItem',
    'UI_EditBoxPopup',
    'UI_SettingPopup',
    'UI_SettingPopup_Dev',
    'UI_DragonDevApiPopup',
    'UI_InvenDevApiPopup',
    'UI_MonsterCard',
    'UI_FruitFeedPress',
    'UI_LobbyUserInfoPopup',
    'UI_UserDeckInfoPopup',
    'UI_AutoPlaySettingPopup',

    -- UI 드래곤 관리 관련
    'UI_DragonManage_Base',
    'UI_DragonManageInfo',
    'UI_DragonManageInfoView',
    'UI_DragonManageUpgrade',
    'UI_DragonManageUpgradeResult',
    'UI_DragonManagementEvolution',
    'UI_DragonManageEvolutionResult',
    'UI_DragonManagementFriendship',
    'UI_DragonManageFriendshipResult',
    'UI_DragonManageTrain',
    'UI_DragonTrainSlot_ListItem',
    'UI_CharacterCard',
    'UI_SkillDetailPopup',
    'UI_DragonGoodbye',   
    'UI_LobbyObject', 

    'DamageCalc',
    'IconHelper',
    'AnimatorHelper',
    'FormationMgr',
    'FormationMgr_TargetRule',
    'StatusCalculator',
    'StatusCalculatorFormula',
    'ObjectGold',
    'ObjectCharge',

    'DragonCard',
    'TriggerHpPercent',
    'TriggerTime',
    'EffectTimer',

    -- Data
    'DataAdventure',

    -- Network
    'Network',
    'NetworkLocalServer',
}

-------------------------------------
-- function loadModule
-------------------------------------
function loadModule()
    for i,v in ipairs(t_module) do
        require(v)
    end

    require 'socket'
end

-------------------------------------
-- function reloadModule
-------------------------------------
function reloadModule()
    print('#############################')
    print('## reloadModule() start    ##')

    for i,v in ipairs(t_module) do
        if (v ~= 'SoundMgr') and (v ~= 'uilib/UIManager') and (v ~= 'uilib/UILoader')
            and (v ~= 'uilib/TableView') then
            package.loaded[v] = nil
            require(v)
        end
    end

    TABLE:init()
    print('## reloadModule() end      ##')
    print('#############################')
end