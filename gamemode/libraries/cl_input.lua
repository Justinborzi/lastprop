local vgui, gui = vgui, gui

lps = lps or {}

INPUT = {
    MOUSE = 1,
    KEY = 2
}

lps.input = lps.input or {
    keys = {
        {KEY_BACKSPACE,     8,   false, 'BACKSPACE'},
        {KEY_TAB,           9,   false, 'TAB'},
        {KEY_ENTER,         13,  false, 'ENTER'},
        {KEY_PAD_ENTER,     13,  false, 'NUM ENTER'},
        {KEY_LSHIFT,        13,  false, 'L SHIFT'},
        {KEY_RSHIFT,        13,  false, 'R SHIFT'},
        {KEY_LCONTROL,      17,  false, 'L CTRL'},
        {KEY_RCONTROL,      17,  false, 'R CTRL'},
        {KEY_LALT,          18,  false, 'L ALT'},
        {KEY_RALT,          18,  false, 'R ALT'},
        -- Pause/Break, 19
        {KEY_CAPSLOCK,      20,  false, 'CAPS'},
        {KEY_ESCAPE,        27,  false, 'ESC'},
        {KEY_PAGEUP,        33,  false, 'PG UP'},
        {KEY_SPACE,         32,  false, 'SPACE'},
        {KEY_PAGEDOWN,      34,  false, 'PG DOWN'},
        {KEY_END,           35,  false, 'END'},
        -- Home, 36
        {KEY_LEFT,          37,  false, 'LEFT'},
        {KEY_UP,            38,  false, 'UP'},
        {KEY_RIGHT,         39,  false, 'RIGHT'},
        {KEY_DOWN,          40,  false, 'DOWN'},
        {KEY_INSERT,        45,  false, 'INSERT'},
        {KEY_DELETE,        46,  false, 'DEL'},
        {KEY_0,             48,  false, '0'},
        {KEY_1,             49,  false, '1'},
        {KEY_2,             50,  false, '2'},
        {KEY_3,             51,  false, '3'},
        {KEY_4,             52,  false, '4'},
        {KEY_5,             53,  false, '5'},
        {KEY_6,             54,  false, '6'},
        {KEY_7,             55,  false, '7'},
        {KEY_8,             56,  false, '8'},
        {KEY_9,             57,  false, '9'},
        {KEY_A,             65,  false, 'A'},
        {KEY_B,             66,  false, 'B'},
        {KEY_C,             67,  false, 'C'},
        {KEY_D,             68,  false, 'D'},
        {KEY_E,             69,  false, 'E'},
        {KEY_F,             70,  false, 'F'},
        {KEY_G,             71,  false, 'G'},
        {KEY_H,             72,  false, 'H'},
        {KEY_I,             73,  false, 'I'},
        {KEY_J,             74,  false, 'J'},
        {KEY_K,             75,  false, 'K'},
        {KEY_L,             76,  false, 'L'},
        {KEY_M,             77,  false, 'M'},
        {KEY_N,             78,  false, 'N'},
        {KEY_O,             79,  false, 'O'},
        {KEY_P,             80,  false, 'P'},
        {KEY_Q,             81,  false, 'Q'},
        {KEY_R,             82,  false, 'R'},
        {KEY_S,             83,  false, 'S'},
        {KEY_T,             84,  false, 'T'},
        {KEY_U,             85,  false, 'U'},
        {KEY_V,             86,  false, 'V'},
        {KEY_W,             87,  false, 'W'},
        {KEY_X,             88,  false, 'X'},
        {KEY_Y,             89,  false, 'Y'},
        {KEY_Z,             90,  false, 'Z'},
        -- Select, 93
        {KEY_PAD_0,         96,  false, 'PAD 0'},
        {KEY_PAD_1,         97,  false, 'PAD 1'},
        {KEY_PAD_2,         98,  false, 'PAD 2'},
        {KEY_PAD_3,         99,  false, 'PAD 3'},
        {KEY_PAD_4,         100, false, 'PAD 4'},
        {KEY_PAD_5,         101, false, 'PAD 5'},
        {KEY_PAD_6,         102, false, 'PAD 6'},
        {KEY_PAD_7,         103, false, 'PAD 7'},
        {KEY_PAD_8,         104, false, 'PAD 8'},
        {KEY_PAD_9,         105, false, 'PAD 9'},
        {KEY_PAD_MULTIPLY,  105, false, 'PAD *'},
        {KEY_PAD_PLUS,      107, false, 'PAD +'},
        {KEY_PAD_MINUS,     109, false, 'PAD -'},
        {KEY_PAD_DECIMAL,   110, false, 'PAD .'},
        {KEY_PAD_DIVIDE,    111, false, 'PAD /'},
        {KEY_F1,            112, false, 'F1'},
        {KEY_F2,            113, false, 'F2'},
        {KEY_F3,            114, false, 'F3'},
        {KEY_F4,            115, false, 'F4'},
        {KEY_F5,            116, false, 'F5'},
        {KEY_F6,            117, false, 'F6'},
        {KEY_F7,            118, false, 'F7'},
        {KEY_F8,            119, false, 'F8'},
        {KEY_F9,            120, false, 'F9'},
        {KEY_F10,           121, false, 'F10'},
        {KEY_F11,           122, false, 'F11'},
        {KEY_F12,           123, false, 'F12'},
        {KEY_NUMLOCK,       144, false, 'NUM LK'},
        {KEY_SCROLLLOCK,    145, false, 'SCRL LK'},
        {KEY_SEMICOLON,     186, false, ''},
        {KEY_EQUAL,         187, false, '='},
        {KEY_COMMA,         188, false, ','},
        -- Dash, 189
        {KEY_PERIOD,        190, false, '.'},
        {KEY_SLASH,         0,   false, '/'},
        {KEY_LBRACKET,      219, false, '['},
        {KEY_BACKSLASH,     220, false, '\\'},
        {KEY_RBRACKET,      221, false, ']'},
        {KEY_BACKQUOTE,     222, false, '\''},
        {KEY_APOSTROPHE,    222, false, '\''}
    },
    mice = {
        {MOUSE_LEFT,       1001, false, 'L MOUSE'},
        {MOUSE_RIGHT,      1001, false, 'R MOUSE'},
        {MOUSE_MIDDLE,     1001, false, 'M MOUSE'},
        {MOUSE_4,          1001, false, 'MOUSE 4'},
        {MOUSE_5,          1001, false, 'MOUSE 5'},
        {MOUSE_WHEEL_UP,   1001, false, 'MOUSE WU'},
        {MOUSE_WHEEL_DOWN, 1001, false, 'MOUSE WD'},
        {MOUSE_COUNT,      1001, false, 'MOUSE C'}
    }

}

