param(
    [Parameter(Mandatory=$false)]
    [switch]$d
)
$BUILD_MODE = if ($d) { "Debug" } else { "Release" }


$OS = "windows"
$env:CMAKE_GENERATOR = "Ninja"
$env:CMAKE_GENERATOR_PLATFORM = "x64"
$env:CMAKE_C_COMPILER = "cl.exe"
$env:CMAKE_CXX_COMPILER = "cl.exe"
$PROJECT_DIR = Get-Location
$BINS_DIR = Join-Path(Join-Path (Join-Path $PROJECT_DIR "bins") $OS) $BUILD_MODE

New-Item -ItemType Directory -Path $BINS_DIR -Force


#### SDL ####

$SDL_DIR = Join-Path $PROJECT_DIR "third_party/SDL"
$SDL_BUILD_DIR = Join-Path $SDL_DIR "build/$BUILD_MODE"
$SDL_LIBS_DIR = Join-Path (Join-Path $PROJECT_DIR "bindings/$BUILD_MODE/sdl3/libs") $OS

New-Item -ItemType Directory -Path $SDL_LIBS_DIR -Force

Set-Location $SDL_DIR

cmake -S . -B $SDL_BUILD_DIR -GNinja `
      -DCMAKE_BUILD_TYPE="$BUILD_MODE"
cmake --build "$SDL_BUILD_DIR"

Copy-Item -Path (Join-Path $SDL_BUILD_DIR "SDL3.lib") -Destination $SDL_LIBS_DIR -Force

Copy-Item -Path (Join-Path $SDL_BUILD_DIR "SDL3.dll") -Destination $BINS_DIR -Force

Set-Location $PROJECT_DIR


#### SDL_shadercross ####

$SDL_SHADERCROSS_DIR = Join-Path $PROJECT_DIR "third_party/SDL_shadercross"
$SDL_SHADERCROSS_LIBS_DIR = Join-Path (Join-Path (Join-Path (Join-Path $PROJECT_DIR "bindings/") "$BUILD_MODE") "sdl_shadercross/libs") $OS
$DIRECTX_SHADER_COMPILER_DIR = Join-Path $SDL_SHADERCROSS_DIR "external/DirectXShaderCompiler"
$SDL_SHADERCROSS_BUILD_DIR = Join-Path $SDL_SHADERCROSS_DIR "build/$BUILD_MODE"
$SPIRV_CROSS_BUILD_DIR = Join-Path $SDL_SHADERCROSS_DIR "spirv_cross_build/$BUILD_MODE"
$DIRECTX_SHADER_COMPILER_BUILD_DIR = Join-Path $SDL_SHADERCROSS_DIR "external/DirectXShaderCompiler-binaries/windows/"

New-Item -ItemType Directory -Path $SDL_SHADERCROSS_LIBS_DIR -Force

Set-Location $SDL_SHADERCROSS_DIR

cmake -S external/SPIRV-Cross -B $SPIRV_CROSS_BUILD_DIR -GNinja `
      -DCMAKE_BUILD_TYPE="$BUILD_MODE" `
      -DSPIRV_CROSS_SHARED=ON `
      -DSPIRV_CROSS_STATIC=ON
cmake --build "$SPIRV_CROSS_BUILD_DIR"

# if ($d) {
#     $extensions = @("dll", "exp", "ilk", "lib", "pdb")
#     foreach ($extension in $extensions) {
#         $new_path = Join-Path "$SPIRV_CROSS_BUILD_DIR" "spirv-cross-c-shared.$extension"
#         if (Test-Path $new_path -PathType Leaf) {
#             Remove-Item $new_path
#         }
#         Rename-Item -Path (Join-Path "$SPIRV_CROSS_BUILD_DIR" "spirv-cross-c-sharedd.$extension") -NewName "$new_path"
#     }
# }

cmake -P build-scripts/download-prebuilt-DirectXShaderCompiler.cmake

