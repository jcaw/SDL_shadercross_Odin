# SDL_shadercross_Odin

Fork of the [Odin](https://odin-lang.org) bindings for [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross) to use prebuilt `SDL_Shadercross`.

## Example

There is a simple example inside the `src` folder, which showcases both online and offline shader compilation. Online shader compilation is done via the `SDL_shadercross` API, and offline via the `shadercross` binary file.

***Note**: Online shader compilation is only available in the debug build.*

## Clone

To clone the repository, run:

```
git clone --recurse-submodules https://github.com/jcaw/SDL_shadercross_Odin
```

If you have cloned the repository without its submodules, then run:

```
git submodule update --init --recursive
```

## Build

Execute any of the following commands from the root of the repository.

### Linux

(Note that `SDL_Shadercross` is a pain to build on Windows. It may be easier on Linux, but right now I haven't tested.)

1. Run `./setup.sh`, which will generate the libraries needed to build and run the above example.
1. Build with `./build_debug.sh` or `./build_release.sh`
1. Run `./game_debug.bin` or `./game_release.bin`
1. While running `./game_debug.bin`, press `R` to recompile the shaders.

### Windows

Building `SDL_Shadercross` on Windows is a pain. Instead, to use prebuilt libraries:

1. Run `.\setup.ps1`, which will generate the libraries needed to build and run the above example. This may fail (that's fine, we want some of the artifacts). If it fails, do the following to use pre-built libraries:
    1. Navigate to the `SDL_Shadercross` [GitHub Actions](https://github.com/libsdl-org/SDL_shadercross/actions) and download the prebuilt Windows VS artifact (not MSVC) from the latest release's commit. 
        1. From the `bin` folder: place `shadercross.exe` in the `bins/windows` folder. Place everything else in the root directory. These DLLs will need to be distributed with the project.
        1. From the `lib` folder: place `SDL3_shadercross.lib` and `SDL3_shadercross-static.lib` in `bindings/sdl_shadercross/libs/windows/`. There also needs to be a compatible `spirv-cross-c-shared.lib` in there. 
    1. `SDL_Shadercross` is built to target a specific SDL3 release. You must use the SDL3 DLL from the artifacts, and you need a compatible `SDL3.lib` for it. Odin now ships with SDL3 - if it's compatible, you can just pull the lib from Odin `.../Odin/vendor/sdl3/SDL3.lib`. If not, you'll need to build the same version of SDL3 that SDL_Shadercross was compiled for, and pull over `SDL3.lib` (x64). Place it in `bindings/sdl3/libs/windows/`.
1. Build with `.\build_debug.ps1` or `.\build_release.ps1`
1. Run `.\game_debug.exe` or `.\game_release.exe`
1. While running `.\game_debug.exe`, press `R` to recompile the shaders.

## Usage

To use the bindings, your project needs access to the `sdl_shadercross` bindings in the `bindings` folder and your build needs to contain the relevant dynamic libraries and executables from the `bins` folder - easiest is to just copy the bins into your build, properly setting DLL paths, etc. 

Note that unless `SDL_Shadercross` was built with the exact same version of SDL3 that Odin's native bindings use, you will need to use the SDL3 bindings in this project, *not* Odin's native bindings, because Shadercross is dependent on the SDL3 DLL.

## Credits

Certain parts of the example were taken from [Karl Zylinski's hot reload template](https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template). For example, setting up the context's tracking allocator and logger, and checking for bad frees and leaks.
This is a fork of the [SDL_Shadercross_Odin](https://github.com/theopechli/SDL_shadercross_Odin) repository from Theofilos Pechlivanis.
