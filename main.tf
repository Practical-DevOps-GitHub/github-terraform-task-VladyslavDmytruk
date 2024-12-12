provider "github" {
  token = "ghp_hdwa6UjIHHFEIml8eHrxzn3lCocdL208k12fdff" 
# Replace with your GitHub Personal Access Token
}

resource "github_repository" "repo" {
  name        = "github-terraform-task-VladyslavDmytruk"
  description = "Repository configured with Terraform"
  visibility  = "private"
  has_issues  = true
  has_projects = true
  has_wiki    = true
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_branch_protection_v3" "develop " {
  repository_id = github_repository.repo.name
  pattern       = "develop "

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
  enforce_admins = false
  restrictions {
    users = []
    teams = []
  }

}

resource "github_branch_protection_v3" "develop" {
  repository_id = github_repository.repo.name
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 2
  }
  enforce_admins = false
  restrictions {
    users = []
    teams = []
  }
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  file       = ".github/pull_request_template.md"
  content    = <<EOT
Describe your changes
Issue ticket number and link
Checklist before requesting a review:
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOT
}

resource "github_repository_deploy_key" "deploy_key" {
  repository    = github_repository.repo.name
  title         = "DEPLOY_KEY"
 key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNZ6iV1LiJsVc2miHnD/nPq1gPFTB9obNtOjQ1sMsUeIJV/ub4eujEDh2rRN80qOglUvmqCI6MCs7/5wgh8RmYHpdhIjTNHyFbW4WKgPi2hQBP4z2CM8TRnnESvR9QZtzBQuOxzEXshbvUY90IspFNo8XtRPRPAIQrJZZq/sxltGjVXJHrhyoYOUeHeiXdtMXNFZ09sH30XENNDmTTxMeHxLYhNUGwTEOVm8zQkfuLqPZLz2MVIo8uqkV0yTnr0tc6moQUJoUrk9/oUC7/Kuqe/ATE6fMKDnEX1C2oom5t5VRB97t64Pc75WnFFUd603WZ3TUIeT5+N5QffORflGorA7jpQDq9sfkI37DWhfqRyPwZ3BCGe8+0rZmDXY1WjlG7dLKcAQAcGNvSlEHvmFerg7M4ybucRnY6IsldUUoiF+X9gc/PhXBadOTvfbXms74SNAqGObnqitE2Lcs3KbcPoBweDdMjLdjKGSVs+jDe4XsKFKtaSJmxyh7dntqHLM+qh2IhrjSto5xVmtTTEPgONeWdoDqO1hOeGExUMfMTjDDhKT58RO20bailsRzv08GnQcNFpTg47n3mstzZqJJRegcw+nD/uRILfO61+nxWddXD8GrxjWfgNRjsNJYINee7vN6Lmo6t2GQyO8XsdfsdfsdfskMoQ== vladsontv95@gmail.com" 
  read_only     = false
}

resource "github_repository_file" "codeowners" {
  repository = github_repository.repo.name
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
}

resource "github_actions_secret" "pat" {
  repository = github_repository.repo.name
  secret_name = "PAT"
  plaintext_value = "<YOUR_GITHUB_PAT>"
}

output "repository_url" {
  value = github_repository.repo.html_url
}
