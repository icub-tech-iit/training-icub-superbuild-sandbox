# FAQ 🙋🏻‍♂️

1. **Why do I have to use the robotology-superbuild instead of the "classical" approach?**
    > The "classical approach" with the clone and build of repos one by one is error prone, you have to remember the exact order of build, and mainly during debugging this approach can lead to misconfigurations and leftovers in the setup. The robotology-superbuild takes care of compiling **ALL** the repos in the right order, with the right configuration(tags and build type) just with one command. Finally the usage of robotology-superbuild get rid of the `<package>_DIR` to be exported in the bashrc, since all the repos are installed in one location.
1. **I want to know more about the robotology-superbuild; where can I find more infos?**
    > The superbuild is maintained by [@traversaro](https://github.com/traversaro), and [here](https://github.com/robotology/robotology-superbuild) you can find a very detailed documentation

