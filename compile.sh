scriptToAnalyze="$(cat Assets/text/text)"
arr=()
curlyPairs=0
#extract all sim names
for (( i=0; i<${#scriptToAnalyze}; i++ )); do
	if [ "{" == "${scriptToAnalyze:$i:1}" ]
	then
		if [ "\\" != "${scriptToAnalyze:$((i-1)):1}" ]
		then
			curlyPairs=$((curlyPairs+1))
			if [ $((curlyPairs%2)) == "0" ]
			then
				tempPos=0
				for (( j=$i; j<${#scriptToAnalyze}; j++ )); do
					if [ "}" == "${scriptToAnalyze:$j:1}" ]
					then
						arr+=("${scriptToAnalyze:$i+1:tempPos-1}")
						break;
					fi
					tempPos=$((tempPos+1))
				done
			fi
		fi
	fi
done

#create array of sim names that doesn't repeat itself
nonRepeatSims=("${arr[@]}")

lenArr=${#arr[*]}
for (( i=0; i<${lenArr}; i++ ));
do
	lenNonRepeatSims=${#nonRepeatSims[*]}
	for (( j=$i+1; j<${lenNonRepeatSims}; j++ ));
	do
		if [ "${nonRepeatSims[$j]}" == "${arr[$i]}" ]
		then
			nonRepeatSims=(${nonRepeatSims[@]:0:$j} ${nonRepeatSims[@]:$(($j + 1))})
			j=$((j-1))
			lenNonRepeatSims=${#arr2[*]}
		fi
	done
done

#gets list of classes
cd Simulations
lengthArr=()
allClasses=()
for (( i=0; i<${lenNonRepeatSims}; i++ ));
do
	cd ${nonRepeatSims[$i]}
	cd Source
	rm *~ 2> /dev/null
	shopt -s nullglob
	tempArray=(*)
	shopt -u nullglob
	lengthArr+=("${#tempArray[*]}")
	lengthArr[i]=$((lengthArr[i]-2)) #Don't include Main.hx and Simulation.hx
	tempLen=${#tempArray[*]}
	for (( j=0; j<${tempLen}; j++ ));
	do
		allClasses+=("${tempArray[j]}")
	done
	cd ..
	cd ..
done

lenAllClasses=${#allClasses[*]}
for (( i=0; i<${lenAllClasses}; i++ ));
do
	if [ "${allClasses[$i]}" == "Main.hx" ]
	then
		allClasses=(${allClasses[@]:0:$i} ${allClasses[@]:$(($i + 1))})
		i=$((i-1))
		lenAllClasses=${#allClasses[*]}
	elif [ "${allClasses[$i]}" == "Simulation.hx" ]
	then
		allClasses=(${allClasses[@]:0:$i} ${allClasses[@]:$(($i + 1))})
		i=$((i-1))
		lenAllClasses=${#allClasses[*]}
	fi
done

#check for duplicated class names
duplication="false"

for (( i=0; i<${lenAllClasses}; i++ ));
do
	if [ "Univ" != "${allClasses[i]:0:4}" ]
	then
		for (( j=$i+1; j<${lenAllClasses}; j++ ));
		do
			if [ "${allClasses[$j]}" == "${allClasses[$i]}" ]
			then
				duplication="true"
				lenLengthArr=${#lengthArr[*]}
				directoryNum=0
				classNum=0
				echo "Duplication between Simulation"
				for (( k=0; k<${lenLengthArr}; k++ ));
				do
					classNum=$((classNum+lengthArr[k]))
					if [ "$classNum" -ge "$i" ]
					then
						echo "${nonRepeatSims[directoryNum]}"
						echo "and"
						break;
					fi
					directoryNum=$((directoryNum+1))
				done
				directoryNum=0	
				classNum=0
				for (( k=0; k<${lenLengthArr}; k++ ));
				do
					classNum=$((classNum+lengthArr[k]))
					if [ "$classNum" -ge "$j" ]
					then
						echo "${nonRepeatSims[directoryNum]}"
						break;
					fi
					directoryNum=$((directoryNum+1))
				done
				echo "over the class ${allClasses[$j]}"
			fi
		done
	fi
done

if [ "$duplication" == "true" ]
then
	echo "Compilation program will now exit due to the duplication."
	exit;
fi

#if [ "$duplication" == "false" ]
#then
#	echo "No duplicates!"
#fi

#Assemble the classes together
cd ..
rm -r Source 2> /dev/null
mkdir Source

directoryNum=0
nextDirectoryNum=0
nextDirectoryNum=$((nextDirectoryNum+lengthArr[0]))
for (( i=0; i<${lenAllClasses}; i++ ));
do
	if [ "$nextDirectoryNum" -le "$i" ]
	then
		directoryNum=$((directoryNum+1))
		nextDirectoryNum=$((nextDirectoryNum+lengthArr[directoryNum]))
	fi
	cp Simulations/${nonRepeatSims[$directoryNum]}/Source/${allClasses[$i]} Source
done

for (( i=0; i<${lenNonRepeatSims}; i++ ));
do
	cp -R Simulations/${nonRepeatSims[$i]}/Assets/* Assets
done

cp BaseCode/* Source

#edit files to make it actualyl compilable
lineString=""
for (( i=0; i<${lenArr}; i++ ));
do
	lineString+=${arr[$i]},
done
lineString=${lineString::-1}
sed -i '10s/.*/ '"$lineString"' /' Source/SimulationHandle.hx

lineString=""
for (( i=0; i<${lenArr}; i++ ));
do
	lineString+="sims[$i] = new ${arr[$i]}(s, Main.calibrationFactor);"
done
lineString=${lineString::-1}
sed -i '22s/.*/ '"$lineString"' /' Source/SimulationHandle.hx

rm Source/*~ 2> /dev/null

#from the internet:
#shopt -s nullglob
#array=(*)
#shopt -u nullglob # Turn off nullglob to make sure it doesn't interfere with anything later
#echo "${array[@]}"  # Note double-quotes to avoid extra parsing of funny characters in filenames
