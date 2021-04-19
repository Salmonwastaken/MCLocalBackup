# Check if Screen is already attached, force a full save, (temporarily) turn off auto save
# and inform users backup has started (in Dutch)
if ! screen -r -S minecraft -X stuff $'\nsay World backup begonnen, dit kan laggen!\nsave-all\nsave-off\n';
then
# If the screen IS attached, throw a quick message and exit the program
    echo "Screen is attached. Not taking world backup!"
    exit 1
fi

#Premade commands to use with waitsilence
CMDworld='inotifywait -m -r /home/pi/MinecraftServer/world --exclude "^./dynmap.*" | grep -v ACCESS'
CMDnether='inotifywait -m -r /home/pi/MinecraftServer/world_nether --exclude "^./dynmap.*" | grep -v ACCESS'
CMDend='inotifywait -m -r /home/pi/MinecraftServer/world_the_end --exclude "^./dynmap.*" | grep -v ACCESS'

# Ensure minecraft has finished writing the world:
waitsilence -timeout 5s -command "$CMDworld"
# Index world folder using bup
bup index /home/pi/MinecraftServer/world/
# Local backup of the world using bup
bup save -n Worldbackup /home/pi/MinecraftServer/world

#Same as before, but for the nether
waitsilence -timeout 5s -command "$CMDnether"
bup index /home/pi/MinecraftServer/world_nether/
bup save -n Netherbackup /home/pi/MinecraftServer/world_nether

#Same as before, but for the end
waitsilence -timeout 5s -command "$CMDend"
bup index /home/pi/MinecraftServer/world_the_end
bup save -n Endbackup /home/pi/MinecraftServer/world_the_end

# Turn auto-save back on and inform server users (in Dutch) that backup was succesfully completed
screen -S minecraft -X stuff $'save-on\nsay World backup voltooid.\n'