--[[---------------------------------------------------------
--   Name: lps.input:CheckKeys()
---------------------------------------------------------]]--
function lps.input:CheckKeys()

    local busy = self:IsBusy()
    local cursor = vgui.CursorVisible()

    for i=1, #self.keys do
        if (input.IsKeyDown(self.keys[i][1]) and self.keys[i][3] == false) then
            safecall(function() hook.Call('KeyDown', GAMEMODE, self.keys[i][1], self.keys[i][2], self.keys[i][4], INPUT.KEY, busy, cursor) end)
            self.keys[i][3] = true
        end

        if (not input.IsKeyDown(self.keys[i][1]) and self.keys[i][3] == true) then
            safecall(function() hook.Call('KeyUp', GAMEMODE, self.keys[i][1], self.keys[i][2], self.keys[i][4], INPUT.KEY, busy, cursor) end)
            self.keys[i][3] = false
        end
    end

    for i=1, #self.mice do
        if (input.IsMouseDown(self.mice[i][1]) and self.mice[i][3] == false) then
            safecall(function() hook.Call('KeyDown', GAMEMODE, self.mice[i][1], self.mice[i][2], self.mice[i][4], INPUT.MOUSE, busy, cursor) end)
            self.mice[i][3] = true
        end

        if (not input.IsMouseDown(self.mice[i][1]) and self.mice[i][3] == true) then
            safecall(function() hook.Call('KeyUp', GAMEMODE, self.mice[i][1], self.mice[i][2], self.mice[i][4], INPUT.MOUSE, busy, cursor) end)
            self.mice[i][3] = false
        end
    end

end

--[[---------------------------------------------------------
--   Name: lps.input:IsBusy()
---------------------------------------------------------]]--
function lps.input:IsBusy()
    local busy = hook.Call('IsBusy', GAMEMODE)
    if (not busy) then
        busy = ((gui.IsGameUIVisible()) or (gui.IsConsoleVisible()))
    end
    return busy
end

--[[---------------------------------------------------------
--   Name: lps.input:KeyData()
---------------------------------------------------------]]--
function lps.input:KeyData(key, keytype)
    if (keytype == INPUT.MOUSE) then
        for i=1, #self.mice do
            if(self.mice[i][1] == key) then return self.mice[i] end
        end
    else
        for i=1, #self.keys do
            if(self.keys[i][1] == key) then return self.keys[i] end
        end
    end
    return false
end

--[[---------------------------------------------------------
--   Hook: input:CheckKeys
---------------------------------------------------------]]--
hook.Add('Think', 'input:CheckKeys', function()
    lps.input:CheckKeys()
end)

--[[---------------------------------------------------------
--   Hook: StartChat:IsBusy
---------------------------------------------------------]]--
hook.Add('StartChat', 'StartChat:IsBusy', function()
    hook.Add('IsBusy', 'IsBusy:Chat', function() return true end)
end)

--[[---------------------------------------------------------
--   Hook: FinishChat:IsBusy
---------------------------------------------------------]]--
hook.Add('FinishChat', 'FinishChat:IsBusy', function()
    hook.Remove('IsBusy', 'IsBusy:Chat')
end)