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

# Test 5: Set Default Style
run_test "Set default response style" \
         "bin/gemini --set-style minimal" \
         0 \
         "Default response style set to: minimal" \
         ""
# Assert response style is written to correct file
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/response_style")" == "minimal" ]]; then
    echo "  [PASS] File assertion: response_style written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: response_style matches incorrect or missing content."
    ((FAILED_TESTS++))
fi

# Reset style to default for remaining tests
rm -f "$XDG_CONFIG_HOME/anyllm-cli/response_style"

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

# Test 10: Gemini API Key Override flag
run_test "Gemini API Key Override Check" \
         "bin/gemini --key override_gemini_key How are you?" \
         0 \
         "Hello from Gemini!" \
         "Thinking..."

if grep -q "key=override_gemini_key" tests/mock_bin/curl_args.log; then
    echo "  [PASS] File assertion: Gemini API key override used correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Gemini API key override not found in curl arguments."
    ((FAILED_TESTS++))
fi

# Test 11: ChatGPT API Key Override flag
run_test "ChatGPT API Key Override Check" \
         "bin/chatgpt --key override_openai_key How are you?" \
         0 \
         "Hello from ChatGPT!" \
         "Thinking..."

if grep -q "Authorization: Bearer override_openai_key" tests/mock_bin/curl_args.log; then
    echo "  [PASS] File assertion: ChatGPT API key override used correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: ChatGPT API key override not found in curl arguments."
    ((FAILED_TESTS++))
fi

# Test 12: Short flag -m (model override)
run_test "Short flag -m Check" \
         "bin/gemini -m gemini-1.5-pro How are you?" \
         0 \
         "Hello from Gemini!" \
         "Thinking..."

if grep -q "models/gemini-1.5-pro:" tests/mock_bin/curl_args.log; then
    echo "  [PASS] File assertion: Short flag -m model override used correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Short flag -m model override not found in curl arguments."
    ((FAILED_TESTS++))
fi

# Test 13: Short flag -s (style override)
run_test "Short flag -s Check" \
         "bin/gemini -s minimal How are you?" \
         0 \
         "Hello from Gemini!" \
         "Thinking..."

if grep -q "systemInstruction" tests/mock_bin/curl_args.log; then
    echo "  [PASS] File assertion: Short flag -s style override used correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Short flag -s style override not found in curl arguments."
    ((FAILED_TESTS++))
fi

# Test 14: Short flag -k (key override)
run_test "Short flag -k Check" \
         "bin/gemini -k short_key How are you?" \
         0 \
         "Hello from Gemini!" \
         "Thinking..."

if grep -q "key=short_key" tests/mock_bin/curl_args.log; then
    echo "  [PASS] File assertion: Short flag -k key override used correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Short flag -k key override not found in curl arguments."
    ((FAILED_TESTS++))
fi

# Test 15: Interactive --set-model for Gemini
run_test "Interactive set-model Gemini" \
         "echo '1' | bin/gemini --set-model" \
         0 \
         "Default gemini model set to: gemini-2.5-flash" \
         ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/gemini_model")" == "gemini-2.5-flash" ]]; then
    echo "  [PASS] File assertion: gemini_model written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: gemini_model is incorrect or missing."
    ((FAILED_TESTS++))
fi

# Test 16: Interactive --set-model for OpenAI
run_test "Interactive set-model OpenAI" \
         "echo '1' | bin/gemini --set-model openai" \
         0 \
         "Default openai model set to: gpt-4o" \
         ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/openai_model")" == "gpt-4o" ]]; then
    echo "  [PASS] File assertion: openai_model written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: openai_model is incorrect or missing."
    ((FAILED_TESTS++))
fi

# Test 17: Interactive --set-style
run_test "Interactive set-style" \
         "echo '2' | bin/gemini --set-style" \
         0 \
         "Default response style set to: minimal" \
         ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/response_style")" == "minimal" ]]; then
    echo "  [PASS] File assertion: response_style written correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: response_style is incorrect or missing."
    ((FAILED_TESTS++))
fi

