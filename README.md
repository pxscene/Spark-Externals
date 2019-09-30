# externals
This contains all the dependent components of Spark and their built artifacts of the dependent components.

## steps for adding new component
Below are the steps to add a new component. 

1. Add the folder of component in repository.
2. Add build steps for the component (configure and make rules) in build.sh file. Represent the directory with a unique small name X. X need not be same string as directory name. It is user defined name for identifying component within the script.
3. Add variable X_build=0 as default. This indicates component won't be built by default.
4. Add variable X_depends=("X" <list of dependencies seperated by space>). First value should be component itself.
5. Add a switch case in enable_build_flags() function mapping the component folder name to above X_build variable.
6. Add a line need_component_rebuild "${X_depends[@]}" in prepare_dependent_component_list function. Add this line in way, such that is below all the dependent component lines in function need_component_rebuild. For examples, if component X is dependent on A and B, then add as below:

    - need_component_rebuild "{A_depends[@]}"
    - need_component_rebuild "{B_depends[@]}"
    - ...
    - need_component_rebuild "{X_depends[@]}"
