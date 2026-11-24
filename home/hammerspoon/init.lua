require("hs.ipc")   -- ターミナルから `hs` コマンドで操作できるようにする
hs.autoLaunch(true) -- ログイン時に自動起動
-- =========================================================
-- 右クリックを押しながらトラックボール → 縦横ピクセルスクロール
-- 右クリックをすぐ離した場合は通常の右クリックとして動作
-- =========================================================

local SPEED = 3            -- スクロール倍率（大きいほど速い。整数推奨）
local INVERT = false       -- false: ボールの向きに画面が付いてくる（タッチパネル風） / true: 逆
local CLICK_THRESHOLD = 3  -- 押している間の移動量がこれ以下なら普通の右クリック扱い
local MARK = 0x5343524C    -- 自分で発行したイベントの目印（再捕捉防止）

local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties

local pressed = false
local moved = 0
local anchor = nil

local function round(x)
  return x >= 0 and math.floor(x + 0.5) or -math.floor(-x + 0.5)
end

rightDragScroll = hs.eventtap.new(
  { types.rightMouseDown, types.rightMouseUp, types.rightMouseDragged },
  function(e)
    if e:getProperty(props.eventSourceUserData) == MARK then
      return false
    end

    local t = e:getType()

    if t == types.rightMouseDown then
      pressed = true
      moved = 0
      anchor = hs.mouse.absolutePosition()
      return true

    elseif t == types.rightMouseDragged then
      if not pressed then return false end
      local dx = e:getProperty(props.mouseEventDeltaX)
      local dy = e:getProperty(props.mouseEventDeltaY)
      moved = moved + math.abs(dx) + math.abs(dy)
      local s = INVERT and -SPEED or SPEED
      hs.mouse.absolutePosition(anchor) -- カーソルを固定
      return true, { hs.eventtap.event.newScrollEvent({ round(dx * s), round(dy * s) }, {}, "pixel") }

    elseif t == types.rightMouseUp then
      if not pressed then return false end
      pressed = false
      if moved <= CLICK_THRESHOLD then
        local pos = anchor or e:location()
        local down = hs.eventtap.event.newMouseEvent(types.rightMouseDown, pos)
        local up = hs.eventtap.event.newMouseEvent(types.rightMouseUp, pos)
        down:setProperty(props.eventSourceUserData, MARK)
        up:setProperty(props.eventSourceUserData, MARK)
        return true, { down, up }
      end
      return true
    end

    return false
  end
)
rightDragScroll:start()

-- eventtap はタイムアウト等で無効化されることがあるので定期的に復帰させる
rightDragScrollWatchdog = hs.timer.doEvery(5, function()
  if not rightDragScroll:isEnabled() then
    pressed = false
    rightDragScroll:start()
  end
end)

-- =========================================================
-- 拡大 / 縮小（前面アプリに ⌘= / ⌘- を送る）
--   ・Ctrl + スクロール（ホイールを奥 = 拡大、手前 = 縮小）
--   ・（任意）マウスのサイドボタン（進む = 拡大、戻る = 縮小）
-- =========================================================

local ZOOM_INVERT = false             -- true でスクロールの拡大/縮小の向きを逆に
local ZOOM_PIXEL_STEP = 40            -- トラックパッド等の滑らかなスクロールで 1 段階ズームする移動量
local ZOOM_WITH_SIDE_BUTTONS = false  -- true でサイドボタンを拡大/縮小に使う（ブラウザの戻る/進むは使えなくなる）
-- Ctrl+スクロールでカーソル位置を中心にズームできるアプリは横取りせずそのまま通す
local ZOOM_PASSTHROUGH_APPS = { ["Figma"] = true }

local function zoomEvents(zoomIn)
  local key = zoomIn and "=" or "-"
  return {
    hs.eventtap.event.newKeyEvent({ "cmd" }, key, true),
    hs.eventtap.event.newKeyEvent({ "cmd" }, key, false),
  }
end

local zoomAccum = 0

ctrlScrollZoom = hs.eventtap.new({ types.scrollWheel }, function(e)
  local f = e:getFlags()
  if not f.ctrl or f.cmd or f.alt or f.shift then return false end
  local app = hs.application.frontmostApplication()
  if app and ZOOM_PASSTHROUGH_APPS[app:name()] then return false end

  -- ナチュラルスクロールでも「ホイールを奥へ = 拡大」になるよう向きを揃える
  local sign = (hs.mouse.scrollDirection() == "natural") and -1 or 1
  if ZOOM_INVERT then sign = -sign end

  if e:getProperty(props.scrollWheelEventIsContinuous) == 1 then
    -- 慣性スクロールでズームが暴走しないよう、慣性分は捨てる
    if e:getProperty(props.scrollWheelEventMomentumPhase) ~= 0 then return true end
    zoomAccum = zoomAccum + e:getProperty(props.scrollWheelEventPointDeltaAxis1) * sign
    if math.abs(zoomAccum) < ZOOM_PIXEL_STEP then return true end
    local zoomIn = zoomAccum > 0
    zoomAccum = 0
    return true, zoomEvents(zoomIn)
  end

  local dy = e:getProperty(props.scrollWheelEventDeltaAxis1) * sign
  if dy == 0 then return false end
  return true, zoomEvents(dy > 0)
end)
ctrlScrollZoom:start()

-- サイドボタン: 3 = 戻る（手前側）, 4 = 進む（奥側）
sideButtonZoom = hs.eventtap.new({ types.otherMouseDown, types.otherMouseUp }, function(e)
  if not ZOOM_WITH_SIDE_BUTTONS then return false end
  local b = e:getProperty(props.mouseEventButtonNumber)
  if b ~= 3 and b ~= 4 then return false end
  if e:getType() == types.otherMouseUp then return true end
  return true, zoomEvents(b == 4)
end)
sideButtonZoom:start()

-- eventtap はタイムアウト等で無効化されることがあるので定期的に復帰させる
zoomWatchdog = hs.timer.doEvery(5, function()
  if not ctrlScrollZoom:isEnabled() then ctrlScrollZoom:start() end
  if not sideButtonZoom:isEnabled() then sideButtonZoom:start() end
end)

hs.alert.show("右クリックスクロール / Ctrl+スクロール拡大 有効")
