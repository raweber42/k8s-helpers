#!/bin/bash

# Check if resource argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <RESOURCE> [OPTIONS]"
    echo "Example: $0 pods"
    echo "Example: $0 services --exclude cluster1,cluster2"
    echo "Example: $0 pods --only cluster3,cluster4"
    echo ""
    echo "Options:"
    echo "  --exclude CLUSTERS  Comma-separated list of clusters to exclude"
    echo "  --only CLUSTERS     Only run on specified comma-separated list of clusters"
    exit 1
fi

RESOURCE="$1"
shift

# Parse options
EXCLUDE_CLUSTERS=""
ONLY_CLUSTERS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --exclude)
            EXCLUDE_CLUSTERS="$2"
            shift 2
            ;;
        --only)
            ONLY_CLUSTERS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Convert comma-separated strings to arrays
IFS=',' read -ra EXCLUDE_ARRAY <<< "$EXCLUDE_CLUSTERS"
IFS=',' read -ra ONLY_ARRAY <<< "$ONLY_CLUSTERS"

# Function to check if cluster should be processed
should_process_cluster() {
    local cluster="$1"
    
    # If --only is specified, only process clusters in that list
    if [ -n "$ONLY_CLUSTERS" ]; then
        for only_cluster in "${ONLY_ARRAY[@]}"; do
            if [ "$cluster" = "$only_cluster" ]; then
                return 0
            fi
        done
        return 1
    fi
    
    # If --exclude is specified, skip clusters in that list
    if [ -n "$EXCLUDE_CLUSTERS" ]; then
        for exclude_cluster in "${EXCLUDE_ARRAY[@]}"; do
            if [ "$cluster" = "$exclude_cluster" ]; then
                return 1
            fi
        done
    fi
    
    return 0
}

# Define the directory where your kubeconfig files are stored.
KUBE_DIR="$HOME/.kube"

# Check if the .kube directory exists
if [ ! -d "$KUBE_DIR" ]; then
    echo "Error: The .kube directory does not exist at $KUBE_DIR."
    exit 1
fi

echo "Starting check on all kubeconfig files in $KUBE_DIR..."
echo "Checking resource: $RESOURCE"
[ -n "$EXCLUDE_CLUSTERS" ] && echo "Excluding clusters: $EXCLUDE_CLUSTERS"
[ -n "$ONLY_CLUSTERS" ] && echo "Only processing clusters: $ONLY_CLUSTERS"
echo "################################"

# Loop through each .yaml file in the specified directory
for KUBECONFIG_FILE in "$KUBE_DIR"/*.yaml; do
    # Ensure a file was found to avoid running on a non-existent glob
    if [ -f "$KUBECONFIG_FILE" ]; then
        # Extract the base name of the file (e.g., from 'cluster-a.yaml' to 'cluster-a')
        CONTEXT_NAME=$(basename "$KUBECONFIG_FILE" .yaml)

        # Check if this cluster should be processed
        if should_process_cluster "$CONTEXT_NAME"; then
            echo "Next cluster: $CONTEXT_NAME"

            kubie exec "$CONTEXT_NAME" default kubectl get "$RESOURCE" --all-namespaces 2>&1

            echo "################################"
        else
            echo "Skipping cluster: $CONTEXT_NAME"
            echo "################################"
        fi
    else
        echo "No YAML files found in $KUBE_DIR."
    fi
done

echo "Finished iterating over clusters."

# TODO: Add more instructions and '--help'
# TODO: Add -o for file output
