#!/bin/sh

test_surprising_kubeconfig() {
  export HOME=/tmp/root
  mkdir -p $HOME/.kube

  echo "Testing 'controller-runtime Go binary"

  echo "  Using In-cluster discovery:"

  ANS=$(surprising-kubeconfig whoami)
  if [ "$ANS" != "system:serviceaccount:demo:default" ]; then
    echo "    error: not running under the expected service account, got: '$ANS'"
  fi

  ANS=$(surprising-kubeconfig -n default can-i) 
  if [ "$ANS" != "no" ]; then
    echo "    error: we don't have permissions to get pods in default namespace"
  fi

  ANS=$(surprising-kubeconfig -n demo can-i) 
  if [ "$ANS" != "yes" ]; then
    echo "    error: we do have permissions to get pods in demo namespace"
  fi

  cp /scripts/kubeconfig ~/.kube/config
  echo "  Adding ~/.kube/config:"

  # the kubeconfig impersonates as demo user, so we can check whether kubectl actually loaded the kubeconfig.
  # Despite the kubeconfig is there, controller-runtime doesn't load it.
  ANS=$(surprising-kubeconfig whoami)
  if [ "$ANS" != "system:serviceaccount:demo:default" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi

  echo "  Using explicit KUBECONFIG=~/.kube/config :"
  export KUBECONFIG=~/.kube/config

  # now, the kubeconfig is loaded and we can see the expected user the kubeconfig impersonates as.
  ANS=$(surprising-kubeconfig whoami)
  if [ "$ANS" != "demo" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi

  echo "  Disable in-cluster discovery and have it use ~/.kube/config:"
  unset KUBECONFIG
  unset KUBERNETES_SERVICE_HOST
  unset KUBERNETES_SERVICE_PORT
  # now, let's disable the in-cluster discovery and you'll see that the kubeconfig from ~/.kube/config is used
  ANS=$(surprising-kubeconfig whoami)
  if [ "$ANS" != "demo" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi
}

test_surprising_kubeconfig || true

sleep infinity
