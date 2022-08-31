-- The gif driver software.
--
-- The main concept: on the bpcore engine readme, first download and run the
-- fullscreen image demo. It covers the concepts involved in displaying a
-- fullscreen image. This demo simply builds on top of the fullscreen image
-- demo, by demonstrating that the texture can be swapped out from under the
-- tiles, to implement video playback.

fade(1)

txtr(2, "1_u.bmp")  -- First portion of image
txtr(1, "1_l.bmp")  -- Second portion of image

dofile("framecount.lua")

-- Tile layer 1 displays above tile layer zero. We want to initialize all of
-- layer 1 to a transparent tile, so that it won't cover the upper half of the
-- image.
for y = 0, 19 do
   for x = 0, 29 do
      -- There are six rows of 30 image tiles in test1.bmp, followed by
      -- transparent tiles. 6 * 30 = 180.
      tile(1, x, y, 180)
   end
end

function draw_img(layer, x, y, w, h)
   local t = 0
   for yy = 0, h - 1 do
      for xx = 0, w - 1 do
         tile(layer, x + xx, y + yy, t)
         t = t + 1
      end
   end
end

-- draw the image
draw_img(2, 0, 0, 30, 14)
draw_img(1, 0, 14, 30, 6)

fade(0)

local frame = 1

local step = 0

-- Cache file locations in the rom for faster texture swapping.
local file_cache_u = {} -- image upper part
local file_cache_l = {} -- image lower part

for frame = 1, framecount do
   table.insert(file_cache_u, {file(frame .. "_u.bmp")})
   table.insert(file_cache_l, {file(frame .. "_l.bmp")})
end


while true do
   if frame == framecount + 1 then
      frame = 1
   end
   clear()
   local t_u = file_cache_u[frame]
   local t_l = file_cache_l[frame]
   txtr(2, t_u[1], t_u[2])
   txtr(1, t_l[1], t_l[2])
   display()
   step = step + 1
   if step == 4 then
      frame = frame + 1
      step = 0
   end
end
