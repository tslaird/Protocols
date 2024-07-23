## Project organization

Projects can be organized in the following way:
```
README.md
data/
results/
  figures/
  manuscripts/
sandbox/
src/
workflow/
  snakefile.smk
  envs/
  benchmarks/
  backup.sh
```

The .gitignore file should have
```
*
!src/*
!workflow/*
!*/
```

