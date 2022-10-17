---
title: "Introduction"
teaching: 15
exercises: 0
questions:
- "Why and when should we use the cloud?"
- "Who is / are AWS?"
- "How do we use the cloud?"
objectives:
- "Learners will describe advantages and disadvantages of the cloud"
- "Learners will analyze their use-cases for suitability for cloud
  computing"
- "Learners will log into the AWS console and look around"
keypoints:
- "The cloud provides on-demand access to infinite computational resources"
- "Resources need to be carefully managed, because charges are usually
  tied to how long resources are held"
- "The cloud is great for bursty, high-volume computing, or for some
  small services you might want to run"
---

## Oceanhackweek 2019 Specific Topics
1. Data Storage
2. Security/Private Data
3. Pangeo: Jupyterhub, Dask, Xarray

## What is cloud computing?

Cloud computing encompasses a large collection of publicly available
services provided by many different companies where you can provision
computing on machines that are *only* accessible to you through an
intermediated interface (such as a web-browser or through ssh).

These types of services range from things like Google Drive or Dropbox,
that provide access to storage through a browser, to services that give
you access to a linux-installed bare metal machine ("bare metal" means
that you get the entire machine to yourself, you are the "single tenant"
of this machine).

This contrasts with buying your own desktop or laptop computer, or
cluster of machines, or with buying external storage devices (such as a
RAID, redundant array of independent disks). It also contrasts with some
services that are not publicly accessible, such as institutional
clusters, and the [XSEDE](https://www.xsede.org/) services, that may also
only be accessible to you through an intermediated interface.

## Why use the cloud?

1. Cattle, not pets

![cattlenotpets](https://cdn2.hubspot.net/hubfs/5041972/Imported_Blog_Media/Pets-Cattle-1-4.png)


2. More data sets are moving to the cloud e.g. (Landsat, Sentinel-2) -- compute where you store to minimize time downloading, storage problems

![red queen](../fig/redqueen.png)

### There are about six advantages to using the public cloud as a research platform.

1. You do not wait for compute tasks to go through a queue

    > Compute can start as soon as you want it

2. You do not purchase and maintain hardware, operating systems etcetera

    > Upgrades just happen

3. You pay for resources you use; and then shut them off

    > You don't have to buy into an institutional cluster if the cost calculation doesn't make sense for you.

4. You have huge scale-up potential (reduced processing time)

    > In principle, you have near-infinite computing capacity.

5. There is a huge support community rapidly expanding cloud tools and tech

    > Because of the public availability of these resources, and substantial buy-in from industry, there is a large eco-system of tools and resources.

6. Storage, reliability, security and many other off-the-shelf services

    > And they just keep making new stuff.

### There are about four reasons to not migrate to the cloud

1. You have already identified an adequate-to-your-needs computing environment like XSEDE
    Sometimes it just doesn't make sense. In some cases, you already have the access to the resources you need.

2. You don't have time to learn how to work on the public cloud
    There is stuff to learn. That's what we're here for! But there will be more to learn after this session is over. If you prefer to learn other things, you might not want to invest your time in learning about the cloud.

3. You operate your computer(s) at a very high duty cycle (more cost-effective)
    If your computer is constantly computing something, the cloud might end up costing you more.

4. There is too much administrative drag preventing you from using the cloud
    That's a thing. Especially when working with human subject data that is encumbered through regulation (such as HIPAA).

## Cloud adoption framework

If you are working examples you will want to set up and configure an AWS
cloud account. Be aware that if you put a credit card number in you will
want to know how to turn things off because the first rule of cloud
computing is...


**Cloud computing is like a utility: You pay for resources you allocate**

While learning AWS use free / low-cost resources and practice deleting them
when you are done with them. You do not want to exceed your trial credits
of around $100.

## Advisories

> ## The burden of cloud management is on each of us
> There are details to learn about managing your work on the public cloud.
> Without this skill life can quickly become expensive; for example if you accidentally
> allocate > expensive resources and leave them running.
> (Cloud instances can be turned off without losing state/progress and they can
> be saved as memory images.)
{: .callout}


> ## Lemons from lemonade
> A good way of getting some bad news is to publish **and then delete** your cloud
> access credentials on GitHub. GitHub supports versioning: Someone who is not your
> friend can roll back your public repository to the version where the key was
> present, grab that key, and start using your cloud account at your expense.
{: .callout}


### Our Public Cloud Framework

This *framework* is the vocabulary and relationships we use to describe
using the public cloud platform for data-driven research. Here comes the
jargon storm! In what follows we assume you are a **Researcher** focused
on data-driven science and that you are interested in adopting the cloud
as a way of streamlining that process in some capacity.


As a Researcher you do perfunctory processing and exploratory processing.
The cloud can help you with both, but at a cost: The time you invest to
learn new methods. We call this *cloud adoption* and the core premise is
that you no longer have a *familiar computer* with an attached storage
system where you log in and do your work. The cloud model is (they like
to say) *cattle not pets*: You have a huge pool of available compute
resources and you rent them by the hour. When you are done with them you
simply *Stop* or *Terminate* them and they go back into the resource
pool.  Before continuing let's do a quick cost analysis of what this
means: How does a cloud machine compare to a desktop?


> ## A Cloud Under Your Desk
> A good desktop might cost $3000; and a very powerful cloud instance
> will cost about $0.40 (USD) per hour. Let's say for the sake of
> argument that they are equivalent in compute power and attached
> storage. If you work eight-hour days with four weeks of vacation then
> your annual compute cost is roughly $800. Over three years your "cloud
> under the desk" runs you $2400; but you can make this cheaper if you do
> not need the compute power; or you can throttle it up when you need a
> lot. You might also ask: What are the additional tradeoffs and other
> factors?


#### The cloud components are compute, store, manage, web and services

  - Compute (=EC2)

  - Storage (= S3)

    - 0.024 dollars per GB-month (and x 1/2 and x 1/4 for archival applications)

- Manage = Databases... SQL, Not Only SQL... Data Warehouses... query machinery

- Web = Web services, web sites, APIs, Clients, confederation, ...

- Services = All of the above simplified: Often no Compute involved


#### The cloud facets to learn about are admin, cost, security, scale and time

- Admin is easy to dismiss; but it is always present, even on the cloud

  - You can keep your cloud environment up-to-date without becoming a sysadmin


- Cost is 'one penny per processor-hour and three pennies per GB-month'
  - ...but there are more details...
  - ...and there are cost calculators... which can be misleading...
  - ...so we recommend these steps, for example for grant writing


- The cloud is secure provided you manage your credentials
    - keep them out of GitHub (which can be rolled back)
    - Use MFA
    - Follow other standard procedures
    - If you are going over to PHI / HIPAA there is a whole 'nother level to this

- The cloud is cost-competitive with traditional **buy and maintain** (**BAM**)
  - This in part depends on your percent usage: Machine time / wall clock time
    - Studies indicate the breakeven is currently around 50%
  - The cloud *crushes* **BAM** on your wall clock time
    - Start wait is zero

### Should I move to the cloud?

This really depends on the value of your time in relation to your
research budget; and on how much of your wall clock time you spend doing
computing.  It also depends on your team's capacity to assess and learn
cloud tech for your work. This might be very fast - which is what we find
in the majority of cases - but if you are getting into sophisticated work
e.g. using a web framework or developing a database then substantial
bootstrapping effort will be required.


### Commercial Cloud Options
[Google Cloud Platform](http://console.cloud.google.com): Easy Interface, cheap computing options ($300 credits, free signup)
[Amazon Web Services](http://console.aws.com): LOTS of services, features, most widely used ($200 AWS Educate)
[Microsoft Azure](http://portal.azure.com): Integrates well with other Microsoft products

### The AWS console.

Let's get concrete. There are several ways to interact with cloud
computing resources. Today, we will see how to interact through a web
console, through command line interfaces, and through programmatic APIs.

We'll start with a relatively manual way, that is also relatively
straight-forward: using the AWS web console. To do so, we go to:

    http://aws.amazon.com/

To log in click on the top right "My account" and then "AWS management console"

The account ID we will use here is "uwescience". Enter your credentials.
You might have to change your password the first time that you log in.

### The console and regions

Once you are in, you can select from among several different services
through the console. There are a dizzying array of services to choose
from, really.

One thing that we will point out first before we even look at any of the
services that we can access is that AWS operates several different data
centers. You would think that this doesn't matter, because it's all in
the cloud anyway, but that's wrong. The location of the data centers
matters, because communication between data centers is slow, expensive,
and sometimes just impossible. For this reason, you always want to keep
an eye on the "region" in which you are operating. For everything that we
will do here, we will use the "us-east-2" region (Ohio).

Let's look at some services that we can use. Let's start with S3.
