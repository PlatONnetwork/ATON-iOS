
#----------configure----------------#

updateInfo=""

commitToSVN=false

#------------static--------------#

CONFIG_PLIST_FILE_PATH="./platonWallet/resources/config.plist"

INFO_PLIST_FILE_PATH="./platonWallet/Info.plist"


scheme='platonWallet'

DATE=$(date "+%Y%m%d%H%M")


#------------end--------------#

# Appenv=$(/usr/libexec/PlistBuddy -c "Print :envirnment" "${CONFIG_PLIST_FILE_PATH}")
# echo envirnment $Appenv

# BUILD_ID_NUM=$(/usr/libexec/PlistBuddy -c "Print :build" "${CONFIG_PLIST_FILE_PATH}")
# BUILD_ID=$(printf 'B%s' $BUILD_ID_NUM)
# echo custom version $BUILD_ID


CFBundleVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFO_PLIST_FILE_PATH}")
echo bundle version: $CFBundleVersion

CFBundleShortVersionString=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFO_PLIST_FILE_PATH}")
echo buldle short version: $CFBundleShortVersionString


DATEFORMAT1=$(date "+%Y-%m-%d_%H:%M:%S")
updateInfo=$(printf "%s\nversion:%s_%s\nenv:%s\naut:%s\n%s" "$DATEFORMAT1" "$CFBundleShortVersionString" "$BUILD_ID" "$Appenv" "$SVN_USERNAME"  "$updateInfo")
echo updateInfo: $updateInfo


output_directory=$(printf "platonWallet_v%s" "$CFBundleShortVersionString")

ipaName=$(printf "platonWallet_v%s_%s.ipa" "$CFBundleShortVersionString" "$DATE")
echo ipaName: $ipaName


echoError(){
	echo  " \\033[0;31m"
	echo $1
	echo  " \\033[1;37m"
	return 0
}

echoSucc(){
	echo  " \\033[1;32m"
	echo $1
	echo  " \\033[1;37m"
	return 0
}

STARTTIME=$(date +%s)

# find . -name "*.ipa" | xargs rm
# find . -name "*.DSYM.zip" | xargs rm


pod install --verbose

mkdir -p ./builds/$output_directory

fastlane gym --clean --export_method ad-hoc --scheme $scheme --output_name $ipaName --output_directory ./builds/$output_directory

fullParam1=$1
sholdTag="true"
result=$(echo $fullParam1 | grep "${sholdTag}")
if [[ "$result" == "" ]]
then
    echo "no input to create tag"
else
    tagName=$(printf "%s_%s" "$CFBundleShortVersionString" "$DATE")
	echo "creatting a lightweight tag:"$tagName
    git tag $tagName
    git push origin --tags
fi

