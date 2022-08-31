# lua gif demo

Run metabuild.lua, followed by build.lua.

metabuild.lua converts a 15 color 240x160 gif into a series of images, and
outputs a manifest.lua file with the image file names.

build.lua compiles the image files together with a video driver lua script in
main.lua.
