# conda



# conda cheatsheet
(taken from https://github.com/KorfLab/learning-conda)

To create a new environment for go development:
```conda create --name {environment_name}```

To activate the base environment:
```conda activate {environment_name}```

To deactivate conda and reset your shell to the OS default behavior (i.e. base environment):
```conda deactivate```

To export your environment as a yaml file:
```conda env export > env.yml```

To create an environment from a yaml:
```conda env create -f env.yml```

To remove an environment:
```conda env remove --name env_name_goes_here```
