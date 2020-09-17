# icub-setup-installation

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/icub-tech-iit/icub-setup-installation)
## TOC 📑
* [Assignment 👨‍🏫](#assignment-)
* [Introduction ℹ](#introduction-)
* [Prepare your system :gear:](#prepare-your-system--gear)
  + [Env variables 🌐](#env-variables-)
  👨‍🏫+ [Dependencies :books:](#dependencies--books)
* [Get software source code, compile and install - `icub-head` :robot:](#get-software-source-code--compile-and-install----icub-head---robot)
* [Get software source code, compile and install - `icubsrv` :computer:](#get-software-source-code--compile-and-install----icubsrv---computer)
* [Folder tree of robotology-superbuild :leaf:](#folder-tree-of-robotology-superbuild--leaf)
* [Run the software :rocket:](#run-the-software--rocket)
* [Existing Wiki Documentation 👓](#existing-wiki-documentation-)
* [FAQ 🙋🏻‍♂️](#faq-)
## Assignment 👨‍🏫

Open the gitpod :point_up: and install the `robotology-superbuild` following the instructions for the setup of [`icub-head`](https://github.com/icub-tech-iit/icub-setup-installation#get-software-source-code-compile-and-install---icub-head) and then for the setup of [`icubsrv`](https://github.com/icub-tech-iit/icub-setup-installation#get-software-source-code-compile-and-install---icubsrv).

## Introduction ℹ

This repository contains instructions and sandboxes for the SW setup of the iCub cluster using the [`robotology-superbuild`](https://github.com/robotology/robotology-superbuild).

One of the main goals of the robotology-superbuild is to simplify downloading and building all the software 
that is necessary to have on the main control computer contained in the head of the iCub robot, whose hostname 
is `icub-head` (or `pc104` in older iCub versions). This documentation provides the basic information necessary to 
use the robotology-superbuild on the computer contained in the head of the iCub robot and its respective laptop(usually called `icubsrv`). 

**Warning: if your iCub robot is not currently using the robotology-superbuild, do not attempt to migrate it
without coordinating with the iCub support. For any doubt, please open an issue at [`robotology/icub-tech-support`](https://github.com/robotology/icub-tech-support/issues).**

## Prepare your system :gear:
### Env variables 🌐
The operating system contained in the `icub-head`/`pc104` is tipically installed by IIT, for more information on it, please
check the relevant documentation at http://wiki.icub.org/wiki/The_Linux_on_the_pc104.

On this machine, in `/home/icub/.bashrc_iCub` a script containing several enviroment variables definitions is provided. If you want to  migrate to use
the robotology-superbuild, you need to remove the existing `.bashrc_iCub` file, and substitute it with the one provided in https://git.robotology.eu/MBrunettini/icub-environment/raw/master/bashrc_iCub_superbuild.

After you modified the `.bashrc_iCub` script, reboot the computer and  in a new shell check che values of the `ROBOTOLOGY_SUPERBUILD_SOURCE_DIR` and `YARP_ROBOT_NAME` env variables.
If `ROBOTOLOGY_SUPERBUILD_SOURCE_DIR` contains `/usr/local/src/robot/robotology-superbuild`, and `YARP_ROBOT_NAME` contains the string specific to your robot,
then the modification of the `.bashrc_iCub` was successful. 

### Dependencies :books:

Before proceeding with the installation of the superbuild, it is necessary to install the dependencies of our software.
This can be done simply following these steps:

```sh
sudo sh -c 'echo "deb http://www.icub.org/ubuntu <distro> contrib/science" > /etc/apt/sources.list.d/icub.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 57A5ACB6110576A6
sudo apt update
sudo apt install -y icub-common

```
where `<distro>` is the ubuntu\debian distribution(e.g `xenial`, `bionic`, `buster`, `focal`).

:warning: note that since in gitpod is not possible to execute sudo commands(e.g. `sudo apt install ..`), the dependencies are already installed in the docker, then this step is not part of the assignment. 

## Get software source code, compile and install - `icub-head` :robot:
On the `icub-head`/`pc104`, the software repository necessary to run the iCub robot are contained in the `/usr/local/src/robot` directory.
On a new machine, this directory should be empty. All the relevant software can download and build with the following commands:
~~~sh
cd ${ROBOT_CODE}
git clone https://github.com/robotology/robotology-superbuild.git
cd robotology-superbuild
git checkout v<release>
mkdir build
cmake -DROBOTOLOGY_USES_GAZEBO:BOOL=OFF -DROBOTOLOGY_ENABLE_ICUB_HEAD:BOOL=ON YCM_EP_DEVEL_MODE_robots-configuration:BOOL=ON ..
make
~~~
where `<release>` is the release version on which the iCub has to be setupped.

The main difference over the standard installation of the robotology-superbuild, is that the `ROBOTOLOGY_USES_GAZEBO` option
is disabled (as the Gazebo is tipically not installed in the `icub-head`/`pc104` machine) and the `ROBOTOLOGY_ENABLE_ICUB_HEAD` option
is enabled, to enable all the YARP devices that are necessary to interface with the internal communication bus of the iCub robot.

Moreover, `YCM_EP_DEVEL_MODE_robots-configuration` is set to `ON`, in this way the user can define a specific branch of `robots-configuration` instead of master.
The handle of robots-configuration inside the superbuild is treated [in the dedicated section.](robots-configuration.md)

The `make` command in this case will download, compile and install all the software necessary to run the robot itself.

If you need to use other *superbuild profiles*, they can be easily enabled with the corresponding CMake option.

**Important: do not run `make install` for the superbuild: the superbuild already installs all the software in 
`/usr/local/src/robot/robotology-superbuild/build/install`, and installing the software elsewhere on the robot is not currently supported.**

**Important: If you are using an old iCub that still uses the CAN internal bus, you also need to enable the `ROBOTOLOGY_USES_CFW2CAN` CMake option. Note that in this case, the `.bashrc_iCub` file should also contain the definition of the 
`CFW2CANAPI_DIR` environmental variables, in addition to all the environmental variable already defined  in that file.
See the main robotology-superbuild README for more detailed information.**

**Important: since [`icub-firmware-build`]("https://github.com/robotology/icub-firmware-build") does not contains sources to be compiled, but just binaries, it is not included in the superbuild, then it has to be cloned separately.**

## Get software source code, compile and install - `icubsrv` :computer:

The steps for setupping the `icubsrv` are the same, but are different the flags needed in the configuration phase of the superbuild:

~~~sh
cd ${ROBOT_CODE}
git clone https://github.com/robotology/robotology-superbuild.git
cd robotology-superbuild
git checkout v<release>
mkdir build
cmake -DROBOTOLOGY_USES_GAZEBO:BOOL=OFF -DROBOTOLOGY_ENABLE_ICUB_BASIC_DEMOS:BOOL=ON ..
make
~~~

where `<release>` is the release version on which the iCub has to be setupped.

## Folder tree of robotology-superbuild :leaf:

One of the main difference to get used to is the different folder tree structure respect the old approach with the clone of the single repositories.
Once you have correctly installed the `robotology-superbuild` you will have this folder tree for `icub-head`:
```
└── robotology-superbuild
...
    └── robotology
        ├── ICUB
        ├── ICUBcontrib
        ├── RobotTestingFramework
        ├── YARP
        ├── YCM
        ├── icub-tests
        ├── icub-models
        ├── icub_firmware_shared
        └── robots-configuration
```

And this folder tree on `icubsrv`:

```
└── robotology-superbuild
...
    └── robotology
        ├── ICUB
        ├── ICUBcontrib
        ├── RobotTestingFramework
        ├── YARP
        ├── YCM
        ├── funny-things
        ├── icub-basic-demos
        ├── icub-tests
        ├── icub-models
        ├── robots-configuration
        └── speech
```

These folder trees are reflected also in the build directory.
For example, you can find the `YARP` build directory in `$ROBOT_CODE/robotology-superbuild/build/robotology/YARP`.


## Run the software :rocket:

If the `make` command of the robotology-superbuild was successful, you just need to modify `~/.bashrc_iCub` uncommenting `#export OBJ_SUBDIR="build"` source it again and 
you will then be ready to use all the software provided by the robotology-superbuild.

For checking your installation run on a terminal `yarpserver --write`, and in another `iCub_SIM`.

## Existing Wiki Documentation 👓
Most of the existing documentation regarding the installation of the software on the pc104/icub-head 

| Normal page            |  Superbuild version           |
|:-------------------------:|:---------------------------------:|
| http://wiki.icub.org/wiki/ICub_Software_Installation |  http://wiki.icub.org/wiki/ICub_Software_Installation_(superbuild) | 
| http://wiki.icub.org/wiki/Windows:_installation_from_sources  | http://wiki.icub.org/wiki/Windows:_installation_from_sources_using_the_robotology-superbuild | 
|  http://wiki.icub.org/wiki/Linux:Installation_from_sources  |  http://wiki.icub.org/wiki/Linux:Installation_from_sources_using_the_robotology-superbuild  | 
| http://wiki.icub.org/wiki/MacOSX:_installation  |  http://wiki.icub.org/wiki/MacOS:Installation_from_sources_using_the_robotology-superbuild |  
| http://wiki.icub.org/wiki/ICub_server_laptop_installation_instructions | Change the last code box in section http://wiki.icub.org/wiki/ICub_server_laptop_installation_instructions#Software_repositories to `git clone https://github.com/robotology/robotology-superbuild.git` | 
| http://wiki.icub.org/wiki/Compilation_on_the_pc104 | https://wiki.icub.org/wiki/Compilation_on_the_pc104/icub-head_with_the_robotology-superbuild  | 
| https://git.robotology.eu/MBrunettini/icub-environment/raw/master/home/bashrc_iCub |  https://git.robotology.eu/MBrunettini/icub-environment/raw/master/home/bashrc_iCub_superbuild |

## FAQ 🙋🏻‍♂️ 

Check it out the [FAQ section.](FAQ.md)
