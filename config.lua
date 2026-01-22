local A, L = ...

local mediapath = "Interface\\AddOns\\"..A.."\\media\\"

L.cfg = {

  bar = {
    height = 16,
    width = 210,
    texture = mediapath.."Skullflower3",
  },

  cp = {
    height = 16,
    texture = mediapath.."Skullflower",
    pos = { a1 = "LEFT", a2 = "LEFT", af = "energyBarBg", x = 0, y = -18 },
    spacing = 2,
  },

  pos = { a1 = "CENTER", a2 = "CENTER", af = "UIParent", x = 0, y = -251 },

  text = {
    font = mediapath.."Expressway.ttf",
    size = 15,
    pos = { a1 = "BOTTOM", a2 = "TOP", af = "energyBar", x = 0, y = 0 },
  },

  colors = {
    bg         = {   0/255,   0/255,   0/255, 1 },
    mana       = {   0/255, 190/255, 230/255, 1 },
    rage       = {  102/0,  65/255,  65/255, 1 },
    focus      = { 230/255, 140/255,  60/255, 1 },
    energy     = { 246/255, 222/255,  32/255, 1 },
    runicpower = {   0/255, 190/255, 230/255, 1 },
    lunarpower = {  65/255,  65/255,  65/255, 1 },
    maelstrom  = {   0/255, 127/255, 255/255, 1 },
    insanity   = {  65/255,  65/255,  65/255, 1 },
    fury       = {  65/255,  65/255,  65/255, 1 },
    pain       = {  65/255,  65/255,  65/255, 1 },
  },
}
