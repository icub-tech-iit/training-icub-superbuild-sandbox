Handling `robots-configuration` with the superbuild
===================================================

It is a common use case that, during the setup of a new `iCub`, it is used a development branch for adding the xmls of the new robot, and for changing them during the test phase.

The superbuild usually puts all repositories on a specific branch or tag.

Using the `master` branch, all the repos are set to `master` (except for YARP that has as stable branch `yarp-3.x`).
Using a specific tag(e.g. `v2020.08`) the superbuild puts all the repos to the tags specified for that release accordingly to the [sowftware versioning table](https://wiki.icub.org/wiki/Software_Versioning_Table).

It exists a CMake argument called `YCM_EP_DEVEL_MODE_<package_name>` that, if set to `ON`, allows to ovverride manually the branch/tag of `<package_name>` repository.
Note that if set to `OFF` any time you will do `make` in the `ROBOTOLOGY_SUPERBUILD_BUILD_DIR`, it will overwrite any user modification/checkout.

In this case the variable to be set ot `ON` is `YCM_EP_DEVEL_MODE_robots-configuration`, then access to the source of `robots-configuration` and checkout to the `<development_branch>` that has to be used:
```sh
cd $ROBOTOLOGY_SUPERBUILD_BUILD_DIR
cmake -DYCM_EP_DEVEL_MODE_robots-configuration:BOOL=ON ..
cd $ROBOT_CODE/robotology-superbuild/robotology/robots-configuration
git checkout <development_branch>
cd $ROBOTOLOGY_SUPERBUILD_BUILD_DIR
make
```

### Notes
1. Remember to check if `YARP_ROBOT_NAME` is defined correctly before installing `robots-configuration`
1. It is sufficient to execute once the command `cmake -DYCM_EP_DEVEL_MODE_robots-configuration:BOOL=ON ..`, this option will be enabled until the build is canceled/cleaned up.
