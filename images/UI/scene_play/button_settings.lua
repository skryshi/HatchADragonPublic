--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:751d0b9921fe4d5879d4119f8ed7edf0:1/1$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- button_settings_exit
            x=54,
            y=54,
            width=50,
            height=50,

        },
        {
            -- button_settings_exit_pressed
            x=54,
            y=2,
            width=50,
            height=50,

        },
        {
            -- button_settings_sound
            x=2,
            y=54,
            width=50,
            height=50,

        },
        {
            -- button_settings_sound_pressed
            x=2,
            y=2,
            width=50,
            height=50,

        },
    },
    
    sheetContentWidth = 128,
    sheetContentHeight = 128
}

SheetInfo.frameIndex =
{

    ["button_settings_exit"] = 1,
    ["button_settings_exit_pressed"] = 2,
    ["button_settings_sound"] = 3,
    ["button_settings_sound_pressed"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
