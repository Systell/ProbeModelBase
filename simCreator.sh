echo "What is the technical name you would like to give this simulation (remember: no duplicate class names!)?"
read SIMNAME
if  [ -d "$SIMNAME" ]; then
	echo "Another simulation already has that name, overwrite it? [y/n]"
	while true; do
    		read yn
    		case $yn in
        		[Yy]* ) break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer y or n.";;
    		esac
	done
fi
openfl create project $SIMNAME
cp BaseSimulationCode/* $SIMNAME/Source
sed -i '7s/.*/class '$SIMNAME' extends Simulation/' $SIMNAME/Source/insertname.hx
sed -i '10s/.*/		var sim:'$SIMNAME' = new '$SIMNAME'(stage, 1);/' $SIMNAME/Source/Main.hx
mv $SIMNAME/Source/insertname.hx $SIMNAME/Source/$SIMNAME.hx
