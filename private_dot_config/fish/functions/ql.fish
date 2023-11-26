function ql --description 'Allow the type of a given plain text file to be previewed by registering it for QLStephen'
    set type (mdls -name kMDItemContentType $argv[1] | sed -n 's/^kMDItemContentType = \"\(.*\)\"$/\1/p')
    echo $type
    plutil -insert CFBundleDocumentTypes.0.LSItemContentTypes.0 -string $type ~/Library/QuickLook/QLStephen.qlgenerator/Contents/Info.plist
    qlmanage -r
end
