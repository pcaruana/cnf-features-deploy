# GitOps ZTP pipeline
![GitOps ZTP flow overview](ztp_gitops_flow.png)

## Installing the GitOps Zero Touch Provisioning pipeline

### Preparation of ZTP GIT repository
Create a GIT repository for hosting site configuration data. The ZTP pipeline will require read access to this repository.
1. Create a directory structure with separate paths for SiteConfig and PolicyGenTemplate CRs
2. Export the argocd directroy from the ztp-site-generator container image by executing the following commands
```
    $ podman pull quay.io/redhat_emp1/ztp-site-generator:latest
    $ mkdir -p ./out
    $ podman run --rm ztp-site-generator:latest extract /home/ztp --tar | tar x -C ./out
```
3. Check the out directory that created above. It contains the following sub directories
  - out/extra-manifest: contains the source CRs files that SiteConfig uses to generate extra manifest configMap.
  - out/source-crs: contains the source CRs files that PolicyGenTemplate uses to generate the ACM policies.
  - out/argocd/deployment: contains patches and yaml file to apply on the hub cluster for use in the next step of this procedure.
  - out/argocd/example: contains example SiteConfig and PolicyGenTemplate that represent our recommended configuration.

### Preparation of Hub cluster for ZTP
These steps configure your hub cluster with a set of ArgoCD Applications which generate the required installation and policy CRs for each site based on a ZTP gitops flow.

**Requirements:**
- Openshift Cluster v4.8/v4.9 as Hub cluster
- Advanced Cluster Management (ACM) operator v2.3/v2.4 installed in the hub cluster
- Red Hat OpenShift GitOps operator v1.3 on the hub cluster

