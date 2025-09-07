#' Generate git-based label for output files
#'
#' Creates a descriptive label containing the latest git tag, current branch name,
#' and short commit SHA for tracking which version of code generated output files.
#' This enables reproducible research by clearly identifying the code state.
#'
#' @return Character string in format "tag-branch-commit" (e.g., "v1.0.0-main-a1b2c3d4")
#'
#' @details The function prioritizes the most recent git tag. If no tags exist,
#'   it uses "no-tag" as a placeholder. The commit SHA is truncated to 8 characters
#'   for readability while maintaining uniqueness.
#'
#' @examples
#' \dontrun{
#' # Generate output filename with version info
#' output_file <- paste0("analysis_", get_git_label(), ".pdf")
#' }
get_git_label <- function() {
  # Get current branch name (first branch in list is typically current)
  git_branch <- names(git2r::branches())[1]

  # Get all available git tags
  git_tags <- names(git2r::tags())

  # Select most recent tag or fallback to "no-tag"
  git_tag <- if (length(git_tags) > 0) {
    git_tags[length(git_tags)]  # Last tag is most recent
  } else {
    "no-tag"
  }

  # Get short commit SHA (8 characters for uniqueness + readability)
  git_commit <- substr(git2r::commits()[[1]][1]$sha, 1, 8)

  # Combine components with hyphens for readability
  if(git_branch=="master") {
    paste0(git_tag)
  } else {
    paste0(git_tag, "-", git_branch, "-", git_commit)
  }
}
