
local MameCmd = require("mameCmd")

local ret = {}

-- src : https://datacrystal.romhacking.net/wiki/Super_Mario_Bros.:RAM_map

local adressCoins = 0x075E
local adressLives = 0x075A


local adressMarioState = 0x0756
local marioStateEnum = {
    small = 0x0,
    big = 0x01,
    fiery = 0x02
}

local adressPlayerState = 0xE
local playerStateEnum = {
    climbingVine = 0x1,
    enteringReversedLPipe = 0x2,
    inAPipe = 0x3,
    playerDie = 0x6,
    enteringArea = 0x7,
    normal = 0x8,
    cannotMove = 0x9,
    dying = 0x0B
}

local adressEnemies = {0x16, 0x17, 0x18, 0x19, 0x1A}
local ennemyEnum = {
    GreenKoopa            = 0x00,
    BuzzyBeetle           = 0x02,
    RedKoopa              = 0x03,
    HammerBro             = 0x05,
    Goomba                = 0x06,
    Bloober               = 0x07,
    BulletBill_FrenzyVar  = 0x08,
    GreyCheepCheep        = 0x0a,
    RedCheepCheep         = 0x0b,
    Podoboo               = 0x0c,
    PiranhaPlant          = 0x0d,
    GreenParatroopaJump   = 0x0e,
    RedParatroopa         = 0x0f,
    GreenParatroopaFly    = 0x10,
    Lakitu                = 0x11,
    Spiny                 = 0x12,
    FlyCheepCheepFrenzy   = 0x14,
    FlyingCheepCheep      = 0x14,
    BowserFlame           = 0x15,
    Fireworks             = 0x16,
    BBill_CCheep_Frenzy   = 0x17,
    Stop_Frenzy           = 0x18,
    Bowser                = 0x2d,
    PowerUpObject         = 0x2e,
    VineObject            = 0x2f,
    FlagpoleFlagObject    = 0x30,
    StarFlagObject        = 0x31,
    JumpspringObject      = 0x32,
    BulletBill_CannonVar  = 0x33,
    RetainerObject        = 0x35,
    TallEnemy             = 0x09
}
ret.ennemyEnum = ennemyEnum

local adressMarioFacingDirection = 0x0033
local marioFacingDirectionEnum = {
    notOnScreen = 0x0,
    right = 0x01,
    left = 0x02
}

local adressHorizontalSpeed = 0x0057 -- horizontal movement
local horizontalSpeedRange = {
    notMoving = 0x0,
    maxRight = 0x30, -- The more you are near 30 the more you have right speed
    maxLeft = 0xD8 -- 0xFE is very slow to the left
}

local adressVerticalVelocity = 0x009F -- jump etc
local verticalVelocityRange = {
    noVelocity = 0x0,
    topJump = 0xFB,
    topFall = 0x05
}

local adressSwimmingFlag = 0x704
local swimmingFlagEnum = {
    swim = 0x1,
    noSwim = 0x0 -- On the ground gravity
}

local adressTimer = {0x07F8, 0x07F9, 0x07FA}

local adressWorld = 0x075F -- [0, 7]
local adressLevel = 0x0760 -- [0, 3]

local adressLevelLoadingSetting = 0x772
local levelLoadingSettingEnum = {
    restart = 0x0,
    before = 0x1,
    reset = 0x3
}

local adressLevelPalette = 0x0773
local levelPaletteEnum = {
    normal = 0x0,
    underwater = 0x1,
    night = 0x2,
    underground = 0x3,
    castle = 0x4
}

local adressPauseStatus = 0x776
local pauseStatusEnum = {
    inPause = {0x01, 0x81}, -- dans les états 0x8X les input pour enlever/mettre la pause est désactivé
    notPause = {0x0, 0x80}
}

-- * Functions * --

local function setMarioState(marioState)
    MameCmd.writeMemory(adressMarioState, marioStateEnum[marioState])
end
ret.setMarioState = setMarioState

local function setTimer(amount)
    local firstDigit, secondDigit, thirdDigit -- from left to right
    firstDigit = amount // 100
    secondDigit = amount % 100 // 10
    thirdDigit = amount % 10
    MameCmd.writeMemory(adressTimer[1], firstDigit)
    MameCmd.writeMemory(adressTimer[2], secondDigit)
    MameCmd.writeMemory(adressTimer[3], thirdDigit)
end
ret.setTimer = setTimer

local function setAllEnemies(ennemyKind)
    for _, v in ipairs(adressEnemies) do
        MameCmd.writeMemory(v, ennemyKind)
    end
end
ret.setAllEnemies = setAllEnemies

local function isLevelOver()
    return MameCmd.readMemory(adressLevelLoadingSetting) == levelLoadingSettingEnum.before
end
ret.isLevelOver = isLevelOver

local function isLevel(levelValue)
    return MameCmd.readMemory(adressLevel) == levelValue
end
ret.isLevel = isLevel

local function getCoinsNumber()
    return MameCmd.readMemory(adressCoins)
end
ret.getCoinsNumber = getCoinsNumber

local function isMarioDead()
    return MameCmd.readMemory(adressPlayerState) == playerStateEnum.playerDie
end
ret.isMarioDead = isMarioDead

return ret

