#!/bin/bash
# This bash script runs a program called ffmpeg that can change picture, audio and video formats
# ffmpeg is probably already installed on your Raspberry Pi
# We will use it to convert an image sequence to a video then video to animated gif


#Rename image sequnce

a=1
rm /home/pi/.node-red/static/seq/lastsnap.jpg
for i in /home/pi/.node-red/static/seq/*.jpg; do
  new=$(printf "%03d.jpg" "$a") #%03d renames to zero padded length of 3
  mv -i -- "$i" /home/pi/.node-red/static/img/"$new"
  let a=a+1
done



#make a video from the image sequence
ffmpeg -r 12 -f image2 -s 640x480 -i /home/pi/.node-red/static/img/%03d.jpg -vcodec libx264 -crf 25  -pix_fmt yuv420p /home/pi/.node-red/static/gif/gif.mp4
#-r is the framerate (fps)
#-crf is the quality, lower means better quality, 15-25 is usually good
#-f force format
#-s is the resolution
#-pix_fmt yuv420p specifies the pixel format, change this as needed

# make a color pallete for gif
ffmpeg -y -i /home/pi/.node-red/static/gif/gif.mp4 -vf fps=12,scale=480:-1:flags=lanczos,palettegen /home/pi/.node-red/static/gif/palette.png
#remove any remaining gif files.  You can remove this line to keep gifs
rm /home/pi/.node-red/static/gif/*.gif
# make gif from video file using palette.png we just made
ffmpeg -i /home/pi/.node-red/static/gif/gif.mp4 -i /home/pi/.node-red/static/gif/palette.png -filter_complex "fps=12,scale=480:-1:flags=lanczos[x];[x][1:v]paletteuse" /home/pi/.node-red/static/gif/output.gif

# remove pallet.png and video
rm -f /home/pi/.node-red/static/img/*jpg
rm /home/pi/.node-red/static/gif/palette.png
rm /home/pi/.node-red/static/gif/gif.mp4

# rename gif to unique name so browsers won't show cached version
# note: $1 is a built-in variable that references the first perameter used when this script was invoked
# in this case, the node red exec node passed the msg.payload value into it
# if done manually, we would issue ./make-gif.sh my-picture-name
mv /home/pi/.node-red/static/gif/output.gif /home/pi/.node-red/static/gif/$1.gif




