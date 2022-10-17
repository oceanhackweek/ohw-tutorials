---
title: "Doing computations in the cloud"
teaching: 0
exercises: 30
questions:
- "What can we use a cloud machine for?"

objectives:
- "Learn how to get data from S3 onto your machine and what to do once it's there"
- "Set up a Jupyter notebook server on your cloud machine"

keypoints:
- "Anything you can do with your desktop (almost), you can do with your cloud machine"
- "For interactive stuff, you can set up Jupyter to run on that machine"
---

### How to do computations on your cloud machine

Now, we have data inside our cloud machine. Let's see how we can do some
computing with this data.

To install Python-related software, we'll make sure that our machine has the
`pip` Python package manager for our installation of Python 3:

~~~
sudo apt-get install python3-pip
~~~
{: .bash}

Here, we're going to install DIPY on our machine and show that we can
read this data and do some computations on it.

~~~
pip3 install dipy
~~~
{: .bash}

We'll also install IPython, so that we have a nice environment to work in:

~~~
pip3 install ipython
~~~
{: .bash}

We fire up IPython and write some code:

~~~
import nibabel as nib
img = nib.load('HARDI150.nii.gz')
data = img.get_data()

import dipy.core.gradients as dpg
gtab = dpg.gradient_table('HARDI150.bval', 'HARDI150.bvec')

from dipy.reconst import dti
ten_model = dti.TensorModel(gtab)
ten_fit = ten_model.fit(data[40, 40, 40])
~~~
{: .python}


### How to get HCP data into your machine

[This page](https://wiki.humanconnectome.org/display/PublicData/How+To+Connect+to+Connectome+Data+via+AWS) describes the process.

We go to [https://db.humanconnectome.org/](The HCP connectome DB) get an account and log in.

Then, we click on the Amazon S3 button and that should give us our key pair

We use `aws configure` to add this to our machine.

What's in there?

~~~
aws s3 ls s3://hcp-openaccess-temp/
~~~
{: .bash}

Let's keep drilling down into one subject's diffusion data:

~~~
aws s3 ls s3://hcp-openaccess-temp/HCP
~~~
{: .bash}

~~~
aws s3 ls s3://hcp-openaccess-temp/HCP/994273
~~~
{: .bash}

~~~
aws s3 ls s3://hcp-openaccess-temp/HCP/994273/T1w
~~~
{: .bash}

~~~
aws s3 ls s3://hcp-openaccess-temp/HCP/994273/T1w/Diffusion
~~~
{: .bash}


The following command grabs the diffusion data from one subject and
downloads it to your machine:

~~~
aws s3 cp s3://hcp-openaccess-temp/HCP/994273/T1w/Diffusion/ . --recursive
~~~
{: .bash}


### How to get a Jupyter notebook running on the cloud

What if we want to do some interactive computations? For this, we can use Jupyter.

Next, we will go through the steps of setting up a notebook server on a cloud machine.

This is based on the [Jupyter documentation](http://jupyter-notebook.readthedocs.io/en/stable/public_server.html)

We start by installing jupyter:

~~~
pip3 install jupyter
~~~
{: .bash}

Then, we generate a Jupyter config file:

~~~
jupyter notebook --generate-config
~~~
{: .bash}

And create a password:

~~~
jupyter notebook password
~~~
{: .bash}

We'll need a self-signed certificate, so that we can use the more secure
https protocol

~~~
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem
~~~
{: .bash}

Next, we'll edit the jupyter config to tell it what to do when we run the jupyter notebook command:

~~~
nano .jupyter/jupyter_notebook_config.py
~~~

We'll need to add the following lines at the top:

~~~
c.NotebookApp.certfile = u'/home/ubuntu/mycert.pem'
c.NotebookApp.keyfile = u'/home/ubuntu/mykey.key'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
~~~
{: .python}

Save the file and get out of there.

I recommend using a `screen` session to run jupyter. This means that you
can close your laptop and the session will keep going.

~~~
screen
~~~
{: .bash}

~~~
jupyter notebook
~~~
{: .bash}

Detach the screen by typing ctrl-A-D. Jupyter session is still running,
but it's in that screen session, so you can't see it. It will continue
running for as long as the machine is still turned on.

To access the notebook that you just created:
1. Go to your aws console, find and connect to the instance that is running that notebook.
2. Copy the public IP address field: Public DNS (IPv4)
3. Open a new tab in your browser and go to https://[Public_IP_from_step_3]:[c.NotebookApp.port] where c.NotebookApp.port is the port you pointed to above (8888)
4. Click proceed.

#### `boto3` is a library that talks to AWS for you


~~~
s3 = boto3.resource('s3',
                    aws_access_key_id = "XXXXXXXXXXXXXXXXXXXX",
                    aws_secret_access_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
~~~
{: .bash}

~~~
b.download_file("HCP/994273/T1w/Diffusion/data.nii.gz", "data.nii.gz")
b.download_file("HCP/994273/T1w/Diffusion/bvals", "bvals")
b.download_file("HCP/994273/T1w/Diffusion/bvecs", "bvecs")
~~~
{: .bash}

And then you can write the dipy code here.
