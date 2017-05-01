print('----------------------------------------------------------------------------')
print('[StandAlone]')
print('----------------------------------------------------------------------------')

--arc
--ccdump(package.path)

--package.path = package.path .. ';../src'

require 'Table'

ccdump(arg)

function isWin32()
    return true
end


--TABLE:init()

while (true) do
    io.write("Press <Enter> to continue...")
    local command = io.read()

    if (command == 'help') then
        print(' いしflksdfjsdlkfjsdf')
        print(' いしflksdfjsdlkfjsdf')
        print(' いしflksdfjsdlkfjsdf')
        print(' いしflksdfjsdlkfjsdf')
        print(' いしflksdfjsdlkfjsdf')

    elseif (command == 'exit') then
        break
    end
end


--[[
io.write("Press <Enter> to continue...")
io.read()
--]]
