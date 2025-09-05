get_git_label<-function() {
  gitBranch=names(git2r::branches())[1]
  gitTag=names(git2r::tags())
  gitCommit=substr(git2r::commits()[[1]][1]$sha,1,8)
  paste0(gitTag,"-",gitBranch,"-",gitCommit)
}
