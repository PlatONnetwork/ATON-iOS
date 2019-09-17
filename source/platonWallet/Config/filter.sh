echo
echo "Please operation"
echo
echo '[1] Before commit and send pull request'
echo
echo '[2] Recover code'


read -p "Please input:" inputNumber
echo

beforeCommit(){
    cp EnvConfig.swift EnvConfig-tmp.swift
    cp CommonService.swift CommonService-tmp.swift
    cp CommonConfig.swift CommonConfig-tmp.swift
    sed -i '*.bak' 's/ = "\(.*\)"/ = ""/g' EnvConfig.swift
    sed -i '*.bak' 's/ = "\(.*\)"/ = ""/g' CommonService.swift
    sed -i '*.bak' 's/ = "\(.*\)"/ = ""/g' CommonConfig.swift
    # sed -i '*.bak' 's/"\(.*\)"/""/g' EnvConfig.swift
    # sed -i '*.bak' 's/"\(.*\)"/""/g' CommonService.swift
    # sed -i '*.bak' 's/"\(.*\)"/""/g' CommonConfig.swift
    find . -maxdepth 10 -type f -name '*.swift-e' -delete
    find . -maxdepth 10 -type f -name '*.bak' -delete
}

recoveryCode(){
    cp EnvConfig-tmp.swift EnvConfig.swift
    cp CommonService-tmp.swift CommonService.swift
    cp CommonConfig-tmp.swift CommonConfig.swift
}




if [ "$inputNumber" -eq '1' ]; then
    echo
    beforeCommit && echo 'successfully done'
elif [ "$inputNumber" -eq '2' ]; then
    echo "⚠️_⚠️_⚠️ Please synchronize other people's source code"
    recoveryCode && echo 'successfully done'

else
    echo "Error input"
fi;