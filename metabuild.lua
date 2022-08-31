#!/usr/bin/env lua
--
-- metabuild.lua
--
-- Extracts frames from an input gif and generates a manifest file for
-- build.lua.
--


local name = "wind_rises"
local filename = name .. ".gif"

local gif = require("gif")(filename)
local bmp = require("bmp")

manifest = io.open("manifest.lua", "w")
manifest:write("local app = {\n")
manifest:write("name = '" .. name .. "',\n")
manifest:write("spritesheets = {},\n")
manifest:write("audio = {},\n")
manifest:write("scripts = {'main.lua', 'framecount.lua'},\n")
manifest:write("misc = {},\n")
manifest:write("tilesets = {\n")

print('Number of animation frames: '.. gif.get_file_parameters().number_of_images)

local w, h = gif.get_width_height()
if w ~= 240 or h ~= 160 then
   error("Image should be 240x160p! (the gba screen size)")
end

local frame_count = gif.get_file_parameters().number_of_images

-- Just the simplest way to communicate the number of frames to main.lua. The
-- main script can simply run dofile("framecount.lua") to fetch the frame count.
framecount_file = io.open("framecount.lua", "w")
framecount_file:write("framecount = ")
framecount_file:write(frame_count)
framecount_file:close()

for frame = 1, frame_count do
   print("converting frame " .. frame .. "...")

   -- Empty frames to fill with data. Mostly I was just feeling lazy and using a
   -- canned image means I don't have to generate a valid bmp header.
   local out_u, err = bmp.from_file("template/empty_frame_u.bmp")
   -- Note: using two images due to max layer texture size.


   if out_u == nil then
      error("for file: " .. path .. ", error: " .. err)
   end

   local matrix = gif.read_matrix()
   for x = 1, w do
      for y = 1, 112 do
         local pixel = matrix[y][x]
         -- again, laziness. Probably the slowest way to extract rgb from a
         -- colorhex integer. In the time I've taken to type this comment, I
         -- could probably fix it. But the stuff below is pretty clear, for
         -- demonstration purposes.
         local hex = ("%06X"):format(pixel)
         local r = tonumber("0x"..hex:sub(1,2))
         local g = tonumber("0x"..hex:sub(3,4))
         local b = tonumber("0x"..hex:sub(5,6))
         out_u:set_pixel(x - 1, y - 1, r, g, b)
      end
   end
   out_u:write_to_file(frame .. "_u.bmp")

   local out_l, err2 = bmp.from_file("template/empty_frame_l.bmp")
   if out_l == nil then
      error("for file: " .. path .. ", error: " .. err2)
   end

   for x = 1, w do
      for y = 112, 159 do
         local pixel = matrix[y][x]
         -- again, laziness. Probably the slowest way to extract rgb from a
         -- colorhex integer. In the time I've taken to type this comment, I
         -- could probably fix it. But the stuff below is pretty clear, for
         -- demonstration purposes.
         local hex = ("%06X"):format(pixel)
         local r = tonumber("0x"..hex:sub(1,2))
         local g = tonumber("0x"..hex:sub(3,4))
         local b = tonumber("0x"..hex:sub(5,6))
         out_l:set_pixel(x - 1, y - 112, r, g, b)
      end
   end
   out_l:write_to_file(frame .. "_l.bmp")

   manifest:write("'" .. frame .. "_u.bmp',\n")
   manifest:write("'" .. frame .. "_l.bmp',\n")

   if frame ~= frame_count then
      if not gif:next_image() then
         error("failed to load next frame!")
      end
   end
end

-- Close "GIF object" (file will be closed now)
gif.close()

manifest:write("}} \n return app")
manifest:close()
