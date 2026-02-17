#!/usr/bin/env bash

setup_signing_keychain() {
    local temp_dir="$1"

    # Decode certificate
    local cert_path="$temp_dir/certificate.p12"
    echo -n "$APPLE_CERTIFICATE" | base64 --decode > "$cert_path"

    # Create temporary keychain
    local keychain_password="$(openssl rand -base64 32)"
    local keychain_path="$temp_dir/signing.keychain-db"

    security create-keychain -p "$keychain_password" "$keychain_path"
    security set-keychain-settings -lut 21600 "$keychain_path"
    security unlock-keychain -p "$keychain_password" "$keychain_path"

    # Import certificate
    security import "$cert_path" \
        -P "$APPLE_CERTIFICATE_PASSWORD" \
        -A -t cert -f pkcs12 \
        -k "$keychain_path" \
        -T /usr/bin/codesign \
        -T /usr/bin/security \
        -T /usr/bin/xcrun

    # Allow codesign to access without prompt
    security set-key-partition-list \
        -S 'apple-tool:,apple:' \
        -k "$keychain_password" \
        "$keychain_path" &> /dev/null

    # Add to search list
    security list-keychain -d user -s "$keychain_path" $(security list-keychains -d user | tr -d '"')

    # Store for cleanup
    echo "$keychain_path" > "$temp_dir/keychain_path"

    # Extract identity
    local identity=$(security find-identity -v -p codesigning "$keychain_path" | \
        grep "Developer ID Application" | \
        sed -n 's/.*"\(.*\)"/\1/p' | \
        head -n 1)

    if [ -z "$identity" ]; then
        echo "Error: Could not find Developer ID Application identity" >&2
        return 1
    fi

    echo "$identity"
}

cleanup_signing_keychain() {
    local temp_dir="$1"

    if [ -f "$temp_dir/keychain_path" ]; then
        local keychain_path=$(cat "$temp_dir/keychain_path")
        security delete-keychain "$keychain_path" 2>/dev/null || true
    fi
}
