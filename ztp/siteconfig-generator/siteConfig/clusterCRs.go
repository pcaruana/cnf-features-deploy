package siteConfig

const clusterCRs = `
apiVersion: v1
kind: Namespace
metadata:
  name: siteconfig.Spec.Clusters.ClusterName
  labels:
    name: siteconfig.Spec.Clusters.ClusterName
  annotations:
    argocd.argoproj.io/sync-wave: "0"
---
apiVersion: extensions.hive.openshift.io/v1beta1
kind: AgentClusterInstall
metadata:
  name: siteconfig.Spec.Clusters.ClusterName
  namespace: siteconfig.Spec.Clusters.ClusterName
  annotations:
    agent-install.openshift.io/install-config-overrides: siteconfig.Spec.Clusters.NetworkType
    argocd.argoproj.io/sync-wave: "1"
spec:
  clusterDeploymentRef:
    name: siteconfig.Spec.Clusters.ClusterName
  imageSetRef:
    name: siteconfig.Spec.Clusters.ClusterImageSetNameRef
  apiVIP: siteconfig.Spec.Clusters.ApiVIP
  ingressVIP: siteconfig.Spec.Clusters.IngressVIP
  networking:
    clusterNetwork: siteconfig.Spec.Clusters.ClusterNetwork
    machineNetwork: siteconfig.Spec.Clusters.MachineNetwork
    serviceNetwork: siteconfig.Spec.Clusters.ServiceNetwork
  provisionRequirements:
    controlPlaneAgents: siteconfig.Spec.Clusters.NumMasters
    workerAgents: siteconfig.Spec.Clusters.NumWorkers
  sshPublicKey: siteconfig.Spec.SshPublicKey
  manifestsConfigMapRef:
    name: siteconfig.Spec.Clusters.ClusterName
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: siteconfig.Spec.Clusters.ClusterName
  namespace: siteconfig.Spec.Clusters.ClusterName
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  baseDomain: siteconfig.Spec.BaseDomain
  clusterInstallRef:
    group: extensions.hive.openshift.io
    kind: AgentClusterInstall
    name: siteconfig.Spec.Clusters.ClusterName
    version: v1beta1
  clusterName: siteconfig.Spec.Clusters.ClusterName
  platform:
    agentBareMetal:
      agentSelector:
        matchLabels:
          cluster-name: siteconfig.Spec.Clusters.ClusterName
  pullSecretRef:
    name: siteconfig.Spec.PullSecretRef.Name
---
apiVersion: agent-install.openshift.io/v1beta1
kind: NMStateConfig
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
  name: siteconfig.Spec.Clusters.Nodes.HostName
  namespace: siteconfig.Spec.Clusters.ClusterName
  labels:
    nmstate-label: siteconfig.Spec.Clusters.ClusterName
spec:
  config: siteconfig.Spec.Clusters.Nodes.NodeNetwork.Config
  interfaces: siteconfig.Spec.Clusters.Nodes.NodeNetwork.Interfaces
---
apiVersion: agent-install.openshift.io/v1beta1
kind: InfraEnv
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
  name: siteconfig.Spec.Clusters.ClusterName
  namespace: siteconfig.Spec.Clusters.ClusterName
spec:
  clusterRef:
    name: siteconfig.Spec.Clusters.ClusterName
    namespace: siteconfig.Spec.Clusters.ClusterName
  sshAuthorizedKey: siteconfig.Spec.SshPublicKey
  proxy: siteconfig.Spec.Clusters.ProxySettings
  pullSecretRef:
    name: siteconfig.Spec.PullSecretRef.Name
  ignitionConfigOverride: siteconfig.Spec.Clusters.IgnitionConfigOverride
  nmStateConfigLabelSelector:
    matchLabels:
      nmstate-label: siteconfig.Spec.Clusters.ClusterName
  additionalNTPSources: siteconfig.Spec.Clusters.AdditionalNTPSources
---
apiVersion: metal3.io/v1alpha1
kind: BareMetalHost
metadata:
  name: siteconfig.Spec.Clusters.Nodes.HostName
  namespace: siteconfig.Spec.Clusters.ClusterName
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    inspect.metal3.io: disabled
    bmac.agent-install.openshift.io/hostname: siteconfig.Spec.Clusters.Nodes.HostName
    bmac.agent-install.openshift.io/installer-args: siteconfig.Spec.Clusters.Nodes.InstallerArgs
    bmac.agent-install.openshift.io/ignition-config-overrides: siteconfig.Spec.Clusters.Nodes.IgnitionConfigOverride
    bmac.agent-install.openshift.io/role: siteconfig.Spec.Clusters.Nodes.Role
  labels:
    infraenvs.agent-install.openshift.io: siteconfig.Spec.Clusters.ClusterName
spec:
  bootMode: siteconfig.Spec.Clusters.Nodes.BootMode
  bmc:
    address: siteconfig.Spec.Clusters.Nodes.BmcAddress
    disableCertificateVerification: true
    credentialsName: siteconfig.Spec.Clusters.Nodes.BmcCredentialsName.Name
  bootMACAddress: siteconfig.Spec.Clusters.Nodes.BootMACAddress
  automatedCleaningMode: disabled
  online: true
  rootDeviceHints: siteconfig.Spec.Clusters.Nodes.RootDeviceHints
  userData:  siteconfig.Spec.Clusters.Nodes.UserData
  # TODO: https://github.com/openshift-kni/cnf-features-deploy/issues/619
---
# Extra manifest will be added to the data section
kind: ConfigMap
apiVersion: v1
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
  name: siteconfig.Spec.Clusters.ClusterName
  namespace: siteconfig.Spec.Clusters.ClusterName
data:
---
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: siteconfig.Spec.Clusters.ClusterName
  labels: siteconfig.Spec.Clusters.ClusterLabels
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  hubAcceptsClient: true
---
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "2"
  name: siteconfig.Spec.Clusters.ClusterName
  namespace: siteconfig.Spec.Clusters.ClusterName
spec:
  clusterName: siteconfig.Spec.Clusters.ClusterName
  clusterNamespace: siteconfig.Spec.Clusters.ClusterName
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  applicationManager:
    enabled: false
  certPolicyController:
    enabled: false
  iamPolicyController:
    enabled: false
  policyController:
    enabled: true
  searchCollector:
    enabled: false
`
