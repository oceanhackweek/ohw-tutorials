---
title: "Cloudknot: harnessing the power of AWS Batch"
teaching: 30
exercises: 0
questions:
- ""

objectives:
- "Participants will use Cloudknot to scale things up"

keypoints:
- "AWS allows you to scale your computation up"
- "Cloudknot simplifies the use of AWS Batch"
---

What if you wanted to run a DTI analysis on all of the subjects in the HCP?

You could loop over all of the subjects, but that would take a long time.

Cattle not pets!

One of the services that AWS has to allow you to do so is Batch.

Batch is great, but it's a bit complicated, and we wrote a library that
automates everything that it does.

~~~
import cloudknot as ck
ck.set_region('us-east-2')
~~~


[https://github.com/richford/cloudknot/blob/master/examples/03_write_to_s3_bucket.ipynb](https://github.com/richford/cloudknot/blob/master/examples/03_write_to_s3_bucket.ipynb)


~~~
def calculate_dti(subject):
    import boto3
    import dipy
    from dipy.reconst import dti
    import dipy.core.gradients as dpg
    import nibabel as nib

    s3 = boto3.resource('s3',
                        aws_access_key_id = "XXXXXXXXXXXXXXXXXXXX",
                        aws_secret_access_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    b = s3.Bucket("hcp-openaccess-temp")
    b.download_file("HCP/%s/T1w/Diffusion/data.nii.gz"%subject, "data.nii.gz")
    b.download_file("HCP/%s/T1w/Diffusion/bvals"%subject, "bvals")
    b.download_file("HCP/%s/T1w/Diffusion/bvecs"%subject, "bvecs")
    img = nib.load('data.nii.gz')
    data = img.get_data()

    gtab = dpg.gradient_table('bvals', 'bvecs')

    ten_model = dti.TensorModel(gtab)
    ten_fit = ten_model.fit(data)
    nib.save(nib.Nifti1Image(ten_fit.fa, img.affine), 'fa.nii.gz')
    b = s3.Bucket('neurohack-arokem')
    b.upload_file('fa.nii.gz', '%s_fa.nii.gz'%subject)
    return ten_fit.fa
~~~

~~~
knot = ck.Knot(name='calculate-dti',
               func=calculate_dti,
               pars_policies=('AmazonS3FullAccess',))
~~~

~~~
results = knot.map([991267, 992774, 994273])
~~~

~~~
knot.clobber()
