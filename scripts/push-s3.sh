#!/usr/bin/env bash
nix shell nixpkgs#awscli --command aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $AWS_PROFILE_NAME
nix shell nixpkgs#awscli --command aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $AWS_PROFILE_NAME
echo "$BINARY_CACHE_SECRET_KEY" > /tmp/cache-key.sec
nix copy --to s3://nackage\?profile=$AWS_PROFILE_NAME\&endpoint=$S3_API_ENDPOINT\&compression=zstd\&secret-key=/tmp/cache-key.sec .#niri .#niri-debug .#xwayland-satellite
