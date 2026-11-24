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

hs.alert.show("右クリックスクロール 有効")