**Steps:**
1. Install the [Topology Aware Lifecycle Operator](https://github.com/openshift-kni/cluster-group-upgrades-operator#readme), which will coordinate with any new sites added by ZTP and manage application of the PGT-generated policies.
2. Patch the ArgoCD instance in the hub cluster using the patch files previously extracted into the out/argocd/deployment/ directory:
```
    $ oc patch argocd openshift-gitops -n openshift-gitops  --patch-file out/argocd/deployment/argocd-openshift-gitops-patch.json --type=merge
    $ oc patch deployment openshift-gitops-repo-server -n openshift-gitops --patch-file out/argocd/deployment/deployment-openshift-repo-server-patch.json
```
3. Prepare the ArgoCD pipeline configuration
- Create a git repository with directory structure similar to the example directory.
- Configure access to the repository using the ArgoCD UI. Under Settings configure:
  - Repositories --> Add connection information (URL ending in .git, eg https://repo.example.com/repo.git, and credentials)
  - Certificates --> Add the public certificate for the repository if needed
- Modify the two ArgoCD Applications (out/argocd/deployment/clusters-app.yaml and out/argocd/deployment/policies-app.yaml) based on your GIT repository:
  - Update URL to point to git repository. The URL must end with .git, eg: https://repo.example.com/repo.git
  - The targetRevision should indicate which branch to monitor
  - The path should specify the path to the SiteConfig or PolicyGenTemplate CRs respectively
4. Apply pipeline configuration to your *hub* cluster using the following command.
```
    oc apply -k out/argocd/deployment
```

### Deploying a site
The following steps prepare the hub cluster for site deployment and initiate ZTP by pushing CRs to your GIT repository.
- Add required secrets for site to the hub cluster. These resources must be in a namespace with a name matching the cluster name. In the example the cluster name & namespace is `test-sno`
    1. Create secret for authenticating to the site BMC. Ensure the secret name matches the name used in the SiteConfig. In the example SiteConfig this is named `test-sno-bmh-secret`.
    2. Create pull secret for site. The pull secret must contain all credentials necessary for installing OpenShift and all required operators. In the example SiteConfig this is named `assisted-deployment-pull-secret`
- Add the SiteConfig CR for your site to your git repository
    Note: The extra-manifest Machine configs exist under [source-crs/extra-manifest](https://github.com/openshift-kni/cnf-features-deploy/tree/master/ztp/source-crs/extra-manifest) will be included in the generated configMap for extra manifest.
    Optional: For adding other extra-manifests to the provisioned cluster, create a directory ex; `sno-extra-manifest/` in relative path at siteconfig GIT repository and add the extra-manifest files to it. Then in the SiteConfig.yaml  set the extraManifestPath field ex; `extraManifestPath: sno-extra-manifest/` .
- Add the PolicyGenTemplate CR for your site to your git repository
- Push your changes to the git repository. The SiteConfig and PolicyGenTemplate CRs may be pushed simultaneously.

### Monitoring progress
The ArgoCD pipeline uses the SiteConfig and PolicyGenTemplate CRs in GIT to generate the cluster configuration CRs & ACM policies then sync them to the hub.

The progress of this synchronization can be monitored in the ArgoCD dashboard.

Once the synchonization is complete, the installation generally proceeds in two phases:

1. The Assisted Service Operator installs OpenShift on the cluster

The progress of cluster installation can be monitored from the ACM dash board, or the command line:
```
     $ export CLUSTER=<clusterName>
     $ oc get agentclusterinstall -n $CLUSTER $CLUSTER -o jsonpath='{.status.conditions[?(@.type=="Completed")]}' | jq
     $ curl -sk $(oc get agentclusterinstall -n $CLUSTER $CLUSTER -o jsonpath='{.status.debugInfo.eventsURL}')  | jq '.[-2,-1]'
```

2. The Topology Aware Lifecycle Operator then applies the configuration policies which are bound to the cluster

Each cluster's policies will be applied in the order defined by the ran.openshift.io/ztp-deploy-wave annotations.

The progress of configuration policy reconciliation can be monitored in the ACM dash board.

The final policy that will become compliant is the one defined in the `du-validator-policy-*` policies. This policy, when compliant on a cluster, corresponds to the ZTP process completing, ensuring that all cluster configuration, operator installation, and operator configuration has completed.

### Site Cleanup
To remove a site and the associated installation and configuration policy CRs by removing the SiteConfig & PolicyGenTemplate file name from the kustomization.yaml file. The generated CRs will be removed as well.
**NOTE: After removing the SiteConfig file, if its corresponding clusters stuck in the detach process check [ACM page](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.4/html/clusters/managing-your-clusters#remove-managed-cluster) how to clean detach managed cluster **

### Pipeline Teardown
If you need to remove the ArgoCD pipeline and all generated artifacts follow this procedure
1. Detach all clusters from ACM
1. Delete the kustomization.yaml under deployment directory
```
    $ oc delete -k out/argocd/deployment
```

## Troubleshooting GitOps ZTP
As noted above the ArgoCD pipeline uses the SiteConfig and PolicyGenTemplate CRs from GIT to generate the cluster configuration CRs & ACM policies. The following steps can be used to troubleshoot issues that may occur in this process.

### Validate generation of installation CRs
The installation CRs are applied to the hub cluster in a namespace with name matching the site name.  
```
    $ oc get AgentClusterInstall -n <clusterName>
```
If no object is returned, troubleshoot the ArgoCD pipeline flow from SiteConfig to installation CRs.

1. Did the SiteConfig->ManagedCluster get generated to the hub cluster ?
```
     $ oc get managedcluster
```
If the SiteConfig->ManagedCluster is missing, check the `clusters` application failed to synchronize the files from GIT to the hub.
```
    $ oc describe -n openshift-gitops application clusters 
```

Check for `Status: Conditions:` it will show error logs ex; setting invalid `extraManifestPath: ` in the siteConfig will raise error as below.
```
Status:
  Conditions:
    Last Transition Time:  2021-11-26T17:21:39Z
    Message:               rpc error: code = Unknown desc = `kustomize build /tmp/https___git.com/ran-sites/siteconfigs/ --enable-alpha-plugins` failed exit status 1: 2021/11/26 17:21:40 Error could not create extra-manifest ranSite1.extra-manifest3 stat extra-manifest3: no such file or directory
2021/11/26 17:21:40 Error: could not build the entire SiteConfig defined by /tmp/kust-plugin-config-913473579: stat extra-manifest3: no such file or directory
Error: failure in plugin configured via /tmp/kust-plugin-config-913473579; exit status 1: exit status 1
    Type:  ComparisonError
```

Check for `Status: Sync:` if there are log errors the `Sync: Status:` could be as below `Unknown` / `Error`.
```
Status:
  Sync:
    Compared To:
      Destination:
        Namespace:  clusters-sub
        Server:     https://kubernetes.default.svc
      Source:
        Path:             sites-config
        Repo URL:         https://git.com/ran-sites/siteconfigs/.git
        Target Revision:  master
    Status:               Unknown
```
 

### Validate generation of configuration policy CRs

Policy CRs are generated in the same namespace as the PolicyGenTemplate from which they were created. The same troubleshooting flow applies to all policy CRs generated from PolicyGenTemplates regardless of whether they are ztp-common, ztp-group or ztp-site based.  
```
    $ export NS=<namespace>
    $ oc get policy -n $NS
```
The expected set of policy wrapped CRs should be displayed.

If the Policies failed synchronized follow these troubleshooting steps:

```
    $ oc describe -n openshift-gitops application policies 
```

1. Check for `Status: Conditions:` which will show error logs. For example, setting an invalid `sourceFile->fileName:` will generate an error as below. 
```
Status:
  Conditions:
    Last Transition Time:  2021-11-26T17:21:39Z
    Message:               rpc error: code = Unknown desc = `kustomize build /tmp/https___git.com/ran-sites/policies/ --enable-alpha-plugins` failed exit status 1: 2021/11/26 17:21:40 Error could not find test.yaml under source-crs/: no such file or directory
Error: failure in plugin configured via /tmp/kust-plugin-config-52463179; exit status 1: exit status 1
    Type:  ComparisonError
```

1. Check for `Status: Sync:`. If there are log errors at `Status: Conditions:`, the `Sync: Status:` will be as `Unknown` or `Error`.
```
Status:
  Sync:
    Compared To:
      Destination:
        Namespace:  policies-sub
        Server:     https://kubernetes.default.svc
      Source:
        Path:             policies
        Repo URL:         https://git.com/ran-sites/policies/.git
        Target Revision:  master
    Status:               Error
```

1. Did the policies get copied to the cluster namespace?
When ACM recognizes that policies apply to a ManagedCluster, the policy CR objects are applied to the cluster namespace.
```
    $ oc get policy -n <clusterName>
```
All applicable policies should be copied here by ACM (ie should show common, group and site policies). The policy names are `<policyGenTemplate.Name>.<policyName>`

1. For any policies not copied to the cluster namespace check the placement rule.
The matchSelector in the PlacementRule for those policies should match labels on the ManagedCluster.
```
    $ oc get placementrule -n $NS`
```
Make note of the PlacementRule name appropriate for the missing policy (eg common, group or site)
```
    $ oc get placementrule -n $NS <placmentRuleName> -o yaml
```
- The status/decisions should include your cluster name
- The key/value of the matchSelector in the spec should match the labels on your managed cluster.
Check labels on MangedCluster:  
```
    $ oc get ManagedCluster $CLUSTER -o jsonpath='{.metadata.labels}' | jq
```
1. Are some policies compliant and others not
```
    $ oc get policy -n $CLUSTER
```
If the Namespace, OperatorGroup, and Subscription policies are compliant but the operator configuration policies are not it is likely that the operators did not install on the spoke cluster. This causes the operator config policies to fail to apply because the CRD is not yet applied to spoke.
