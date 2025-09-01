resource "kubernetes_manifest" "argocd_root_app" {
  manifest = yamldecode(file("${path.module}/../gitops/apps/root-app.yaml"))

  depends_on = [
    helm_release.argocd
  ]
}

resource "kubernetes_manifest" "argocd_project_cluster" {
  manifest = yamldecode(file("${path.module}/../gitops/apps/projects/cluster.yaml"))
  depends_on = [
    helm_release.argocd
  ]
}

resource "kubernetes_manifest" "argocd_project_apps" {
  manifest = yamldecode(file("${path.module}/../gitops/apps/projects/apps.yaml"))
  depends_on = [
    helm_release.argocd
  ]
}

