# NeuroscienceTasks
Repository containing computational neuroscience tasks.

## Authors
- João Amaro, Faculty of Medicine, University of Lisbon
- Pedro Rocha, Faculty of Medicine, University of Lisbon

## TODO
- [ ] Add the neurosurgery task paradigms.

## Code

Merging other repositories into this one:
```shell
cd C:/Users/joaop/git/JoaoAmaro2001/NeuroscienceTasks

git remote add psychiatry-study ../psychiatry-study
git fetch psychiatry-study
git subtree add --prefix=psychiatry-study psychiatry-study main

git remote add task-experiment1 ../task-experiment1
git fetch task-experiment1
git subtree add --prefix=task-experiment1 task-experiment1 main

git remote add task-experiment1_depression ../task-experiment1_depression
git fetch task-experiment1_depression
git subtree add --prefix=task-experiment1_depression task-experiment1_depression main

git remote add task-experiment2_mri ../task-experiment2_mri
git fetch task-experiment2_mri
git subtree add --prefix=task-experiment2_mri task-experiment2_mri main

git remote add task-experiment2_optimized ../task-experiment2_optimized
git fetch task-experiment2_optimized
git subtree add --prefix=task-experiment2_optimized task-experiment2_optimized main

git remote add task-experiment5 ../task-experiment5
git fetch task-experiment5
git subtree add --prefix=task-experiment5 task-experiment5 main
```

Update from remote (Example from psychiatry study):
```shell
git fetch psychiatry-study
git subtree pull \
  --prefix=psychiatry-study \
  psychiatry-study \
  main
```
