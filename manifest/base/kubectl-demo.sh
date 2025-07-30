#!/bin/bash

test_kubectl() {
  echo "Testing kubectl"
  mkdir -p $HOME/.kube

  echo "  Using In-cluster discovery:"

  ANS=$(kubectl auth whoami -ojsonpath="{.status.userInfo.username}")
  if [ "$ANS" != "system:serviceaccount:demo:default" ]; then
    echo "    error: not running under the expected service account"
  fi

  export KUBECONFIG=/scripts/kubeconfig
  echo "  Using explicit KUBECONFIG:"

  # the kubeconfig impersonates as demo user, so we can check whether kubectl actually loaded the kubeconfig
  ANS=$(kubectl auth whoami -ojsonpath="{.status.userInfo.username}")
  if [ "$ANS" != "demo" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi

  unset KUBECONFIG
  cp /scripts/kubeconfig ~/.kube/config
  echo "  Adding ~/.kube/config:"

  # the kubeconfig impersonates as demo user, so we can check whether kubectl actually loaded the kubeconfig
  ANS=$(kubectl auth whoami -ojsonpath="{.status.userInfo.username}")
  if [ "$ANS" != "demo" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi
}

test_kubectl || true

sleep infinity
