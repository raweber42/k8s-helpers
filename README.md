Scripts and other tooling to make working with Kubernetes easier.

## kubie-all: run kubectl commands across all your clusters
Example output:
```bash
$ sh kubie_all.sh pod
Starting check on all kubeconfig files in /Users/<YOUR_NAME>/.kube...
------------------------------------------------------
Next cluster: first-cluster
CONTEXT => first-cluster
No resources found
--------------------
------------------------------------------------------
Next cluster: second-cluster
CONTEXT => second-cluster
NAMESPACE     NAME            SYNCED   READY   CONNECTION-SECRET   AGE
apps          web-database    True     True                        47d
services      user-store      True     True                        46d
--------------------
------------------------------------------------------
Next cluster: third-cluster
CONTEXT => dev
NAMESPACE     NAME                 SYNCED   READY   CONNECTION-SECRET   AGE
frontend      webapp-db            True     True                        68d
frontend      cache-service        True     True                        74d
frontend      cache-prod           True     True                        74d
reports       analytics-db         True     True                        88d
core          main-postgres        True     True                        18d
core          auth-postgres        True     True                        18d
testing       test-database        True     True                        143d
testing       staging-db           True     True                        52d
load          perf-postgres        True     True                        18d
load          stress-postgres      True     True                        18d
services      customer-data        True     True                        61d
inventory     product-db           True     True                        26d
mobile        app-database         True     True                        88d
legacy        old-system-db        True     True                        48d
--------------------
