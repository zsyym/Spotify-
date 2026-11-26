#!/bin/bash
set -eu
cd "$(dirname "$0")/../.."
binary=$(mktemp -t spotify-playlist-tests)
trap 'rm -f "$binary"' EXIT
models=Spotify/Common/Models
library=Spotify/Library/Models
yy=Spotify/Pods/YYModel/YYModel
xcrun --sdk macosx clang -fobjc-arc -fmodules -isysroot "$(xcrun --sdk macosx --show-sdk-path)" \
    -I"$models" -I"$library" -ISpotify/Core/Network -ISpotify/Common/Services -ISpotify/Pods/Headers/Public \
    "$yy"/{YYClassInfo,NSObject+YYModel}.m "$models"/{SCPlaylist,SCTrack,SCAlbum,SCArtist,SCLocalMusicCatalog}.m \
    "$library"/{SCLibraryStore,SCLibraryItemModel}.m Spotify/Common/Services/SCNeteaseMusicService.m \
    -ISpotify/Home/Data -ISpotify/Home/Models Spotify/Home/Data/{SCHomeDataProvider,SCRemoteHomeProvider}.m \
    Spotify/Home/Models/SCHomeSectionModel.m Tests/Music/{SCRecommendedPlaylistTests,SCHomeProviderTests}.m -framework Foundation -framework CoreFoundation -o "$binary"
"$binary" docs/api/samples/home.json
