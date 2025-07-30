package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	authenticationv1 "k8s.io/api/authentication/v1"
	authorizationv1 "k8s.io/api/authorization/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	ctrl "sigs.k8s.io/controller-runtime"
)

var (
	namespace = flag.String("n", "", "namespace to test")
)

func canI(ctx context.Context, cl *kubernetes.Clientset) error {
	req := &authorizationv1.SelfSubjectAccessReview{
		Spec: authorizationv1.SelfSubjectAccessReviewSpec{
			ResourceAttributes: &authorizationv1.ResourceAttributes{
				Resource:  "pods",
				Verb:      "list",
				Namespace: *namespace,
			},
		},
	}
	res, err := cl.AuthorizationV1().SelfSubjectAccessReviews().Create(ctx, req, metav1.CreateOptions{})
	if err != nil {
		return fmt.Errorf("failed to create self subject access review: %w", err)
	}

	if false {
		fmt.Fprintf(os.Stderr, "      Checking ns: %q\tAllow: %v\tReason: %q\n", *namespace, res.Status.Allowed, res.Status.Reason)
	}

	if res.Status.Allowed {
		fmt.Println("yes")
	} else {
		fmt.Println("no")
	}
	return nil
}

func whoami(ctx context.Context, cl *kubernetes.Clientset) error {
	res, err := cl.AuthenticationV1().SelfSubjectReviews().Create(ctx, &authenticationv1.SelfSubjectReview{}, metav1.CreateOptions{})
	if err != nil {
		return fmt.Errorf("failed to create self subject review: %w", err)
	}

	fmt.Println(res.Status.UserInfo.Username)
	return nil
}

func mainE() error {
	ctx := context.Background()

	cfg, err := ctrl.GetConfig()
	if err != nil {
		return err
	}

	cl, err := kubernetes.NewForConfig(cfg)
	if err != nil {
		return fmt.Errorf("failed to create clientset: %w", err)
	}

	if got, want := flag.NArg(), 1; got != want {
		return fmt.Errorf("expected %d argument, got %d", want, got)
	}

	switch cmd := flag.Arg(0); cmd {
	case "can-i":
		return canI(ctx, cl)
	case "whoami":
		return whoami(ctx, cl)
	default:
		return fmt.Errorf("unknown command: %#v", flag.Args())
	}
}

func main() {
	flag.Parse()

	if err := mainE(); err != nil {
		log.Fatal(err)
	}
}
