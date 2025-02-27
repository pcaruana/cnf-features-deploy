module github.com/openshift-kni/cnf-features-deploy

go 1.16

require (
	github.com/coreos/go-systemd v0.0.0-20191104093116-d3cd4ed1dbcf // indirect
	github.com/coreos/ignition v0.35.0
	github.com/gatekeeper/gatekeeper-operator v0.1.1
	github.com/ghodss/yaml v1.0.1-0.20190212211648-25d852aebe32
	github.com/golang/glog v0.0.0-20210429001901-424d2337a529
	github.com/ishidawataru/sctp v0.0.0-20191218070446-00ab2ac2db07
	github.com/k8snetworkplumbingwg/network-attachment-definition-client v0.0.0-20200626054723-37f83d1996bc
	github.com/k8snetworkplumbingwg/sriov-network-operator v1.0.1-0.20211126031536-11faae79733e
	github.com/kennygrant/sanitize v1.2.4
	github.com/lack/mcmaker v0.0.5
	github.com/metallb/metallb-operator v0.0.0-20211202081249-1b0df396f552
	github.com/onsi/ginkgo v1.16.4
	github.com/onsi/gomega v1.16.0
	github.com/open-policy-agent/frameworks/constraint v0.0.0-20211123155909-217139c4a6bd
	github.com/open-policy-agent/gatekeeper v0.0.0-20211201075931-d7de2a075a41
	github.com/openshift-kni/performance-addon-operators v0.0.0-20210722194338-183a9c3da026
	github.com/openshift-psap/special-resource-operator v0.0.0-20210726202540-2fdec192a48e
	github.com/openshift/api v3.9.1-0.20191213091414-3fbf6bcf78e8+incompatible
	github.com/openshift/client-go v3.9.0+incompatible
	github.com/openshift/cluster-nfd-operator v0.0.0-20210727033955-e8e9697b5ffc
	github.com/openshift/cluster-node-tuning-operator v0.0.0-20200914165052-a39511828cf0
	github.com/openshift/machine-config-operator v4.2.0-alpha.0.0.20190917115525-033375cbe820+incompatible
	github.com/openshift/ptp-operator v0.0.0-20210714172658-472d32e04af5
	github.com/smart-edge-open/openshift-operator/N3000 v0.0.0-20210929104519-4a309763e614
	github.com/smart-edge-open/openshift-operator/sriov-fec v0.0.0-20210929104519-4a309763e614
	github.com/spf13/cobra v1.1.3
	github.com/stretchr/testify v1.7.0
	golang.org/x/sys v0.0.0-20210817190340-bfb29a6856f2
	gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b
	k8s.io/api v0.22.2
	k8s.io/apiextensions-apiserver v0.22.2
	k8s.io/apimachinery v0.22.2
	k8s.io/client-go v12.0.0+incompatible
	k8s.io/klog v1.0.0
	k8s.io/kubelet v0.21.2
	k8s.io/kubernetes v1.21.1
	k8s.io/utils v0.0.0-20210819203725-bdf08cb9a70a
	kubevirt.io/qe-tools v0.1.6
	sigs.k8s.io/controller-runtime v0.10.2
)

// Pinned to kubernetes-1.21.2
replace (
	k8s.io/api => k8s.io/api v0.21.2
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.21.2
	k8s.io/apimachinery => k8s.io/apimachinery v0.21.2
	k8s.io/apiserver => k8s.io/apiserver v0.21.2
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.21.2
	k8s.io/client-go => k8s.io/client-go v0.21.2
	k8s.io/cloud-provider => k8s.io/cloud-provider v0.21.2
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.21.2
	k8s.io/code-generator => k8s.io/code-generator v0.21.2
	k8s.io/component-base => k8s.io/component-base v0.21.2
	k8s.io/component-helpers => k8s.io/component-helpers v0.21.2
	k8s.io/controller-manager => k8s.io/controller-manager v0.21.2
	k8s.io/cri-api => k8s.io/cri-api v0.21.2
	k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.21.2
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.21.2
	k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.21.2
	k8s.io/kube-proxy => k8s.io/kube-proxy v0.21.2
	k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.21.2
	k8s.io/kubectl => k8s.io/kubectl v0.21.2
	k8s.io/kubelet => k8s.io/kubelet v0.21.2
	k8s.io/kubernetes => k8s.io/kubernetes v1.21.2
	k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.21.2
	k8s.io/metrics => k8s.io/metrics v0.21.2
	k8s.io/mount-utils => k8s.io/mount-utils v0.21.2
	k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.21.2
)

// Other pinned deps
replace (
	github.com/apache/thrift => github.com/apache/thrift v0.14.0
	github.com/cri-o/cri-o => github.com/cri-o/cri-o v1.18.1
	github.com/go-log/log => github.com/go-log/log v0.1.0
	github.com/gorilla/websocket => github.com/gorilla/websocket v1.4.2
	github.com/mtrmac/gpgme => github.com/mtrmac/gpgme v0.1.1
	github.com/openshift/api => github.com/openshift/api v0.0.0-20210713130143-be21c6cb1bea // release-4.8
	github.com/openshift/client-go => github.com/openshift/client-go v0.0.0-20210521082421-73d9475a9142 // release-4.8
	github.com/openshift/cluster-node-tuning-operator => github.com/openshift/cluster-node-tuning-operator v0.0.0-20210303185751-cbeeb4d9f3cc // release-4.9
	github.com/openshift/library-go => github.com/openshift/library-go v0.0.0-20210706120254-6f1208ffd780 // release-4.8
	github.com/openshift/machine-config-operator => github.com/openshift/machine-config-operator v0.0.1-0.20210701174259-29813c845a4a // release-4.8
	sigs.k8s.io/controller-runtime => sigs.k8s.io/controller-runtime v0.9.2
)

// Test deps
replace (
	github.com/k8snetworkplumbingwg/sriov-network-operator => github.com/openshift/sriov-network-operator v0.0.0-20211207043958-2bfa00ead503 // release-4.10
	github.com/metallb/metallb-operator => github.com/openshift/metallb-operator v0.0.0-20220126083843-10d63d74c04c //release-4.10
	github.com/openshift-kni/performance-addon-operators => github.com/openshift-kni/performance-addon-operators v0.0.0-20211108074240-1544d9d65408 // release-4.10
	github.com/openshift-psap/special-resource-operator => github.com/openshift/special-resource-operator v0.0.0-20211202035230-4c86f99c426b // release-4.10
	github.com/openshift/cluster-nfd-operator => github.com/openshift/cluster-nfd-operator v0.0.0-20210727033955-e8e9697b5ffc // release-4.9
	github.com/openshift/ptp-operator => github.com/openshift/ptp-operator v0.0.0-20211201021143-27df2443c98f //release-4.10
)
