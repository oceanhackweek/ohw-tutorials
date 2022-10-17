---
title: "Storing data in the cloud"
teaching: 0
exercises: 30
questions:
- "What are the three primary ways of talking to the cloud?"
- "What are the main activities supported by cloud consoles?"

objectives:
- "Learn how to spin up an instance, install the AWS CLI and create an s3 bucket"

keypoints:
- "AWS is low-cost, feature rich, has widest use"
- "At a high level you want to know about EC2, S3 and IAM"
---


### Pre-requisites

To follow the steps below, you will need a terminal program, such as
iTerm/Terminal on the Mac or
[Windows bash](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or
[Putty](https://www.putty.org) on Windows.

### Logging in to the AWS Console & Creating an EC2 instance

Log in to the https://uwescience.signin.aws.amazon.com/console.
Use the IAM Username and Password that was provided to you Account ID/Alias:
uwescience

Once you are logged on the the console, on the right top hand corner next
to your IAM username you will see a region.
Please make sure that US-East(Ohio) is selected from the drop down menu. 
We will be solely using the Ohio region for this tutorial cloud work.

Under Build a Solution, select Launch A Virtual Machine

#### Step 1: Choose an Amazon Machine Image (AMI)

Select Ubuntu Server 18.04 LTS (HVM), SSD Volume Type

#### Step 2: Choose an Instance Type

Select 'm4.xlarge', click Next: Configure Instance Details

#### Step 3: Configure Instance Details

The only thing you will need to change is the IAM role. 
Select
*neurohacks3fullaccess* from the Drop Down List. 
IAM roles allow AWS resources to communicate with one 
another without the use of access keys.
Click Next: Add Storage

#### Step 4: Add Storage

Change the Size to 25GiB. 
Click Next: Add Tags

#### Step 5: Add Tags

Key - Name, Value - neurohack-user
Key - Owner, Value - neurohack-user

Please append *neurohack* to your IAM username for all AWS resources you
provision. 
This helps us keep track of the resources.

#### Step 6: Configure Security Group

Select the Select an existing security group button
Check the neurohack-SG button and click Review and Launch

#### Step 7: Review Instance Launch

Click Launch

The Select an existing key pair or Create a new key pair window will pop
up.

From the drop down menu, select Create a new key pair. 
The key pair name will be *neurohack-IAMusername*

Make sure to Download Key Pair. Note where the Key Pair is saved (for
Mac/Linux, it is usually automatically saved to your Downloads folder).

If you want to use the hub for the next few steps, upload the key file
into the hub using the upload button.

Once you have saved the Key Pair (e.g. neurohack-testuser1.pem), click
Launch Instances.

You will see the Launch Status screen. 
Click on ID number associated with your instance.

You will be taken to the EC2 dashboard. 
Look for the IPv4 Public IP. 
You will need this IP to ssh into your instance.

### Storage on the cloud: S3

In S3, we can create "buckets" with data. 
These are like folders on a computer, except they're not really on
any computer that we can access, so we'll have to download them
onto some other computers to do any computations with the data.

One of the main things to remember about S3 is that storing data on S3 is
not very expensive ($0.02/GB/month) but you can end up paying quite a
bit if you move the data out of the AWS data-center in which your data is
stored. 
One way to avoid that is to do all your compute in that data-center. 
That is, bring your compute to where the data is.

That means that you will want to keep an eye on the "region" in which the
data is stored (in our case Ohio) and only download the data to machines
that are in that region.


### Logging on to the EC2 instance, installing the AWS CLI and creating s3 buckets

To figure out how to connect to your machine, highlight it in the
console, and then click on "connect"

This will show you the instructions for how to connect, including the unique
IP address of your machine.

Use your terminal of choice (iTerm or Terminal on Mac and Linux and Windows Bash) and locate the Key Pair file you downloaded. Change the permission of the file using:

`chmod 400 neurohack-user.pem`

*Note that your key file might be a text file instead of a regular .pem file

'Log on to your instance with ssh:

``` ssh -i "neurohack-user.pem" ubuntu@ec2-18-191-95-47.us-east-2.compute.amazonaws.com ```

Once logged on, update and upgrade packages and install the awscli:

``` sudo apt update ```

``` sudo apt upgrade ```

``` sudo apt install awscli```

To list bucket contents (this will list ALL the s3 buckets in the account):

``` aws s3 ls ```

 To create a new bucket (please use *neurohack-IAMusername*)

``` aws s3 mb s3://neurohack-user```

You should now be able to see your bucket when you list the bucket
contents again.

### S3 manipulation

To copy files from one s3 bucket to another:

```  aws s3 cp s3://neurohack-amandatan s3://neurohack-yourbucket --recursive```

List contents of your bucket:

``` aws s3 ls s3://neurohack-yourbucket```

You should now see 4 files.

```

2018-07-31 18:32:01        770 HARDI150.bval
2018-07-31 18:32:00       3889 HARDI150.bvec
2018-07-31 18:32:01   91378947 HARDI150.nii.gz
2018-07-31 18:32:51    1153166 t1.nii.gz

```
Next we are going to install some packages and work with this data.