cmake -S . -B $SDL_SHADERCROSS_BUILD_DIR -GNinja `
      -DCMAKE_BUILD_TYPE="$BUILD_MODE" `
      -DDirectXShaderCompiler_ROOT="$SDL_SHADERCROSS_DIR/external/DirectXShaderCompiler-binaries" `
      -DSDLSHADERCROSS_SHARED=ON `
      -DSDLSHADERCROSS_STATIC=OFF `
      -DSDLSHADERCROSS_VENDORED=OFF `
      -DSDLSHADERCROSS_CLI=ON `
      -DSDLSHADERCROSS_WERROR=OFF `
      -DSDLSHADERCROSS_INSTALL=ON `
      -DSDLSHADERCROSS_INSTALL_RUNTIME=ON `
      -DSDLSHADERCROSS_INSTALL_CPACK=ON `
      -DCMAKE_PREFIX_PATH="$SPIRV_CROSS_BUILD_DIR" `
      -DSDL3_DIR="$SDL_BUILD_DIR" `
      -DCMAKE_INSTALL_PREFIX="$SDL_SHADERCROSS_DIR/sdl_shadercross_install_build/$BUILD_MODE"
cmake --build "$SDL_SHADERCROSS_BUILD_DIR"

Copy-Item -Path (Join-Path $SDL_SHADERCROSS_BUILD_DIR "shadercross.exe") -Destination $BINS_DIR -Force
Copy-Item -Path (Join-Path $DIRECTX_SHADER_COMPILER_BUILD_DIR "bin/x64/dxc.exe") -Destination $BINS_DIR -Force

Copy-Item -Path (Join-Path $SDL_SHADERCROSS_BUILD_DIR "SDL3_shadercross.lib") -Destination $SDL_SHADERCROSS_LIBS_DIR -Force
Copy-Item -Path (Join-Path $SPIRV_CROSS_BUILD_DIR "spirv-cross-c-shared*.lib") -Destination $SDL_SHADERCROSS_LIBS_DIR -Force

Copy-Item -Path (Join-Path $SDL_SHADERCROSS_BUILD_DIR "SDL3_shadercross.dll") -Destination $BINS_DIR -Force
Copy-Item -Path (Join-Path $SPIRV_CROSS_BUILD_DIR "spirv-cross-c-shared*.dll") -Destination $BINS_DIR -Force
Copy-Item -Path (Join-Path $DIRECTX_SHADER_COMPILER_BUILD_DIR "bin/x64/dxcompiler.dll") -Destination $BINS_DIR -Force
Copy-Item -Path (Join-Path $DIRECTX_SHADER_COMPILER_BUILD_DIR "bin/x64/dxil.dll") -Destination $BINS_DIR -Force


if ($d) {
    Copy-Item -Path (Join-Path $SDL_BUILD_DIR "SDL3.pdb") -Destination $BINS_DIR -Force
    Copy-Item -Path (Join-Path $SDL_SHADERCROSS_BUILD_DIR "SDL3_shadercross.pdb") -Destination $BINS_DIR -Force
    Copy-Item -Path (Join-Path $SPIRV_CROSS_BUILD_DIR "spirv-cross-c-sharedd.pdb") -Destination $BINS_DIR -Force
}

# TODO: Copy include headers?
$ODIN_FILES_BASE_DIR = (Join-Path (Join-Path $PROJECT_DIR "bindings") "Odin")
Copy-Item -Force -Recurse -Path (Join-Path $ODIN_FILES_BASE_DIR "sdl3/*")            -Destination (Join-Path $PROJECT_DIR "bindings/$BUILD_MODE/sdl3/")
Copy-Item -Force -Recurse -Path (Join-Path $ODIN_FILES_BASE_DIR "sdl_shadercross/*") -Destination (Join-Path $PROJECT_DIR "bindings/$BUILD_MODE/sdl_shadercross/")

Set-Location $PROJECT_DIR
