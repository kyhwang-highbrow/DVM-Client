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
    'Table',
    'TableClass',
    'RichLabel',
    'NumberLabel',
    'LevelupDirector',
    'LevelupDirector_GameResult',
    'MapManager',
    'ScrollMap',
    'ScrollMapLayer',
    'AnimationMap',
    'ServerData',
    'ServerData_User',
    'ServerData_Dragons',
    'ServerData_Deck',
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

    -- Table
    'TableStageDesc',
    'TableDragon',
    'TableMonster',
    'TableDragonSkill',
    'TableFriendship',
    'TableFruit',

    -- Interface
    'IEventDispatcher',
    'ITopUserInfo_EventListener',

    -- Scene
    'SceneCommon',
    'SceneLogo',
    'ScenePatch',
    'SceneTitle',
    'SceneLobby',
    'SceneDV',
    'SceneGame',
    'SceneAdventure',

    -- Phys
	'PhysWorld',
    'PhysObject',

    'Animator',
    'AnimatorPng',
    'AnimatorSpine',
    'AnimatorVrp',

    'Entity',
    'GameWorld',
    'GameWorld_Touch',
    'GameWorld_Formation',
    'GameState',
    'GameFever',
    'GameCamera',
    'GameTimeScale',
    'TamerSpeechSystem',
    'TamerSkillSystem',
    'TamerSkillCut',
	'TamerSkillManager',

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

	'Character',
    'CharacterEvent',
    'CharacterState',
    'CharacterSkill',
    'CharacterStateDelegate',
    'Hero',
    'Enemy',
    'EnemyLua',
    'EnemyLua_Boss',
    'Monster_GiantDragon',
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
	
	'StatusEffectIcon',

	-- EFFECT
	'LinkEffect',
	'EffectHeal',
    'EffectBezierLink',
    'EffectLinearDot',
    
	-- SKILL HELPER
	'SkillHitEffectDirector',

    -- SKILL    
	'Skill',
	'SkillRay',
    'SkillLaser',
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
	'SkillExplosion',
	'SkillConicAtk',
	'SkillConicAtk_Spread',
	'SkillRolling',
	'SkillAddAttack',
	'SkillCounterAttack',

    -- SKILL INDICATOR
    'SkillIndicatorMgr',
    'SkillIndicator',
    'SkillIndicator_Tamer',
    'SkillIndicator_laser',
    'SkillIndicator_Range',
    'SkillIndicator_Target',
	'SkillIndicator_OppositeTarget',
    'SkillIndicator_HealingWind',
    'SkillIndicator_Crash',
    'SkillIndicator_LeafBlade',
	'SkillIndicator_AoERound',
	'SkillIndicator_Conic',
	'SkillIndicator_ConicSpread',
    
	-- BUFF
	'Buff',
    'Buff_Protection',
	'Buff_Barrier',
    
	-- TAMER SPECAIL SKILL
	'TamerSpecialSkillCombination',

	'WaveMgr',
    'DynamicWave',
    'ActivityCarrier',

	-- UI
    'UI_BlockPopup',
    'UI_Network',
    'UI_NetworkLoading',
    'UI_TitleScene',
    'UI_TitleSceneLoading',
    'UI_LobbyNew',
    'UI_Lobby',
    'UI_Game',
    'UI_GameResultNew',
    'UI_GamePause',
    'UI_GameDebug',
    'UI_ReadyScene',
    'UI_ReadyScene_Deck',
    'UI_AdventureSceneNew',
    'UI_AdventureChapterSelectPopup',
    'UI_AdventureChapterButton',
    'UI_AdventureStageButton',
    'UI_AdventureFirstRewardPopup',
    'UI_AdventureStageInfo',
    'UI_IngameDragonInfo',
    'UI_IngameUnitInfo',
    'UI_Popup',
    'UI_SimplePopup',
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
    'UI_NestDragonDungeonListItem',
    'UI_NestDungeonStageSelectPopup',
    'UI_EditBoxPopup',
    'UI_SettingPopup',
    'UI_SettingPopup_Dev',
    'UI_DragonDevApiPopup',
    'UI_InvenDevApiPopup',
    'UI_MonsterCard',
    'UI_FruitFeedPress',

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
    'UI_CharacterCard',
    'UI_SkillDetailPopup',

    -- UIC (UI Component)
    'UIC_Node',
    'UIC_Button',

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
    'EffectTimer',

    -- Data
    'DataAdventure',
    'DataStamina',

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