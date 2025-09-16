#!/bin/bash

# OAuth Test Script
# This script helps test OAuth flow manually

echo "🔐 OAuth Test Script"
echo "==================="

# Configuration
CLIENT_ID="Ov23liEI45VHtjMirJdp"
REDIRECT_URI="zimransui://oauth-callback"
TOKEN_ENDPOINT="https://github.com/login/oauth/access_token"

echo "Client ID: $CLIENT_ID"
echo "Redirect URI: $REDIRECT_URI"
echo ""

# Generate PKCE parameters (similar to Swift code)
echo "Generating PKCE parameters..."

# Generate code verifier (64 characters)
CODE_VERIFIER=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-64)
echo "Code Verifier: $CODE_VERIFIER"

# Generate code challenge (SHA256 hash, base64url encoded)
CODE_CHALLENGE=$(echo -n "$CODE_VERIFIER" | openssl dgst -sha256 -binary | openssl base64 | tr -d "=+/" | tr "+/" "-_")
echo "Code Challenge: $CODE_CHALLENGE"
echo ""

# Build authorization URL
AUTH_URL="https://github.com/login/oauth/authorize?client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&scope=user:email&state=test_state&allow_signup=true&code_challenge=$CODE_CHALLENGE&code_challenge_method=S256"

echo "Authorization URL:"
echo "$AUTH_URL"
echo ""

echo "📋 Instructions:"
echo "1. Open the URL above in your browser"
echo "2. Authorize the app"
echo "3. Copy the 'code' parameter from the redirect URL"
echo "4. Run this script with the code: ./test_oauth.sh <CODE>"
echo ""

if [ $# -eq 1 ]; then
    CODE=$1
    echo "Testing token exchange with code: $CODE"
    echo ""
    
    # Test token exchange
    echo "Making token exchange request..."
    curl -X POST "$TOKEN_ENDPOINT" \
        -H "Accept: application/json" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID" \
        -d "grant_type=authorization_code" \
        -d "redirect_uri=$REDIRECT_URI" \
        -d "code=$CODE" \
        -d "code_verifier=$CODE_VERIFIER" \
        -v
else
    echo "No code provided. Run with: ./test_oauth.sh <CODE>"
fi
