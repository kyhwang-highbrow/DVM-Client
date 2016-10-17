
--------------------------------
-- @module AzVRP
-- @extend Node

--------------------------------
-- @function [parent=#AzVRP] isRepeat 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVRP] setSpriteSubstitution 
-- @param self
-- @param #string str
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVRP] enableDrawShapeInfo 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVRP] enableDrawSocketInfo 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVRP] unregisterScriptSocketHandler 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] SetCheckValidRect 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVRP] isEndAnimation 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVRP] getSocketNode 
-- @param self
-- @param #string str
-- @return Node#Node ret (return value: cc.Node)
        
--------------------------------
-- @function [parent=#AzVRP] getVisualName 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- @function [parent=#AzVRP] getVisualIndex 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVRP] getEventShapeIndex 
-- @param self
-- @param #string str
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVRP] setRepeat 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVRP] getCurrentSocketEvent_Frame 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- @function [parent=#AzVRP] initEventShapeList 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] bindVRP 
-- @param self
-- @param #string str
-- @param #cc.AzVRP azvrp
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVRP] buildEventShapeID 
-- @param self
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVRP] getCurrentSocketEvent_Idx 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVRP] getVisualGroupName 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- overload function: setVisual(string)
--          
-- overload function: setVisual(string, string)
--          
-- overload function: setVisual(int)
--          
-- @function [parent=#AzVRP] setVisual
-- @param self
-- @param #string str
-- @param #string str
-- @return bool#bool ret (retunr value: bool)

--------------------------------
-- @function [parent=#AzVRP] registerScriptSocketHandler 
-- @param self
-- @param #int int
        
--------------------------------
-- @function [parent=#AzVRP] enableSocketHandler 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVRP] getCurrentSocketEvent_refIdx 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVRP] getEventShapeName 
-- @param self
-- @param #int int
-- @return char#char ret (return value: char)
        
--------------------------------
-- @function [parent=#AzVRP] getValidRect 
-- @param self
-- @return rect_table#rect_table ret (return value: rect_table)
        
--------------------------------
-- @function [parent=#AzVRP] getSocketIndex 
-- @param self
-- @param #string str
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVRP] buildPhysicBody 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] getDuration 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- @function [parent=#AzVRP] buildSprite 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVRP] clearSocketHandler 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] releaseSprite 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] getVisualListLuaTable 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- @function [parent=#AzVRP] initWithFile 
-- @param self
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVRP] loadPlistFiles 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVRP] setFrame 
-- @param self
-- @param #float float
        
--------------------------------
-- @function [parent=#AzVRP] getCurrentSocketEvent_ID 
-- @param self
-- @return char#char ret (return value: char)
        
--------------------------------
-- @function [parent=#AzVRP] queryEventShape 
-- @param self
-- @param #float float
        
--------------------------------
-- @function [parent=#AzVRP] getSocketName 
-- @param self
-- @param #int int
-- @return char#char ret (return value: char)
        
--------------------------------
-- @function [parent=#AzVRP] getCurrentSocketEvent_TM 
-- @param self
-- @return Mat4#Mat4 ret (return value: cc.Mat4)
        
--------------------------------
-- @function [parent=#AzVRP] removeUnusedCache 
-- @param self
        
--------------------------------
-- overload function: create(string)
--          
-- overload function: create()
--          
-- @function [parent=#AzVRP] create
-- @param self
-- @param #string str
-- @return AzVRP#AzVRP ret (retunr value: cc.AzVRP)

--------------------------------
-- @function [parent=#AzVRP] removeCache 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVRP] removeCacheAll 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] onEnter 
-- @param self
        
--------------------------------
-- @function [parent=#AzVRP] onExit 
-- @param self
        
return nil
