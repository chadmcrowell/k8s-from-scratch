/*
Copyright 2025.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"
	"fmt"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	appsv1 "github.com/chadmcrowell/podset-operator/api/v1"
)

// PodSetReconciler reconciles a PodSet object
type PodSetReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=apps.example.com,resources=podsets,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=apps.example.com,resources=podsets/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=apps.example.com,resources=podsets/finalizers,verbs=update
// +kubebuilder:rbac:groups="",resources=configmaps,verbs=get;list;watch;create;update;patch;delete

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the PodSet object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.22.4/pkg/reconcile
func (r *PodSetReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx)

	// Fetch the PodSet resource
	var podSet appsv1.PodSet
	if err := r.Get(ctx, req.NamespacedName, &podSet); err != nil {
		return ctrl.Result{}, client.IgnoreNotFound(err)
	}

	// Log what we found
	log.Info("Reconciling PodSet", "name", podSet.Name, "replicas", podSet.Spec.Replicas)

	// Step 3: Create or update a ConfigMap
	configMap := &corev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:      podSet.Name + "-config",
			Namespace: podSet.Namespace,
		},
		Data: map[string]string{
			"replicas": fmt.Sprintf("%d", podSet.Spec.Replicas),
			"image":    podSet.Spec.Image,
			"status":   "managed-by-operator",
		},
	}

	// Set PodSet as owner of ConfigMap (for garbage collection)
	if err := ctrl.SetControllerReference(&podSet, configMap, r.Scheme); err != nil {
		log.Error(err, "Failed to set controller reference")
		return ctrl.Result{}, err
	}

	// Create or update ConfigMap
	err := r.Create(ctx, configMap)
	if err != nil {
		if errors.IsAlreadyExists(err) {
			log.Info("ConfigMap already exists, updating")
			if err := r.Update(ctx, configMap); err != nil {
				log.Error(err, "Failed to update ConfigMap")
				return ctrl.Result{}, err
			}
		} else {
			log.Error(err, "Failed to create ConfigMap")
			return ctrl.Result{}, err
		}
	}

	// Update PodSet status
	podSet.Status.Ready = true
	podSet.Status.Message = "ConfigMap created successfully"
	if err := r.Status().Update(ctx, &podSet); err != nil {
		log.Error(err, "Failed to update PodSet status")
		return ctrl.Result{}, err
	}

	log.Info("Successfully reconciled PodSet")
	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *PodSetReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&appsv1.PodSet{}).
		Named("podset").
		Complete(r)
}