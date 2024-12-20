# Shell script for automating deployments using jenkins
# Reference - https://medium.com/@ian.k9.burton/finally-a-full-jenkins-example-to-deploy-to-salesforce-using-dx-mdapi-d619ad037258

#!/bin/bash

sfdx force:auth:jwt:grant -username "$UserName" -jwtkeyfile "$KEY_FILE" -clientid "$ConsumerKey" instanceurl "$instanceurl"

declare -A metadatamap
while IFS=' ' read value name
do
    metadatamap[$value]="$name"
done < $MetaDataMapping

git diff --name-status $TargetBranch..$SourceBranch -- > difffile.txt

readarray filelist < <(sed 's/\t/\n/g' difffile.txt)

mkdir -p DeployPackage

declare -A packagearray
declare -A destructivepackagearray

GitStatus=""

for i in ${!filelist[@]}
do	

filepath="$(echo -e "${filelist[i]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

case "${filepath}" in
	M) 
	GitStatus="$filepath"
	;;
	A) 
	GitStatus="$filepath"
	;;
	D) 
	GitStatus="$filepath"
	;;
	R???) 
	GitStatus="R"
	#  a file rename, but we arent handling this
	;;
	C???)
	GitStatus="C"
	#  a file copy, but we arent handling this
	;;
	*)	
		# this means its not a status, but rather a filepath
		filename="$(basename -- "${filepath}")"
		fileext="${filename##*.}"
		filenameonly="${filename%.*}"
		filetype="$(cut -d/ -f2 <<<"${filepath}")"
		filefolder=$(basename $(dirname "${filepath}")) 
		
		case "${GitStatus}" in	
			R) 
				#we arent handling renames
			;;
			C) 
				#we arent handling copies
			;;
			D) 			
				deleteditems=${destructivepackagearray["$filetype"]};				
				if [[ "$fileext" != *"xml" ]] && [[ "$filename" != "package.xml" ]]; then
				
					# no duplicates
					if [[ "$deleteditems" =~ "<members>"$filename"</members>" ]]; then
						echo "in the list"
					else
						echo "adding to destructive package"
						destructivepackagearray[$filetype]+="<members>"$filename"</members>"
					fi
					
				fi
								
			;;
			*)	
				if [[ "$filename" != "package.xml" ]]; then
				
					mkdir -p DeployPackage"/"$(dirname "${filepath}") && cp -p "${filepath}" "DeployPackage/${filepath}"

					if [[ "$extension" == "cls" ]] || [[ "$extension" == "trigger" ]] || [[ "$extension" == "js" ]] || [[ "$extension" == "cmp" ]] || [[ "$extension" == "email" ]]; then
						cp -p "${filepath}""-meta.xml" "DeployPackage/${filepath}""-meta.xml"
					fi
					if [[ ${filepath} == *"-meta.xml"* ]]; then
						metafilepath=${filepath%-*}
                        filename="${filename%.*}"
						filename=${filename%-*}
                       cp -p "${metafilepath}" "DeployPackage/${metafilepath}" 
					fi	
					
					packagemember=$filename
					if [[ "$filetype" == "aura" || "$filetype" == "lwc" ]]; then
						packagemember=$filefolder
						completefolder=$(dirname "${file}")
                        cp -r ./$completefolder "./DeployPackage/src/$filetype/"
					fi
					if [[ "$extension" == "report" ]] || [[ "$filetype" == "email" ]] || [[ "$extension" == "dashboard" ]]; then
						packagemember=$folder/""$filename
					fi
					
					packageitems=${packagearray["$filetype"]};
					if [[ "$packageitems" =~ *"<members>"$packagemember"</members>"* ]]; then
						echo "This item is already in the package"
					else
						packagearray["$filetype"]+="<members>"$packagemember"</members>"
					fi
				fi
			;;
		esac
	;;
esac

done	

destructivePackage="<?xml version=\"1.0\" encoding=\"UTF-8\"?><Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">"
Package="<?xml version=\"1.0\" encoding=\"UTF-8\"?><Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">"

for member in "${!packagearray[@]}"; do   
	Package+="<types>${packagearray["$member"]}<name>${metadatamap["$member"]}</name></types>"   
done

destrcount=0
for dmember in "${!destructivepackagearray[@]}"; do   
	destructivePackage+="<types>${destructivepackagearray["$dmember"]}<name>${metadatamap["$dmember"]}</name></types>"   
	((destrcount+=1))	   
done

destructivePackage+="<version>47.0</version></Package>"
Package+="<version>47.0</version></Package>"

echo $Package > DeployPackage/src/Package.xml
if [[ $destrcount>0 ]]; then
	echo $destructivePackage > DeployPackage/src/destructiveChanges.xml
fi
	
sfdx force:mdapi:deploy -d DeployPackage/src -u "$UserName" -w -1
