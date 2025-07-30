# surprising-kubeconfig

The controller runtime uses this specific order where in-cluster wins over $HOME/.kube/config

```
	// GetConfig creates a *rest.Config for talking to a Kubernetes apiserver.
	// If --kubeconfig is set, will use the kubeconfig file at that location.  Otherwise will assume running
	// in cluster and use the cluster provided kubeconfig.
	//
	// The returned `*rest.Config` has client-side ratelimting disabled as we can rely on API priority and
	// fairness. Set its QPS to a value equal or bigger than 0 to re-enable it.
	//
	// Config precedence
	//
	// * --kubeconfig flag pointing at a file
	//
	// * KUBECONFIG environment variable pointing at a file
	//
	// * In-cluster config if running in cluster
	//
	// * $HOME/.kube/config if exists.
	GetConfig = config.GetConfig
```

That's surprising because it's different from the order that `kubectl` uses.

This repo contains a test case that proves that the controller-runtime discovery implementation indeed follows its documentation
and that it indeed diverges from the behaviour of `kubectl`.

The demo shell scripts (one for the controller-runtime Go binary and one that uses kubectl) use assertions to prove facts
and print an error otherwise.

You can re-run the test case and see that there are no errors and thus that the assertions prove facts about kubectl and controller-runtime
k8s config discovery ordering.

```console
$ ctrlptl apply -f ctlptl.yml
$ tilt ci
$ kubectl -n demo logs deploy/demo
Testing 'controller-runtime Go binary
  Using In-cluster discovery:
  Adding ~/.kube/config:
  Using explicit KUBECONFIG=~/.kube/config :
  Disable in-cluster discovery and have it use ~/.kube/config:
$ kubectl -n demo logs deploy/kubectl-demo
Testing kubectl
  Using In-cluster discovery:
  Using explicit KUBECONFIG:
  Adding ~/.kube/config:
```

