# Handling robots-configuration with the superbuild
It is a common use case that, during the setup of a new `iCub`, it is used a development branch for adding the xmls of the new robot, and for changing them after during the test phase.

The superbuild usually put all the repository on a specific branch or tag.

Using the `master` branch, all the repos are set to `master` (except for YARP that has as stable branch `yarp-3.x`).
Using a specific tag(e.g. `v2020.08`) the superbuild puts all the repos to the tags specified for that release accordingly to the [sowftware versioning table](https://wiki.icub.org/wiki/Software_Versioning_Table).

It exists a CMake argument called `YCM_EP_DEVEL_MODE_<package_name>` that, if set to `TRUE`, allows to ovverride manually the branch/tag of `<package_name>` repository.
Note that if set to `FALSE` any time you will do `make` in the `ROBOTOLOGY_SUPERBUILD_BUILD_DIR`, it will overwrite any user modification/checkout.

Once that CMake variable has been set to `TRUE`, access to the source of `robots-configuration` and checkout to the `<development_branch>`:
```sh
cd $ROBOT_CODE/robotology-superbuild/robotology/robots-configuration
git checkout <development_branch>
cd $ROBOTOLOGY_SUPERBUILD_BUILD_DIR
make
```
