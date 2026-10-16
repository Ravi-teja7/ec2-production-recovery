# Architecture

## Request flow

1. A browser or HTTP client connects to the EC2 public IPv4 address on TCP port 80.
2. The security group permits inbound HTTP from the internet.
3. Docker publishes the Nginx container port on host port 80.
4. Nginx returns its default HTTP response.

## Administration

SSH on TCP port 22 is allowed only from the configured administrator CIDR. The administrator connects using the private key corresponding to the EC2 key pair.

## Storage and backup

The instance uses an encrypted 12 GiB gp3 EBS root volume. A manual EBS snapshot was created and verified as completed. The snapshot is independent of the instance lifecycle, but it incurs storage charges and is not a scheduled backup policy.

## Monitoring and recovery

CloudWatch monitors the EC2 `StatusCheckFailed_System` metric. The alarm is configured with the regional EC2 recovery action:

`arn:aws:automate:eu-north-1:ec2:recover`

This action is intended for supported underlying EC2 system failures. It does not restart a stopped Docker container, repair application bugs, or cover every possible outage.

## Current design limitations

- One EC2 instance, without multi-AZ failover.
- No load balancer or Auto Scaling Group.
- No automated recurring snapshots or retention policy.
- No TLS termination or custom domain.
- No dedicated application health alarm or automated container remediation.
- Recovery action has been configured but an underlying EC2 system failure has not been injected or observed during testing.
