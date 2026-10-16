# Recovery Procedure

## 1. Confirm the outage

From an administrator workstation, check the web application:

```powershell
curl.exe -I --max-time 10 http://YOUR_EC2_PUBLIC_IP
```

Replace `YOUR_EC2_PUBLIC_IP` with the current EC2 public IP address.

Expected result when healthy: `HTTP/1.1 200 OK`.

If the request fails, continue with the checks below.

## 2. Check EC2 instance status

Run from PowerShell:

```powershell
aws ec2 describe-instance-status --region eu-north-1 --instance-ids YOUR_INSTANCE_ID --include-all-instances --output table
```

Replace `YOUR_INSTANCE_ID` with the instance ID from Terraform:

```powershell
cd .\terraform
terraform output instance_id
```

A running instance should generally report passing system and instance status checks.

## 3. Check the CloudWatch recovery alarm

```powershell
aws cloudwatch describe-alarms --region eu-north-1 --alarm-names production-ec2-system-recovery --query "MetricAlarms[0].{Name:AlarmName,State:StateValue,Metric:MetricName,Actions:AlarmActions}" --output json
```

Review the alarm state and confirm that the EC2 recovery action is configured.

**Important:** The alarm being configured does not prove that automatic EC2 recovery has been tested successfully.

## 4. Connect to the instance

From the project Terraform directory:

```powershell
$IP = terraform output -raw public_ip
ssh -i ..\ec2-recovery-lab-key.pem ubuntu@$IP
```

If SSH fails, verify that the instance is running, the security group allows SSH from your current public IP, and the private key is available.

## 5. Check the web container

After connecting through SSH, run:

```bash
sudo docker ps -a
sudo docker logs --tail 100 recovery-web
curl -I --max-time 5 http://localhost
```

Check whether the `recovery-web` container is running and whether the local HTTP request succeeds.

## 6. Restart the web container if necessary

If the container is stopped, run:

```bash
sudo docker start recovery-web
```

Then verify locally:

```bash
curl -I --max-time 5 http://localhost
```

Exit SSH:

```bash
exit
```

From PowerShell, test the public endpoint again:

```powershell
curl.exe -I --max-time 10 "http://YOUR_EC2_PUBLIC_IP"
```

Expected result: `HTTP/1.1 200 OK`.

This procedure restarts the application container. It is not the same as recovering a failed EC2 host.

## 7. EBS snapshot recovery notes

The lab has an encrypted EBS snapshot, but no recurring backup schedule is configured.

Before restoring from a snapshot:

1. Identify the affected EC2 instance and EBS volume.
2. Confirm the correct snapshot and its completion state.
3. Plan the recovery carefully to avoid overwriting useful data.
4. Create a replacement volume from the snapshot in the appropriate Availability Zone.
5. Attach and validate the replacement volume according to the recovery plan.

Do not delete the original volume or snapshot until recovery and data validation are complete.

## 8. Incident closeout

Record:

- Incident start and end times.
- Observed symptoms and affected resources.
- CloudWatch alarm state and EC2 status checks.
- Commands executed and recovery actions taken.
- Final HTTP verification result.
- Data integrity checks and outstanding follow-up work.

Document the root cause separately using `docs/rca-template.md`.

## Current lab limitations

- The web application is a sample Nginx container.
- Container restart was tested manually.
- The CloudWatch EC2 system-recovery action is configured but has not been validated by inducing a real system failure.
- Only a one-time EBS snapshot is confirmed; recurring backups are not configured.
- This lab does not provide full production high availability.