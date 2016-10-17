
--------------------------------
-- @module AzVisual
-- @extend Node

--------------------------------
-- @function [parent=#AzVisual] isRepeat 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] enableDrawShapeInfo 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] enableDrawSocketInfo 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] isEndAnimation 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] getSocketNode 
-- @param self
-- @param #string str
-- @return Node#Node ret (return value: cc.Node)
        
--------------------------------
-- @function [parent=#AzVisual] getVisualName 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- @function [parent=#AzVisual] bindSocket 
-- @param self
-- @param #string str
-- @param #string str
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] setRepeat 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] initEventShapeList 
-- @param self
        
--------------------------------
-- @function [parent=#AzVisual] buildEventShapeID 
-- @param self
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] setAdditiveColor 
-- @param self
-- @param #color3b_table color3b
        
--------------------------------
-- @function [parent=#AzVisual] getVisualGroupName 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- overload function: setVisual(string, string)
--          
-- overload function: setVisual(int, int)
--          
-- overload function: setVisual(string)
--          
-- @function [parent=#AzVisual] setVisual
-- @param self
-- @param #int int
-- @param #int int
-- @return bool#bool ret (retunr value: bool)

--------------------------------
-- @function [parent=#AzVisual] setSpriteSubstitution 
-- @param self
-- @param #string str
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVisual] getValidRect 
-- @param self
-- @return rect_table#rect_table ret (return value: rect_table)
        
--------------------------------
-- @function [parent=#AzVisual] bindVisual 
-- @param self
-- @param #string str
-- @param #string str
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] getDuration 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- @function [parent=#AzVisual] buildSprite 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVisual] releaseSprite 
-- @param self
        
--------------------------------
-- @function [parent=#AzVisual] buildPhysicBody 
-- @param self
        
--------------------------------
-- @function [parent=#AzVisual] getShapeCount 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- @function [parent=#AzVisual] loadPlistFiles 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVisual] setFrame 
-- @param self
-- @param #float float
        
--------------------------------
-- @function [parent=#AzVisual] queryEventShape 
-- @param self
-- @param #float float
        
--------------------------------
-- @function [parent=#AzVisual] setFile 
-- @param self
-- @param #string str
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] enableDrawVisibleRect 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] removeUnusedCache 
-- @param self
        
--------------------------------
-- overload function: create(string)
--          
-- overload function: create()
--          
-- @function [parent=#AzVisual] create
-- @param self
-- @param #string str
-- @return AzVisual#AzVisual ret (retunr value: cc.AzVisual)

--------------------------------
-- @function [parent=#AzVisual] removeCache 
-- @param self
-- @param #string str
        
--------------------------------
-- @function [parent=#AzVisual] removeCacheAll 
-- @param self
        
--------------------------------
-- @function [parent=#AzVisual] draw 
-- @param self
-- @param #cc.Renderer renderer
-- @param #cc.Mat4 mat4
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] isOpacityModifyRGB 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- @function [parent=#AzVisual] onExit 
-- @param self
        
--------------------------------
-- @function [parent=#AzVisual] setOpacityModifyRGB 
-- @param self
-- @param #bool bool
        
--------------------------------
-- @function [parent=#AzVisual] update 
-- @param self
-- @param #float float
        
--------------------------------
-- @function [parent=#AzVisual] onEnter 
-- @param self
        
return nil
