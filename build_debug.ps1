$PROJECT_DIR = Get-Location
$OUT_DIR = "$PROJECT_DIR/build_game/Debug"
$OUT_EXE = "game_debug.exe"

New-Item -ItemType Directory -Path "$OUT_DIR"

odin build ./src `
     -debug `
     -o:none `
     -vet `
     -strict-style `
     -max-error-count:1 `
     -define:USE_TRACKING_ALLOCATOR=true `
     -collection:bindings=bindings `
     -out:"$OUT_DIR/$OUT_EXE"
