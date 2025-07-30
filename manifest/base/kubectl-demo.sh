#!/bin/bash

test_kubectl() {
  echo "Testing kubectl"

  echo "  Using In-cluster discovery:"

  ANS=$(kubectl auth whoami -ojsonpath="{.status.userInfo.username}")
  if [ "$ANS" != "system:serviceaccount:demo:default" ]; then
    echo "    error: not running under the expected service account"
  fi

  ANS=$(kubectl auth can-i get pod -n default) 
  if [ "$ANS" != "no" ]; then
    echo "    error: we don't have permissions to get pods in default namespace"
  fi

  ANS=$(kubectl auth can-i get pod -n demo) 
  if [ "$ANS" != "yes" ]; then
    echo "    error: we do have permissions to get pods in demo namespace"
  fi

  ANS=$(kubectl auth can-i get pod) 
  if [ "$ANS" != "yes" ]; then
    echo "    error: the default namespace should be 'demo'"
  fi

  export KUBECONFIG=/scripts/kubeconfig
  echo "  Using explicit KUBECONFIG:"

  # the kubeconfig impersonates as demo user, so we can check whether kubectl actually loaded the kubeconfig
  ANS=$(kubectl auth whoami -ojsonpath="{.status.userInfo.username}")
  if [ "$ANS" != "demo" ]; then
    echo "    error: not running under the expected service account but running under: $ANS"
  fi

  # interestingly, the kubeconfig doesn't set the default namespace, but kubectl
  # honurs the one set in /var/run/secrets/kubernetes.io/serviceaccount/namespace anyway
  ANS=$(kubectl auth can-i get pod) 
  if [ "$ANS" != "yes" ]; then
    echo "    error: since we have permissions, the default namespace cannot be 'default'"
  fi
}

test_kubectl || true

sleep infinity
