/*
Copyright 2018 The Kubernetes Authors.

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

package main

import (
	"flag"
	"log"

	clusterapis "github.com/openshift/cluster-api/pkg/apis"
	"k8s.io/klog"
	"sigs.k8s.io/cluster-api-provider-openstack/pkg/apis"
	_ "sigs.k8s.io/cluster-api-provider-openstack/pkg/cloud/openstack/options"
	"sigs.k8s.io/cluster-api-provider-openstack/pkg/controller"
<<<<<<< HEAD
=======
	"sigs.k8s.io/cluster-api-provider-openstack/pkg/record"
	clusterapis "sigs.k8s.io/cluster-api/pkg/apis"
>>>>>>> 0911380a... Add Record of instance action (#351)
	"sigs.k8s.io/controller-runtime/pkg/client/config"
	"sigs.k8s.io/controller-runtime/pkg/manager"
	"sigs.k8s.io/controller-runtime/pkg/runtime/signals"
)

func main() {

	flag.Set("logtostderr", "true")
	klog.InitFlags(nil)
	flag.Parse()

	// Get a config to talk to the apiserver
	cfg, err := config.GetConfig()
	if err != nil {
		klog.Fatal(err)
	}

	// Create a new Cmd to provide shared dependencies and start components
	mgr, err := manager.New(cfg, manager.Options{})
	if err != nil {
		klog.Fatal(err)
	}

	record.InitFromRecorder(mgr.GetRecorder("openstack-controller"))
	klog.Infof("Initializing Dependencies.")

	// Setup Scheme for all resources
	if err := apis.AddToScheme(mgr.GetScheme()); err != nil {
		klog.Fatal(err)
	}

	if err := clusterapis.AddToScheme(mgr.GetScheme()); err != nil {
		klog.Fatal(err)
	}

	// Setup all Controllers
	if err := controller.AddToManager(mgr); err != nil {
		klog.Fatal(err)
	}

	log.Printf("Starting the Cmd.")

	// Start the Cmd
	log.Fatal(mgr.Start(signals.SetupSignalHandler()))
}
