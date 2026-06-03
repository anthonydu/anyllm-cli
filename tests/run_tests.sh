#!/usr/bin/env bash

# Locate project root and cd to it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

# Setup test environment
export XDG_CONFIG_HOME="$PWD/tests/temp_config"
export PATH="$PWD/tests/mock_bin:$PATH"

# Ensure clean state
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME"

# Setup dummy api keys so the script doesn't fail on missing keys
export GEMINI_API_KEY="test_gemini_key"
export OPENAI_API_KEY="test_openai_key"

PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local cmd="$2"
    local expected_exit_code="$3"
    local expected_output_match="$4"
    local expected_stderr_match="$5"

    echo "Running Test: $test_name..."
    
    # Capture stdout and stderr
    local stdout_file
    local stderr_file
    stdout_file=$(mktemp)
    stderr_file=$(mktemp)
    
    eval "$cmd" > "$stdout_file" 2> "$stderr_file"
    local actual_exit_code=$?
    
    local stdout_content
    local stderr_content
    stdout_content=$(cat "$stdout_file")
    stderr_content=$(cat "$stderr_file")
    
    rm -f "$stdout_file" "$stderr_file"
    
    local test_failed=false
    
    # Check exit status
    if [[ $actual_exit_code -ne $expected_exit_code ]]; then
        echo "  [FAIL] Expected exit code $expected_exit_code, got $actual_exit_code"
        test_failed=true
    fi
    
    # Check stdout match
    if [[ -n "$expected_output_match" ]]; then
        if [[ ! "$stdout_content" == *"$expected_output_match"* ]]; then
            echo "  [FAIL] Expected stdout to contain '$expected_output_match', got:"
            echo "         '$stdout_content'"
            test_failed=true
        fi
    fi
    
    # Check stderr match
    if [[ -n "$expected_stderr_match" ]]; then
        if [[ ! "$stderr_content" == *"$expected_stderr_match"* ]]; then
            echo "  [FAIL] Expected stderr to contain '$expected_stderr_match', got:"
            echo "         '$stderr_content'"
            test_failed=true
        fi
    fi
    
    if $test_failed; then
        ((FAILED_TESTS++))
        return 1
    else
        echo "  [PASS]"
        ((PASSED_TESTS++))
        return 0
    fi
}

# --- Test Cases ---

# Test 1: Direct invocation fails
run_test "Direct Invocation Check" \
         "bin/anyllm Tell me a joke" \
         1 \
         "" \
         "Error: Use 'gemini' or 'chatgpt' directly, not 'anyllm'."

# Test 2: Help command output
run_test "Help Command Check" \
         "bin/gemini --help" \
         0 \
         "" \
         "Usage: <gemini|chatgpt>"

# Test 3: Set Gemini Key
run_test "Set Gemini Key" \
         "bin/gemini --set-key new_gemini_key" \
         0 \
         "API key saved for gemini" \
         ""
# Assert key is written to correct file
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key")" == "new_gemini_key" ]]; then
    echo "  [PASS] File assertion: gemini_api_key written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: gemini_api_key matches incorrect or missing content."
    ((FAILED_TESTS++))
fi

# Test 4: Set OpenAI Key
run_test "Set OpenAI Key" \
         "bin/gemini --set-key openai new_openai_key" \
         0 \
         "API key saved for openai" \
         ""
# Assert key is written to correct file
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/openai_api_key")" == "new_openai_key" ]]; then
    echo "  [PASS] File assertion: openai_api_key written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: openai_api_key matches incorrect or missing content."
    ((FAILED_TESTS++))
fi

# Test 5: Set Default Mode
run_test "Set default response mode" \
         "bin/gemini --set-mode minimal" \
         0 \
         "Default response mode set to: minimal" \
         ""
# Assert response mode is written to correct file
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/response_mode")" == "minimal" ]]; then
    echo "  [PASS] File assertion: response_mode written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: response_mode matches incorrect or missing content."
    ((FAILED_TESTS++))
fi

# Reset mode to default for remaining tests
rm -f "$XDG_CONFIG_HOME/anyllm-cli/response_mode"

# Test 6: Successful Gemini Prompt Stream
run_test "Gemini Prompt Call" \
         "bin/gemini How are you?" \
         0 \
         "Hello from Gemini!" \
         "Thinking..."

# Test 7: Successful ChatGPT Prompt Stream
run_test "ChatGPT Prompt Call" \
         "bin/chatgpt How are you?" \
         0 \
         "Hello from ChatGPT!" \
         "Thinking..."

# Test 8: Curl Connection Failure propagation
export MOCK_ERROR="connection_failed"
run_test "Curl Connection Failure Check" \
         "bin/gemini How are you?" \
         35 \
         "" \
         "Error: Network request failed with curl exit code 35"
unset MOCK_ERROR

# Test 9: API Error Message parsing (Gemini)
export MOCK_ERROR="api_invalid_key"
run_test "API Error Message Check" \
         "bin/gemini How are you?" \
         1 \
         "" \
         "Error: API key not valid"
unset MOCK_ERROR

# Cleanup temp files
rm -rf "$XDG_CONFIG_HOME"
rm -f tests/mock_bin/curl_args.log

echo "------------------------"
echo "Test Summary:"
echo "  Passed: $PASSED_TESTS"
echo "  Failed: $FAILED_TESTS"
echo "------------------------"

if [[ $FAILED_TESTS -ne 0 ]]; then
    exit 1
fi
exit 0
