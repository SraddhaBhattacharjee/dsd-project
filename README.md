# DSD project Fall 2022

## Prerequisites
1. Enable billing
2. Create a project and note the project ID (eg. dsd-project-fall22)
3. Enable Cloud Storage, BigQuery, Workflows, Cloud Functions and Cloud Build here: https://console.cloud.google.com/apis/library 

## Data flow
Simply put, the main idea here is that, whenever we upload a dataset file to cloud storage, it will automatically push the dataset to BigQuery and create the table.

The data flow is:
1. We push a csv file to our Cloud Storage bucket.
2. Our python script runs on Google Cloud Functions to initiate the workflow on Google Workflows, whose steps are defined in the `workflow.yaml` file.
3. The workflow loads the dataset into BigQuery.
4. The workflow creates a table on BigQuery from the loaded dataset.
5. We run our queries on BigQuery.

If we want to upload more datasets, we just upload it to the bucket and Cloud Functions + Workflows take care of the rest.

## How to set up

### Set up gcloud CLI
Follow the instructions here: https://cloud.google.com/sdk/docs/install 

### Initiate the project
Run the following to log into your Google account and initialize the project: 
```
gcloud init
```

### Create the required service accounts
Create a service account for Google Workflow:
```
gcloud iam service-accounts create sa-dsd-workflow
```

Grant required permissions to the service account:
```
gcloud projects add-iam-policy-binding 	dsd-project-fall22 --member serviceAccount:sa-dsd-workflow@dsd-project-fall22.iam.gserviceaccount.com --role roles/bigquery.dataOwner --role roles/storage.objectAdmin
```

Create a service account for Google Cloud Functions:
```
gcloud iam service-accounts create sa-dsd-trigger
```

Grant required permissions to the service account:
```
gcloud projects add-iam-policy-binding dsd-project-fall22 --member serviceAccount:sa-dsd-trigger@dsd-project-fall22.iam.gserviceaccount.com --role roles/workflows.invoker
```

### Deploy the workflow
```
gcloud workflows deploy dsd-workflow --location=northamerica-northeast1 --source=./workflow.yaml --project=dsd-project-fall22 --service-account=sa-dsd-workflow@dsd-project-fall22.iam.gserviceaccount.com
```

### Create the bucket to store the dataset
```
gsutil mb -b on gs://dsd-fall22-dataset
```

Give permission to `sa-dsd-trigger` service account to configure a trigger on the dataset:
```
gcloud projects add-iam-policy-binding dsd-project-fall22 --member serviceAccount:sa-dsd-trigger@dsd-project-fall22.iam.gserviceaccount.com --role roles/storage.objectAdmin
```

### Create the Cloud Functions trigger
The python file for the Cloud Functions trigger is at `trigger/main.py`. 

Deploy the cloud function:
```
gcloud functions deploy dsd-workflow-trigger --region=northamerica-northeast1 --entry-point=cloud_fn_runner --runtime python310 --trigger-resource dsd-fall22-dataset --trigger-event google.storage.object.finalize --service-account=sa-dsd-trigger@dsd-project-fall22.iam.gserviceaccount.com
```

### Upload the dataset to the storage bucket:
The dataset file can be retrieved from https://sadmansh.dev/dsd-dataset.csv

```
curl https://sadmansh.dev/dsd-dataset.csv | gsutil cp - gs://dsd-fall22-dataset/dsd-dataset.csv
```

Running this command will trigger the workflow via the cloud function. Which, in turn, will load the data into BQ and create the table.