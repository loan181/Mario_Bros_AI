# Mario Bros Artificial Intelligence Project

The goal of the project is to develop an artificial intelligence to play the original Mario Bros games.

## Getting Started

The project is programmed in language `LUA` using the `MAME` emulator.  
No official documentation exists on the usage of the LUA module for this emulator, the file `luaEngine.cpp` in the `src`
folder is used to get information over the module.

### Prerequisites/Installing

As stated before `MAME` is required and available for download on [mamedev](http://mamedev.org/oldrel.html), I used the
0.194 version for this project.

You will also need a Mario Bros Rom, the project use `Super Mario Bros. (JU) (PRG0) [!]`.

### Running

After installed `MAME`, copy the project and the ROM you can lauch the project with the following command :

```sh
<PATH_TO_MAME_EXECUTABLE> nes -console -autoboot_script <PATH_TO_THIS_PROJECT_FOLDER>/src/main.lua -cart <PATH_TO_ROM_FILE>
```

Assuming the project folder and ROM is in the same directory than the `MAME` executable and the command prompt is open into this same folder, it should look something like:
```sh
./mame nes -console -autoboot_script src/main.lua -cart "Super Mario Bros. (JU) (PRG0) [!].nes"
```
