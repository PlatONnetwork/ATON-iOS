if ! [ -x "$(command -v slather)" ]; then
  echo 'Error: slather is not installed.' >&2
  echo 'go to website https://github.com/SlatherOrg/slather install slather'
  exit 1
fi

slather coverage --html --scheme platonWalletTests --ignore "*ViewController*.swift" --ignore "*view*.swift" --ignore "*View*.swift" --ignore "*UI*.swift" --output-directory UnitTest-Report --binary-basename platonWallet  --workspace platonWallet.xcworkspace platonWallet.xcodeproj &&  open UnitTest-Report/index.html
#slather coverage --html --scheme platonWalletTests  --output-directory UnitTest-Report --binary-basename platonWallet  --workspace platonWallet.xcworkspace platonWallet.xcodeproj &&  open UnitTest-Report/index.html

