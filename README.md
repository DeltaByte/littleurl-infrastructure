# LittleURL Infrastructure

This repository contains everything that is either not codebase related, or at the least not related to any one specific environment.

Due to the nature of this repository, it has not currently been set up for automated deployments, as such the permissions
model is somewhat non-standard;

- The AWS deployment is assumed to be running via an IAM user in the root AWS account, as such the first deployment will
  require you to disable the TF backend due the S3 storage bucket not actually existing. Subsequent deployments should be
  done using an IAM user in the prod AWS account (or overriding the backend `role_arn`, whatever, this is a readme not the police).

- The Cloudflare provider requires higher privilege access than is normally given via api keys, as such will require the
  email-based authentication is needed with access to create the actual zones themselves.
