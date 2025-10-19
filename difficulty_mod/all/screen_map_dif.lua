local screen_map = require("screen_map")
local S = require("sound_db")
local i18n = require("i18n")
local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end
local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end
local function CJK(default, zh, ja, kr)
    return i18n:cjk(default, zh, ja, kr)
end
local IS_KR3 = KR_GAME == "kr3"

OptionsDifficultyView = class("OptionsDifficultyView", PopUpView)

function OptionsDifficultyView:initialize(sw, sh)
    PopUpView.initialize(self, V.v(sw, sh))

    self.back = KView:new(V.v(sw, sh))
    self.back.anchor = v(sw / 2, sh / 2)

    self:add_child(self.back)

    self.backback = KImageView:new("options_bg_notxt")
    self.backback.anchor = v(self.backback.size.x / 2, self.backback.size.y / 2)
    self.backback.pos = v(sw / 2, sh / 2 - 50)
    self.backback.scale = vv(1.5)

    self.back:add_child(self.backback)

    self.header = GGPanelHeader:new(_("OPTIONS"), 242)
    self.header.pos = v(sw / 2 - 110, sh / 2 - 443)

    self.back:add_child(self.header)

    self.done_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
    self.done_button.anchor = v(self.done_button.size.x / 2, self.done_button.size.y / 2)
    self.done_button.pos = v(sw / 2 + 390, sh / 2 + 315)
    self.done_button.label.size = v(100, 34)
    self.done_button.label.text_size = self.done_button.label.size
    self.done_button.label.pos = v(22, 19)
    self.done_button.label.font_size = 19
    self.done_button.label.font_name = "sans_bold"
    self.done_button.label.vertical_align = "middle"
    self.done_button.label.text = _("BUTTON_DONE")
    self.done_button.label.fit_lines = 1

    function self.done_button.on_click()
        S:queue("GUIButtonCommon")
        self:hide()
    end

    self.back:add_child(self.done_button)
end

function OptionsDifficultyView:show()
    OptionsDifficultyView.super.show(self)
end

function OptionsDifficultyView:hide()
    OptionsDifficultyView.super.hide(self)
end