# Test 18: Unset Key, Model, and Style
# Pre-populate key/model/style files
echo "test_gemini" > "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key"
echo "test_openai" > "$XDG_CONFIG_HOME/anyllm-cli/openai_api_key"
echo "test_model" > "$XDG_CONFIG_HOME/anyllm-cli/gemini_model"
echo "test_model" > "$XDG_CONFIG_HOME/anyllm-cli/openai_model"
echo "test_style" > "$XDG_CONFIG_HOME/anyllm-cli/response_style"

run_test "Unset Gemini Key" "bin/gemini --unset-key" 0 "API key removed for gemini" ""
run_test "Unset OpenAI Key" "bin/gemini --unset-key openai" 0 "API key removed for openai" ""
run_test "Unset Gemini Model" "bin/gemini --unset-model" 0 "Default gemini model reset" ""
run_test "Unset OpenAI Model" "bin/gemini --unset-model openai" 0 "Default openai model reset" ""
run_test "Unset Response Style" "bin/gemini --unset-style" 0 "Default response style reset to default" ""

if [[ ! -f "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key" && \
      ! -f "$XDG_CONFIG_HOME/anyllm-cli/openai_api_key" && \
      ! -f "$XDG_CONFIG_HOME/anyllm-cli/gemini_model" && \
      ! -f "$XDG_CONFIG_HOME/anyllm-cli/openai_model" && \
      ! -f "$XDG_CONFIG_HOME/anyllm-cli/response_style" ]]; then
    echo "  [PASS] File assertion: Unsetting preferences works correctly."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: One or more preference files were not deleted."
    ((FAILED_TESTS++))
fi

# Test 19: Legacy single API key migration
# Reset temp config first
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/anyllm-cli"
echo "legacy_gemini_key" > "$XDG_CONFIG_HOME/anyllm-cli/api_key"

run_test "Legacy Key Migration Check" "bin/gemini How are you?" 0 "Hello from Gemini!" ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key")" == "legacy_gemini_key" && ! -f "$XDG_CONFIG_HOME/anyllm-cli/api_key" ]]; then
    echo "  [PASS] File assertion: Legacy api_key migrated to gemini_api_key."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Legacy key migration failed."
    ((FAILED_TESTS++))
fi

# Test 20: Legacy response_mode migration
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/anyllm-cli"
echo "code" > "$XDG_CONFIG_HOME/anyllm-cli/response_mode"
# Setup API key in env so prompt call succeeds
export GEMINI_API_KEY="test_gemini_key"

run_test "Legacy response_mode migration" "bin/gemini How are you?" 0 "Hello from Gemini!" ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/response_style")" == "code" && ! -f "$XDG_CONFIG_HOME/anyllm-cli/response_mode" ]]; then
    echo "  [PASS] File assertion: Legacy response_mode migrated to response_style."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Legacy response_mode migration failed."
    ((FAILED_TESTS++))
fi

# Test 21: Legacy config directory migration
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/gemini-cli"
echo "migrated_key" > "$XDG_CONFIG_HOME/gemini-cli/gemini_api_key"

run_test "Legacy Directory Migration" "bin/gemini How are you?" 0 "Hello from Gemini!" ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key")" == "migrated_key" && ! -d "$XDG_CONFIG_HOME/gemini-cli" ]]; then
    echo "  [PASS] File assertion: Legacy gemini-cli config directory migrated to anyllm-cli."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Legacy directory migration failed."
    ((FAILED_TESTS++))
fi

# Test 22: Legacy config directory merging
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/anyllm-cli"
mkdir -p "$XDG_CONFIG_HOME/gemini-cli"
echo "existing_key" > "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key"
echo "new_migrated_key" > "$XDG_CONFIG_HOME/gemini-cli/openai_api_key"

run_test "Legacy Directory Merging" "bin/gemini How are you?" 0 "Hello from Gemini!" ""
if [[ "$(cat "$XDG_CONFIG_HOME/anyllm-cli/gemini_api_key")" == "existing_key" && \
      "$(cat "$XDG_CONFIG_HOME/anyllm-cli/openai_api_key")" == "new_migrated_key" && \
      ! -d "$XDG_CONFIG_HOME/gemini-cli" ]]; then
    echo "  [PASS] File assertion: Legacy files merged and gemini-cli removed."
    ((PASSED_TESTS++))
else
    echo "  [FAIL] File assertion: Legacy directory merging failed."
    ((FAILED_TESTS++))
fi

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
