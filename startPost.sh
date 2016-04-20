echo "What is the technical name you would like to give this post?"
read PROJECTNAME
if  [ -d "Posts/$PROJECTNAME" ]; then
	echo "Another post already has that name, overwrite it? [y/n]"
	while true; do
    		read yn
    		case $yn in
        		[Yy]* ) rm -r Posts/$PROJECTNAME;break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer y or n.";;
    		esac
	done
fi
openfl create project Posts/$PROJECTNAME
mkdir Posts/$PROJECTNAME/BaseCode
cp BaseCode/Source/* Posts/$PROJECTNAME/BaseCode
mkdir Posts/$PROJECTNAME/Assets/text
gedit Posts/$PROJECTNAME/Assets/text/text
mkdir Posts/$PROJECTNAME/Simulations
mkdir Posts/$PROJECTNAME/Simulations/BaseSimulationCode
cp BaseCode/BaseSimulationCode/* Posts/$PROJECTNAME/Simulations/BaseSimulationCode
cp simCreator.sh Posts/$PROJECTNAME/Simulations/
cp compile.sh Posts/$PROJECTNAME/
