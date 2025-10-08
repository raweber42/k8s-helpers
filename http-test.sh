# SCRIPT EXECUTION: bash <command_file> http://your.target.url 100

# The default number of requests if the second argument is not provided
DEFAULT_REQUESTS=10

# Configuration variables
CONCURRENCY=10
CURL_TIMEOUT=5       # <--- MAX TIME FOR THE WHOLE OPERATION (seconds)
CURL_CONNECT_TIMEOUT=3 # <--- MAX TIME FOR CONNECTION/HANDSHAKE (seconds)

# --- Argument Validation and Assignment ---

if [ -z "$1" ]; then
    echo "Error: Please provide a target URL as the first argument." >&2
    echo "Usage: $0 <TARGET_URL> [NUM_REQUESTS]" >&2
    exit 1
fi

TARGET_URL="$1"

# Check if the second argument (NUM_REQUESTS) is provided and is a number
if [ -n "$2" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
    NUM_REQUESTS="$2"
else
    # Use the default if not provided or invalid
    NUM_REQUESTS=$DEFAULT_REQUESTS
    if [ -n "$2" ]; then
        echo "Warning: Invalid number of requests provided ('$2'). Using default: $DEFAULT_REQUESTS." >&2
    fi
fi

echo "--- Starting Load Test ---"
echo "Target URL: $TARGET_URL"
echo "Total Requests: $NUM_REQUESTS"
echo "Concurrency: $CONCURRENCY"
echo "--------------------------"

# --- Request Execution ---

seq $NUM_REQUESTS | xargs -n 1 -P $CONCURRENCY sh -c '
    REQUEST_NUMBER="$1"
    URL="$2"

    # ADDED TIMEOUT FLAGS:
    # -m/--max-time: Maximum time (in seconds) the entire operation is allowed to take.
    # --connect-timeout: Maximum time allowed for the connection phase to complete.
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" -m '$CURL_TIMEOUT' --connect-timeout '$CURL_CONNECT_TIMEOUT' "$URL")
    EXIT_STATUS=$?

    if [ $EXIT_STATUS -eq 0 ]; then
        echo "Req $REQUEST_NUMBER: SUCCESS, Time: ${RESPONSE_TIME}s"
    elif [ $EXIT_STATUS -eq 28 ]; then
        echo "Req $REQUEST_NUMBER: FAILED, TIMEOUT (Status 28), Time: ${RESPONSE_TIME}s"
    else
        echo "Req $REQUEST_NUMBER: FAILED, Status $EXIT_STATUS, Time: ${RESPONSE_TIME}s"
    fi
' -- {} "$TARGET_URL"
